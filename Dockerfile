FROM bitnami/minideb:latest

CMD ["bash"]
RUN apt-get update  \
	&& apt-get install -y --no-install-recommends ca-certificates curl wget  \
	&& rm -rf /var/lib/apt/lists/*
RUN set -ex; if ! command -v gpg > /dev/null; then apt-get update; apt-get install -y --no-install-recommends gnupg dirmngr ; rm -rf /var/lib/apt/lists/*; fi
RUN apt-get update  \
	&& apt-get install -y --no-install-recommends bzr git mercurial openssh-client subversion procps  \
	&& rm -rf /var/lib/apt/lists/*
RUN set -ex; apt-get update; apt-get install -y --no-install-recommends autoconf automake bzip2 dpkg-dev file g++ gcc imagemagick libbz2-dev libc6-dev libcurl4-openssl-dev libdb-dev libevent-dev libffi-dev libgdbm-dev libgeoip-dev libglib2.0-dev libjpeg-dev libkrb5-dev liblzma-dev libmagickcore-dev libmagickwand-dev libncurses5-dev libncursesw5-dev libpng-dev libpq-dev libreadline-dev libsqlite3-dev libssl-dev libtool libwebp-dev libxml2-dev libxslt-dev libyaml-dev make patch xz-utils zlib1g-dev $( if apt-cache show 'default-libmysqlclient-dev' 2>/dev/null | grep -q '^Version:'; then echo 'default-libmysqlclient-dev'; else echo 'libmysqlclient-dev'; fi ) ; rm -rf /var/lib/apt/lists/*
RUN mkdir -p /usr/local/etc  \
	&& { echo 'install: --no-document'; echo 'update: --no-document'; } >> /usr/local/etc/gemrc
ENV RUBY_MAJOR=2.4
ENV RUBY_VERSION=2.4.2
ENV RUBY_DOWNLOAD_SHA256=748a8980d30141bd1a4124e11745bb105b436fb1890826e0d2b9ea31af27f735
ENV RUBYGEMS_VERSION=2.7.3
ENV BUNDLER_VERSION=2.2.0
RUN set -ex  \
	&& buildDeps=' bison dpkg-dev libgdbm-dev ruby '  \
	&& apt-get update  \
	&& apt-get install -y --no-install-recommends $buildDeps  \
	&& rm -rf /var/lib/apt/lists/*  \
	&& wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz"  \
	&& echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.xz" | sha256sum -c -  \
	&& mkdir -p /usr/src/ruby  \
	&& tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1  \
	&& rm ruby.tar.xz  \
	&& cd /usr/src/ruby  \
	&& { echo '#define ENABLE_PATH_CHECK 0'; echo; cat file.c; } > file.c.new  \
	&& mv file.c.new file.c  \
	&& autoconf  \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"  \
	&& ./configure --build="$gnuArch" --disable-install-doc --enable-shared  \
	&& make -j "$(nproc)"  \
	&& make install  \
	&& apt-get purge -y --auto-remove $buildDeps  \
	&& cd /  \
	&& rm -r /usr/src/ruby  \
	&& gem update --system "$RUBYGEMS_VERSION"  \
	&& gem install bundler --version "$BUNDLER_VERSION" --force
ENV GEM_HOME=/usr/local/bundle
ENV BUNDLE_PATH=/usr/local/bundle BUNDLE_BIN=/usr/local/bundle/bin BUNDLE_SILENCE_ROOT_WARNING=1 BUNDLE_APP_CONFIG=/usr/local/bundle
ENV PATH=/usr/local/bundle/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN"  \
	&& chmod 777 "$GEM_HOME" "$BUNDLE_BIN"
CMD ["irb"]
RUN curl -sL https://deb.nodesource.com/setup_14.x | /bin/bash -  \
	&& apt-get install -y nodejs
RUN apt-get install -y build-essential

