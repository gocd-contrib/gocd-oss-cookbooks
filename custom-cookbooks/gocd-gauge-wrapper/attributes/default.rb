default['gocd-gauge-wrapper']['plugins']['java'] = nil
default['gocd-gauge-wrapper']['plugins']['ruby'] = nil
default['gocd-gauge-wrapper']['plugins']['html-report'] = nil

if platform_family?('windows')
  default['gocd-gauge-wrapper']['user'] = 'gocd'
  default['gocd-gauge-wrapper']['group'] = 'Administrator'
else
  default['gocd-gauge-wrapper']['user'] = 'go'
  default['gocd-gauge-wrapper']['group'] = 'go'
end
