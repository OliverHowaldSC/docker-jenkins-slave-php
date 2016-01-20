FROM million12/behat-selenium:latest
MAINTAINER Jonas Renggli <jonas.renggli@swisscom.com>

# - Install OpenSSH server
# - Generate required host keys
# - Remove 'Defaults secure_path' from /etc/sudoers which overrides path when using 'sudo' command
# - Add 'www' user to sudoers
# - Remove non-necessary Supervisord services from parent image 'million12/nginx-php'
# - Remove warning about missing locale while logging in via ssh
RUN \
  yum install -y openssh-server openssh-clients pwgen sudo hostname patch vim mc links && \
  yum clean all && \

  ssh-keygen -q -b 1024 -N '' -t rsa -f /etc/ssh/ssh_host_rsa_key && \
  ssh-keygen -q -b 1024 -N '' -t dsa -f /etc/ssh/ssh_host_dsa_key && \
  ssh-keygen -q -b 521 -N '' -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key && \
  
  sed -i -r 's/.?UseDNS\syes/UseDNS no/' /etc/ssh/sshd_config && \
  sed -i -r 's/.?PasswordAuthentication.+/PasswordAuthentication no/' /etc/ssh/sshd_config && \
  sed -i -r 's/.?UsePAM.+/UsePAM no/' /etc/ssh/sshd_config && \
  sed -i -r 's/.?ChallengeResponseAuthentication.+/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config && \
  sed -i -r 's/.?PermitRootLogin.+/PermitRootLogin no/' /etc/ssh/sshd_config && \

  sed -i '/secure_path/d' /etc/sudoers && \
  echo 'www  ALL=(ALL)  NOPASSWD: ALL' > /etc/sudoers.d/www && \

  rm -rf /config/init/10-nginx-data-dirs.sh /etc/supervisor.d/nginx.conf /etc/supervisor.d/php-fpm.conf && \
  echo > /etc/sysconfig/i18n

# first install nodejs to get npm
RUN \
    yum install -y nodejs && \
    yum clean all

# now, let's get a new node release ;-) see https://github.com/ForbesLindesay/spawn-sync/issues/24
RUN \
    npm cache clean -f && \
    npm install -g n && \
    n stable

# install our stuff
RUN \
    npm install -g grunt-cli && \
    gem install compass && \
    npm install -g gulp && \
    npm install -g yo

# - Install cloudfoundry cli
RUN curl -o /tmp/cf-linux-amd64.tgz http://go-cli.s3-website-us-east-1.amazonaws.com/releases/v6.11.2/cf-linux-amd64.tgz &&\
    tar xvf /tmp/cf-linux-amd64.tgz -C /tmp && \
    mv /tmp/cf /usr/local/bin/cf && \
    rm /tmp/cf-linux-amd64.tgz && \
    cf install-plugin https://swisscom-plugin.nova.scapp.io/linux64/swisscom-plugin

# Install PhantomJS
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2 \
	&& tar xjf phantomjs-1.9.8-linux-x86_64.tar.bz2 \
	&& cp phantomjs-1.9.8-linux-x86_64/bin/phantomjs /usr/bin/phantomjs \
	&& rm -rf phantomjs-*

# Add yslow
RUN wget http://yslow.org/yslow-phantomjs-3.1.8.zip \
	&& unzip yslow-phantomjs-3.1.8.zip \
	&& cp yslow.js /opt/yslow.js \
	&& rm yslow-phantomjs-3.1.8.zip

# Add config/init scripts to run after container has been started
ADD container-files /

EXPOSE 22

# Run container with following ENV variable to add listed users' keys from GitHub.
# Note: separate with coma, space is not allowed here!
#ENV IMPORT_GITHUB_PUB_KEYS github,usernames,coma,separated
