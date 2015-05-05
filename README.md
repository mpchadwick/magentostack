# magentostack

## Supported Platforms

- CentOS 6.5
- Ubuntu 12.04 (untested)
- Ubuntu 14.04 (untested)

## Supported Magento version
Community Edition >= 1.9
Enterprise Edition >= 1.14.1

## Requirements

- Chef 12 or greater.

### Cookbooks

- `apache2`
- `apt`
- `build-essential`
- `chef-sugar`
- `git`
- `openssl`
- `php-fpm`
- `platformstack`
- `yum`
- `yum-ius`
- `yum-epel`

## Recipes

### default
- what it does
  - nothing
- toggles
  - nothing

### apache-fpm
This recipe sets Apache2 configuration so you can deploy your Magento code.
- what it does
  - configures Apache with PHP FPM
  - enables magento required php modules
  - create a self-signed certificate if node['magentostack']['web']['ssl_autosigned'] (default to true)
  - create a Vhost for Magento (non-SSL)
  - create a Vhost for Magento (SSL)
- toggles
  - certificate generation node['magentostack']['web']['ssl_autosigned']

You may disable SSL support by setting `node.set['magentostack']['web']['ssl'] = false`. Note that you may still need to be sure Magento redirects work correctly in this case.

You may supply a custom SSL certificate by setting one or more of these values:
```
node['magentostack']['web']['ssl_custom'] = true
node['magentostack']['web']['ssl_custom_databag'] = 'certificates'
node['magentostack']['web']['ssl_custom_databag_item'] = 'magento'
```

