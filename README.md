
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
* [os-hardening](https://supermarket.chef.io/cookbooks/os-hardening) - This
  cookbook provides numerous security-related configurations, providing all-
  round base protection. Require for local development only, for simulating a
  restricted production machine instance.
* [ssh-hardening](https://supermarket.chef.io/cookbooks/ssh-hardening) - This
  cookbook provides secure ssh-client and ssh-server configurations. Require for
  local development only, for simulating a restricted production machine
  instance.

#### Limitations

This cookbook primary goal is to automate the installation of WebSphere and
various sub-components, focusing on getting WebSphere onto the system and
running, not to deploy and configure applications within the Application Server
itself or to provide every available configurable option.

The focus of this cookbook is to provide you with a base system, not to provide
the ability to migrate configurations, or to add and/or remove components or
move the file system location of the installed components. i.e. you can not
install WebSphere in /opt then decide to move it to /apps.

Configuration and deployment of applications within the WebSphere Application
Server and Portal Server will be handled by Urban Code. Talk to your IBM
representative for additional information about Urban Code, or try a copy out
yourself at any of our Blue is You store locations.

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

## Usage ٩(͡๏̯͡๏)۶

The cookbook is designed to be attribute driven. If you wish to customize your installation the recommended method would be to create a role for you specific needs and override attributes as required within the role.

The cookbook contains five recipes, one for setting up the basic system, one for working with the repositories, and finally the remaining three are to install the various WebSphere components. These recipes can be installed individually together:

  * `websphere::ihs`: Installs the WebSphere HTTP Server.

  * `websphere::was`: Installs the WebSphere Application Server, Application
    Client for WebSphere Application Server, Web Server Plug-ins for WebSphere
    Application Server, and finally WebSphere Customization Toolbox.

  * `websphere::wps`: Installs the WebSphere Portal Server.

  * `websphere::pkgutil`: Installs the Packaging Utilities which are required to
    manipulate the IBM repositories, for example to update the local repository
    with the latest patches or to remove old product versions.

  * `websphere::install`: Installs the IBM Installation Manager. This is a
    required component which is automatically included into the run list.

## Attributes

Attributes are under several different namespaces, the `wpf` (WebSphere Family Products) namespace is where general attributes reside. Each sub-components or product will also have a uniq namespace, for example `ihs` for the HTTP server, `wps` for the WebSphere Portal Server, etc.

The following attributes affect the behavior of how the cookbook performs an installation, or are used in the recipes for various settings that require flexibility. Attributes have default values set, where possible or appropriate, the default values from IBM are used.

### General attributes:

General attributes can be found in the `default.rb` file, application specific
attributes are located in their respective attributes file.

* `node[:wpf][:base]`: [String] The base directory where all of the
  WebSphere products will reside. The default value is `/opt/IBM`.

* `node[:wpf][:eclipse_dir]`: [String] The path to the eclipse subdirectory
  where Installation Manager is installed.
  Default is `/opt/IBM/InstallationManager/eclipse/`.

* `node[:wpf][:data_dir]`: [String] The Agent Data Location directory contains
  the metadata that tracks the history and state of all product installations
  that the Installation Manager is managing. This directory is created when
  Installation Manager is itself installed.
  The default location is `/opt/IBM/DataLocation`.

  The Agent Data Location directory, which is sometimes referred to as the
  appDataLocation, is critical to the healthy functioning of the Installation
  Manager. After the directory is created, it cannot be moved. If the Agent Data
  Location directory becomes corrupt, all product installations that are tracked
  by the metadata in the Agent Data Location directory become unserviceable and
  need to be reinstalled if service is needed.

* `node[:wpf][:shared_dir]`: [String] Shared Resources Directory, this is used
  for two purposes:
  * It might be used to contain resources that can be shared by installed
    products at run time. WebSphere Application Server products do not have run
    time dependencies on the contents of this folder.
  * It might be used at installation time to stage the payload before it is
    installed into its target folder. In this scenario, filesum checks are
    performed on the transferred data to ensure that it is intact. By default,
    this content remains cached in the Shared Resources Directory after
    installation so that it can be used for future updates or rollback.
    The default location is `/opt/IBM/Shared`.

* `node[:wpf][:user]`: [String] The user to run WebSphere applications.
  The cookbook will create a system account for the user if it does not exist.
  The default is `wasadm`.

* `node[:wpf][:user][:group]`: [String] The group to run WebSphere
  applications. The cookbook will create a local group if it does not exist.
  The default is `wasadm`.

* `node[:wpf][:user][:comment]`: [String] The GECOS comment for the user.

* `node[:wpf][:user][:home]`: [String] The home directory attribute for the
  user. Uses the OS default of `/home/wasadm`.

* `node[:wpf][:user][:shell]`: [String] The Unix shell assigned to the user,
  the default is `/bin/bash`.

* `node[:wpf][:user][:system]`: [TrueClass, FalseClass] Create a system
  account. A system account is an user with an `UID` between `SYSTEM_UID_MIN`
  and `SYSTEM_UID_MAX` as  defined  in `/etc/login.defs`, if no `UID` is
  specified. Default is to use a system account.

* `node[:wpf][:user][:uid]`: [Integer] If `system` is set to false then
  you can select a `UserID` for the account. Default is nil and a system account
  is used.

* `node[:wpf][:user][:gid]`: [Integer] If `system` is set to false then
  you can select a `GroupID` for the account. Default is nil and a system
  account is used.

The cookbook supports using the IBM repository for installation, however this
requires a valid IBM Passport Advantage account or a valid account that has the
entitlements to install the software. Alternatively you can specify a locally
maintained repository that contains the software entitlements and use the remote
IBM repository to fetch the latest hot-fixes and patches. Or, should you so
chose, you can use only the local repository (recommended). Finally, the cookbook also supports installing from the IBM ZIP file disk images.

* `node[:wpf][:online_repo]`: [Array, String] Specify the location of the IBM
  live online product repository. This location is regularly updated with hot-
  patches, services packs and fixes. Default is to use the IBM web-based online
  repository. **Note:** You should not change this attribute.

* `node[:wpf][:local_repository]`: [Array, String] The location for a local
  online product repository. This can be a local copy on the machine, or on an
  internal web or NFS server but must contain a valid `repository.config`.
  Default is nil. NOTE: You will need to specify a local repository URL.

* `node[:wpf][:credential][:url]`: Repository to authenticate with, if
  you use the IBM service repositories, you can specify the
  `http://www.ibm.com/software/repositorymanager/entitled/repository.xml`
  value for the `url` attribute. This value is a generic service repository
  that can be used for IBM packages.

* `node[:wpf][:credential][:username]`: The user name to access the repository,
  to register for an IBM user name and password, go to:
  http://www.ibm.com/account/profile. **Note:** This attribute is optional
  and is only needed if you intend to access the live repositories.

* `node[:wpf][:credential][:password]`: The password to access the repository,
  to register for an IBM user name and password, go to:
  http://www.ibm.com/account/profile. This attribute is optional and is only
  needed if you intend to access the live repositories.

* `node[:wpf][:credential][:master_password_file]`: The location of the
  master password file Installation Manager should use to access the secure
  storage file, this attribute is optional.

* `node[:wpf][:credential][:secure_storage_file]`: The location of the
  secure storage file Installation Manager should use to access the secure
  storage file, this attribute is optional.

The following attributes relate to the package installation and the auto-
generated XML response files.

* `node[:wpf][:agent_input][:clean]`: The clean and temporary attributes
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

* `node[:wpf][:agent_input][:temporary]`: The default value is false. When
  `false`, the preferences that are set in your response file persist. When
  `true`, the preferences that are set in the response file do not persist.

  You can use temporary and clean together. For example, you set
  `node[:wpf][:agent_input][:clean] = true` and
  `node[:wpf][:agent_input][:temporary] = false`. After you run the silent
  installation, the repository setting that is specified in the response file
  overrides the preferences that were previously set.

* `node[:wpf][::preferences]`: A list of preferences that define the
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

The namespace `appclient` is used to distinguish the attributes as specific to
the Application Client.

* `node[:appclient][:id]`: [String] The Uniq IBM product ID for Application
  Client. Default value is `com.ibm.websphere.APPCLIENT.v85`. **Note:** You
  should not change this attribute.

* `node[:appclient][:repositories]`: [Array, String] The location for a local
  online product repository. This can be a local copy on the machine, or on an
  internal web or NFS server. Information on how to create your own local online
  product repository can be found later in this document. Default is `nil`.

* `node[:appclient][:modify]`: [TrueClass, FalseClass] Use the install and
  uninstall commands to inform Installation Manager of the installation packages
  to install or uninstall. A value of `false` indicates not to modify an
  existing install by adding or removing features. A `true` value indicates to
  modify an existing install by adding or removing features. The default value
  is `false`.

* `node[:appclient][:version]`: [String] The version attribute is optional. If
  a version number is provided, then the offering will be installed or
  uninstalled at the version level specified as long as it is available in the
  repositories. If the version attribute is not provided, then the default
  behavior is to install or uninstall the latest version available in the
  repositories. The version number can be found in the repository.xml file in
  the repositories. This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier version.
  This roll back can happen if the version specified is earlier than the
  installed version or if a version is not specified. For example, you have
  version 1.0.2 of a package that is installed and the latest version of the
  package available in the repository is version 1.0.1. When you install the
  package, the installed version of the package is rolled back to version 1.0.1.

* `node[:appclient][:profile]`: [String] The profile attribute is required and
  typically is unique to the offering. If modifying or updating an existing
  installation, the profile attribute must match the profile ID of the targeted
  installation of WebSphere Application Server. The default value is
  `Application Client for IBM WebSphere Application Server V8.5`.

* `node[:appclient][:features]`: [String] The features attribute is optional.
  Offerings always have at least one feature; a required core feature which is
  installed regardless of whether it is explicitly specified. If other feature
  names are provided, then only those features will be installed. Features must
  be comma delimited without spaces. The default value is
  `javaee.thinclient.core.feature,javaruntime,developerkit,samples,` \
  `standalonethinclient.resourceadapter.runtime,embeddablecontainer`

The optional feature offering IDs are enclosed:

* IBM Developer Kit, Java 2 Technology Edition
* Java 2 Runtime Environment      `javaruntime`
* Developer Kit                   `developerkit`
* Samples                         `samples`
* Standalone Thin Clients, Resource Adapters, and Embeddable Containers
* Standalone Thin Clients Runtime `standalonethinclient.resourceadapter.runtime`
* Standalone Thin Clients Samples `standalonethinclient.resourceadapter.samples`
* Embeddable EJB container        `embeddablecontainer`

* `node[:appclient][:fixes]`: [Symbol] The `installFixes` attribute
  indicates whether fixes available in repositories are installed with the
  product. By default, all available fixes will be installed with the offering.

    Valid values for `installFixes`:
    * `:none`        : Do not install available fixes.
    * `:recommended` : Installs all available recommended fixes.
    * `:all`         : Installs all available fixes.

* `node[:appclient][:dir]`: [String] The installation
  directory for Application Client. Default is `/opt/IBM/WebSphere/AppClient`.

Additionally the namespace `[:appclient][:data]` is used at installation time,
these key/value pairs correspond to the hash values created in the installation
XML file.

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

The IBM HTTP Server is based on Apache HTTP Server 2.2.8, with additional fixes.
The Apache Web server can be built with many different capabilities and configuration options. IBM HTTP Server includes a set of features from the available options. The namespace `[:ihs]` is used for any specific HTTP server attributes.

* `node[:ihs][:id]`: [String] The Uniq IBM product ID for HTTP Server. Default
  value is `com.ibm.websphere.IHS.v85`. **Note:** You should not change this
  attribute.

* `node[:appclient][:repositories]`: [Array, String] The location for a local
  online product repository. This can be a local copy on the machine, or on an
  internal web or NFS server. Information on how to create your own local online
  product repository can be found later in this document. Default is `nil`.

* `node[:ihs][:modify]`: [TrueClass, FalseClass] Use the install and uninstall
  commands to inform Installation Manager of the installation packages to
  install or uninstall. A value of `false` indicates not to modify an existing
  install by adding or removing features. A `true` value indicates to modify an
  existing install by adding or removing features. The default value is `false`.

* `node[:ihs][:version]`: [String] The version attribute is optional. If a
  version number is provided, then the offering will be installed or uninstalled
  at the version level specified as long as it is available in the repositories.
  If the version attribute is not provided, then the default behavior is to
  install or uninstall the latest version available in the repositories. The
  version number can be found in the repository.xml file in the repositories.
  This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier version.
  This roll back can happen if the version specified is earlier than the
  installed version or if a version is not specified. For example, you have
  version 1.0.2 of a package that is installed and the latest version of the
  package available in the repository is version 1.0.1. When you install the
  package, the installed version of the package is rolled back to version 1.0.1.

* `node[:ihs][:profile]`: [String] The profile attribute is required and
  typically is unique to the offering. If modifying or updating an existing
  installation, the profile attribute must match the profile ID of the targeted
  installation of WebSphere Application Server. The default value is
  `IBM HTTP Server V8.5`.

* `node[:ihs][:features]`: [String] The features attribute is optional.
  Offerings always have at least one feature; a required core feature which is
  installed regardless of whether it is explicitly specified. If other feature
  names are provided, then only those features will be installed. Features must
  be comma delimited without spaces.
  The default value is `core.feature,arch.64bit`.

* `node[:ihs][:fixes]`: [Symbol] The `installFixes` attribute indicates whether
  fixes available in repositories are installed with the product. By default,
  all available fixes will be installed with the offering.

  Valid values for `installFixes`:
  * `:none`        : Do not install available fixes.
  * `:recommended` : Installs all available recommended fixes.
  * `:all`         : Installs all available fixes.

* `node[:ihs][:dir]`: [String] The installation directory for HTTP Server.
  Default is `/opt/IBM/HTTPServer`.

Additionally the namespace `[:ihs][:data]` is used at installation time, these
key/value pairs correspond to the hash values created in the installation XML
file.

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
### IBM Installation Manager

The IBM Installation Manager (IIM) is a packaging technology that supports a
wide range of IBM Software product installations.

* `node[:iim][:id]`: [String] The Uniq IBM product ID for Installation Manager,
  default value is `com.ibm.cic.agent`.

* `node[:iim][:repositories]`: [Array, String] Specify the repositories that are
  used during the installation. Use a URL or UNC path to specify the remote
  repositories. Or use directory paths to specify the local repositories. The
  default value is `nil`.

* `node[:iim][:modify]`: Use the install and uninstall commands to inform
  Installation Manager of the installation packages to install or uninstall. A
  value of `false` indicates not to modify an existing install by adding or
  removing features. A `true` value indicates to modify an existing install by
  adding or removing features. The default value is `false`.

* `node[:iim][:version]`: The version attribute is optional. If a version number
  is provided, then the offering will be installed or uninstalled at the version
  level specified as long as it is available in the repositories. If the version
  attribute is not provided, then the default behavior is to install or
  uninstall the latest version available in the repositories. The version number
  can be found in the repository.xml file in the repositories.

  **Note:** In some cases, a package might be rolled back to an earlier version.
  This roll back can happen if the version specified is earlier than the
  installed version or if a version is not specified. For example, you have
  version 1.0.2 of a package that is installed and the latest version of the
  package available in the repository is version 1.0.1. When you install the
  package, the installed version of the package is rolled back to version 1.0.1.

* `node[:iim][:profile]`: The profile attribute is required and typically is
  unique to the offering. If modifying or updating an existing installation, the
  profile attribute must match the profile ID of the targeted installation of
  WebSphere Application Server. The default value is `IBM Installation Manager`.

* `node[:iim][:features]`: The features attribute is optional. Offerings always
  have at least one feature; a required core feature which is installed
  regardless of whether it is explicitly specified. If other feature names are
  provided, then only those features will be installed. Features must be comma
  delimited without spaces. The default value is `agent_core,agent_jre`.

* `node[:iim][:fixes]`: [Symbol] The `installFixes` attribute indicates whether
  fixes available in repositories are installed with the product. By default,
  all available fixes will be installed with the offering.

  Valid values for `installFixes`:
  * `:none`        : Do not install available fixes.
  * `:recommended` : Installs all available recommended fixes.
  * `:all`         : Installs all available fixes.

* `node[:iim][:dir]`: The installation directory for Installation Manager. The
  default is `/opt/IBM/InstallationManager`.

* `node[:iim][:install_from]`: [Symbol] Used to specify whether to install
  Packaging Utility with Installation Manager, or to only install Installation
  Manager standalone. The Packaging Utility provides a toolset to manage and
  query installation repositories. The default value is `:with_pkgutil`
  installing the Packaging Utility alongside IIM. Valid values for
  `:install_from` are:

    * `:standalone`:   Install the Packaging Utility with Installation Manager.
    * `:with_pkgutil`: Installs only Installation Manager.

    * `node[:iim][:file][:standalone][:name]`: Zip file that
      contains the standalone IBM Installation Manager package. Default value
      is `agent.installer.linux.gtk.x86_64_1.8.0.20140902_1503.zip`

    * `node[:iim][:file][:standalone][:source]`: Where the IIM zip
      file is located, can be any valid file path or URL, you can also use a
      URL shorter and the cookbook will expand it to the correct URL. Default
      value is `http://ibm.co/1zr8L6q`.

    * `node[:iim][:file][:standalone][:checksum]`: The SHA-1
      checksum of the zip file.

    * `node[:iim][:file][:with_pkgutil][:name]`: Zip file that
      contains the IBM Installation Manager and Packaging Utility. The default
      value is `agent.installer.linux.gtk.x86_64_1.8.0.20140902_1503.zip`

    * `node[:iim][:file][:with_pkgutil][:source]`: Where the zip
      file is located, can be any valid file path or URL, you can also use
      a URL shorter and the cookbook will expand it to the correct URL. Default
      value is `http://ibm.co/1zr8L6q`.

    * `node[:iim][:file][:with_pkgutil][:checksum]`: The SHA-1
      checksum of the zip file.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### IBM Packaging Utility

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

* `node[:pkgutil][:id]`: [String] The Uniq IBM product ID for the
  IBM Packaging Utility. Default value is `com.ibm.cic.packagingUtility`.
  **Note:** You should not change this attribute.

* `node[:pkgutil][:repositories]`: [Array, String] The location for a local
  online product repository. This can be a local copy on the machine, or on an
  internal web or NFS server. Information on how to create your own local online
  product repository can be found later in this document. Default is `nil`.

* `node[:pkgutil][:modify]`: [TrueClass, FalseClass] Use the install and
  uninstall commands to inform Installation Manager of the installation packages
  to install or uninstall. A value of `false` indicates not to modify an
  existing install by adding or removing features. A `true` value indicates to
  modify an existing install by adding or removing features. The default value
  is `false`.

* `node[:pkgutil][:version]`: [String] The version attribute is optional. If a
  version number is provided, then the offering will be installed or uninstalled
  at the version level specified as long as it is available in the repositories.
  If the version attribute is not provided, then the default behavior is to
  install or uninstall the latest version available in the repositories. The
  version number can be found in the repository.xml file in the repositories.
  This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier version.
  This roll back can happen if the version specified is earlier than the
  installed version or if a version is not specified. For example, you have
  version 1.0.2 of a package that is installed and the latest version of the
  package available in the repository is version 1.0.1. When you install the
  package, the installed version of the package is rolled back to version 1.0.1.

* `node[:pkgutil][:profile]`: [String] The profile attribute is required and
  typically is unique to the offering. If modifying or updating an existing
  installation, the profile attribute must match the profile ID of the targeted
  installation of WebSphere Application Server. The default value is
  `IBM Packaging Utility`.

* `node[:pkgutil][:features]`: [String] The features attribute is optional.
  Offerings always have at least one feature; a required core feature which is
  installed regardless of whether it is explicitly specified. If other feature
  names are provided, then only those features will be installed. Features must
  be comma delimited without spaces. The default value is
  `packaging_utility,jre`.

* `node[:pkgutil][:fixes]`: [Symbol] The `installFixes` attribute indicates
  whether fixes available in repositories are installed with the product. By
  default, all available fixes will be installed with the offering.

  Valid values for `installFixes`:
  * `:none`        : Do not install available fixes.
  * `:recommended` : Installs all available recommended fixes.
  * `:all`         : Installs all available fixes.

* `node[:pkgutil][:dir]`: [String] The installation directory for Packaging
  Utility. Default is `/opt/IBM/PackagingUtility`.

Additionally the namespace `[:pkgutil][:data]` is used at installation time,
these key/value pairs correspond to the hash values created in the installation
XML file.

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
### Web Server Plug-ins for WebSphere Application Server

The Web Server Plug-ins connect a IHS Web Server and a WebSphere application
Server. The primary responsibility of the plug-in is to forward requests to the
Application server.

* `node[:plg][:id]`: [String] The Uniq IBM product ID for the Web Server Plug-
  ins for WebSphere Application Server. Default value is
  `com.ibm.websphere.PLG.v85`. **Note:** You should not change this attribute.

* `node[:plg][:repositories]`: [Array, String] The location for a local online
  product repository. This can be a local copy on the machine, or on an internal
  web or NFS server. Information on how to create your own local online product
  repository can be found later in this document. Default is `nil`.

* `node[:plg][:modify]`: [TrueClass, FalseClass] Use the install and uninstall
  commands to inform Installation Manager of the installation packages to
  install or uninstall. A value of `false` indicates not to modify an existing
  install by adding or removing features. A `true` value indicates to modify an
  existing install by adding or removing features. The default value is `false`.

* `node[:plg][:version]`: [String] The version attribute is optional. If a
  version number is provided, then the offering will be installed or uninstalled
  at the version level specified as long as it is available in the repositories.
  If the version attribute is not provided, then the default behavior is to
  install or uninstall the latest version available in the repositories. The
  version number can be found in the repository.xml file in the repositories.
  This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier version.
  This roll back can happen if the version specified is earlier than the
  installed version or if a version is not specified. For example, you have
  version 1.0.2 of a package that is installed and the latest version of the
  package available in the repository is version 1.0.1. When you install the
  package, the installed version of the package is rolled back to version 1.0.1.

* `node[:plg][:profile]`: [String] The profile attribute is required and
  typically is unique to the offering. If modifying or updating an existing
  installation, the profile attribute must match the profile ID of the targeted
  installation of WebSphere Application Server. The default value is
  `Web Server Plug-ins for IBM WebSphere Application Server V8.5`.

* `node[:plg][:features]`: [String] The features attribute is optional.
  Offerings always have at least one feature; a required core feature which is
  installed regardless of whether it is explicitly specified. If other feature
  names are provided, then only those features will be installed. Features must
  be comma delimited without spaces. The default value is
  `core.feature,com.ibm.jre.6_64bit`.

* `node[:plg][:fixes]`: [Symbol] The `installFixes` attribute indicates
  whether fixes available in repositories are installed with the product. By
  default, all available fixes will be installed with the offering.

  Valid values for `installFixes`:
  * `:none`        : Do not install available fixes.
  * `:recommended` : Installs all available recommended fixes.
  * `:all`         : Installs all available fixes.

* `node[:plg][:dir]`: [String] The installation directory for the Web Server
  Plugins. Default is `/opt/IBM/WebSphere/Plugins`.

Additionally the namespace `[:plg][:data]` is used at installation time, these
key/value pairs correspond to the hash values created in the installation XML
file.

  * `user.import.profile`: [TrueClass, FalseClass] Include data keys for product
    specific profile properties. Default is `false`.

  * `cic.selector.nl`: [String] Specifies the language pack to be installed
    using ISO-639 language codes. The default value is `en`.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### IBM WebSphere Application Server Network Deployment

The IBM [WebSphere Application Server][] blah...



* `node[:was][:id]`: [String] The Uniq IBM product ID for WebSphere Application
  Server. Default value is `com.ibm.websphere.ND.v85`. **Note:** You should not change this attribute.

* `node[:was][:repositories]`: [Array, String] The location for a local online
  product repository. This can be a local copy on the machine, or on an internal
  web or NFS server. Information on how to create your own local online product
  repository can be found later in this document. Default is `nil`.

* `node[:was][:modify]`: [TrueClass, FalseClass] Use the install and uninstall
  commands to inform Installation Manager of the installation packages to
  install or uninstall. A value of `false` indicates not to modify an existing
  install by adding or removing features. A `true` value indicates to modify an
  existing install by adding or removing features. The default value is `false`.

* `node[:was][:version]`: [String] The version attribute is optional. If a
  version number is provided, then the offering will be installed or uninstalled
  at the version level specified as long as it is available in the repositories.
  If the version attribute is not provided, then the default behavior is to
  install or uninstall the latest version available in the repositories. The
  version number can be found in the repository.xml file in the repositories.
  This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier version.
  This roll back can happen if the version specified is earlier than the
  installed version or if a version is not specified. For example, you have
  version 1.0.2 of a package that is installed and the latest version of the
  package available in the repository is version 1.0.1. When you install the
  package, the installed version of the package is rolled back to version 1.0.1.

* `node[:was][:profile]`: [String] The profile attribute is required and
  typically is unique to the offering. If modifying or updating an existing
  installation, the profile attribute must match the profile ID of the targeted
  installation of WebSphere Application Server. The default value is
  `IBM WebSphere Application Server V8.5`.

* `node[:was][:features]`: [String] The features attribute is optional.
  Offerings always have at least one feature; a required core feature which is
  installed regardless of whether it is explicitly specified. If other feature
  names are provided, then only those features will be installed. Features must
  be comma delimited without spaces. The default value is `core.feature,` \
  `ejbdeploy,thinclient,embeddablecontainer,samples,com.ibm.sdk.6_64bit`.

* `node[:was][:fixes]`: [Symbol] The `installFixes` attribute indicates
  whether fixes available in repositories are installed with the product. By
  default, all available fixes will be installed with the offering.

  Valid values for `installFixes`:
  * `:none`        : Do not install available fixes.
  * `:recommended` : Installs all available recommended fixes.
  * `:all`         : Installs all available fixes.

* `node[:was][:dir]`: [String] The installation directory for the WebSphere
  Application Server. Default is `/opt/IBM/WebSphere/AppServer`.

Additionally the namespace `[:was][:data]` is used at installation time, these
key/value pairs correspond to the hash values created in the installation XML
file.

  * `user.import.profile`: [TrueClass, FalseClass] Include data keys for product
    specific profile properties. Default is `false`.

  * `cic.selector.os`: [String] Specifies the operating system. Default value
    is `linux`.

  * `cic.selector.ws`: [String] Specifies the type of window system. The
    default value is `gtk`.

  * `cic.selector.arch`: [String] The platform architecture, **note:** this
    cookbook only supports 64bit architecture. The default value is `x86_64`.

  * `cic.selector.nl`: [String] Specifies the language pack to be installed
    using ISO-639 language codes. The default value is `en`.

The following attributes apply to the runtime, effecting the operations and use of the WebSphere Application Server;

  * `node[:was][:cmt_log_home]`: [String] The log home property determines the
    directory that would hold log files produced by the `wasprofile` tool. The
    default path is: `<install location>/logs/manageprofiles`

  * `node[:was][:log_name_prefix]`: [String] The prefix for all `wasprofile` log
    file names.

  * `node[:was][:pmt_log_name_prefix]`: [String] The prefix for all ` pmt gui`
    log file names.

  * `node[:was][:profile_registry]`: [String] The profile registry property
    determines the path to the XML file that contains information about all
    registered profiles. The default path for this profile is:
    `<install location>/properties/profileRegistry.xml`

  * `node[:was][:log_level]`: [Integer] The log level determines the verbosity
    of log files produced by the `wasprofile` tool. The available range is from
    0 to 7. The default level is 3.

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


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### WebSphere Customization Toolbox    <`)))><

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Providers

This cookbook includes LWRPs for managing:

* `Chef::Provider::Websphere`:
* `Chef::Provider::WebsphereCredentials`:
* `Chef::Provider::WebsphereRepository`:





Please see the [TESTING.md](TESTING.md).

## Contributing

Please see the [CONTRIBUTING.md](CONTRIBUTING.md).

## License and Authors

Author:: Stefano Harding <sharding@trace3.com>

Copyright:: 2014-2015, Stefano Harding

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

```
            .oooO
            (   )   Oooo.
+------------\ (----(   )------------------------------------------------------+
              \_)    ) /                     CHEF, A HEALTHY COMPUTING DIVISION
                    (_/

```

[Berkshelf]: http://berkshelf.com "Berkshelf"
[Chef]: https://www.getchef.com "Chef"
[ChefDK]: https://www.getchef.com/downloads/chef-dk "Chef Development Kit"
[Chef Documentation]: http://docs.opscode.com "Chef Documentation"
[ChefSpec]: http://chefspec.org "ChefSpec"
[Foodcritic]: http://foodcritic.io "Foodcritic"
[Learn Chef]: http://learn.getchef.com "Learn Chef"
[Test Kitchen]: http://kitchen.ci "Test Kitchen"
[WebSphere Application Server]: http://www-01.ibm.com/support/knowledgecenter/#!/SSAW57_8.5.5/as_ditamaps/was855_welcome_ndmp.html "WebSphere Application Server"

