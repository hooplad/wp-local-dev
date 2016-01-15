# Setup


Download Virtualbox (5.x) and Vagrant (1.7.4). The Puppet install might make you do a lot of things to your Mac and create a user specifically for Puppet. I'm sorry about that. 

Getting going with VirtualBox should be straightforward unless you're using an old version. If this is the case, STOP RIGHT NOW. You might be breaking your other Puppet/Vagrant scripts if you upgrade to 5.x. Otherwise, be sure to uninstall the older verson of VirtualBox first, then install the new version.

You will run the following command once you have Vagrant and Puppet installed. Open a Terminal window and run the following;

```
puppet module install puppetlabs-apache
```

If you don't have any pretense to installing Ruby/Puppet on your local machine, just grab the following modules and point your Vagrant to that directory;


[Apache](https://forge.puppetlabs.com/puppetlabs/apache)

puppetlabs/stdlib (>= 2.4.0 < 5.0.0)
puppetlabs/concat (>= 1.1.1 < 2.0.0)


[MySQL](https://forge.puppetlabs.com/puppetlabs/mysql)


You will need to do some port forwarding to make sure that you have access to the VM that you're running from your workstation.

## Editing Your Hosts File

Run the following;

```
vim /etc/hosts
```

Add the line to it. Be sure that you're appending this;

```
127.0.0.1 wpdev.org
```

## Port Fowarding on OS X 10.8

This is what I have stored away to make port forwaring happen;

```
sudo ipfw delete 00001;
sudo ipfw add 101 fwd 127.0.0.1,8443 tcp from any to me 443 in;
sudo ipfw add 100 fwd 127.0.0.1,8080 tcp from any to me 80 in
```

This is what my rules look like;

```
00100   154    11743 fwd 127.0.0.1,8080 tcp from any to me dst-port 80 in
00101     0        0 fwd 127.0.0.1,8443 tcp from any to me dst-port 443 in
65535 36758 18226089 allow ip from any to any
```

## Port Forwarding on OS X 10.10

Pulled these steps from ( http://blog.brianjohn.com/forwarding-ports-in-os-x-el-capitan.html )

```
sudo vim /etc/pf.anchors/wp-local-development
```

The file should contain:


```
rdr pass on lo0 inet proto tcp from any to any port 80 -> 127.0.0.1 port 8080
rdr pass on lo0 inet proto tcp from any to any port 443 -> 127.0.0.1 port 8443
``` 


Now test these settings with the following command;

```
sudo pfctl -vnf /etc/pf.anchors/wp-local-development
```

Now we want to be able to apply these changes to your workstation. Create another file like so;

```
sudo vim /etc/pf-wp-local-development.conf
```

Have it say;


```
rdr-anchor "forwarding"
load anchor "forwarding" from "/etc/pf.anchors/wp-development"
```


Test and apply this configuration like so;

```
sudo pfctl -ef /etc/pf.anchors/wp-local-development
```

There's one last piece where you can automatically forward these things off at boot. Pull down the details here but haven't run through them yet, read about Port Forwarding on OS X 10.10 at Boot. This is entirely up to you and depends on how you have your workstation setup. This isn't required but might save you time in the future as otherwise you'll need to run the **pfctl -ef** mentioned previously. Otherwise, read on!

Now you should have everything settled. Just **vagrant up** and go to wpdev.org and you'll be set to go!

## Port Forwarding on OS X 10.10 at Boot


NOTE: THIS HAS NOT YET BEEN TESTED!

You can use the commands above to start port forwarding on demand if you wish, otherwise if (like me) you want to forward ports automatically at startup you can create a launchctl plist file. Create a file under /Library/LaunchDaemons/com.apple.pfctl-.plist with the following contents: 
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
     <key>Label</key>
     <string>com.apple.pfctl-<CUSTOM NAME></string>
     <key>Program</key>
     <string>/sbin/pfctl</string>
     <key>ProgramArguments</key>
     <array>
          <string>pfctl</string>
          <string>-e</string>
          <string>-f</string>
          <string>/etc/pf-<CUSTOM NAME>.conf</string>
     </array>
     <key>RunAtLoad</key>
     <true/>
     <key>KeepAlive</key>
     <false/>
</dict>
</plist>
```

Add the file to startup using the following command:

```
sudo launchctl load -w /Library/LaunchDaemons/com.apple.pfctl-<CUSTOM NAME>.plist
```
