FROM debian:bookworm AS builder
USER root
ARG DEBIAN_FRONTEND=noninteractive
ARG QUADPYPE_PYTHON_VERSION=4.0.20
ARG QUADPYPE_QUAD_SYNCHRO_VERSION="4.0.20"

LABEL org.opencontainers.image.name="quadpype-module-docker"
LABEL org.opencontainers.image.documentation="https://github.com/quadproduction/quadpype-module-docker"

ENV QUADPYPE_MONGO="mongodb://localhost:27017"

# Update base
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    ca-certificates bash git cmake make curl wget build-essential libssl-dev zlib1g-dev libbz2-dev  \
    libreadline-dev libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev  \
    libffi-dev liblzma-dev patchelf libgl1 libxcb-* libxkbcommon* libdbus-1-3

# Clone QuadPype
RUN cd /opt/ && \
    git clone --recurse-submodules https://github.com/quadproduction/quadpype.git && \
    cd quadpype && \
    git fetch --all --tags

WORKDIR /opt/quadpype

# Install pyenv
RUN curl https://pyenv.run | bash && \
    echo 'export PYENV_ROOT="$HOME/.pyenv"'>> $HOME/.bashrc && \
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> $HOME/.bashrc && \
    echo 'eval "$(pyenv init - bash)"' >> $HOME/.bashrc &&

SHELL ["/bin/bash", "--login", "-c"]

RUN source ~/.bashrc

# Install python
RUN pyenv install ${QUADPYPE_PYTHON_VERSION}
RUN pyenv local ${QUADPYPE_PYTHON_VERSION}

# The QUADPYPE_QUAD_SYNCHRO_VERSION should be re-apply/updated when the docker container is (re)started
# First Add a container environnement variable named QUADPYPE_QUAD_SYNCHRO_VERSION set to the version wanted, then
# set the container CMD to:
# '/bin/bash' '-c' 'git stash && git checkout tags/${QUADPYPE_QUAD_SYNCHRO_VERSION} && YOUR_ORIGINAL_CMD_HERE'
RUN git checkout tags/${QUADPYPE_QUAD_SYNCHRO_VERSION}

# Create virtualenv
RUN ./src/tools/install_environment.sh

ENTRYPOINT [""]
CMD [""]
