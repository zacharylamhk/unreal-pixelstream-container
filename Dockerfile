# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Environment variables for NVIDIA GPU support
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# System setup as root
# Install sudo and clean up apt cache
RUN apt-get update && apt-get install -y sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user with sudo privileges (no password required)
RUN useradd -ms /bin/bash ubuntu && \
    usermod -aG sudo ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Update and upgrade system packages
RUN apt-get update && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Install essential graphics libraries
RUN apt-get update && apt-get install -y \
    libgl1 vulkan-tools \
    && rm -rf /var/lib/apt/lists/*

# Configure Vulkan ICD (Installable Client Driver) for NVIDIA
RUN cat > /etc/vulkan/icd.d/nvidia_icd.json <<EOF
{
    "file_format_version" : "1.0.0",
    "ICD": {
        "library_path": "libGLX_nvidia.so.0",
        "api_version" : "1.3.194"
    }
}
EOF

# Create directory for EGL vendor configurations
RUN mkdir -p /usr/share/glvnd/egl_vendor.d

# Configure EGL vendor for NVIDIA
RUN cat > /usr/share/glvnd/egl_vendor.d/10_nvidia.json <<EOF
{
    "file_format_version" : "1.0.0",
    "ICD" : {
        "library_path" : "libEGL_nvidia.so.0"
    }
}
EOF

# Configure Vulkan implicit layers for NVIDIA Optimus
RUN cat > /etc/vulkan/implicit_layer.d/nvidia_layers.json <<EOF
{
    "file_format_version" : "1.0.0",
    "layer": {
        "name": "VK_LAYER_NV_optimus",
        "type": "INSTANCE",
        "library_path": "libGLX_nvidia.so.0",
        "api_version" : "1.3.194",
        "implementation_version" : "1",
        "description" : "NVIDIA Optimus layer",
        "functions": {
            "vkGetInstanceProcAddr": "vk_optimusGetInstanceProcAddr",
            "vkGetDeviceProcAddr": "vk_optimusGetDeviceProcAddr"
        },
        "enable_environment": {
            "__NV_PRIME_RENDER_OFFLOAD": "1"
        },
        "disable_environment": {
            "DISABLE_LAYER_NV_OPTIMUS_1": ""
        }
    }
}
EOF

# Switch to non-root user and set working directory
USER ubuntu
WORKDIR /home/ubuntu
