FROM debian:bookworm AS builder
USER root
ARG DEBIAN_FRONTEND=noninteractive
ARG QUADPYPE_QUAD_SYNCHRO_VERSION="4.3.0"

LABEL org.opencontainers.image.name="quadpype-module-docker"
LABEL org.opencontainers.image.documentation="https://github.com/quadproduction/quadpype-module-docker"

ENV QUADPYPE_MONGO="mongodb://localhost:27017"

# Update base image and add required packages
RUN apt-get update -y

RUN apt-get install -y --no-install-recommends ca-certificates

RUN echo "deb [trusted=yes] https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu/ jammy main" >> /etc/apt/sources.list

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    bash git cmake make curl wget build-essential libcrypt-dev libssl-dev zlib1g-dev libbz2-dev \
    iputils-ping libreadline-dev libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
    libffi-dev liblzma-dev patchelf libgl1 libxcb-* libxkbcommon* libdbus-1-3 libgtk2.0-dev libegl1-mesa libxau-dev \
    libpng16-16 libbrotli-dev libfreetype6-dev python3.9 python3.9-dev python3.9-distutils python3.9-venv


RUN ping -V

RUN ping -q -c1 google.com

# Clone QuadPype
RUN cd /opt/ && \
    git clone --recurse-submodules https://github.com/quadproduction/quadpype.git && \
    cd quadpype && \
    git fetch --all --tags

WORKDIR /opt/quadpype

SHELL ["/bin/bash", "--login", "-c"]

RUN source ~/.bashrc

# The QUADPYPE_QUAD_SYNCHRO_VERSION should be re-apply/updated when the docker container is (re)started
# First Add a container environnement variable named QUADPYPE_QUAD_SYNCHRO_VERSION set to the version wanted, then
# set the container CMD to:
# '/bin/bash' '-c' 'git stash && git checkout tags/${QUADPYPE_QUAD_SYNCHRO_VERSION} && YOUR_ORIGINAL_CMD_HERE'
RUN git checkout tags/${QUADPYPE_QUAD_SYNCHRO_VERSION}

# Ensure required scripts are executable
RUN chmod +x ./src/tools/install_environment.sh
RUN chmod +x ./src/tools/activate.sh

# Create virtualenv
RUN ./src/tools/install_environment.sh

ENTRYPOINT [""]
CMD [""]
