case node['platform_family']
when 'debian'
  include_recipe 'apt'

  apt_repository 'node.js' do
    uri node['nodejs']['repo']
    distribution node['lsb']['codename']
    components ['main']
    keyserver node['nodejs']['keyserver']
    key node['nodejs']['key']
  end
when 'rhel'
  cookbook_file "/etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL" do
    owner 'root'
    group 'root'
    mode '0644'
  end
  yum_repository 'node.js' do
    description "Node.js Packages for Enterprise Linux $releasever - $basearch"
    baseurl     "https://rpm.nodesource.com/pub_6.x/el/$releasever/$basearch"
    enabled     true
    gpgcheck    true
    gpgkey      'file:///etc/pki/rpm-gpg/NODESOURCE-GPG-SIGNING-KEY-EL'
    action      :create
  end

  # include_recipe 'yum-epel'
end
