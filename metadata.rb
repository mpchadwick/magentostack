# Encoding: utf-8
name 'magentostack'
maintainer 'Rackspace'
maintainer_email 'rackspace-cookbooks@rackspace.com'
license 'Apache 2.0'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
description 'Provides a full Magento stack'
version '0.0.4'

depends 'apache2', '~> 3.0.0'
depends 'apt'
depends 'ark'
depends 'build-essential'
depends 'chef-sugar'
depends 'cron'
depends 'database', '= 3.0.1'
depends 'git'
depends 'logrotate'
depends 'mysql-multi'
depends 'openssl'
depends 'php-fpm'
depends 'platformstack'
depends 'platformstack', '>= 1.5.3'
depends 'redisio'
depends 'rackspacecloud'
depends 'rackspace_iptables'
depends 'stack_commons', '>= 0.0.37'
depends 'yum'
depends 'yum-ius'
depends 'yum-epel'
depends 'xml'
depends 'xmledit'
