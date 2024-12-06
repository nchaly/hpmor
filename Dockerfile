# syntax=docker/dockerfile:1

# base image
FROM ubuntu:22.04

# set timezone
ENV TZ=Europe/Berlin

# prevent keyboard input requests in apt install
ARG DEBIAN_FRONTEND=noninteractive

# install core packages
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y python3 git gnupg2

# miktex installation
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D6BC243565B2087BC3F897C9277A7293F59E4889
RUN echo "deb http://miktex.org/download/ubuntu jammy universe" | tee /etc/apt/sources.list.d/miktex.list

RUN apt-get update

# for pdf, copied from scripts/install_requirements_pdf.sh
RUN apt-get install -y miktex latexmk
# for ebook, copied from scripts/install_requirements_ebook.sh
RUN apt-get install -y  pandoc calibre imagemagick ghostscript

RUN miktexsetup --shared=yes finish

# set working directory
WORKDIR /app

# mount host directory as volume
VOLUME /app

# default command: build 1-vol pdf and all ebook formats
# CMD latexmk hpmor ; ./scripts/make_ebooks.sh

# 1. preparation
# 1.1 build/update image from Dockerfile
#  docker build -t hpmor .

# 1.2 create container that mounts current working dir to /app
#  docker run --name hpmor-en -it --mount type=bind,src="$(pwd)",dst=/app hpmor bash
#  exit

# note: in Windows you need to replace "$(pwd)" by "%cd%" for the following commands
# even easier: docker run  -it --rm -v "%cd%:/app" hpmor 
# (use cmd, in powershell %% syntax is bye-bye.)

# 2. use container
#  docker start -ai hpmor-en
#  latexmk hpmor ; ./scripts/make_ebooks.sh
#  exit

# Optional: run latex once:
# latexmk -e '$max_repeat=1' hpmor
# Directly:
# export TEXFONTS=fonts//: 
# xelatex hpmor --output-directory=output --aux-directory=output/temp

# 3. optionally: cleanup/delete hpmor from docker
# delete container
#  docker rm hpmor-en
# delete image
#  docker rmi hpmor
