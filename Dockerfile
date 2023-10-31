# Builds a Docker image with Ubuntu 22.04 and Visual Studio Code
# for scientific computing, including language supports for C/C++,
# Python, FORTRAN, MATLAB, Markdown, LaTeX, and Doxygen. Also
# enables the extensions doxygen, gitLens, terminal, clang-format,
# and code spell checker.
#
# Authors:
# Xiangmin Jiao <xmjiao@gmail.com>

FROM x11vnc/docker-desktop:latest
LABEL maintainer "Xiangmin Jiao <xmjiao@gmail.com>"

USER root
WORKDIR /tmp

ADD image/usr /usr
ADD image/home $DOCKER_HOME/

# Install vscode and system packages
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list' && \
    \
    apt install apt-transport-https && \
    apt-get update && \
    apt-get install  -y --no-install-recommends \
        build-essential \
        pkg-config \
        gfortran \
        cmake \
        bison \
        flex \
        git \
        bash-completion \
        rsync \
        wget \
        ccache \
        \
        clang \
        clang-format findent fortran-language-server \
        nano code \
        fonts-liberation \
        xauth xdg-utils \
        enchant-2 \
        pandoc \
        doxygen shellcheck && \
    pip3 install -U \
        setuptools \
        ipython && \
    pip3 install -U \
        autopep8 \
        flake8 \
        yapf \
        black \
        pylint \
        pytest \
        Cython \
        Sphinx \
        pyenchant \
        sphinx_rtd_theme && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    echo 'config_vscode.sh' >> /usr/local/bin/init_vnc && \
    perl -e 's/code --/code --no-sandbox --/g' -pi /usr/share/applications/code.desktop && \
    echo "alias code='code --no-sandbox'" >> $DOCKER_HOME/.zshrc && \
    chown -R $DOCKER_USER:$DOCKER_GROUP $DOCKER_HOME

USER $DOCKER_USER
ENV  GIT_EDITOR=vim EDITOR=code
ENV  DONT_PROMPT_WSL_INSTALL=1
WORKDIR $DOCKER_HOME

# Install vscode extensions
RUN mkdir -p $DOCKER_HOME/.vscode && \
    mv $DOCKER_HOME/.vscode $DOCKER_HOME/.config/vscode && \
    ln -s -f $DOCKER_HOME/.config/vscode $DOCKER_HOME/.vscode && \
    bash -c 'for ext in \
        ms-vscode.cpptools \
        ms-vscode.cpptools-extension-pack \
        jbenden.c-cpp-flylint \
        foxundermoon.shell-format \
        cschlosser.doxdocgen \
        bbenoist.doxygen \
        streetsidesoftware.code-spell-checker \
        eamodio.gitlens \
        james-yu.latex-workshop \
        yzhang.markdown-all-in-one \
        davidanson.vscode-markdownlint \
        gimly81.matlab \
        krvajalm.linter-gfortran \
        fortran-lang.linter-gfortran \
        ms-python.python \
        guyskk.language-cython \
        ms-vscode.makefile-tools \
        vector-of-bool.cmake-tools \
        twxs.cmake \
        shardulm94.trailing-spaces \
        github.vscode-pull-request-github \
        formulahendry.code-runner \
        GitHub.copilot \
        GitHub.copilot-chat \
        genieai.chatgpt-vscode \
        timonwong.shellcheck; \
        do \
            code --install-extension $ext; \
        done' && \
    chmod -R a+r $HOME/.config && \
    find $DOCKER_HOME -type d -exec chmod a+x {} \;

USER root
