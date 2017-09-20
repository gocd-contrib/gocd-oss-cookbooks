require 'etc'

resource_name :yarn_run

property :script, String, name_property: true
property :user, String
property :user_home, [String, nil], default: nil
property :dir, String
property :args, Array, default: []
property :production, [TrueClass, FalseClass], default: false

default_action :run

action :run do
  user_group = ::Etc.getgrgid(::Etc.getpwnam(new_resource.user).gid).name
  user_home = new_resource.user_home
  if user_home.nil?
    user_home = ::Etc.getpwnam(new_resource.user).dir
  end

  run_command = "yarn run #{new_resource.script}"
  if new_resource.production
    run_command += ' --production'
  end

  if !new_resource.args.empty?
    run_command += " -- #{new_resource.args.join(' ')}"
  end

  execute "execute `#{run_command}` at `#{new_resource.dir}`" do
    command run_command
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
