# encoding: UTF-8
#
# Cookbook Name:: websphere
# Attributes:: portal_server
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

# ======================== IBM WebSphere Portal Server =========================
#
default[:wps] = {
  # The Uniq IBM product ID for IBM WebSphere Portal Server.
  id: 'com.ibm.websphere.PORTAL.SERVER.v80',

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
  version: '8.0.1.20130123_1736',

  # The profile attribute is required and typically is unique to the offering.
  # If modifying or updating an existing installation, the profile attribute
  # must match the profile ID of the targeted installation of WebSphere
  # Application Server.
  profile: 'IBM WebSphere Portal Server V8',

  # The features attribute is optional. Offerings always have at least one
  # feature; a required core feature which is installed regardless of whether
  # it is explicitly specified. If other feature names are provided, then only
  # those features will be installed. Features must be comma delimited without
  # spaces.
  features: 'ce.install,portal.binary,portal.profile,dmgr.profile',

  # The installFixes attribute indicates whether fixes available in repositories
  # are installed with the product. By default, all available fixes will be
  # installed with the offering.
  #
  # Valid values for installFixes:
  #   none        = Do not install available fixes.
  #   recommended = Installs all available recommended fixes.
  #   all         = Installs all available fixes.
  fixes: :all,

  # The installation directory for IBM WebSphere Portal Server.
  dir: lazy { ::File.join( node[:wpf][:base], 'WebSphere/Portal') },

  data: [
    # Include data keys for product specific profile properties.
    { key:   'user.import.profile', value: false    },
    # Specifies the operating system.
    { key:   'cic.selector.os',     value: 'linux'  },
    # Specifies the type of window system.
    { key:   'cic.selector.ws',     value: 'gtk'    },
    # Specifies the architecture to install: 32-bit or 64-bit.
    { key:   'cic.selector.arch',   value: 'x86' },
    # Specifies the language pack to be installed using ISO-639 language codes.
    { key:   'cic.selector.nl',     value: 'en'     }
  ]
}
