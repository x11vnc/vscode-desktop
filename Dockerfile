# Builds a Docker image with Ubuntu 18.04 and Visual Studio Code
# for scientific computing, including language supports for C/C++,
# Python, FORTRAN, MATLAB, Markdown, LaTeX, and Doxygen. Also
# enables the extensions doxygen, gitLens, terminal, clang-format,
# and code spell checker.
#
# Authors:
# Xiangmin Jiao <xmjiao@gmail.com>

FROM x11vnc/desktop:18.04
LABEL maintainer "Xiangmin Jiao <xmjiao@gmail.com>"

USER root
WORKDIR /tmp

ADD image/home $DOCKER_HOME/

# Install vscode and system packages
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' && \
    \
    apt-get update && \
    apt-get install  -y --no-install-recommends \
        vim \
        build-essential \
        pkg-config \
        gfortran \
        cmake \
        bison \
        flex \
        git \
        bash-completion \
        bsdtar \
        rsync \
        wget \
        ccache \
        \
        clang \
        clang-format \
        libboost-all-dev \
        code \
        enchant && \
    apt-get install -y --no-install-recommends \
        python3-pip \
        python3-dev \
        python3-wheel \
        pandoc \
        ttf-dejavu && \
    apt-get clean && \
    pip3 install -U \
        setuptools && \
    pip3 install -U \
        autopep8 \
        flake8 \
        yapf \
        black \
        pyenchant \
        pylint \
        pytest \
        Cython \
        Sphinx \
        sphinx_rtd_theme && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chown -R $DOCKER_USER:$DOCKER_GROUP $DOCKER_HOME

USER $DOCKER_USER
WORKDIR $DOCKER_HOME

# Install vscode extensions
RUN mkdir -p $DOCKER_HOME/.vscode && \
    mv $DOCKER_HOME/.vscode $DOCKER_HOME/.config/vscode && \
    ln -s -f $DOCKER_HOME/.config/vscode $DOCKER_HOME/.vscode && \
    git clone https://github.com/VundleVim/Vundle.vim.git \
        $DOCKER_HOME/.vim/bundle/Vundle.vim && \
    vim -c "PluginInstall" -c "quitall" && \
    python3 $DOCKER_HOME/.vim/bundle/YouCompleteMe/install.py \
        --clang-completer --system-boost && \
    bash -c 'for ext in \
        ms-vscode.cpptools \
        jbenden.c-cpp-flylint \
        cschlosser.doxdocgen \
        bbenoist.doxygen \
        streetsidesoftware.code-spell-checker \
        eamodio.gitlens \
        james-yu.latex-workshop \
        yzhang.markdown-all-in-one \
        davidanson.vscode-markdownlint \
        gimly81.matlab \
        krvajalm.linter-gfortran \
        ms-python.python \
        guyskk.language-cython \
        vector-of-bool.cmake-tools \
        twxs.cmake \
        shardulm94.trailing-spaces \
        ms-azuretools.vscode-docker \
        formulahendry.code-runner \
        formulahendry.terminal; \
        do \
            code --install-extension $ext; \
        done'

USER root
