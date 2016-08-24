
module PerforceFtp
  def get_ftp_path(version, executable_name)
    'http://ftp.perforce.com/perforce/' + get_complete_p4_path(version) + "/#{executable_name}"
  end

  private

  def get_complete_p4_path(version)
    "r#{version}/#{get_p4_os_directory}"
  end

  def get_p4_os_directory
    architecture = node[:kernel][:machine] == "x86_64" ? "x86_64" : "x86"
    case node[:os]
      when "linux"
        os = "linux26#{architecture}"
      when "windows"
        architecture = node[:kernel][:machine] == "x86_64"  ? "x64" : "x86"
        os = "nt#{architecture}"
    end
    "bin.#{os}"
  end
end

class Chef::Recipe
  include PerforceFtp
end
