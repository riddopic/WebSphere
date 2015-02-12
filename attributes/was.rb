# encoding: UTF-8
#
# Cookbook Name:: websphere
# Attributes:: was
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

# ====================== IBM WebSphere Application Server ======================
#
default[:was] = {
  # The Uniq IBM product ID for IBM WebSphere Application Server.
  id: 'com.ibm.websphere.ND.v85',

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
  # must match the profile ID of the targeted installation of WebSphere
  # Application Server.
  profile: 'IBM WebSphere Application Server V8.5',

  # The features attribute is optional. Offerings always have at least one
  # feature; a required core feature which is installed regardless of whether
  # it is explicitly specified. If other feature names are provided, then only
  # those features will be installed. Features must be comma delimited without
  # spaces.
  features: 'core.feature,ejbdeploy,thinclient,embeddablecontainer,samples,' \
            'com.ibm.sdk.6_64bit',

  # The installFixes attribute indicates whether fixes available in repositories
  # are installed with the product. By default, all available fixes will be
  # installed with the offering.
  #
  # Valid values for installFixes:
  #   none        = Do not install available fixes.
  #   recommended = Installs all available recommended fixes.
  #   all         = Installs all available fixes.
  fixes: :all,

  # The installation directory for IBM WebSphere Application Server.
  dir: lazy { ::File.join( node[:wpf][:base], 'WebSphere/AppServer') },

  data: [
    # Include data keys for product specific profile properties.
    { key:   'user.import.profile', value: false   },
    # Specifies the operating system.
    { key:   'cic.selector.os',     value: 'linux' },
    # Specifies the type of window system.
    { key:   'cic.selector.ws',     value: 'gtk'   },
    # Specifies the architecture to install: 32-bit or 64-bit.
    { key:   'cic.selector.arch',   value: 'x86'   },
    # Specifies the language pack to be installed using ISO-639 language codes.
    { key:   'cic.selector.nl',     value: 'en'    }
  ],

  # =========================== Application Settings ==========================
  #
  # The log home property determines the directory that would hold log
  # files produced by the wasprofile tool.
  # The default path is: `<install location>/logs/manageprofiles`
  cmt_log_home: '${was.install.root}/logs/manageprofiles',

  # The prefix for all wasprofile log file names.
  log_name_prefix: 'wasprofile',

  # The prefix for all pmt gui log file names.
  pmt_log_name_prefix: 'pmt',

  # The profile registry property determines the path to the XML file that
  # contains information about all registered profiles. The default path for
  # this profile is: `<install location>/properties/profileRegistry.xml`
  profile_registry: '${was.install.root}/properties/profileRegistry.xml',

  # The log level determines the verbosity of log files produced by the
  # wasprofile tool. The available range is from 0 to 7. The default level is 3.
  log_level: 3,

  # The log level determines the verbosity of log files produced by the
  # pmt tool. The available range is from 0 to 7. The default log level is 3.
  pmt_log_level: 3,

  # Any action arguments whose values should be masked from the logging
  # for security reasons.
  maskable_action_arguments: %w(
    samplepw winservicePassword adminPassword dmgrAdminPassword password
    adminPwd keyStorePassword   importPersonalCertKSPassword
    importSigningCertKSPassword importDefaultCertKSPassword
    importRootCertKSPassword
  ),

  # The default profile path property determines the default path for all
  # profiles.
  default_profile_home: '${was.install.root}/profiles',

  # The location of the JNI libraries for NativeFile.
  native_file_jni_directory: '${JAVA_NATIVE_LIB_DIR}',

  # Number of retries to obtain a lock on the IPC file used by
  # the wsadmin listener process.
  listener_lock_retry_count: 240_000,

  # Number of retries used to determine if the wsadmin listener process
  # has been initialized.
  listener_initialization_lock_retry_count: 12_000,

  # Number of retries used to determine successful shutdown of the wsadmin
  # listener process.
  listener_shutdown_lock_retry_count: 12_000,

  # Arguments that should be allowed through the strict command line
  # validation.
  additional_command_line_arguments: %w(
    debug omitValidation registry omitAction appendLogs
  ),

  # The default location for searching for profile templates
  default_template_location: '${was.install.root}/profileTemplates',

  # The default template to use for profile creation
  default_template_name: 'default',

  # Specify if the post installer should modify the permissions of any files it
  # creates. Valid values are 'true' or 'false'. Any other value will default to
  # false. Removing this property from the file will also have it default to
  # false. When set to false, any files created by post installer will have
  # permission based on the umask setting of the system.
  cmt_pi_modperms: true,

  # Specify if post installer should clean up its logs. This will cleanup logs
  # for each product located in `PROFILE_HOME/properties/service/productDir`.
  # One of the following cleanup criteria can be used/specified:
  #
  # * Specify the number of logs to keep from 0-999. EG. `WS_CMT_PI_LOGS=10`
  #
  # * Specify the total size the logs should occupy from 0-999. For example:
  #   `WS_CMT_PI_LOGS=10MB` (KB = Kilobytes	MB = Megabytes GB = Gigabytes)
  #
  #	* Specify the amount of time to keep logs around from 0-999. For example:
  #   `WS_CMT_PI_LOGS=2W` (D = Days	W = Weeks	M = Months Y = Years)
  #
  #	* Specify a specific date after which a log older than the date will be
  #   deleted in a format of DD-MM-YYYY. For example: `05-10-2012` It must
  #		all numerics and be separated by dashes or it will be ignored.
  #
  # Note that only one criteria can be used at a time. If more than one is
  # specified, the last value specified in this file will be used.
  cmt_pi_logs: 10,
}
