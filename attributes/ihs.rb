# encoding: UTF-8
#
# Cookbook Name:: websphere
# Attributes:: ihs
#
# Author:    Stefano Harding <riddopic@gmail.com>
# License:   Apache License, Version 2.0
# Copyright: (C) 2014-2015 Stefano Harding
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_attribute 'websphere::default'

# ============================== IBM HTTP Server ===============================
#
default[:ihs] = {
  # The Uniq IBM product ID for IBM HTTP Server .
  id: 'com.ibm.websphere.IHS.v85',

  # Specify the repositories that are used during the installation. Use a URL
  # or UNC path to specify the remote repositories. Or use directory paths to
  # specify the local repositories. If none is specified it will default to
  # using `node[:wpf][:repositories][:local]`, default is nil.
  repositories: nil,

  # Use the install and uninstall commands to inform Installation Manager of the
  # installation packages to install or uninstall.
  #   false = Indicates not to modify an existing install by adding or removing
  #           features.
  #   true  = Indicates to modify an existing install by adding or removing
  #           features.
  modify: false,

  # The version attribute is optional. If a version number is provided, then the
  # offering will be installed or uninstalled at the version level specified as
  # long as it is available in the repositories. If the version attribute is not
  # provided, then the default behavior is to install or uninstall the latest
  # version available in the repositories. The version number can be found in
  # the repository.xml file in the repositories.
  #
  # NOTE: In some cases, a package might be rolled back to an earlier version.
  # This roll back can happen if the version specified is earlier than the
  # installed version or if a version is not specified. For example, you have
  # version 1.0.2 of a package that is installed and the latest version of the
  # package available in the repository is version 1.0.1. When you install the
  # package, the installed version of the package is rolled back to version
  # 1.0.1.
  version: nil,

  # The profile attribute is required and typically is unique to the offering.
  # If modifying or updating an existing installation, the profile attribute
  # must match the profile ID of the targeted installation.
  profile: 'IBM HTTP Server V8.5',

  # The features attribute is optional. Offerings always have at least one
  # feature; a required core feature which is installed regardless of
  # whether it is explicitly specified. If other feature names are
  # provided, then only those features will be installed. Features must be
  # comma delimited without spaces.
  features: 'core.feature,arch.64bit',

  # The installFixes attribute indicates whether fixes available in
  # repositories are installed with the product. By default, all available
  # fixes will be installed with the offering.
  #
  # Valid values for installFixes:
  #   none        = Do not install available fixes.
  #   recommended = Installs all available recommended fixes.
  #   all         = Installs all available fixes.
  fixes: :all,

  # The service init script.
  init: 'ihs',

  # The installation directory for IBM HTTP Server
  dir: lazy { ::File.join( node[:wpf][:base], 'WebSphere/HTTPServer') },

  data: [
    # Include data keys for product specific profile properties.
    { key:   'user.import.profile',                value: false  },
    # Specifies the operating system.
    { key:   'cic.selector.os',                    value: 'linux'},
    # Specifies the type of window system.
    { key:   'cic.selector.ws',                    value: 'gtk'  },
    # Specifies the architecture to install: x86 or x86_64.
    { key:   'cic.selector.arch',                  value: 'x86'  },
    # Your guess is as good as mine.
    { key:   'user.ihs.httpPort',                  value: 80     },
    # This option indicates whether you accept the limitations associated with
    # installing as a non-root user. The following installation actions cannot
    # be performed with installing as a non-root or non-administrative user.
    { key:   'user.ihs.allowNonRootSilentInstall', value: true   },
    { key:   'user.ihs.http.server.service.name',  value: 'none' },
    { key:   'user.ihs.installHttpService',        value: false  },
    # Specifies the language pack to be installed using ISO-639 language codes.
    { key:   'cic.selector.nl',                    value: 'en'   }
  ]
}

# ============================= IBM HTTP Settings ==============================

default[:ihs][:dir]
default[:ihs][:lock_dir]          = 'logs/'
default[:ihs][:pid_file]          = 'logs/httpd.pid'
default[:ihs][:timeout]           = 300
default[:ihs][:keepalive]         = 'On'
default[:ihs][:keepaliverequests] = 100
default[:ihs][:keepalivetimeout]  = 5
default[:ihs][:user]              = node[:wpf][:user][:name]
default[:ihs][:group]             = node[:wpf][:user][:group]
default[:ihs][:error_log]         = 'error.log'
default[:ihs][:log_dir]           = 'var/log/apache2'
default[:ihs][:listen_ports]      = %w(*)
default[:ihs][:listen_addresses]  = %w(80)
default[:ihs][:contact]           = 'ops@example.com'
default[:ihs][:server_name]       = node[:hostname]
default[:ihs][:docroot_dir] = lazy { ::File.join(node[:ihs][:dir], 'htdocs') }
default[:ihs][:directory_index]   = %w(index.html index.html.var)

# Worker Attributes
default[:ihs][:workers][:threadlimit]            = 25
default[:ihs][:workers][:serverlimit]            = 64
default[:ihs][:workers][:startservers]           = 1
default[:ihs][:workers][:maxclients]             = 600
default[:ihs][:workers][:minsparethreads]        = 25
default[:ihs][:workers][:maxsparethreads]        = 75
default[:ihs][:workers][:threadsperchild]        = 25
default[:ihs][:workers][:maxrequestsperchild]    = 0
