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

# Install mscode and system packages
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg && \
    sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' && \
    \
    apt-get update && \
    apt-get install  -y --no-install-recommends \
        build-essential \
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
        clang-format \
        code && \
    apt-get install -y --no-install-recommends \
        python3-pip \
        python3-dev \
        pandoc \
        ttf-dejavu && \
    apt-get clean && \
    pip3 install -U \
        setuptools && \
    pip3 install -U \
        autopep8 \
        flake8 \
        pylint && \
    echo "move_to_config vscode" >> /usr/local/bin/init_vnc && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chown -R $DOCKER_USER:$DOCKER_GROUP $DOCKER_HOME

USER $DOCKER_USER
WORKDIR $DOCKER_HOME

# Install mscode extensions
RUN bash -c 'for ext in \
        ms-vscode.cpptools \
        xaver.clang-format \
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
        formulahendry.terminal; \
        do \
            code --install-extension $ext; \
        done' && \
    echo '@code .' >> $DOCKER_HOME/.config/lxsession/LXDE/autostart

USER root
