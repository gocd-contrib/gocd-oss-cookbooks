if defined?(ChefSpec)
  ChefSpec.define_matcher :yarn_install
  ChefSpec.define_matcher :yarn_run

  def run_yarn_install(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:yarn_install, :run, resource_name)
  end

  def run_yarn_run(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:yarn_run, :run, resource_name)
  end
end
