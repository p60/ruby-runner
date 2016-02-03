#!/usr/bin/env bash

set -euo pipefail

function aptspeedup() {
    echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup
}

function noautostart() {
    echo "exit 101" > /usr/sbin/policy-rc.d
}

function aptupgrade() {
    apt-get update
    apt-get upgrade -y
}

function aptcleanup() {
    echo 'DPkg::Post-Invoke {"/bin/rm -rf /var/cache/apt/* /var/lib/apt/lists/* || true";};' > /etc/apt/apt.conf.d/no-cache
}


function dependencies() {
    LC_ALL=C
    apt-get install     -y  \
            sudo            \
            git             \
            curl            \
            build-essential \
            autoconf        \
            libreadline-dev \
            libssl-dev      \
            libxml2-dev     \
            libxslt-dev     \
            zlib1g-dev      \
            libbz2-dev      \
            libpq-dev       \
            libsqlite3-dev  \
            libfreetype6    \
            libfontconfig   \
            nodejs          \
            npm
}

function updatenode() {
    npm cache clean -f
    npm install -g npm@3.6.0
    npm install -g n@2.1.0
    n 5.4.1
}

function linknode() {
    ln -s /usr/bin/nodejs /usr/local/bin/node
}

function genlocale() {
    locale-gen en_US.UTF-8
    LANG=en_US.UTF-8
}
function builderuser() {
    useradd builder --create-home
    chgrp -R builder /usr/local
    find /usr/local -type d | xargs chmod g+w
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/builder
    chmod 0440 /etc/sudoers.d/builder
}

function installruby() {
    # These are here because this runs in a nested shell
    ruby_version=2.2
    ruby_install_sha=28e6703e17be70c1dcdc9499804355a3a41c90da
    bundler_version=1.10.5

    cd /tmp
    curl -L -o ruby-install.tar.gz https://github.com/postmodern/ruby-install/archive/${ruby_install_sha}.tar.gz
    tar xzf ruby-install.tar.gz
    rm -f ruby-install.tar.gz
    cd ruby-install*
    ./bin/ruby-install --system ruby ${ruby_version} -- --disable-install-doc
    cd
    rm -rf /tmp/ruby-install*
    rm -rf /home/builder/src
    gem install bundler -v ${bundler_version} --no-rdoc --no-ri
}

aptspeedup
noautostart
aptupgrade
dependencies
linknode
updatenode
genlocale
builderuser
export -f installruby
su builder -c installruby
aptcleanup
