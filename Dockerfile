FROM dockerfile/java:oracle-java7
MAINTAINER ServiceRocket Tools

ENV NODE_VERSION 0.10.35
ENV NPM_VERSION 2.1.16

RUN apt-get update && apt-get install -y \
    openssh-server \
    ca-certificates \
    curl

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.16.1/install.sh | sh \
  && source /root/.bashrc \
  && nvm install $NODE_VERSION \
  && nvm use $NODE_VERSION \
  && nvm alias default $NODE_VERSION \
  && npm install -g npm@"$NPM_VERSION" \
  && mkdir -p /root/npm \
  && cd /root/npm \
  && npm install --save lineman \
  && cd /root/npm/node_modules/lineman \
  && npm link

# Configure SSH as part of Jenkins slave requirement
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# Add user jenkins to the image
RUN adduser --quiet jenkins
RUN echo "jenkins:jenkins" | chpasswd

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]