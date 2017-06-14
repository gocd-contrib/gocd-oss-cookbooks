FROM centos:6
MAINTAINER GoCD Team <go-cd-dev@googlegroups.com>

COPY vendor/ /var/chef-solo/cookbooks/
COPY custom-cookbooks/ /var/chef-solo/cookbooks/
COPY solo.rb /etc/chef/solo.rb
COPY solo.json /etc/chef/solo.json

RUN rpm -ivh https://packages.chef.io/stable/el/6/chef-12.13.37-1.el6.x86_64.rpm && \
    chef-solo && \
    yum remove chef -y && \
    yum clean all

ENTRYPOINT ["/bin/tini", "--"]

USER go
# we need `messagebus` because otherwise FF throws a missing UUID
CMD ["/bin/bash", "-lc", "/bootstrap.sh"]
