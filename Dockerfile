# Build: docker build -t genezys/gitlab:7.8.4 .
# Data: docker run --name gitlab_data --volume /var/opt/gitlab --volume /var/log/gitlab --volume /etc/gitlab ubuntu:14.04 /bin/true
# Run: docker run --detach --name gitlab_app --publish 8080:80 --publish 2222:22 --volumes-from gitlab_data genezys/gitlab:7.8.4

FROM ubuntu:14.04
MAINTAINER Vincent Robert <vincent.robert@genezys.net>

# Install required packages
RUN apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qy --no-install-recommends \
      ca-certificates \
      openssh-server \
      wget

# Download & Install GitLab
# If the Omnibus package version below is outdated please contribute a merge request to update it.
# If you run GitLab Enterprise Edition point it to a location where you have downloaded it.
RUN TMP_FILE=$(mktemp); \
    wget -q -O $TMP_FILE https://downloads-packages.s3.amazonaws.com/ubuntu-14.04/gitlab_7.8.4-omnibus-1_amd64.deb \
    && dpkg -i $TMP_FILE \
    && rm -f $TMP_FILE

# Manage SSHD through runit
RUN mkdir -p /opt/gitlab/sv/sshd/supervise \
    && mkfifo /opt/gitlab/sv/sshd/supervise/ok \
    && printf "#!/bin/sh\nexec 2>&1\numask 077\nexec /usr/sbin/sshd -D" > /opt/gitlab/sv/sshd/run \
    && chmod a+x /opt/gitlab/sv/sshd/run \
    && ln -s /opt/gitlab/sv/sshd /opt/gitlab/service \
    && mkdir -p /var/run/sshd

# Add bootstrap script
ADD gitlab.rb /opt/gitlab/etc/gitlab.rb.template
ADD gitlab.sh /usr/local/bin/gitlab.sh
RUN chmod +x /usr/local/bin/gitlab.sh

# Expose web & ssh
EXPOSE 80 22

# Volume & configuration
VOLUME ["/var/opt/gitlab", "/var/log/gitlab", "/etc/gitlab"]

# Default is to run runit & reconfigure
CMD ["/usr/local/bin/gitlab.sh"]
