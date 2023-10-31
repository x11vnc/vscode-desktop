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
    code --install-extension github.copilot \
        --install-extension github.copilot-chat \
        --install-extension github.vscode-pull-request-github \
        --install-extension genieai.chatgpt-vscode \
        --install-extension ms-vscode.cpptools \
        --install-extension ms-vscode.cpptools-extension-pack \
        --install-extension ms-vscode.makefile-tools \
        --install-extension mathworks.language-matlab \
        --install-extension cschlosser.doxdocgen \
        --install-extension bbenoist.doxygen \
        --install-extension streetsidesoftware.code-spell-checker \
        --install-extension eamodio.gitlens \
        --install-extension james-yu.latex-workshop \
        --install-extension yzhang.markdown-all-in-one \
        --install-extension davidanson.vscode-markdownlint \
        --install-extension fortran-lang.linter-gfortran \
        --install-extension ms-python.python \
        --install-extension guyskk.language-cython \
        --install-extension twxs.cmake \
        --install-extension shardulm94.trailing-spaces \
        --install-extension formulahendry.code-runner \
        --install-extension foxundermoon.shell-format \
        --install-extension timonwong.shellcheck && \
    chmod -R a+r $HOME/.config && \
    find $DOCKER_HOME -type d -exec chmod a+x {} \;

USER root
