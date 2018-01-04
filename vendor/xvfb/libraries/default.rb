def xvfb_systype
  return 'systemd' if ::File.exist?('/proc/1/comm') &&
                      ::File.open('/proc/1/comm').gets.chomp == 'systemd'
  return 'upstart' if platform?('ubuntu') && ::File.exist?('/sbin/initctl')
  'sysvinit'
end
