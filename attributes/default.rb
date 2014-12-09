# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Attributes:: default
#

default[:websphere] = {
  # The base directory where all WebSphere products will reside. The default
  # value is '/opt/IBM'. Note: When installing with a non-root account software
  # will be installed in /opt/IBM/IBM/PackageName.
  base_dir:   '/opt/IBM',

  # The path to the shared directory for IBM products. Default is
  # `/opt/IBM/DataLocation`
  data_dir:   '/opt/IBM/DataLocation',

  # The path to the Installation Manager shared data directory. Default is
  # `/opt/IBM/IBM/Shared`.
  shared_dir: '/opt/IBM/Shared'
}

# User and Group name under which the server will be installed and running.
default[:websphere][:user] = {
  name:    'wasadm',
  group:   'wasadm',
  comment: 'Websphere Administrative Account',
  home:    '/home/wasadm',
  shell:   '/bin/bash',
  system:  true,
  uid:     nil,
  gid:     nil
}

# The list of Applications to install.
default[:websphere][:apps] = [ nil ]

# ================================ Repositories ================================
#
# Repositories are locations that Installation Manager queries for installable
# packages. Repositories can be local (on the machine with Installation Manager)
# or remote (corporate intranet or hosted elsewhere on the internet).
default[:websphere][:repositories] = {
  # IBM WebSphere Live Update Repositories. Including this repository ensures
  # your system is always built with the most up-to-date patches and hot fixes.
  live: 'http://www.ibm.com/software/repositorymanager',

  # Local repository of WebSphere.
  local: nil
}

default[:websphere][:credential] = {
  # Note: If you use the IBM service repositories, you can specify the
  # http://www.ibm.com/software/repositorymanager/entitled/repository.xml
  # value for the `url` attribute. This value is a generic service repository
  # that can be used for IBM packages.
  url: 'http://www.ibm.com/software/repositorymanager/entitled/repository.xml',

  # IBM user name and password. To register for an IBM user name and password,
  # go to: http://www.ibm.com/account/profile
  # @note: This is only needed if you intend to access the live repositories.
  username: nil,
  password: nil,

  # The location of the master password file IIM should use to access the secure
  # storage file, this attribute is optional.
  master_password_file: ::File.join(node[:websphere][:user][:home], '.mpf'),

  # The location of the secure storage file IIM should use to access the
  # repoistory, this attribute is optional.
  secure_storage_file: ::File.join(node[:websphere][:user][:home], '.ssf')
}

# =========================== Response File Settings ===========================
#
# The clean and temporary attributes specify the repositories and other
# preferences Installation Manager uses and whether those settings should
# persist after the installation finishes.
#
# The default value is false. Installation Manager uses the repository and
# other preferences that are specified in the response file and the existing
# preferences that are set in Installation Manager. If a preference is specified
# in the response file and set in the Installation Manager, the preference that
# is specified in the response file takes precedence.
#
# When clean='true', Installation Manager uses the repository and other
# preferences that are specified in the response file. Installation Manager
# does not use the existing preferences that are set in Installation Manager.
#
# Valid values for clean:
# true  = Only use the repositories and other preferences that are specified in
#         the response file.
# false = Use the repositories and other preferences that are specified in the
#         response file and Installation Manager.
default[:websphere][:agent_input][:clean] = false

# The default value is false. When temporary='false', the preferences that are
# set in your response file persist. When temporary='true', the preferences that
# are set in the response file do not persist.
#
# You can use temporary and clean together. For example, you set clean='true'
# and temporary='false'. After you run the silent installation, the repository
# setting that is specified in the response file overrides the preferences that
# were previously set.
#
# Valid values for temporary:
# true  = Repositories and other preferences specified in the response file do
#         not persist in Installation Manager.
# false = Repositories and other preferences specified in the response file
#         persist in Installation Manager.
default[:websphere][:agent_input][:temporary] = true

default[:websphere][:preferences] = [
  # This key specifies the location of the shared resources directory. The
  # shared resource directory is specified the first time you install a package.
  # You cannot change this location after you install a package.
  # This preference is set during the installation process when you use the
  # Installation Manager interface.
  { key:   'com.ibm.cic.common.core.preferences.eclipseCache',
    value: '${sharedLocation}' },

  # The default value is 30 seconds.
  { key:   'com.ibm.cic.common.core.preferences.connectTimeout',
    value: 30 },

  # The default value is 30 seconds.
  { key:   'com.ibm.cic.common.core.preferences.readTimeout',
    value: 30 },

  # The default value is 0.
  { key:   'com.ibm.cic.common.core.preferences.downloadAutoRetryCount',
    value: 0  },

  # When this key is set to true, service repositories are searched when
  # products are installed or updated. Change this key to false to disable the
  # function. The default value is true.
  { key:   'offering.service.repositories.areUsed',
    value: true },

  # When this key is set to true, Nonsecure SSL Mode is enabled and is set as
  # permanent by default. When this key is set to false, Nonsecure SSL Mode is
  # disabled. The default value is false.
  #
  # NOTE: You cannot enable Nonsecure SSL Mode with the session setting in a
  # response file.
  { key:   'com.ibm.cic.common.core.preferences.ssl.nonsecureMode',
    value: false },

  # The default value is false.
  { key:   'com.ibm.cic.common.core.preferences.http.disablePreemptiveAuthentication',
    value: false },

  # This key specifies the type of authentication scheme used. The default value
  # is NTLM. Definition of values:
  #   LM:     LANMANAGER authentication is used.
  #   NTLM:   NTLM version 1 authentication is used.
  #   NTLMv2: NTLM versions 2 authentication is used.
  { key:   'http.ntlm.auth.kind',
    value: 'NTLM' },

  { key:   'http.ntlm.auth.enableIntegrated.win32',
    value: true },

  # When this key is set to true, the files that are required to roll the
  # package back to a previous version are stored on your computer. When this
  # key is set to false, files that are required for a rollback or an update are
  # not stored. If you do not store these files, you must connect to your
  # original repository or media to roll back a package. When the preference is
  # changed from true to false, the stored files are deleted the next time that
  # you install, update, modify, roll back, or uninstall a package.
  { key:   'com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts',
    value: true },

  # When this key is set to true, if an error occurs during the installation or
  # the update process, the files that are downloaded are not deleted. The next
  # time you download these files, the time to download the files decreases
  # because some of the files are downloaded already.
  #
  # When this key is set to false, files that are downloaded are deleted if an
  # error occurs.
  { key:   'com.ibm.cic.common.core.preferences.keepFetchedFiles',
    value: false },

  # The default value is false.
  { key:   'PassportAdvantageIsEnabled',
    value: false },

  # When this key is set to true, a search for updates occurs first when you run
  # a silent installation. The default value is false.
  #
  # When the key is set to false and the IBM product that you are installing
  # requires a newer version of Installation Manager, a message shows when you
  # run the silent installation. The message indicates that a later version of
  # Installation Manager is required. The silent installation stops.
  { key:   'com.ibm.cic.common.core.preferences.searchForUpdates',
    value: false },

  { key:   'com.ibm.cic.agent.ui.displayInternalVersion',
    value: false },

  { key:   'com.ibm.cic.common.sharedUI.showErrorLog',
    value: true  },

  { key:   'com.ibm.cic.common.sharedUI.showWarningLog',
    value: true  },

  { key:   'com.ibm.cic.common.sharedUI.showNoteLog',
    value: true  }
]