See instructions in [the certificate cookbook](https://github.com/atomic-penguin/cookbook-certificate#requirements) for how to prepare an appropriate encrypted data bag.

> Only Community Edition >= 1.9 and Enterprise Edition >= 1.14.1 are supported by Magentostack, therefore it's PHP 5.5 only

<!---
# Only for Magento CE <1.9 or EE < 1.14 (not supported yet)
apache2::mod_fastcgi doesn't allow to compile mod_Fastcgi from source, therefore it will not use the mod_fastcgi patched version. It means Ubuntu with Magento CE <1.9 or EE < 1.14 might have some bugs. [References](http://www.magentocommerce.com/boards/m/viewthread/229253/)
--->

### varnish and modman
In order to use Varnish, include the varnish recipe in your wrapper or ensure you're set to community edition, where Varnish is enabled by default. This installs varnish using default settings, as well as modman and installs the turpentine module for Magento.

Under `System > Configuration > Web > Secure` change the Offloader header value to `HTTP_X_FORWARDED_PROTO` (from the default SSL_OFFLOADED) and make sure the Base URL has `https` for the protocol, then save.

You should also ensure you set `node['magentostack']['varnish']['secret']` to something on each server, and then also set that value in the Administration GUI in Magento, and do an initial flush of the Varnish cache.

See the [main page about turpentine](http://www.magentocommerce.com/magento-connect/turpentine-varnish-cache.html), the [installation instructions for turpentine](https://github.com/nexcess/magento-turpentine/wiki/Installation), and the [modman Github site](https://github.com/colinmollenhour/modman), for more information and documentation.

### gluster
- what it does
  - sets up glusterfs based on the `node['rackspace_gluster']['config']['server']['glusters']` attribute
    - this may involve some manual setup, it is glusterfs afterall

### magento_admin
- what it does
  - set up a cronjob to run Magento admin tasks

### magento_install
- what it does
  - download and extract Magento, consulting `node['magentostack']['install_method']` for 'cloudfiles', 'ark', or 'git'

### magento_configure
- what it does
  - install Magento by running install.php (basic configuration, DB bootstrap, SSL url etc...)
  - or by copying a provided local.xml.template and editing it in-place from there
  - *Note*: It will always edit the local.xml after the fact with values from chef.

### mysql_add_drive
- what it does
  - formats /dev/xvde1 and will prepare it for the mysql datadir.
  - creates the mysql user and manages the /var/lib/mysql mountpoint

### mysql_holland
---
Warning
mysql_holland package will install python-setup tools preventing to apply this fix https://github.com/rackspace-cookbooks/stack_commons/pull/86, so you must include magentostack::mysql_holland as late as possible in your run_list.
---
-  what it does
  -  installs holland
  -  will set up a backup job based on if you are running as a slave or not

### mysql_master
- what it does
  - sets up mysql master (runs the mysql_base recipe as well)
  - will allow slaves to connect (via iptables)

### mysql_slave
- what it does
  - sets up the mysql slave (runs the mysql_base recipe as well)
  - allows the master to connect (via iptables)

### nfs_client and nfs_server
- server recipe installs nfs server and configures an export (by default, under /exports)
  for magento media
- client recipe creates a mount point, and mounts the export from the server
  (uses search with a tag to find the server)

### newrelic
- what it does
  - sets up newrelic and the php agent for newrelic

### redis recipes

Please note that the redis recipes use an accumulator pattern, just like their
upstream cookbook. This means you must include all redis recipes for instances
and they will build on to the data structure containing all redis instances.

Once all redis instances have been defined, call `magentostack::redis_configure`
to actually install and configure all redis masters, slaves, or sentinels that
were previously declared using the individual recipes below, as well as
configure any iptables rules that are required (assuming platformstack has
iptables turned on).

For example, this would an appropriate runlist for a single instance, a single
slave, and the appropriate sentinel:
```
  magentostack::redis_single
  magentostack::redis_single_slave
  magentostack::redis_sentinel
  magentostack::redis_configure
```

Example for installing just the session instance:
```
  magentostack::redis_session
  magentostack::redis_configure
```
or only its slave:
```
  magentostack::redis_session_slave
  magentostack::redis_configure
```

Example to get a sentinel only:
```
  magentostack::redis_sentinel
  magentostack::redis_configure
```

#### redis_single
- what it does
  - configures a standalone redis server in `node['redisio']['servers']`
  - redis server bound to `node['magentostack']['redis']['bind_port_single']`
  - tags node with `magentostack_redis` and `magentostack_redis_single` for discovery

#### redis_object, redis_page, redis_session
- what it does
  - configures a redis server in `node['redisio']['servers']`
  - instance is bound to `node['magentostack']['redis']['bind_port_X']` where X is object, page, or session
  - tags node with `magentostack_redis` and `magentostack_redis_X` for later discovery

#### redis_sentinel
- what it does
  - sets up redis sentinel bound to `node['magentostack']['redis']['bind_port_sentinel']`
  - uses discovery in `libraries/util.rb` to find all redis servers in current chef environment
  - discovery is based on tags and chef environment, see `node['magentostack']['redis']['discovery_query']` to override
  - determines a master (using tags) in this order: redis_session.rb, redis_single.rb, `none`
  - assumes a session store is the most important to monitor (upstream only supports configuring sentinel to monitor one master)

#### redis_configure
- what it does
  - shortcut to run all of the redisio recipes needed to install & configure redis
  - should be used after any calls to the redis_(single/object/page/session/sentinel) recipes
  - build any iptables rules and call `add_iptables_rule` on them

## Data_Bags

No Data_Bag configured for this cookbook

## Attributes

### default

- `default['magentostack']['newrelic']['application_monitoring'] = ''`
  - controls if we allow newrelic to to do application monitoring
    - is set to `'true'` in the newrelic recipe
- `default['magentostack']['mysql']['databases'] = {}`
  - contains a list of databases to set up (along with users / passwords)
- `default['magentostack']['apache']['sites'] = {}`
  - Default attribute required by stack_commons *not used by Magentostack*

### Apache-fpm
- `default['magentostack']['web']['domain']`
  - Vhost Servername
- `default['magentostack']['web']['http_port']`
  - port for non-SSL vhost
- `default['magentostack']['web']['https_port']`
  - port for SSL vhost
default['magentostack']['web']['server_aliases'] = node['fqdn']
- `default['magentostack']['web']['cookbook']` and `default['magentostack']['web']['template']`
  - where to find the Vhost templates
- `default['magentostack']['web']['fastcgi_cookbook']` and `default['magentostack']['web']['fastcgi_template']`
  - where to find the Fast-cgi templates
- `default['magentostack']['web']['dir']`
  - Documenent root (where to put Magento code)
- `default['magentostack']['web']['ssl_key']` and `default['magentostack']['web']['ssl_cert']` and `default['magentostack']['web']['ssl_chain']`
  - where are the certificates and keys and a chain/intermediate(might be useful when disabling self-signed)

### Magento
- `default['magentostack']['config'][*]`
  - install.php related options, see https://github.com/AutomationSupport/magentostack/blob/master/definitions/magento_initial_configuration.rb
- `normal['magentostack']['mysql']['databases']['magento_database']`
  - create Magento DB and Magento DB users
- `default['magentostack']['download_url']` and `default['magentostack']['checksum']`
  - where to get Magento and the file checksum (faster re-converge)
- default['magentostack']['flavor'] = 'community' # could also be enterprise
  - controls if the stack should try to configure a full page cache or not

### NFS Server and client

# search query for discovery of nfs server
```
# Used to override the permitted client IPs on the nfs_server
node['magentostack']['nfs_server']['override_allow'] = ['1.2.3.4', '5.6.7.8']

# Used to override the NFS mount on clients, not used by default
node['magentostack']['nfs_server']['override_host'] = '1.2.3.4'

# where the export lives on the NFS server
node['magentostack']['nfs_server']['export_name'] = 'magento_media'
node['magentostack']['nfs_server']['export_root'] = '/export'

# how to search for an NFS server
node['magentostack']['nfs_server']['discovery_query'] = "tags:magentostack_nfs_server AND chef_environment:#{node.chef_environment}"

# clients
node['magentostack']['nfs_client']['mount_point'] = '/mnt/magento_media'
node['magentostack']['nfs_client']['symlink_target'] = 'media' # within /var/www/html/magento
```
### gluster

contains attributes used in setting up gluster, node the commented out section, it helps to actually hard code these IPs

### monitoring

controls how cloud_monitoring is used within magentostack

### php_fpm

shouldn't really be messed with

### redis

You can define a password for each redis instance(or for the single one) using the run_state attribute type.
This type prevents to store passwords on the node. The passwords will be used to set up the Redis instances and configure Magento.

Multiple redis instances
```
node.run_state['magentostack_redis_password_session'] = 'runstatepasswordsession'
node.run_state['magentostack_redis_password_object'] = 'runstatepasswordobject'
node.run_state['magentostack_redis_password_page'] = 'runstatepasswordpage'
```
Single redis instance
```
node.run_state['magentostack_redis_password_single'] = 'runstatepasswordsingle'
```

## Usage

### useful datastructures

### magentostack

```
- MySQL DB Single Node:
```json
{
    "run_list": [
      "recipe[platformstack::default]",
      "recipe[platformstack::rackops_rolebook]",
      "recipe[magentostack::mysql_master]"
    ]
}
```

- MySQL DB Master Node:
```json
{
    "run_list": [
      "recipe[platformstack::default]",
      "recipe[platformstack::rackops_rolebook]",
      "recipe[magentostack::mysql_master]"
    ]
}
```

- MySQL DB Slave Node:
```json
{
    "run_list": [
      "recipe[platformstack::default]",
      "recipe[platformstack::rackops_rolebook]",
      "recipe[magentostack::mysql_slave]"
    ]
}
```

## New Relic Monitoring

To configure New Relic, make sure the `node['newrelic']['license']` attribute is set and include the `platformstack` cookbook in your run_list.  You can also run the `magentostack::newrelic` recipe for some more advanced monitors.


# Contributing

https://github.com/rackspace-cookbooks/contributing/blob/master/CONTRIBUTING.md


# Authors
Authors:: Matthew Thode <matt.thode@rackspace.com>
