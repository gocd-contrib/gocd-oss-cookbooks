FROM centos:6
MAINTAINER GoCD Team <go-cd-dev@googlegroups.com>

RUN rpm -ivh https://packages.chef.io/stable/el/6/chef-12.13.37-1.el6.x86_64.rpm

COPY vendor/ /var/chef-solo/cookbooks/
COPY custom-cookbooks/ /var/chef-solo/cookbooks/
COPY solo.rb /etc/chef/solo.rb
COPY solo.json /etc/chef/solo.json

RUN chef-solo
RUN yum clean all

ENTRYPOINT ["/bin/tini", "--"]

USER go
CMD ["/bin/bash", "-lc", "vncserver :3 -geometry '1280x960' -depth 16; export DISPLAY=:3; exec /go/go-agent"]
