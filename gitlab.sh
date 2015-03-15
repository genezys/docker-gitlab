#!/bin/sh

# Copy the template gitlab.rb to the configuration volume
if [ ! -f /etc/gitlab/gitlab.rb ]
then
	cp /opt/gitlab/etc/gitlab.rb.template /etc/gitlab/gitlab.rb
fi

# Run reconfigure in the background while we start the services
gitlab-ctl reconfigure &
/opt/gitlab/embedded/bin/runsvdir-start
