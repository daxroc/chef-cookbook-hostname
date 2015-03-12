# -*- coding: utf-8 -*-

name             'hostname'
maintainer       'Maciej Pasternacki'
maintainer_email 'maciej@3ofcoins.net'
license          'MIT'
description      'Configures hostname and FQDN'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.4.0'

%w{ debian fedora freebsd redhat ubuntu }.each do |os|
  supports os
end

depends 'hostsfile'
