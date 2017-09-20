require 'etc'

resource_name :yarn_install

property :dir, String, name_property: true
property :user, String
property :user_home, [String, nil], default: nil

default_action :run

action :run do
  user_group = ::Etc.getgrgid(::Etc.getpwnam(new_resource.user).gid).name
  user_home = new_resource.user_home
  if user_home.nil?
    user_home = ::Etc.getpwnam(new_resource.user).dir
  end

  execute "execute yarn install at `#{new_resource.dir}`" do
    command 'yarn install'
    cwd new_resource.dir
    user new_resource.user
    group user_group
    environment(
      'HOME' => user_home,
      'USER' => new_resource.user
    )
    action :run
  end
end
