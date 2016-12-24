actions :install, :remove
default_action :install

attribute :name,     kind_of: String, name_attribute: true
attribute :version,  kind_of: String
attribute :user,     kind_of: [String, Integer], required: true
attribute :group,    kind_of: [String, Integer], required: true
attribute :password, kind_of: String
attribute :domain,   kind_of: String
