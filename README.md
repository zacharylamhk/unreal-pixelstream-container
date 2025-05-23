# NVIDIA-Enabled Docker Container for Unreal Engine Pixel Streaming

This Docker container provides a ready-to-use environment for running Unreal Engine applications with NVIDIA GPU acceleration and Pixel Streaming capabilities.

## Features

- Ubuntu 22.04 base image
- Proper NVIDIA GPU configuration
- Vulkan and OpenGL support
- Non-root user with sudo privileges
- X11 forwarding support for display
- Optimized for Unreal Engine Pixel Streaming

## Prerequisites

- Docker installed
- NVIDIA Docker runtime installed
- NVIDIA drivers installed on host machine
- X server running on host (for display forwarding)

## Building the Image

```bash
docker build -t unreal-pixel-streaming .



docker run --rm -it \
  --runtime=nvidia \
  --gpus all \
  --network=host \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $HOME/.Xauthority:/home/ubuntu/.Xauthority \
  -v <your_unreal_game_source_path>:/app \
  unreal-pixel-streaming \
  /app/<your_game> \
  -PixelStreamingIP=<IP> \
  -PixelStreamingPort=8888 \
  -renderoffscreen \
  -PixelStreamingID=<Game_ID>
