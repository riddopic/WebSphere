
# WebSphere Cookbook

The [IBM WebSphere](http://www.ibm.com/web/portal/software/websphere), family
includes and supports a range of products that helps you develop and serve your
business applications. These products make it easier for clients to build,
deploy, and manage dynamic websites and other more complex solutions
productively and effectively.

You can find more information about using WebSphere Application from the
[WebSphere Application Server V8.5.5 Technical Overview](http://www.redbooks.ibm.com/redpapers/pdfs/redp4855.pdf).

Use this cookbook to install and configure any of the following components:

 * Application Client for WebSphere Application Server
 * IBM HTTP Server for WebSphere Application Server
 * IBM Packaging Utility
 * Web Server Plug-ins for WebSphere Application Server
 * Pluggable Application Client for WebSphere Application Server
 * IBM WebSphere Portal
 * IBM WebSphere Application Server Network Deployment
 * WebSphere Customization Toolbox
 * All product prerequisites, including WebSphere Application Server ND V8.5.5

The cookbook also creates a user account to manage the components, and creates
and configures all the components that are required for a running WebSphere
Application Server instance.

## Requirements

Before trying to use the cookbook make sure you have a supported system. If you
are attempting to use the cookbook in a standalone manner to do testing and
development you will need a functioning Chef/Ruby environment, with the
following:

* Chef 11 or higher
* Ruby 1.9 (preferably from the Chef full-stack installer)

#### Chef

Chef Server version 11+ and Chef Client version 11.16.2+ and Ohai 7+ are
required. Clients older that 11.16.2 do not work.

#### Platforms

This cookbook uses Test Kitchen to do cross-platform convergence and post-
convergence tests. The tested platforms are considered supported. This cookbook
may work on other platforms or platform versions with or without modification.

* Red Hat Enterprise Linux (RHEL) Server 6 x86_64 (RedHat, CentOS, Oracle etc.)

#### Cookbooks

The following cookbooks are required as noted (check the metadata.rb file for
the specific version numbers):

* [chef_handler](https://supermarket.getchef.com/cookbooks/chef_handler) -
  Distribute and enable Chef Exception and Report handlers.
* [garcon](comming soon to a supermarket near you) - Provides handy hipster,
  hoodie ninja cool awesome methods and features.
* [ohai](https://supermarket.chef.io/cookbooks/ohai) - Creates a configured
  plugin path for distributing custom Ohai plugins, and reloads them via Ohai
  within the context of a Chef Client run during the compile phase (if needed)
* [sudo](https://supermarket.chef.io/cookbooks/sudo) - The Chef sudo cookbook 
  installs the sudo package and configures the /etc/sudoers file. Require for
  local development only.

#### Limitations

This cookbook primary goal is to automate the installation of WebSphere and
various sub-components, focusing on getting WebSphere onto the system and
running, not to deploy and configure applications within the Application Server
itself. Configuration and deployment of applications within the WebSphere
Application Server and Portal Server will be handled by Urban Code.

Talk to your IBM representative for additional information about Urban Code, or try a copy out yourself at any of our Blue is You store locations.  

### Development Requirements

In order to develop and test this Cookbook, you will need a handful of gems
installed.

* [Chef][]
* [Berkshelf][]
* [Test Kitchen][]
* [ChefSpec][]
* [Foodcritic][]

It is recommended for you to use the Chef Developer Kit (ChefDK). You can get
the [latest release of ChefDK from the downloads page][ChefDK].

On Mac OS X, you can also use [homebrew-cask](http://caskroom.io) to install
ChefDK.

Once you install the package, the `chef-client` suite, `berks`, `kitchen`, and
this application (`chef`) will be symlinked into your system bin directory,
ready to use.

You should then set your Ruby/Chef development environment to use ChefDK. You
can do so by initializing your shell with ChefDK's environment.

    eval "$(chef shell-init SHELL_NAME)"

where `SHELL_NAME` is the name of your shell, (bash or zsh). This modifies your
`PATH` and `GEM_*` environment variables to include ChefDK's paths (run without
the `eval` to see the generated code). Now your default `ruby` and associated
tools will be the ones from ChefDK:

    which ruby
    # => /opt/chefdk/embedded/bin/ruby

You will also need Vagrant 1.6+ installed and a Virtualization provider such as
VirtualBox or VMware.

## Usage

Ah, the good stuff.... Need to fill this in...

## Attributes

Attributes are under the `websphere` namespace, the following attributes affect
the behavior of how the cookbook performs an installation, or are used in the
recipes for various settings that require flexibility. Attributes have default
values set, where possible or appropriate, the default values from IBM are used.

### General attributes:

General attributes can be found in the `default.rb` file, application specific
attributes are located in their respective attributes file.

* `node[:websphere][:base_dir]`: [String] The base directory where all of the
  WebSphere products will reside. The default value is `/opt/IBM`. Note: When
  installing with a non-root account software will be installed in this
  directory and also the users home directory that runs the installs.

* `node[:websphere][:data_dir]`: [String] The path to the shared directory for
  IBM products. Default is `/opt/IBM/DataLocation`

* `node[:websphere][:data_dir]`: [String] The path to the Installation Manager
  shared data directory. Default is `/opt/IBM/IBM/Shared`.

* `node[:websphere][:user]`: [String] The user to run WebSphere applications.
  The cookbook will create a system account for the user if it does not exist.
  The default is `wasadm`.

* `node[:websphere][:user][:group]`: [String] The group to run WebSphere
  applications. The cookbook will create a local group if it does not exist.
  The default is `wasadm`.

* `node[:websphere][:user][:comment]`: [String] The GECOS comment for the user..

* `node[:websphere][:home]`: [String] The home directory attribute for the 
  `:user`. The default value is to use the same directory that the Install
  Manager uses.
  
* `node[:websphere][:user][:system]`: [TrueClass, FalseClass] Create a system
  account. A system account is an user with an `UID` between SYSTEM_UID_MIN and 
  SYSTEM_UID_MAX as  defined  in `/etc/login.defs`, if no UID is specified. 
  Default is to use a system account.

* `node[:websphere][:user][:uid]`: [Integer] If `system` is set to false then
  you can select a `UserID` for the account. Default is nil and a system account
  is used.

* `node[:websphere][:user][:gid]`: [Integer] If `system` is set to false then
  you can select a `GroupID` for the account. Default is nil and a system 
  account is used.

* `node[:websphere][:apps]`: [String, Array] A list of available WebSphere 
  applications or components available in the the current repository. **Note:** 
  the names must match the namespace; `:was` is WebSphere Application Server, 
  the attribute namespace is `node[:websphere][:was]`. By default only IIM is 
  installed.

* `node[:websphere][:repositories][:live]`: The live IBM WebSphere repository.
  This location is regularly updated with hot-patches, services packs and fixes.

* `node[:websphere][:repositories][:local]`: The local WebSphere repository,
  must contain a valid `repository.config`. Default is nil.

* `node[:websphere][:repositories][:live]`: [Array, String] Specify the
  location of the IBM live online product repository. This location is
  regularly updated with hot-patches, services packs and fixes. Default is to
  use the IBM web-based online repository. **Note:** You should not change
  this attribute.

* `node[:websphere][:repositories][:local]`: [Array, String] The location for
  a local online product repository. This can be a local copy on the machine,
  or on an internal web or NFS server. Information on how to create your own
  local online product repository can be found later in this document. Default
  is `nil`.

* `node[:websphere][:credential][:url]`: Repository to authenticate with, if
  you use the IBM service repositories, you can specify the
  `http://www.ibm.com/software/repositorymanager/entitled/repository.xml`
  value for the `url` attribute. This value is a generic service repository
  that can be used for IBM packages.

* `node[:websphere][:credential][:username]`: The user name to access the
  repository, to register for an IBM user name and password, go to: http://
  www.ibm.com/account/profile. **Note:** This attribute is optional and is only
  needed if you intend to access the live repositories.

* `node[:websphere][:credential][:password]`: The password to access the
  repository, to register for an IBM user name and password, go to: http://
  www.ibm.com/account/profile. This attribute is optional and is only needed
  if you intend to access the live repositories.

* `node[:websphere][:credential][:master_password_file]`: The location of the
  master password file Installation Manager should use to access the secure
  storage file, this attribute is optional.

* `node[:websphere][:credential][:secure_storage_file]`: The location of the
  secure storage file Installation Manager should use to access the secure
  storage file, this attribute is optional.

* `node[:websphere][:agent_input][:clean]`: The clean and temporary attributes
  specify the repositories and other preferences Installation Manager uses and
  whether those settings should persist after the installation finishes.

  The default value is false. Installation Manager uses the repository and
  other preferences that are specified in the response file and the existing
  preferences that are set in Installation Manager. If a preference is
  specified in the response file and set in the Installation Manager, the
  preference that is specified in the response file takes precedence.

  When `true`, Installation Manager uses the repository and other preferences
  that are specified in the response file. Installation Manager does not use
  the existing preferences that are set in Installation Manager.

* `node[:websphere][:agent_input][:temporary]`: The default value is false. When
  `false`, the preferences that are set in your response file persist. When
  `true`, the preferences that are set in the response file do not persist.

  You can use temporary and clean together. For example, you set
  `node[:websphere][:agent_input][:clean] = true` and `node[:websphere]
  [:agent_input][:temporary] = false`. After you run the silent installation,
  the repository setting that is specified in the response file overrides the
  preferences that were previously set.

* `node[:websphere][:shared_dir]`: The path to the shared directory for IBM
  products.

* `node[:websphere][::preferences]`: A list of preferences that define the
  behavior during installation. These values are created as part of the response
  file.

  * `com.ibm.cic.common.core.preferences.eclipseCache`: This key specifies the
    location of the shared resources directory. The shared resource directory
    is specified the first time you install a package. You cannot change this
    location after you install a package. This preference is set during the
    installation process when you use the Installation Manager interface.

  * `com.ibm.cic.common.core.preferences.connectTimeout`: The default value is
    30 seconds.

  * `com.ibm.cic.common.core.preferences.readTimeout`: The default value is 30
    seconds.

  * `com.ibm.cic.common.core.preferences.downloadAutoRetryCount`: The default
    value is 0.

  * `offering.service.repositories.areUsed`: When this key is set to true,
    service repositories are searched when products are installed or updated.
    Change this key to false to disable the function. The default value is true.

  * `com.ibm.cic.common.core.preferences.ssl.nonsecureMode`: When this key is
    set to true, Nonsecure SSL Mode is enabled and is set as permanent by
    default. When this key is set to false, Nonsecure SSL Mode is disabled. The
    default value is false. **Note:** You cannot enable Nonsecure SSL Mode with
    the session setting in a response file.

  * `com.ibm.cic.common.core.preferences.http.disablePreemptiveAuthentication`:
    The default value is false.

  * `http.ntlm.auth.kind`: This key specifies the type of authentication scheme
    used. The default value is NTLM. Definition of values:
      * `LM`:     `LANMANAGER` authentication is used.
      * `NTLM`:   `NTLM` version 1 authentication is used.
      * `NTLMv2`: `NTLM` versions 2 authentication is used.

  * `http.ntlm.auth.enableIntegrated.win32`: Needs documentation.

  * `com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts`: When this
    key is set to `true`, the files that are required to roll the package back
    to a previous version are stored on your computer. When this key is set to
    `false`, files that are required for a rollback or an update are not stored.
    If you do not store these files, you must connect to your original
    repository or media to roll back a package. When the preference is changed
    from `true` to `false`, the stored files are deleted the next time that you
    install, update, modify, roll back, or uninstall a package.

  * `com.ibm.cic.common.core.preferences.keepFetchedFiles`: When this key is set
    to `true`, if an error occurs during the installation or the update process,
    the files that are downloaded are not deleted. The next time you download
    these files, the time to download the files decreases because some of the
    files are downloaded already. When this key is set to `false`, files that
    are downloaded are deleted if an error occurs.

  * `PassportAdvantageIsEnabled`: The default value is false.

  * `com.ibm.cic.common.core.preferences.searchForUpdates`: When this key is set
    to `true`, a search for updates occurs first when you run a silent
    installation. The default value is `false`.

    When the key is set to `false` and the IBM product that you are installing
    requires a newer version of Installation Manager, a message shows when you
    run the silent installation. The message indicates that a later version of
    Installation Manager is required. The silent installation stops.

  * `com.ibm.cic.agent.ui.displayInternalVersion`: Needs documentation.

  * `com.ibm.cic.common.sharedUI.showErrorLog`: Needs documentation.

  * `com.ibm.cic.common.sharedUI.showWarningLog`: Needs documentation.

  * `com.ibm.cic.common.sharedUI.showNoteLog`: Needs documentation.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Application Client for WebSphere Application Server

The Application Client provides a variety of stand-alone thin clients, as embeddable JAR files, Java EE clients, ActiveX to EJB Bridge and Pluggable Application Client. These include:

* IBM Thin Client for Java API for XML-based Web Services (JAX-WS)
* IBM Thin Client for Java API for XML-based RPC (JAX-RPC)
* IBM Thin Client for Java Messaging Service (JMS)
* IBM Resource Adapter for JMS
* IBM Thin Client for JPA
* IBM Thin Client for EJB.

The namespace `[:websphere][:appclient]` is used for any specific Application
client attributes.

* `node[:websphere][:appclient][:id]`: [String] The Uniq IBM product ID for
  Application Client. Default value is `com.ibm.websphere.APPCLIENT.v85`.
  **Note:** You should not change this attribute.

* `node[:websphere][:appclient][:repositories]`: [Array, String] The location
  for a local online product repository. This can be a local copy on the
  machine, or on an internal web or NFS server. Information on how to create
  your own local online product repository can be found later in this document.
  Default is `nil`.

* `node[:websphere][:appclient][:modify]`: [TrueClass, FalseClass] Use the
  install and uninstall commands to inform Installation Manager of the
  installation packages to install or uninstall. A value of `false` indicates
  not to modify an existing install by adding or removing features. A `true`
  value indicates to modify an existing install by adding or removing features.
  The default value is `false`.

* `node[:websphere][:appclient][:version]`: [String] The version attribute is
  optional. If a version number is provided, then the offering will be installed
  or uninstalled at the version level specified as long as it is available in
  the repositories. If the version attribute is not provided, then the default
  behavior is to install or uninstall the latest version available in the
  repositories. The version number can be found in the repository.xml file in
  the repositories. This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier version.
  This roll back can happen if the version specified is earlier than the
  installed version or if a version is not specified. For example, you have
  version 1.0.2 of a package that is installed and the latest version of the
  package available in the repository is version 1.0.1. When you install the
  package, the installed version of the package is rolled back to version 1.0.1.

* `node[:websphere][:appclient][:profile]`: [String] The profile attribute is
  required and typically is unique to the offering. If modifying or updating an
  existing installation, the profile attribute must match the profile ID of the
  targeted installation of WebSphere Application Server. The default value is
  `Application Client for IBM WebSphere Application Server V8.5`.

* `node[:websphere][:appclient][:features]`: [String] The features attribute is
  optional. Offerings always have at least one feature; a required core feature
  which is installed regardless of whether it is explicitly specified. If other
  feature names are provided, then only those features will be installed.
  Features must be comma delimited without spaces. The default value is
  `javaee.thinclient.core.feature,javaruntime,developerkit,samples,` \
  `standalonethinclient.resourceadapter.runtime,embeddablecontainer`

  The optional feature offering IDs are enclosed:
  * IBM Developer Kit, Java 2 Technology Edition
  * Java 2 Runtime Environment `javaruntime`)
  * Developer Kit `developerkit`
  * Samples `samples`
  * Standalone Thin Clients, Resource Adapters, and Embeddable Containers
  * Standalone Thin Clients Runtime `standalonethinclient.resourceadapter.runtime`
  * Standalone Thin Clients Samples `standalonethinclient.resourceadapter.samples`
  * Embeddable EJB container `embeddablecontainer`

* `node[:websphere][:appclient][:fixes]`: [String] The fixes attribute is used
  to indicates whether fixes available in repositories are installed with the
  product. Valid values for `none`, do not install available fixes,
  `recommended`, installs all available recommended fixes, or `all`, install
   all available fixes. The default value is `all`.

* `node[:websphere][:appclient][:install_location]`: [String] The installation
  directory for Application Client. Default is `/opt/IBM/WebSphere/AppClient`.

Additionally the namespace `[:websphere][:appclient][:data]` is used at installation time, these key/value pairs correspond to the hash values created in the installation XML file.

  * `user.import.profile`: [TrueClass, FalseClass] Include data keys for product
    specific profile properties. Default is `false`.

  * `user.select.64bit.image,com.ibm.websphere.WCT.v85`: [String] The platform
    architecture, **note:** this cookbook only supports 64bit architecture.
    Default is 'x86_64'.

  * `user.appclient.serverHostname`: [String] Needs documentation. The default
    value is `localhost`.

  * `user.appclient.serverPort`: [Integer] Needs documentation. The default
    value is `2809`.

  * `cic.selector.nl`: [String] Specifies the language pack to be installed
    using ISO-639 language codes. The default value is `en`.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### IBM HTTP Server

The IBM HTTP Server is based on Apache HTTP Server 2.2.8, with additional
fixes. The Apache Web server can be built with many different capabilities and
configuration options. IBM HTTP Server includes a set of features from the
available options. The namespace `[:websphere][:ihs]` is used for any specific
HTTP server attributes.

* `node[:websphere][:ihs][:id]`: [String] The Uniq IBM product ID for
  HTTP Server. Default value is `com.ibm.websphere.IHS.v85`.
  **Note:** You should not change this attribute.

* `node[:websphere][:appclient][:repositories]`: [Array, String] The location
  for a local online product repository. This can be a local copy on the
  machine, or on an internal web or NFS server. Information on how to create
  your own local online product repository can be found later in this document.
  Default is `nil`.

* `node[:websphere][:ihs][:modify]`: [TrueClass, FalseClass] Use the
  install and uninstall commands to inform Installation Manager of the
  installation packages to install or uninstall. A value of `false` indicates
  not to modify an existing install by adding or removing features. A `true`
  value indicates to modify an existing install by adding or removing features.
  The default value is `false`.

* `node[:websphere][:ihs][:version]`: [String] The version attribute is
  optional. If a version number is provided, then the offering will be installed
  or uninstalled at the version level specified as long as it is available in
  the repositories. If the version attribute is not provided, then the default
  behavior is to install or uninstall the latest version available in the
  repositories. The version number can be found in the repository.xml file in
  the repositories. This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier version.
  This roll back can happen if the version specified is earlier than the
  installed version or if a version is not specified. For example, you have
  version 1.0.2 of a package that is installed and the latest version of the
  package available in the repository is version 1.0.1. When you install the
  package, the installed version of the package is rolled back to version 1.0.1.

* `node[:websphere][:ihs][:profile]`: [String] The profile attribute is
  required and typically is unique to the offering. If modifying or updating an
  existing installation, the profile attribute must match the profile ID of the
  targeted installation of WebSphere Application Server. The default value is
  `IBM HTTP Server V8.5`.

* `node[:websphere][:ihs][:features]`: [String] The features attribute is
  optional. Offerings always have at least one feature; a required core feature
  which is installed regardless of whether it is explicitly specified. If other
  feature names are provided, then only those features will be installed.
  Features must be comma delimited without spaces. The default value is
  `core.feature,arch.64bit`.

* `node[:websphere][:ihs][:fixes]`: [String] The fixes attribute is used
  to indicates whether fixes available in repositories are installed with the
  product. Valid values for `none`, do not install available fixes,
  `recommended`, installs all available recommended fixes, or `all`, install
   all available fixes. The default value is `all`.

* `node[:websphere][:ihs][:install_location]`: [String] The installation
  directory for HTTP Server. Default is `/opt/IBM/HTTPServer`.

Additionally the namespace `[:websphere][:ihs][:data]` is used at installation time, these key/value pairs correspond to the hash values created in the installation XML file.

  * `user.import.profile`: [TrueClass, FalseClass] Include data keys for product
    specific profile properties. Default is `false`.

  * `cic.selector.os`: [String] Specifies the operating system. Default value
    is `linux`.

  * `cic.selector.ws`: [String] Specifies the type of window system. The
    default value is `gtk`.

  * `cic.selector.arch`: [String] The platform architecture, **note:** this
    cookbook only supports 64bit architecture. The default value is 'x86_64'.

  * `user.ihs.httpPort`: [Integer] The HTTP port to bind to. Default is `80`.

  * `user.ihs.allowNonRootSilentInstall`: [TrueClass, FalseClass] This option
    indicates whether you accept the limitations associated with installing as
	  a non-root user. The following installation actions cannot be performed
	  with installing as a non-root or non-administrative user. Valid values for
	  `user.ihs.allowNonRootSilentInstall` are true, accepts the limitations.
	  Will install the product. If set to false, it indicates you do not accept
	  the limitations and the install will not occur. The default value is `true`.

  * `cic.selector.nl`: [String] Specifies the language pack to be installed
    using ISO-639 language codes. The default value is `en`.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#### IBM Installation Manager

The IBM Installation Manager (IIM) is a packaging technology that supports a wide range of IBM Software product installations.

* `node[:websphere][:iim][:id]`: [String] The Uniq IBM product ID for
  Installation Manager, default value is `com.ibm.cic.agent`.

* `node[:websphere][:iim][:repositories]`: [Array, String] Specify the 
  repositories that are used during the installation. Use a URL or UNC path to
  specify the remote repositories. Or use directory paths to specify the local
  repositories. The default value is `nil`.

* `node[:websphere][:iim][:modify]`: Use the install and uninstall commands to
  inform Installation Manager of the installation packages to install or
  uninstall. A value of `false` indicates not to modify an existing install by
  adding or removing features. A `true` value indicates to modify an existing
  install by adding or removing features. The default value is `false`.

* `node[:websphere][:iim][:version]`: The version attribute is optional. If a
  version number is provided, then the offering will be installed or uninstalled
  at the version level specified as long as it is available in the repositories.
  If the version attribute is not provided, then the default behavior is to
  install or uninstall the latest version available in the repositories. The
  version number can be found in the repository.xml file in the repositories.

  **Note:** In some cases, a package might be rolled back to an earlier version.
  This roll back can happen if the version specified is earlier than the
  installed version or if a version is not specified. For example, you have
  version 1.0.2 of a package that is installed and the latest version of the
  package available in the repository is version 1.0.1. When you install the
  package, the installed version of the package is rolled back to version 1.0.1.

* `node[:websphere][:iim][:profile]`: The profile attribute is required and
  typically is unique to the offering. If modifying or updating an existing
  installation, the profile attribute must match the profile ID of the targeted
  installation of WebSphere Application Server. The default value is `IBM
  Installation Manager`.

* `node[:websphere][:iim][:features]`: The features attribute is optional.
  Offerings always have at least one feature; a required core feature which is
  installed regardless of whether it is explicitly specified. If other feature
  names are provided, then only those features will be installed. Features must
  be comma delimited without spaces. The default value is
  `agent_core,agent_jre`.

* `node[:websphere][:iim][:fixes]`: The fixes attribute indicates whether fixes
  available in repositories are installed with the product. By default, all
  available fixes will be installed with the offering. Valid values for
  `node[:websphere][:iim][:fixes]` are:
    * `none`:        Do not install available fixes.
    * `recommended`: Installs all available recommended fixes.
    * `all`:         Installs all available fixes.

* `node[:websphere][:iim][:install_location]`: The installation directory for
  Application Client.
  **Note:** the installation will append `/IBM/InstallationManager/eclipse` to
  the specified directory, if you specify a value of `/app/im` the
  actual installation directory will be `/app/im/InstallationManager/eclipse`.
  Default is `/opt/IBM/InstallationManager/eclipse`.

* `node[:websphere][:iim][:install_type]`: [Symbol] Used to specify whether to
  install the Packaging Utility with Installation Manager, or to only install
  Installation Manager standalone. The Packaging Utility provides a toolset to
  manage and query installation repositories. The default value is
  `:with_pkgutil` installing the Packaging Utility alongside IIM. Valid values
  for `:install_type` are:
    * `:standalone`: Install the Packaging Utility with Installation Manager.
    * `:with_pkgutil`: Installs only Installation Manager.

    * `node[:websphere][:iim][:file][:standalone][:name]`: Zip file that
      contains the standalone IBM Installation Manager package. Default value
      is `agent.installer.linux.gtk.x86_64_1.8.0.20140902_1503.zip`

    * `node[:websphere][:iim][:file][:standalone][:source]`: Where the IIM zip
      file is located, can be any valid file path or URL, you can also use a
      URL shorter and the cookbook will expand it to the correct URL. Default
      value is `http://ibm.co/1zr8L6q`.

    * `node[:websphere][:iim][:file][:standalone][:checksum]`: The SHA-1
      checksum of the zip file.

    * `node[:websphere][:iim][:file][:with_pkgutil][:name]`: Zip file that
      contains the IBM Installation Manager and Packaging Utility. The default
      value is `agent.installer.linux.gtk.x86_64_1.8.0.20140902_1503.zip`

    * `node[:websphere][:iim][:file][:with_pkgutil][:source]`: Where the zip
      file is located, can be any valid file path or URL, you can also use
      a URL shorter and the cookbook will expand it to the correct URL. Default
      value is `http://ibm.co/1zr8L6q`.

    * `node[:websphere][:iim][:file][:with_pkgutil][:checksum]`: The SHA-1
      checksum of the zip file.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#### IBM Packaging Utility

You can use the IBM Packaging Utility to create custom or “enterprise” IBM 
Installation Manager repositories that contain multiple products and maintenance 
levels that fit your needs. You can control the content of your enterprise
repository, which then can serve as the central repository to which your
organization connects to perform product installations and updates.

IBM Packaging Utility essentially copies from a set of source IBM Installation 
Manager repositories to a target repository and eliminates duplicate artifacts, 
helping to keep the repository size as small as possible. You can also delete 
(or “prune”) a repository, removing maintenance levels or products that are no 
longer needed.

* `node[:websphere][:pkgutil][:id]`: [String] The Uniq IBM product ID for the
  IBM Packaging Utility. Default value is `com.ibm.cic.packagingUtility`.
  **Note:** You should not change this attribute.

* `node[:websphere][:pkgutil][:repositories]`: [Array, String] The location
  for a local online product repository. This can be a local copy on the
  machine, or on an internal web or NFS server. Information on how to create
  your own local online product repository can be found later in this document.
  Default is `nil`.

* `node[:websphere][:pkgutil][:modify]`: [TrueClass, FalseClass] Use the
  install and uninstall commands to inform Installation Manager of the
  installation packages to install or uninstall. A value of `false` indicates
  not to modify an existing install by adding or removing features. A `true`
  value indicates to modify an existing install by adding or removing features.
  The default value is `false`.

* `node[:websphere][:pkgutil][:version]`: [String] The version attribute is
  optional. If a version number is provided, then the offering will be installed
  or uninstalled at the version level specified as long as it is available in
  the repositories. If the version attribute is not provided, then the default
  behavior is to install or uninstall the latest version available in the
  repositories. The version number can be found in the repository.xml file in
  the repositories. This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier version.
  This roll back can happen if the version specified is earlier than the
  installed version or if a version is not specified. For example, you have
  version 1.0.2 of a package that is installed and the latest version of the
  package available in the repository is version 1.0.1. When you install the
  package, the installed version of the package is rolled back to version 1.0.1.

* `node[:websphere][:pkgutil][:profile]`: [String] The profile attribute is
  required and typically is unique to the offering. If modifying or updating an
  existing installation, the profile attribute must match the profile ID of the
  targeted installation of WebSphere Application Server. The default value is
  `IBM Packaging Utility`.

* `node[:websphere][:pkgutil][:features]`: [String] The features attribute is
  optional. Offerings always have at least one feature; a required core feature
  which is installed regardless of whether it is explicitly specified. If other
  feature names are provided, then only those features will be installed.
  Features must be comma delimited without spaces. The default value is
  `packaging_utility,jre`.

* `node[:websphere][:pkgutil][:fixes]`: [String] The fixes attribute is used
  to indicates whether fixes available in repositories are installed with the
  product. Valid values for `none`, do not install available fixes,
  `recommended`, installs all available recommended fixes, or `all`, install
   all available fixes. The default value is `all`.

* `node[:websphere][:pkgutil][:install_location]`: [String] The installation
  directory for Packaging Utility. Default is `/opt/IBM/PackagingUtility`.

Additionally the namespace `[:websphere][:pkgutil][:data]` is used at installation time, these key/value pairs correspond to the hash values created in the installation XML file.

  * `user.import.profile`: [TrueClass, FalseClass] Include data keys for product
    specific profile properties. Default is `false`.

  * `cic.selector.os`: [String] Specifies the operating system. Default value
    is `linux`.
  
  * `cic.selector.ws`: [String] Specifies the type of window system. The
    default value is `gtk`.
  
  * `cic.selector.arch`: [String] The platform architecture, **note:** this
    cookbook only supports 64bit architecture. The default value is 'x86_64'.
  
  * `cic.selector.nl`: [String] Specifies the language pack to be installed
    using ISO-639 language codes. The default value is `en`.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#### Web Server Plug-ins for WebSphere Application Server

The Web Server Plug-ins connect a IHS Web Server and a WebSphere application
Server. The primary responsibility of the plug-in is to forward requests to the
Application server.

* `node[:websphere][:plg][:id]`: [String] The Uniq IBM product ID for the
  Web Server Plug-ins for WebSphere Application Server. Default value is
  `com.ibm.websphere.PLG.v85`. **Note:** You should not change this attribute.

* `node[:websphere][:plg][:repositories]`: [Array, String] The location
  for a local online product repository. This can be a local copy on the
  machine, or on an internal web or NFS server. Information on how to create
  your own local online product repository can be found later in this document.
  Default is `nil`.

* `node[:websphere][:plg][:modify]`: [TrueClass, FalseClass] Use the
  install and uninstall commands to inform Installation Manager of the
  installation packages to install or uninstall. A value of `false` indicates
  not to modify an existing install by adding or removing features. A `true`
  value indicates to modify an existing install by adding or removing features.
  The default value is `false`.

* `node[:websphere][:plg][:version]`: [String] The version attribute is
  optional. If a version number is provided, then the offering will be installed
  or uninstalled at the version level specified as long as it is available in
  the repositories. If the version attribute is not provided, then the default
  behavior is to install or uninstall the latest version available in the
  repositories. The version number can be found in the repository.xml file in
  the repositories. This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier version.
  This roll back can happen if the version specified is earlier than the
  installed version or if a version is not specified. For example, you have
  version 1.0.2 of a package that is installed and the latest version of the
  package available in the repository is version 1.0.1. When you install the
  package, the installed version of the package is rolled back to version 1.0.1.

* `node[:websphere][:plg][:profile]`: [String] The profile attribute is
  required and typically is unique to the offering. If modifying or updating an
  existing installation, the profile attribute must match the profile ID of the
  targeted installation of WebSphere Application Server. The default value is
  `Web Server Plug-ins for IBM WebSphere Application Server V8.5`.

* `node[:websphere][:plg][:features]`: [String] The features attribute is
  optional. Offerings always have at least one feature; a required core feature
  which is installed regardless of whether it is explicitly specified. If other
  feature names are provided, then only those features will be installed.
  Features must be comma delimited without spaces. The default value is
  `core.feature,com.ibm.jre.6_64bit`.

* `node[:websphere][:plg][:fixes]`: [String] The fixes attribute is used
  to indicates whether fixes available in repositories are installed with the
  product. Valid values for `none`, do not install available fixes,
  `recommended`, installs all available recommended fixes, or `all`, install
   all available fixes. The default value is `all`.

* `node[:websphere][:plg][:install_location]`: [String] The installation
  directory for the Web Server Plugins. Default is `/opt/IBM/WebSphere/Plugins`.

Additionally the namespace `[:websphere][:plg][:data]` is used at installation time, these key/value pairs correspond to the hash values created in the installation XML file.

  * `user.import.profile`: [TrueClass, FalseClass] Include data keys for product
    specific profile properties. Default is `false`.

  * `cic.selector.nl`: [String] Specifies the language pack to be installed
    using ISO-639 language codes. The default value is `en`.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#### Pluggable Application Client for WebSphere Application Server

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#### IBM WebSphere Application Server Network Deployment

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#### WebSphere Customization Toolbox

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Providers

This cookbook includes LWRPs for managing:

* `Chef::Provider::Websphere`:
* `Chef::Provider::WebsphereCredentials`:
* `Chef::Provider::WebsphereRepository`:

### websphere

#### Syntax

#### Actions

#### Attribute Parameters

#### Examples

### websphere_credentials

#### Syntax

#### Actions

#### Attribute Parameters

#### Examples

### websphere_repository

#### Syntax

#### Actions

#### Attribute Parameters

#### Examples

## Testing

Ensure you have all the required prerequisite listed in the Development
Requirements section. You should have a working Vagrant installation with either VirtualBox or VMware installed. From the parent directory of this cookbook begin by running bundler to ensure you have all the required Gems:

    bundle install

A ruby environment with Bundler installed is a prerequisite for using the testing harness shipped with this cookbook. At the time of this writing, it works with Ruby 2.1.2 and Bundler 1.6.2. All programs involved, with the exception of Vagrant and VirtualBox, can be installed by cd'ing into the parent directory of this cookbook and running 'bundle install'.

#### Vagrant and VirtualBox

The installation of Vagrant and VirtualBox is extremely complex and involved. Please be prepared to spend some time at your computer:

If you have not yet installed Homebrew do so now:

    ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

Next install Homebrew Cask:

    brew tap phinze/homebrew-cask && brew install brew-cask

Then, to get Vagrant installed run this command:

    brew cask install vagrant

Finally install VirtualBox:

    brew cask install virtualbox

You will also need to get the Berkshelf and Omnibus plugins for Vagrant:

    vagrant plugin install vagrant-berkshelf
    vagrant plugin install vagrant-omnibus

Try doing that on Windows.

#### Rakefile

The Rakefile ships with a number of tasks, each of which can be ran individually, or in groups. Typing `rake` by itself will perform style checks with [Rubocop](https://github.com/bbatsov/rubocop) and [Foodcritic](http://www.foodcritic.io), [Chefspec](http://sethvargo.github.io/chefspec/) with rspec, and integration with [Test Kitchen](http://kitchen.ci) using the Vagrant driver by default. Alternatively, integration tests can be ran with Test Kitchen cloud drivers for EC2 are provided.

    $ rake -T
    rake all                         # Run all tasks
    rake chefspec                    # Run RSpec code examples
    rake doc                         # Build documentation
    rake foodcritic                  # Lint Chef cookbooks
    rake kitchen:all                 # Run all test instances
    rake kitchen:apps-dir-centos-65  # Run apps-dir-centos-65 test instance
    rake kitchen:default-centos-65   # Run default-centos-65 test instance
    rake kitchen:ihs-centos-65       # Run ihs-centos-65 test instance
    rake kitchen:was-centos-65       # Run was-centos-65 test instance
    rake kitchen:wps-centos-65       # Run wps-centos-65 test instance
    rake readme                      # Generate README.md from _README.md.erb
    rake rubocop                     # Run RuboCop
    rake rubocop:auto_correct        # Auto-correct RuboCop offenses
    rake test                        # Run all tests except `kitchen` / Run 
                                     # kitchen integration tests
    rake yard                        # Generate YARD Documentation

#### Style Testing

Ruby style tests can be performed by Rubocop by issuing either the bundled binary or with the Rake task:

    $ bundle exec rubocop
        or
    $ rake style:ruby

Chef style tests can be performed with Foodcritic by issuing either:

    $ bundle exec foodcritic
        or
    $ rake style:chef

### Testing

This cookbook uses Test Kitchen to verify functionality.

1. Install [ChefDK](http://downloads.getchef.com/chef-dk/)
2. Activate ChefDK's copy of ruby: `eval "$(chef shell-init bash)"`
3. `bundle install`
4. `bundle exec kitchen test kitchen:default-centos-65`

#### Spec Testing

Unit testing is done by running Rspec examples. Rspec will test any libraries, then test recipes using ChefSpec. This works by compiling a recipe (but not converging it), and allowing the user to make assertions about the resource_collection.

#### Integration Testing

Integration testing is performed by Test Kitchen. Test Kitchen will use either the Vagrant driver or EC2 cloud driver to instantiate machines and apply cookbooks. After a successful converge, tests are uploaded and ran out of band of Chef. Tests are be designed to
ensure that a recipe has accomplished its goal.

#### Integration Testing using Vagrant

Integration tests can be performed on a local workstation using Virtualbox or VMWare. Detailed instructions for setting this up can be found at the [Bento](https://github.com/opscode/bento) project web site. Integration tests using Vagrant can be performed with either:

    $ bundle exec kitchen test
        or
    $ rake integration:vagrant

#### Integration Testing using EC2 Cloud provider

Integration tests can be performed on an EC2 providers using Test Kitchen plugins. This cookbook references environmental variables present in the shell that `kitchen test` is ran from. These must contain authentication tokens for driving APIs, as well as the paths to ssh private keys needed for Test Kitchen log into them after they've been created.

Examples of environment variables being set in `~/.bash_profile`:

    # aws
    export AWS_ACCESS_KEY_ID='your_bits_here'
    export AWS_SECRET_ACCESS_KEY='your_bits_here'
    export AWS_KEYPAIR_NAME='your_bits_here'

Integration tests using cloud drivers can be performed with either

    $ bundle exec kitchen test
        or
    $ rake integration:cloud

### Guard

Guard tasks have been separated into the following groups:

- `doc`
- `lint`
- `unit`
- `integration`

By default, Guard will generate documentation, lint, and run unit tests.
The integration group must be selected manually with `guard -g integration`.

## Contributing

Please see the [CONTRIBUTING.md](CONTRIBUTING.md).

## License and Authors

Author:: Stefano Harding <sharding@trace3.com>

Copyright:: 2014, Stefano Harding

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

- - -

[Berkshelf]: http://berkshelf.com "Berkshelf"
[Chef]: https://www.getchef.com "Chef"
[ChefDK]: https://www.getchef.com/downloads/chef-dk "Chef Development Kit"
[Chef Documentation]: http://docs.opscode.com "Chef Documentation"
[ChefSpec]: http://chefspec.org "ChefSpec"
[Foodcritic]: http://foodcritic.io "Foodcritic"
[Learn Chef]: http://learn.getchef.com "Learn Chef"
[Test Kitchen]: http://kitchen.ci "Test Kitchen"
