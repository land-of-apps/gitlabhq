FROM ubuntu:16.04

RUN /bin/bash -c "set -x; export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y git curl graphicsmagick runit libimage-exiftool-perl \
        libre2-dev cmake gnupg2 libssl-dev g++-8 ed libkrb5-dev libpq-dev \
        libsqlite3-dev libicu-dev g++ libre2-dev sudo tzdata \
    && curl -sSL https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz \
        | tar -xz -C /usr/local \
    && curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh \
        | bash \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m gitlab \
    && adduser gitlab sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    "

USER gitlab

RUN /bin/bash -c "cd ~ \
    && gpg2 --recv-keys \
        409B6B1796C275462A1703113804BB82D39DC0E3 \
        7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
    && curl -sSL https://get.rvm.io \
        | bash -s stable \
    && source /home/gitlab/.rvm/scripts/rvm \
    && rvm install ruby-2.6.6 \
    && gem install gitlab-development-kit \
    && git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0 \
    && cd ~/.asdf \
    && git checkout "$(git describe --abbrev=0 --tags)" \
    && cd ~ \
    && source ~/.asdf/asdf.sh \
    && gdk init gdk \
    && cd gdk \
    && export NODEJS_CHECK_SIGNATURES=no \
    && make bootstrap \
    && gdk trust . \
    && bundle config build.pg --with-opt-dir="$HOME/.asdf/installs/postgres/11.8" \
    && gdk install \
    "
