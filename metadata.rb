# encoding: UTF-8

name             'websphere'
maintainer       'Stefano Harding'
maintainer_email 'riddopic@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures IBM WebSphere IIM, IHS and WAS'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.3'

%w( redhat centos oracle scientific ).each do |os|
  supports os, '>= 5.5'
end

depends 'garcon', '~> 0.7.3'
