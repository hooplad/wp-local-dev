# Disabling IP tables on the VM
# is preventing requests from reaching httpd
service { 'iptables':
    ensure => 'stopped',
}

#################
# WP-CLI
#################

# Once I figure out the directory refresh issues, this should be left commented unless
# this step is failing because CURL and PHP5-CLI are not present
# Comment out "# Download WP-CLI using curl ( assumptions being made here )"
# and uncomment everything else in this section

# Pulled from
# https://www.digitalocean.com/community/tutorials/how-to-use-puppet-to-manage-wordpress-themes-and-plugins-on-ubuntu-14-04

# Install curl
#package { 'curl':
#   ensure => "installed",
#}

# Install php5-cli
#package { 'php5-cli':
#   ensure => "installed",
#}

# Download WP-CLI using curl
#exec { 'Install WP CLI':
#   command => "/usr/bin/curl -o /usr/bin/wp -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar",
#   require => [ Package['curl'], Package['php5-cli'] ],
#   creates => "/usr/bin/wp-cli"
#}

# Download WP-CLI using curl ( assumptions being made here )
exec { 'Install WP CLI':
   command => "/usr/bin/curl -o /usr/bin/wp -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar",
   creates => "/usr/bin/wp-cli"
}

# Change the mode of WP-CLI to a+x
file { '/usr/bin/wp':
   mode => "775",
   require => Exec['Install WP CLI']
}

#################
# Apache
#################

class { 'apache': } 

apache::vhost { 'wpdev.org':
   port    => '8080',
   docroot => '/var/www/html',
   # Directory refresh issue, leaving root as owner
   #docroot_owner => 'apache',
   #docroot_group => 'apache',
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
   # Getting caught on a directory refresh that's getting invoked somewhere that
   # reowns the directory to root. Just having root own everything...for now
   #  wp_owner       => 'apache',
   wp_owner       => 'root',

   # hunter-wordpress module isn't handling the change the WP's SSL cert and redirect
   # Yay for not verifying variables!
   install_url    => '--no-check-certificate https://wordpress.org',
   install_dir    => '/var/www/html',   
}

#################
