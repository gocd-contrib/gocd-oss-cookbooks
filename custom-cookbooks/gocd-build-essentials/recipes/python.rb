include_recipe 'yum-epel'

# this is needed for awscli
package %w(python-devel python-pip python-virtualenv)
