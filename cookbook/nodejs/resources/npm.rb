actions :install, :uninstall, :install_local, :uninstall_local

attribute :name, :kind_of => String, :name_attribute => true
attribute :version, :default => nil
attribute :path, :default => nil

def initialize(*args)
  super
  @action = :install
end


