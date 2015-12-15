# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
   config.vm.box = "centos64"
   # You will need to forward ports on your machine to allow yourself
   # to view the wordpress install hosted on the VM
   # I have this documented in my tiddlywiki but it's a bit involved...
   config.vm.network :forwarded_port, host: 8080, guest: 80
   config.vm.network :forwarded_port, host: 3000, guest: 3000

   config.vm.provision "puppet" do |puppet|
      # Good for debugging
      #puppet.options = " --verbose --detailed-exitcodes"

      # install puppet on your machine then run;
      #
      # puppet module install hunner-wordpress
      # puppet module install puppetlabs-apache

      # Change this to reflect your user and home directory
      puppet.module_path = "~/.puppet/modules/"
      #puppet.manifests_path = "manifests"
      #puppet.manifest_file = "default.pp"
   end
end
