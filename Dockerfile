FROM haskell:8.8.3

ENV GHC_VERSION="8.8.3"
ENV HLS_VERSION="0.4.0"

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Create directories for lib/exe; Avoid stack errors during creation
RUN mkdir -p $HOME/.local/bin

# Configure apt and install packages
RUN apt-get update && apt-get upgrade -y
RUN apt-get -y install --no-install-recommends apt-utils 2>&1 \
    #
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    && apt-get -y install git procps lsb-release \
    && apt-get -y install curl wget screen build-essential \
    #
    # Install HIE Dependencies
    && apt-get -y install libicu-dev libncurses-dev libgmp-dev zlib1g-dev

RUN git clone https://github.com/haskell/haskell-language-server.git --branch=${HLS_VERSION} --recurse-submodules \
    && /usr/local/bin/stack config set install-ghc --global true \
    && cd haskell-language-server \
    && stack ./install.hs hls-${GHC_VERSION} \
    && stack ./install.hs data

# Clean build files
RUN rm -rf /haskell-language-server

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
