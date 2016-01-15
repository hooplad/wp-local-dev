#################
# Puppet wide variables
#################

# For MySQL
$databasename = "wordpress"
$databaseuser = "wordpress"
$password     = "hvyYH856g&89y76"
$host         = "localhost"

# For Apache
$docroot = "/var/www/html"
$apacheoptions = ['Indexes','FollowSymLinks','Includes']
$apacheoverrides = ['FileInfo', 'Options']

# Disabling IP tables on the VM
# is preventing requests from reaching httpd
service { 'iptables':
   ensure => 'stopped',
   enable => false,
}

#################
# Apache
#################

class { 'apache': } 
class { '::apache::mod::php': }

apache::vhost { 'wpdev.org NON-SSL':
   servername => 'wpdev.org',
   docroot    => $docroot,
   port       => '80',
   options    => $apacheoptions,
   override   => $apacheoverrides,
   before     => Exec['Install WP CLI'],
   # Directory refresh issue, leaving root as owner
   #docroot_owner => 'apache',
   #docroot_group => 'apache',
}

apache::vhost { 'wpdev.org SSL':
   servername => 'wpdev.org',
   docroot    => $docroot,
   port       => '443',
   options    => $apacheoptions,
   override   => $apacheoverrides,
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
exec { 'Download WordPress Core':
   command => "wp core download", 
   cwd     => $docroot,
   path    => '/sbin:/bin:/usr/sbin:/usr/bin',
}
->
exec { 'Generate wp-config.php':
   command => "wp core config --dbname='${databasename}' --dbuser='${databaseuser}' --dbpass='${password}'", 
   cwd     => $docroot,
   path    => '/sbin:/bin:/usr/sbin:/usr/bin',
}
->
exec { 'Finish WP Install':
   #command => 'wp core install --url=http://wpdev.org --title="LOCAL DEV WordPress" --admin_user="admin" --admin_password="admin" --admin_email="root@localhost.localdomain"',
   command => 'wp core multisite-install --url=http://wpdev.org --title="LOCAL DEV WordPress" --admin_user="admin" --admin_password="admin" --admin_email="root@localhost.localdomain"', # Comment this in and the other out if you want to start with a MS site
   cwd     => $docroot,
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

@@mysql::db { "${databasename}" :
   user     => $databaseuser,
   password => $password,
   host     => $host,
   grant    => ['ALL'],
   # TODO, need to test how fragile this is. will puppet continue by creating an empty database
   # or will it barf and stop running? just rename this file to check and see
   #sql      => '/var/dbdump/dump.sql',
}
