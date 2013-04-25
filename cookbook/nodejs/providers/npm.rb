action :install do 
   cmd = "sudo npm -g install #{new_resource.name}"
   cmd += "@#{new_resource.version}" if new_resource.version

   execute "install NPM module #{new_resource.name}" do
      command cmd
   end
end

action :uninstall do 
   cmd = "sudo npm -g uninstall #{new_resource.name}"
   cmd += "@#{new_resource.version}" if new_resource.version
   execute "uninstall NPM module #{new_resource.name}" do
      command cmd
   end
end

action :install_local do
   path = new_resource.path if new_resource.path
   cmd = "sudo npm install #{new_resource.name}"
   cmd += "@#{new_resource.version}" if new_resource.version
   execute "install NPM module #{new_resource.name} locally" do
      cwd path
      command cmd
   end
end

action :uninstall_local do 
   path = new_resource.path if new_resource.path
   cmd = "sudo npm uninstall #{new_resource.name}"
   cmd += "@#{new_resource.version}" if new_resource.version
   execute "uninstall NPM module #{new_resource.name} locally"  do
      cwd path
      command cmd
   end
end

