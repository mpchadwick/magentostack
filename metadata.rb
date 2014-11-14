# Encoding: utf-8
name 'magentostack'
maintainer 'Rackspace'
maintainer_email 'rackspace-cookbooks@rackspace.com'
license 'Apache 2.0'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
description 'Provides a full php stack'
version '0.0.1'

depends 'apache2'
depends 'apt'
depends 'build-essential'
depends 'chef-sugar'
depends 'git'
depends 'openssl'
depends 'php-fpm'
depends 'platformstack'
depends 'stack_commons'
depends 'yum'
depends 'yum-ius'
depends 'yum-epel'
