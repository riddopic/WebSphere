# encoding: UTF-8
#
# Cookbook Name:: websphere
# Attributes:: iim
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

# ========================== IBM Installation Manager ==========================
#
default[:iim] = {
  # The Uniq IBM product ID for IBM Installation Manager.
  id: 'com.ibm.cic.agent',

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
  version: '1.8.1000.20141125_2157',

  # The profile attribute is required and typically is unique to the offering.
  # If modifying or updating an existing installation, the profile attribute
  # must match the profile ID of the targeted installation of WebSphere
  # Application Server.
  profile: 'IBM Installation Manager',

  # The features attribute is optional. Offerings always have at least one
  # feature; a required core feature which is installed regardless of whether
  # it is explicitly specified. If other feature names are provided, then only
  # those features will be installed. Features must be comma delimited without
  # spaces.
  features: 'agent_core,agent_jre',

  # The installFixes attribute indicates whether fixes available in repositories
  # are installed with the product. By default, all available fixes will be
  # installed with the offering.
  #
  # Valid values for installFixes:
  #   :none        = Do not install available fixes.
  #   :recommended = Installs all available recommended fixes.
  #   :all         = Installs all available fixes.
  fixes: :none,

  # The installation directory for IBM Installation Manager (IIM).
  dir: lazy { ::File.join(node[:wpf][:base], 'InstallationManager/eclipse') },

  # Installation Manager can be installed along with the Packaging Utility
  # providing access to the Packaging Utility toolset to manage and query
  # installation repositories. Valid values are; `:standalone`, do not install
  # the Packaging Utility and only install IIM. `:with_pkgutil` install the
  # Packaging Utility with IIM. The default value is `:with_pkgutil`.
  install_from: :with_pkgutil,

  data: [],

  files: {
    standalone: {
      # Zip file that contains the IBM Installation Manager package.
      name: 'agent.installer.linux.gtk.x86_64_1.8.1000.20141126_2002.zip',

      # Local or remote location where the IIM zip file is located. Default is
      # to download from IBM. You can use a URL shortner for convince, the
      # and the cookbook will expand t the correct path.
      source: 'http://ibm.co/1zr8L6q',

      # The SHA-256 checksum of the zip file. Checksum are calculated with:
      # shasum -a 256 /path/to/file
      checksum:'c9af97d4d953e0d08b612b208d6807e6ac7ce2d22883698ad20413462bc0499a'
    },

    with_pkgutil: {
      # Zip file that contains the IBM Installation Manager package with the
      # Packaging Utility bundle.
      name: 'pu.offering.disk.linux.gtk.x86_64_1.8.1000.20141126_2003.zip',

      # Local or remote location where the IIM/Packaging Utility zip file is
      # located. Default is to download from IBM. You can use a URL shortner
      # for convince, the and the cookbook will expand t the correct path.
      source: 'http://ibm.co/1z91ntT',

      # The SHA-256 checksum of the zip file. Checksum are calculated with:
      # shasum -a 256 /path/to/file
      checksum:'706bc445b37276ed0f4b32d2cd01f101eae1fadaacf7a9550c8c01a2e6d8b10f'
    }
  }
}
