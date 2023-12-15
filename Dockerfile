FROM ubuntu:22.04
SHELL ["/bin/bash", "-c"]
RUN apt update
RUN apt install -y git wget sudo curl build-essential python3-pip nano
# Setup non-root user
RUN useradd -ms /bin/bash -G sudo ubuntu
RUN passwd -d ubuntu
USER ubuntu
WORKDIR /home/ubuntu

# recursive for dilithiumpy submodule
RUN git clone --recursive https://github.com/dop-amin/opentitan.git

ENV REPO_TOP=/home/ubuntu/opentitan
WORKDIR /home/ubuntu/opentitan

# Steps from https://opentitan.org/book/doc/getting_started/index.html
RUN sed '/^#/d' ./apt-requirements.txt | xargs sudo apt install -y
RUN python3 -m pip install --user -U pip "setuptools<66.0.0"
ENV PATH=~/.local/bin:$PATH
RUN pip3 install --user -r python-requirements.txt
USER root
RUN mkdir /tools
RUN chown ubuntu:ubuntu /tools
USER ubuntu
RUN ./util/get-toolchain.py

RUN python3 -m pip install --user tabulate