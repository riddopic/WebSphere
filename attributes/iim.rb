# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Attributes:: iim
#

# ========================== IBM Installation Manager ==========================
#
default[:websphere][:iim] = {
  # The Uniq IBM product ID for IBM Installation Manager.
  id: 'com.ibm.cic.agent',

  # Specify the repositories that are used during the installation. Use a URL
  # or UNC path to specify the remote repositories. Or use directory paths to
  # specify the local repositories.
  repositories: ['.'],

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
  version: '1.8.0.20140902_1503',

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
  #   none        = Do not install available fixes.
  #   recommended = Installs all available recommended fixes.
  #   all         = Installs all available fixes.
  fixes: 'none',

  # The installation directory for IBM Installation Manager (IIM).
  # NOTE: The installation will append `/InstallationManager/eclipse` to the
  # path. Default is `/opt/IBM/IBM/InstallationManager/eclipse`.
  install_location: '/opt/IBM',

  # Installation Manager can be installed along with the Packaging Utility
  # providing access to the Packaging Utility toolset to manage and query
  # installation repositories. Valid values are; `:standalone`, do not install
  # the Packaging Utility and only install IIM. `:with_pkgutil` install the
  # Packaging Utility with IIM. The default value is `:with_pkgutil`.
  install_type: :with_pkgutil,

  data: [
    # The eclipseLocation data key should use the same directory path to
    # Installation Manager as the `install_location` attribute.
    { key:   'eclipseLocation',
      value: lambda { node[:websphere][:iim][:install_location] } }],

  file: {
    standalone: {
      # Zip file that contains the IBM Installation Manager package.
      name: 'agent.installer.linux.gtk.x86_64_1.8.1000.20141126_2002.zip',

      # Local or remote location where the IIM zip file is located. Default is
      # to download from IBM.
      source: 'http://ibm.co/1zr8L6q',

      # The SHA-256 checksum of the zip file. Checksum are calculated with:
      # shasum -a 256 /path/to/file | cut -c-12
      checksum: 'c9af97d4d953'
    },

    with_pkgutil: {
      # Zip file that contains the IBM Installation Manager package with the
      # Packaging Utility bundle.
      name: 'pu.offering.disk.linux.gtk.x86_64_1.8.1000.20141126_2003.zip',

      # Unlike the standalone IIM utility this zip file creates subdirectories.
      work_dir: 'disk_linux.gtk.x86_64/InstallerImage_linux.gtk.x86_64',

      # Local or remote location where the IIM/Packaging Utility zip file is
      # located. Default is to download from IBM.
      source: 'http://ibm.co/1AoUlEK',

      # The SHA-256 checksum of the zip file. Checksum are calculated with:
      # shasum -a 256 /path/to/file | cut -c-12
      checksum: '706bc445b372'
    }
  }
}
