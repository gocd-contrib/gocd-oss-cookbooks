case node['platform_family']
when 'rhel', 'fedora'
  include_recipe 'yum-epel'
  if node['platform_version'].to_i == 7
    package %w(icewm icewm-clearlooks)
  else
    package %w(icewm icewm-clearlooks xorg-x11-twm)
  end

when 'debian', 'gentoo'

  package %w(icewm icewm-clearlooks xorg-x11-twm)

end
