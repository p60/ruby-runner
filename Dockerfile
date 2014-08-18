#Taken from d11wtq/ruby-docker

FROM ubuntu:trusty

MAINTAINER statianzo

ENV PATH /app/bin:/app/vendor/bundle/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PORT 5000
EXPOSE 5000

RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive && \
    apt-get update     -y && \
    apt-get install     -y   \
    sudo                     \
    git                      \
    supervisor               \
    curl                     \
    build-essential          \
    autoconf                 \
    libreadline-dev          \
    libssl-dev               \
    libxml2-dev              \
    libxslt-dev              \
    zlib1g-dev               \
    libbz2-dev               \
    libpq-dev                \
    libsqlite3-dev           \
    nodejs                && \
    apt-get clean

RUN rm -rf /var/cache/apt/* /var/lib/apt/lists/*

# Make node available as "node"
RUN ln -s /usr/bin/nodejs /usr/local/bin/node

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

RUN useradd --no-create-home builder && \
    chgrp -R builder /usr/local && \
    find /usr/local -type d | xargs chmod g+w && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder && \
    chmod 0440 /etc/sudoers.d/builder

RUN useradd --no-create-home app

ADD /bin/proc2super /usr/local/bin/

USER builder

ADD https://github.com/sstephenson/ruby-build/archive/v20140524.tar.gz /tmp/

RUN cd /tmp;                           \
    sudo chown builder: *.tar.gz;      \
    tar xzf *.tar.gz; rm -f *.tar.gz; \
    cd ruby-build*;                    \
    ./bin/ruby-build 2.1.2 /usr/local; \
    cd; rm -rf /tmp/ruby-build*

RUN gem install bundler -v 1.6.5 --no-rdoc --no-ri
