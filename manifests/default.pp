# Disabling IP tables on the VM
# is preventing requests from reaching httpd
service { 'iptables':
    ensure => 'stopped',
}

#################
# Apache
#################

class { 'apache': } 
class { '::apache::mod::php': }

apache::vhost { 'wpdev.org NON-SSL':
   servername => 'wpdev.org',
   docroot    => '/var/www/html',
   port       => '80',
   before     => Exec['Install WP CLI'],
   # Directory refresh issue, leaving root as owner
   #docroot_owner => 'apache',
   #docroot_group => 'apache',
}

apache::vhost { 'wpdev.org SSL':
   servername => 'wpdev.org',
   docroot    => '/var/www/html',
   port       => '443',
   ssl        => true,
   # Directory refresh issue, leaving root as owner
   #docroot_owner => 'apache',
   #docroot_group => 'apache',
}


#################
# WP-CLI
#################

# Pulled from
# https://www.digitalocean.com/community/tutorials/how-to-use-puppet-to-manage-wordpress-themes-and-plugins-on-ubuntu-14-04

# Download WP-CLI using curl ( assumptions being made here )
# dependent on PHP and Vhosts getting setup
exec { 'Install WP CLI':
   command => "/usr/bin/curl -o /usr/bin/wp -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar",
   creates => "/usr/bin/wp-cli",
}
->
# Change the mode of WP-CLI to a+x
file { '/usr/bin/wp':
   mode => "775",
}
->
exec { 'Finish WP Install':
   command => 'wp core install --url=http://wpdev.org --title="LOCAL DEV WordPress" --admin_user="admin" --admin_password="admin" --admin_email="root@localhost.localdomain"',
   #command => 'wp core multisite-install --url=http://wpdev.org --title="LOCAL DEV WordPress" --admin_user="admin" --admin_password="admin" --admin_email="root@localhost.localdomain"', # Comment this in and the other out if you want to start with a MS site
   cwd     => '/var/www/html',
   path    => '/sbin:/bin:/usr/sbin:/usr/bin',
}

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

$wpinstalldir = '/var/www/html'

class { 'wordpress': 
   wp_site_domain => 'wpdev.org',
   db_user        => 'wordpress',
   db_password    => 'hvyYH856g&89y76',
   create_db      => true,
   create_db_user => true,
   # Getting caught on a directory refresh that's getting invoked somewhere that
   # reowns the directory to root. Just having root own everything...for now
   #wp_owner       => 'apache',

   install_dir    => $wpinstalldir,
}

#################
