# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Attributes:: appclient
#

# ============ Application Client for WebSphere Application Server =============
#
default[:websphere][:appclient] = {
  # Specify whether or not to install Application Client (APPCLIENT).
  install: true,

  # The Uniq IBM product ID for Application Client.
  id: 'com.ibm.websphere.APPCLIENT.v85',

  # Specify the repositories that are used during the installation. Use a URL
  # or UNC path to specify the remote repositories. Or use directory paths to
  # specify the local repositories.
  repositories: ->{
    'http://repo.mudbox.dev/ibm/repositorymanager/com.ibm.websphere.APPCLIENT.v85' },

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
  # must match the profile ID of the targeted installation of WebSphere
  # Application Server.
  profile: 'Application Client for IBM WebSphere Application Server V8.5',

  # The features attribute is optional. Offerings always have at least one
  # feature; a required core feature which is installed regardless of whether
  # it is explicitly specified. If other feature names are provided, then only
  # those features will be installed. Features must be comma delimited without
  # spaces.
  features: 'core.feature,pct,zpmt,zmmt',

  # The installFixes attribute indicates whether fixes available in repositories
  # are installed with the product. By default, all available fixes will be
  # installed with the offering.
  #
  # Valid values for installFixes:
  #   none        = Do not install available fixes.
  #   recommended = Installs all available recommended fixes.
  #   all         = Installs all available fixes.
  fixes: 'all',

  # The installation directory for Application Client.
  # Default is `/opt/IBM/WebSphere/AppClient`.
  install_location: '/opt/IBM/WebSphere/AppClient',

  data: [
    # The eclipseLocation data key should use the same directory path to
    # WebSphere Application Server as the installationLocation attribute.
    { key:   'eclipseLocation',
      value: lambda { node[:websphere][:appclient][:install_location] } },
    # Include data keys for product specific profile properties.
    { key:   'user.import.profile',           value: false              },
    { key:   'user.select.64bit.image,com.ibm.websphere.WCT.v85',
      value: 'x86_64'                                                   },
    { key:   'user.appclient.serverHostname', value: 'localhost'        },
    { key:   'user.appclient.serverPort',     value: 2809               },
    { key:   'user.ihs.allowNonRootSilentInstall', value: true    }, #######
    # Specifies the language pack to be installed using ISO-639 language codes.
    { key:   'cic.selector.nl',               value: 'en'               }
  ]
}
