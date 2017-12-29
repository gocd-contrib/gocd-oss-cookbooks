if node['platform_family'] != 'windows'
  include_recipe 'go-user::user'
end

include_recipe 'go-user::go-agent'
include_recipe 'go-user::git'
include_recipe 'go-user::gradle'
include_recipe 'go-user::maven'
include_recipe 'go-user::rubygems'
include_recipe 'go-user::npm'
