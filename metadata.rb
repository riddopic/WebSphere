# encoding: UTF-8

name 'websphere'
maintainer 'Stefano Harding'
maintainer_email 'sharding@trace3.com'
license 'Apache 2.0'
description 'Installs/Configures IBM WebSphere Application Server'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.0'

%w( redhat centos oracle scientific ).each do |os|
  supports os, '>= 5.5'
end

depends 'chef_handler', '~> 1.1.6'
depends 'garcon',       '~> 0.7.8'
depends 'ohai',         '~> 2.0.1'
