FROM haskell:8.6.5

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
    && apt-get -y install libicu-dev libtinfo-dev libgmp-dev

# Install HIE
RUN git clone https://github.com/haskell/haskell-ide-engine --branch 0.11.0.0 --recurse-submodules \
    && cd haskell-ide-engine \
    && sed -i "s|lts-13.18 # GHC 8.6.4|lts-13.27 # GHC 8.6.5 |g" shake.yaml \
    && stack install.hs cabal-hie-8.6.5 \
    && stack install.hs cabal-build-doc

# Clean HIE build files
RUN rm -rf /haskell-ide-engine

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
