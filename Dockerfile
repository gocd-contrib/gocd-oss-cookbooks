FROM centos:6
MAINTAINER GoCD Team <go-cd-dev@googlegroups.com>

COPY . /chef-cookbooks

RUN rpm -ivh https://packages.chef.io/files/stable/chef/13.2.20/el/6/chef-13.2.20-1.el6.x86_64.rpm && \
    chef-solo -c /chef-cookbooks/solo.rb && \
    yum remove chef -y && \
    yum clean all --enablerepo='*' && \
    rm -rf /chef-cookbooks/ /root/.cache

ENTRYPOINT ["/bin/tini", "--"]

USER go
# we need `messagebus` because otherwise FF throws a missing UUID
CMD ["/bin/bash", "-lc", "/bootstrap.sh"]
