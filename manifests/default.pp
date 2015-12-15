# Disabling IP tables on the VM
# is preventing requests from reaching httpd
service { 'iptables':
    ensure => 'stopped',
}

#################
# Apache
#################

class { 'apache': } 

apache::vhost { 'wpdev.org':
   port    => '8080',
   docroot => '/var/www/html',
#   docroot_owner => 'apache',
#   docroot_group => 'apache',
}

class { '::apache::mod::php': }

################
# MySQL
################

class { '::mysql::client':
   require => Class['::mysql::server'],
}

class { '::mysql::bindings':
   php_enable => true,
}

class { '::mysql::server':
  root_password => 'hjkai8yihbk3o87fwiscig238yvibge98dhkckb',
}

#################
# WordPress
#################

class { 'wordpress': 
   version        => '4.4',
   wp_site_domain => 'wpdev.org',
   db_user        => 'wordpress',
   db_password    => 'hvyYH856g&89y76',
   create_db      => true,
   create_db_user => true,
# Getting caught on a directory refresh that's getting invoked somewhere. Just having root own everything...for now
#  wp_owner       => 'apache',
   wp_owner       => 'root',

   # hunter-wordpress module isn't handling the change the WP's SSL cert and redirect
   # Yay for not verifying variables!
   install_url    => '--no-check-certificate https://wordpress.org',
   install_dir    => '/var/www/html',   
}

#################
