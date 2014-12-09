# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Attributes:: ihs
#

include_attribute 'websphere::default'

# ============================== IBM HTTP Server ===============================
#
default[:websphere][:ihs] = {
  # The Uniq IBM product ID for IBM HTTP Server .
  id: 'com.ibm.websphere.IHS.v85',

  # Specify the repositories that are used during the installation. Use a URL
  # or UNC path to specify the remote repositories. Or use directory paths to
  # specify the local repositories. If none is specified it will default to
  # using `node[:websphere][:repositories][:local]`, default is nil.
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
  version: '8.5.5003.20140730_1249',

  # The profile attribute is required and typically is unique to the offering.
  # If modifying or updating an existing installation, the profile attribute
  # must match the profile ID of the targeted installation of HTTP Server.
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
  fixes: 'none',

  # The service init script.
  init: 'ihs',

  # The installation directory for IBM HTTP Server. The default value is
  # `/opt/IBM/IBM/WebSphere/HTTPServer` for non-root installations or
  # `/opt/IBM/WebSphere/HTTPServer` for root installations.
  install_location: ::File.join(
    node[:websphere][:base_dir], 'WebSphere/HTTPServer'),

  data: [
    # Include data keys for product specific profile properties.
    { key:   'user.import.profile',         value: false         },
    # Specifies the operating system.
    { key:   'cic.selector.os',             value: 'linux'       },
    # Specifies the type of window system.
    { key:   'cic.selector.ws',             value: 'gtk'         },
    # Specifies the architecture to install: x86 or x86_64.
    { key:   'cic.selector.arch',           value: 'x86'         },
    # Your guess is as good as mine.
    { key:   'user.ihs.httpPort',           value: 80            },
    # This option indicates whether you accept the limitations associated with
    # installing as a non-root user. The following installation actions cannot
    # be performed with installing as a non-root or non-administrative user.
    { key:   'user.ihs.allowNonRootSilentInstall', value: true   },
    { key:   'user.ihs.http.server.service.name',  value: 'none' },
    { key:   'user.ihs.installHttpService',        value: false  },
    # Specifies the language pack to be installed using ISO-639 language codes.
    { key:   'cic.selector.nl',             value: 'en'          }
  ]
}
