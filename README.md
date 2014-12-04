What is GitLab?
===============

GitLab offers git repository management, code reviews, issue tracking, activity feeds, wikis. It has LDAP/AD integration, handles 25,000 users on a single server but can also run on a highly available active/active cluster. A subscription gives you access to our support team and to GitLab Enterprise Edition that contains extra features aimed at larger organizations.

<https://about.gitlab.com>

![GitLab Logo](https://gitlab.com/uploads/appearance/logo/1/brand_logo-c37eb221b456bb4b472cc1084480991f.png)


How to use this image
=====================

I recommend creating a data volume container first, this will simplify migrations and backups:

```bash
docker run --name gitlab_data genezys/gitlab:7.5.2 /bin/true
```

This empty container will exist to persist as volumes the 3 directories used by GitLab, so remember not to delete it:

- `/var/opt/gitlab` for application data
- `/var/log/gitlab` for logs
- `/etc/gitlab` for configuration

Then run GitLab:

```bash
docker run --detach --name gitlab --publish 8080:80 --publish 2222:22 --volumes-from gitlab_data genezys/gitlab:7.5.2
```

The first run will take a while as GitLab needs to configure itself. You can follow the process with `docker logs -f gitlab`.

You can then go to `http://localhost:8080/` (or `http://192.168.59.103:8080/` if you use boot2docker). Next time, you can just use `docker start gitlab` and `docker stop gitlab`.

To login, you can use the default GitLab credentials: username `root`, password `5iveL!fe`.


How to configure GitLab
=======================

This container uses the official Omnibus GitLab distribution, so all configuration is done in the unique configuration file `/etc/gitlab/gitlab.rb`.

To access GitLab configuration, you can start an interactive command line in a new container using the shared data volume container, you will be able to browse the 3 directories and use your favorite text editor:

```bash
docker run -ti -e TERM=linux --rm --volumes-from gitlab_data ubuntu 
vi /etc/gitlab/gitlab.rb
```

**Note** that GitLab will reconfigure itself **at each container start.** You will need to restart the container to reconfigure your GitLab.

You can find all available options in [Omnibus GitLab documentation](https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/README.md#configuration).
