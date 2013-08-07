Vagrant::Config.run do |config|
  config.vm.box       = 'precise32'
  config.vm.box_url   = 'http://files.vagrantup.com/precise32.box'
  config.vm.host_name = 'wisevoter'

  config.vm.forward_port 3000, 3000

  config.vm.provision :shell, :path => "builddev.sh"

end
