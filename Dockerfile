FROM ubuntu:14.04.2

MAINTAINER peer60

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
RUN echo "exit 101" > /usr/sbin/policy-rc.d

RUN apt-get update

RUN apt-get upgrade -y

RUN echo 'DPkg::Post-Invoke {"/bin/rm -rf /var/cache/apt/* /var/lib/apt/lists/* || true";};' > /etc/apt/apt.conf.d/no-cache

RUN LC_ALL=C \
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
    nodejs

RUN ln -s /usr/bin/nodejs /usr/local/bin/node

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8

RUN useradd builder --create-home && \
    chgrp -R builder /usr/local && \
    find /usr/local -type d | xargs chmod g+w && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder && \
    chmod 0440 /etc/sudoers.d/builder

USER builder
WORKDIR /home/builder

RUN cd /tmp                                                                             ; \
    curl -L -o chruby.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz ; \
    tar xzf chruby.tar.gz                                                               ; \
    rm -f chruby.tar.gz                                                                 ; \
    cd chruby*                                                                          ; \
    sudo ./scripts/setup.sh                                                             ; \
    cd                                                                                  ; \
    rm -rf /tmp/chruby*                                                                 ;

RUN cd /tmp                                                                                                                           ; \
    curl -L -o ruby-install.tar.gz https://github.com/postmodern/ruby-install/archive/fa7cfafc2d2fd786c56e5301ae9938d8ea7d3165.tar.gz ; \
    tar xzf ruby-install.tar.gz                                                                                                       ; \
    rm -f ruby-install.tar.gz                                                                                                         ; \
    cd ruby-install*                                                                                                                  ; \
    sudo apt-get update                                                                                                               ; \
    ./bin/ruby-install ruby 2.1                                                                                                       ; \
    ./bin/ruby-install ruby 2.2                                                                                                       ; \
    cd                                                                                                                                ; \
    rm -rf /tmp/ruby-install*                                                                                                         ; \
    rm -rf /home/builder/src                                                                                                          ;
