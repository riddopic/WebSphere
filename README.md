
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

## Quick Start Guide (YMMV, TLDR RTFM IMO)

This cookbook comes with a Kitchen file so that you can quickly provision a
machine locally, providing your system has been setup correctly with ChefDK, Vagrant, VirtualBox or VMware then simply `kitchen converge` an instance of your liking:

    $ kitchen list

      Instance            Driver   Provisioner  Last Action
      default-centos-6    Vagrant  ChefZero     <Not Created>
      repoman-centos-6    Vagrant  ChefZero     <Not Created>
      portal-centos-6     Vagrant  ChefZero     <Not Created>
      hardened-centos-6   Vagrant  ChefZero     <Not Created>

To launch a machine run the command `kitchen converge INSTANCE`. Replace the
name `INSTANCE` with the actual desired instance.

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
  cookbook provides secure ssh-client and ssh-server configurations. Require
  for local development only, for simulating a restricted production machine
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

The cookbook is designed to be attribute driven. If you wish to customize your
installation the recommended method would be to create a role for you specific
needs and override attributes as required within the role.

The cookbook contains five recipes, one for setting up the basic system, one
for working with the repositories, and finally the remaining three are to
install the various WebSphere components. These recipes can be installed
individually together:

  * `websphere::ihs`: Installs the WebSphere HTTP Server.

  * `websphere::was`: Installs the WebSphere Application Server, Application
    Client for WebSphere Application Server, Web Server Plug-ins for WebSphere
    Application Server, and finally WebSphere Customization Toolbox.

  * `websphere::wps`: Installs the WebSphere Portal Server.

  * `websphere::pkgutil`: Installs the Packaging Utilities which are required
    to manipulate the IBM repositories, for example to update the local
	repository with the latest patches or to remove old product versions.

  * `websphere::iim`: Installs the IBM Installation Manager. This is a
    required component which is automatically included into the run list.

## Attributes

Attributes are under several different namespaces, the `wpf` (WebSphere Family
Products) namespace is where general attributes reside. Each sub-components or
product will also have a uniq namespace, for example `ihs` for the HTTP
server, `wps` for the WebSphere Portal Server, etc.

The following attributes affect the behavior of how the cookbook performs an
installation, or are used in the recipes for various settings that require
flexibility. Attributes have default values set, where possible or
appropriate, the default values from IBM are used.

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
  Manager. After the directory is created, it cannot be moved. If the Agent
  Data Location directory becomes corrupt, all product installations that are
  tracked by the metadata in the Agent Data Location directory become
  unserviceable and need to be reinstalled if service is needed.

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
  you can select a `UserID` for the account. Default is nil and a system
  account is used.

* `node[:wpf][:user][:gid]`: [Integer] If `system` is set to false then
  you can select a `GroupID` for the account. Default is nil and a system
  account is used.

The cookbook supports using the IBM repository for installation, however this
requires a valid IBM Passport Advantage account or a valid account that has the
entitlements to install the software. Alternatively you can specify a locally
maintained repository that contains the software entitlements and use the
remote IBM repository to fetch the latest hot-fixes and patches. Or, should
you so chose, you can use only the local repository (recommended). Finally,
the cookbook also supports installing from the IBM ZIP file disk images.

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
  behavior during installation. These values are created as part of the
  response file.

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
    Change this key to false to disable the function. The default value is
	true.

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

  * `com.ibm.cic.common.core.preferences.preserveDownloadedArtifacts`: When
    this key is set to `true`, the files that are required to roll the package
	back to a previous version are stored on your computer. When this key is
	set to `false`, files that are required for a rollback or an update are
	not stored.
    If you do not store these files, you must connect to your original
    repository or media to roll back a package. When the preference is changed
    from `true` to `false`, the stored files are deleted the next time that you
    install, update, modify, roll back, or uninstall a package.

  * `com.ibm.cic.common.core.preferences.keepFetchedFiles`: When this key is
    set to `true`, if an error occurs during the installation or the update
	process, the files that are downloaded are not deleted. The next time you
	download these files, the time to download the files decreases because
	some of the files are downloaded already. When this key is set to `false`,
	files that are downloaded are deleted if an error occurs.

  * `PassportAdvantageIsEnabled`: The default value is false.

  * `com.ibm.cic.common.core.preferences.searchForUpdates`: When this key is
    set to `true`, a search for updates occurs first when you run a silent
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
### Application Client for WebSphere Application Server Attributes

The Application Client provides a variety of stand-alone thin clients, as
embeddable JAR files, Java EE clients, ActiveX to EJB Bridge and Pluggable
Application Client. These include:

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
  internal web or NFS server. Information on how to create your own local
  online product repository can be found later in this document. Default is
  `nil`.

* `node[:appclient][:modify]`: [TrueClass, FalseClass] Use the install and
  uninstall commands to inform Installation Manager of the installation
  packages to install or uninstall. A value of `false` indicates not to modify
  an existing install by adding or removing features. A `true` value indicates
  to modify an existing install by adding or removing features. The default
  value is `false`.

* `node[:appclient][:version]`: [String] The version attribute is optional. If
  a version number is provided, then the offering will be installed or
  uninstalled at the version level specified as long as it is available in the
  repositories. If the version attribute is not provided, then the default
  behavior is to install or uninstall the latest version available in the
  repositories. The version number can be found in the repository.xml file in
  the repositories. This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier
  version. This roll back can happen if the version specified is earlier than
   the installed version or if a version is not specified. For example, you
   have version 1.0.2 of a package that is installed and the latest version of
   the package available in the repository is version 1.0.1. When you install
   the package, the installed version of the package is rolled back to version
   1.0.1.

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

  * `user.import.profile`: [TrueClass, FalseClass] Include data keys for
    product specific profile properties. Default is `false`.

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
### IBM HTTP Server Attributes

The IBM HTTP Server is based on Apache HTTP Server 2.2.8, with additional
fixes. The Apache Web server can be built with many different capabilities and
configuration options. IBM HTTP Server includes a set of features from the
available options. The namespace `[:ihs]` is used for any specific HTTP server
attributes.

* `node[:ihs][:id]`: [String] The Uniq IBM product ID for HTTP Server. Default
  value is `com.ibm.websphere.IHS.v85`. **Note:** You should not change this
  attribute.

* `node[:appclient][:repositories]`: [Array, String] The location for a local
  online product repository. This can be a local copy on the machine, or on an
  internal web or NFS server. Information on how to create your own local
  online product repository can be found later in this document. Default is
  `nil`.

* `node[:ihs][:modify]`: [TrueClass, FalseClass] Use the install and uninstall
  commands to inform Installation Manager of the installation packages to
  install or uninstall. A value of `false` indicates not to modify an existing
  install by adding or removing features. A `true` value indicates to modify an
  existing install by adding or removing features. The default value is
  `false`.

* `node[:ihs][:version]`: [String] The version attribute is optional. If a
  version number is provided, then the offering will be installed or
  uninstalled at the version level specified as long as it is available in the
  repositories. If the version attribute is not provided, then the default
  behavior is to install or uninstall the latest version available in the
  repositories. The version number can be found in the repository.xml file in
  the repositories. This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier
  version. This roll back can happen if the version specified is earlier than
  the installed version or if a version is not specified. For example, you
  have version 1.0.2 of a package that is installed and the latest version of
  the package available in the repository is version 1.0.1. When you install
  the package, the installed version of the package is rolled back to version
  1.0.1.

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

  * `user.import.profile`: [TrueClass, FalseClass] Include data keys for
    product specific profile properties. Default is `false`.

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
    the limitations and the install will not occur. The default value is
	`true`.

  * `cic.selector.nl`: [String] Specifies the language pack to be installed
    using ISO-639 language codes. The default value is `en`.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### IBM Installation Manager Attributes

The IBM Installation Manager (IIM) is a packaging technology that supports a
wide range of IBM Software product installations.

* `node[:iim][:id]`: [String] The Uniq IBM product ID for Installation Manager,
  default value is `com.ibm.cic.agent`.

* `node[:iim][:repositories]`: [Array, String] Specify the repositories that
  are used during the installation. Use a URL or UNC path to specify the
  remote repositories. Or use directory paths to specify the local
  repositories. The default value is `nil`.

* `node[:iim][:modify]`: Use the install and uninstall commands to inform
  Installation Manager of the installation packages to install or uninstall. A
  value of `false` indicates not to modify an existing install by adding or
  removing features. A `true` value indicates to modify an existing install by
  adding or removing features. The default value is `false`.

* `node[:iim][:version]`: [String] The version attribute is optional. If a
  version number is provided, then the offering will be installed or
  uninstalled at the version level specified as long as it is available in the
  repositories. If the version attribute is not provided, then the default
  behavior is to install or uninstall the latest version available in the
  repositories. The version number can be found in the repository.xml file in
  the repositories. This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier
  version. This roll back can happen if the version specified is earlier than
  the installed version or if a version is not specified. For example, you
  have version 1.0.2 of a package that is installed and the latest version of
  the package available in the repository is version 1.0.1. When you install
  the package, the installed version of the package is rolled back to version
  1.0.1.

* `node[:iim][:profile]`: The profile attribute is required and typically is
  unique to the offering. If modifying or updating an existing installation,
  the profile attribute must match the profile ID of the targeted installation
  of WebSphere Application Server. The default value is `IBM Installation
  Manager`.

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
### IBM Packaging Utility Attributes

You can use the IBM Packaging Utility to create custom or “enterprise” IBM
Installation Manager repositories that contain multiple products and
maintenance levels that fit your needs. You can control the content of your
enterprise repository, which then can serve as the central repository to which
your organization connects to perform product installations and updates.

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
  internal web or NFS server. Information on how to create your own local
  online product repository can be found later in this document. Default is
  `nil`.

* `node[:pkgutil][:modify]`: [TrueClass, FalseClass] Use the install and
  uninstall commands to inform Installation Manager of the installation
  packages to install or uninstall. A value of `false` indicates not to modify
  an existing install by adding or removing features. A `true` value indicates
  to modify an existing install by adding or removing features. The default
  value is `false`.

* `node[:pkgutil][:version]`: [String] The version attribute is optional. If a
  version number is provided, then the offering will be installed or
  uninstalled at the version level specified as long as it is available in the
  repositories. If the version attribute is not provided, then the default
  behavior is to install or uninstall the latest version available in the
  repositories. The version number can be found in the repository.xml file in
  the repositories. This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier
  version. This roll back can happen if the version specified is earlier than
  the installed version or if a version is not specified. For example, you
  have version 1.0.2 of a package that is installed and the latest version of
  the package available in the repository is version 1.0.1. When you install
  the package, the installed version of the package is rolled back to version
  1.0.1.

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

  * `user.import.profile`: [TrueClass, FalseClass] Include data keys for
    product specific profile properties. Default is `false`.

  * `cic.selector.os`: [String] Specifies the operating system. Default value
    is `linux`.

  * `cic.selector.ws`: [String] Specifies the type of window system. The
    default value is `gtk`.

  * `cic.selector.arch`: [String] The platform architecture, **note:** this
    cookbook only supports 64bit architecture. The default value is 'x86_64'.

  * `cic.selector.nl`: [String] Specifies the language pack to be installed
    using ISO-639 language codes. The default value is `en`.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### Web Server Plug-ins for WebSphere Application Server Attributes

The Web Server Plug-ins connect a IHS Web Server and a WebSphere application
Server. The primary responsibility of the plug-in is to forward requests to the
Application server.

* `node[:plg][:id]`: [String] The Uniq IBM product ID for the Web Server Plug-
  ins for WebSphere Application Server. Default value is
  `com.ibm.websphere.PLG.v85`. **Note:** You should not change this attribute.

* `node[:plg][:repositories]`: [Array, String] The location for a local online
  product repository. This can be a local copy on the machine, or on an
  internal web or NFS server. Information on how to create your own local
  online product repository can be found later in this document. Default is
  `nil`.

* `node[:plg][:modify]`: [TrueClass, FalseClass] Use the install and uninstall
  commands to inform Installation Manager of the installation packages to
  install or uninstall. A value of `false` indicates not to modify an existing
  install by adding or removing features. A `true` value indicates to modify an
  existing install by adding or removing features. The default value is
  `false`.

* `node[:plg][:version]`: [String] The version attribute is optional. If a
  version number is provided, then the offering will be installed or
  uninstalled at the version level specified as long as it is available in the
  repositories. If the version attribute is not provided, then the default
  behavior is to install or uninstall the latest version available in the
  repositories. The version number can be found in the repository.xml file in
  the repositories. This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier
  version. This roll back can happen if the version specified is earlier than
  the installed version or if a version is not specified. For example, you
  have version 1.0.2 of a package that is installed and the latest version of
  the package available in the repository is version 1.0.1. When you install
  the package, the installed version of the package is rolled back to version
  1.0.1.

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

  * `user.import.profile`: [TrueClass, FalseClass] Include data keys for
    product specific profile properties. Default is `false`.

  * `cic.selector.nl`: [String] Specifies the language pack to be installed
    using ISO-639 language codes. The default value is `en`.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### IBM WebSphere Application Server Network Deployment Attributes

The IBM [WebSphere Application Server][] Network Deployment 8.5.5.

* `node[:was][:id]`: [String] The Uniq IBM product ID for WebSphere Application
  Server. Default value is `com.ibm.websphere.ND.v85`. **Note:** You should
  not change this attribute.

* `node[:was][:repositories]`: [Array, String] The location for a local online
  product repository. This can be a local copy on the machine, or on an
  internal web or NFS server. Information on how to create your own local
  online product repository can be found later in this document. Default is
  `nil`.

* `node[:was][:modify]`: [TrueClass, FalseClass] Use the install and uninstall
  commands to inform Installation Manager of the installation packages to
  install or uninstall. A value of `false` indicates not to modify an existing
  install by adding or removing features. A `true` value indicates to modify an
  existing install by adding or removing features. The default value is
  `false`.

* `node[:was][:version]`: [String] The version attribute is optional. If a
  version number is provided, then the offering will be installed or
  uninstalled at the version level specified as long as it is available in the
  repositories. If the version attribute is not provided, then the default
  behavior is to install or uninstall the latest version available in the
  repositories. The version number can be found in the repository.xml file in
  the repositories. This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier
  version. This roll back can happen if the version specified is earlier than
  the installed version or if a version is not specified. For example, you
  have version 1.0.2 of a package that is installed and the latest version of
  the package available in the repository is version 1.0.1. When you install
  the package, the installed version of the package is rolled back to version
  1.0.1.

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

  * `user.import.profile`: [TrueClass, FalseClass] Include data keys for
    product specific profile properties. Default is `false`.

  * `cic.selector.os`: [String] Specifies the operating system. Default value
    is `linux`.

  * `cic.selector.ws`: [String] Specifies the type of window system. The
    default value is `gtk`.

  * `cic.selector.arch`: [String] The platform architecture, **note:** this
    cookbook only supports 64bit architecture. The default value is `x86_64`.

  * `cic.selector.nl`: [String] Specifies the language pack to be installed
    using ISO-639 language codes. The default value is `en`.

The following attributes apply to the runtime, effecting the operations and
use of the WebSphere Application Server;

  * `node[:was][:cmt_log_home]`: [String] The log home property determines the
    directory that would hold log files produced by the `wasprofile` tool. The
    default path is: `<install location>/logs/manageprofiles`

  * `node[:was][:log_name_prefix]`: [String] The prefix for all `wasprofile`
    log file names. The default is `wasprofile`.

  * `node[:was][:pmt_log_name_prefix]`: [String] The prefix for all ` pmt gui`
    log file names. The default is `pmt`.

  * `node[:was][:profile_registry]`: [String] The profile registry property
    determines the path to the XML file that contains information about all
    registered profiles. The default path for this profile is:
    `<install location>/properties/profileRegistry.xml`

  * `node[:was][:log_level]`: [Integer] The log level determines the verbosity
    of log files produced by the `wasprofile` tool. The available range is from
    `0` to `7`. The default level is `3`.

  * `node[:was][:pmt_log_level]`: [Integer] The log level determines the
    verbosity of log files produced by the `pmt tool`. The available range is
    from `0` to `7`. The default log level is `3`.

  * `node[:was][:maskable_action_arguments]`: [Array] Any action arguments
    whose values should be masked from the logging for security reasons.

  * `node[:was][:maskable_action_arguments]`: [String] The default profile path
    property determines the default path for all profiles. The default path is
    `${was.install.root}/profiles`.

  * `node[:was][:native_file_jni_directory]`: [String] The location of the JNI
    libraries for NativeFile. The default is `${JAVA_NATIVE_LIB_DIR}`.

  * `node[:was][:listener_lock_retry_count]`: [Integer] Number of retries to
    obtain a lock on the IPC file used by the `wsadmin` listener process. The
    default is `240_000`.

  * `node[:was][:listener_initialization_lock_retry_count]`: [Integer] Number
    of retries used to determine if the `wsadmin` listener process has been
    initialized. The default is `12_000`.

  * `node[:was][:listener_shutdown_lock_retry_count]`: [Integer] Number of
    retries used to determine successful shutdown of the `wsadmin` listener
    process. The default is `12_000`.

  * `node[:was][:additional_command_line_arguments]`: [Array] Arguments that
    should be allowed through the strict command line validation. The default
    values are: `[debug, omitValidation, registry, omitAction, appendLogs]`.

  * `node[:was][:default_template_location]`: [String] The default location for
    searching for profile templates is `${was.install.root}/profileTemplates`.

  * `node[:was][:default_template_location]`: [String] The default template to
    use for profile creation, the default is aptly named `default`.

  * `node[:was][:cmt_pi_modperms]`: [TrueClass, FalseClass] Specify if the post
    installer should modify the permissions of any files it creates. Valid
    values are `true` or `false`. Any other value will default to `false`.
    Removing this property from the file will also have it default to `false`.
    When set to `false`, any files created by post installer will have
    permission based on the umask setting of the system. The default is `true`.

  * `node[:was][:cmt_pi_logs]`: [String, Integer] Specify if post installer
    should clean up its logs. This will cleanup logs for each product located
	in `PROFILE_HOME/properties/service/productDir`. One of the following
	cleanup criteria can be used/specified:

    * Specify the number of logs to keep from 0-999. EG. `WS_CMT_PI_LOGS=10`.

    * Specify the total size the logs should occupy from 0-999. For example:
      `WS_CMT_PI_LOGS=10MB` (KB = Kilobytes MB = Megabytes GB = Gigabytes)

    * Specify the amount of time to keep logs around from 0-999. For example:
      `WS_CMT_PI_LOGS=2W` (D = Days W = Weeks   M = Months Y = Years)

    * Specify a specific date after which a log older than the date will be
      deleted in a format of DD-MM-YYYY. For example: `05-10-2012` It must
        all numerics and be separated by dashes or it will be ignored.

    Note that only one criteria can be used at a time. If more than one is
    specified, the last value specified in this file will be used.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### WebSphere Customization Toolbox Attributes                       <`)))><

The WebSphere Customization Toolbox include tools for managing, configuring,
and migrating various parts of your WebSphere Application Server environment.

* `node[:wct][:id]`: [String] The Uniq IBM product ID for the Web Server Plug-
  ins for WebSphere Application Server. Default value is
  `com.ibm.websphere.WCT.v85`. **Note:** You should not change this attribute.

* `node[:wct][:repositories]`: [Array, String] The location for a local online
  product repository. This can be a local copy on the machine, or on an
  internal web or NFS server. Information on how to create your own local
  online product repository can be found later in this document. Default is
  `nil`.

* `node[:wct][:modify]`: [TrueClass, FalseClass] Use the install and uninstall
  commands to inform Installation Manager of the installation packages to
  install or uninstall. A value of `false` indicates not to modify an existing
  install by adding or removing features. A `true` value indicates to modify an
  existing install by adding or removing features. The default value is
  `false`.

* `node[:wct][:version]`: [String] The version attribute is optional. If a
  version number is provided, then the offering will be installed or
  uninstalled at the version level specified as long as it is available in the
  repositories. If the version attribute is not provided, then the default
  behavior is to install or uninstall the latest version available in the
  repositories. The version number can be found in the repository.xml file in
  the repositories. This attribute has no default value.

  **Note:** In some cases, a package might be rolled back to an earlier
  version. This roll back can happen if the version specified is earlier than
  the installed version or if a version is not specified. For example, you
  have version 1.0.2 of a package that is installed and the latest version of
  the package available in the repository is version 1.0.1. When you install
  the package, the installed version of the package is rolled back to version
  1.0.1.

* `node[:wct][:profile]`: [String] The profile attribute is required and
  typically is unique to the offering. If modifying or updating an existing
  installation, the profile attribute must match the profile ID of the targeted
  installation of WebSphere Customization Toolbox. The default value is
  `WebSphere Customization Toolbox V8.5`.

* `node[:wct][:features]`: [String] The features attribute is optional.
  Offerings always have at least one feature; a required core feature which is
  installed regardless of whether it is explicitly specified. If other feature
  names are provided, then only those features will be installed. Features must
  be comma delimited without spaces. The default value is
  `core.feature,pct,zmmt,zpmt`.

* `node[:wct][:fixes]`: [Symbol] The `installFixes` attribute indicates
  whether fixes available in repositories are installed with the product. By
  default, all available fixes will be installed with the offering.

  Valid values for `installFixes`:
  * `:none`        : Do not install available fixes.
  * `:recommended` : Installs all available recommended fixes.
  * `:all`         : Installs all available fixes.

* `node[:wct][:dir]`: [String] The installation directory for the WebSphere
  Customization Toolbox. Default is `/opt/IBM/WebSphere/Toolbox`.

Additionally the namespace `[:wct][:data]` is used at installation time, these
key/value pairs correspond to the hash values created in the installation XML
file.

  * `cic.selector.arch`: [String] The platform architecture, **note:** this
    cookbook only supports 64bit architecture. The default value is 'x86_64'.

## Providers

This cookbook includes HWRPs for managing:

  * `Chef::Provider::WebspherePackage`: The `websphere_package` resource
    handles the installation of the various WebSphere products and components,
	supporting a range of installation options from multiple sources.

  * `Chef::Provider::WebsphereProfile`: The `websphere_profile` resource is an
    idempotent provider what allows access to the WebSphere profile settings in
    a Chef centric way without requiring having to shell-out to bash.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### websphere_package

`websphere_package` is a Chef provider that you can use to install, update,
modify, roll back, and uninstall WebSphere packages on your systems. It is a
single provider that uses remote or local software repositories to install,
modify, or update certain IBM products. The program locates and shows available
packages, checks prerequisites and interdependencies, and installs or modifies
the selected packages. You also use `websphere_package` provider to uninstall
the packages that you installed using `websphere_package` provider.

#### Syntax

The syntax for using the `websphere_package` resource in a recipe is as
follows:

    websphere_package 'name' do
      attribute 'value' # see attributes section below
      ...
      action :action # see actions section below
    end

Where:

  * `websphere_package` tells the chef-client to use the
    `Chef::Provider::WebspherePackage` provider during the chef-client run;
  * `name` is the name of the resource block; when the `namespace` attribute is
    not specified as part of a recipe, `name` is also the Chef attribute
    `namespace` of the product to be installed/uninstalled;
  * `attribute` is zero (or more) of the attributes that are available for this
    resource;
  * `:action` identifies which steps the chef-client will take to bring the
    node into the desired state.

For example:

    websphere_package :ihs do
      install_fixes :none
      action :install
    end

#### Actions

  * `:install`: Default. Install the WebSphere product.
  * `:uninstall`: Use to uninstall a given WebSphere product.

#### Attribute Parameters

  * `namespace`: This is the only required attribute. The Chef attribute
    namespace that corresponds to where package specific settings are located.
    For example, the IBM HTTP Server namespace is `ihs`, this corresponds to
	the node attributes under `node[:ihs]`.

  * `id`: The uniq IBM product ID.

  * `version`: If a version number is provided, then the offering will be
    installed or uninstalled at the version level specified as long as it is
    available in the repositories. If the version attribute is not provided,
    then the default behavior is to install or uninstall the latest version
    available in the repositories. The version number can be found in the
    repository.xml file in the repositories.

  * `features`: Each WebSphere package offerings can have multiple features but
    always have at least one; a required core feature which is installed
    regardless of whether it is explicitly specified. If other feature names
	are provided, then only those features will be installed. Features must be
	comma delimited without spaces.

  * `profile`: The profile attribute is unique to the offering. If modifying or
    updating an existing installation, the profile attribute must match the
    profile ID of the targeted installation.

  * `id_ver`: The package ID and version number combined.

  * `install_from`: What type of media should the installation use, supported
    types are `repository` or `files`. When `files` is selected you must also
    include `install_files` attribute. The default is `repository`.

  * `dir`: The target installation directory.

  * `base_dir`: The path to the base directory where all of the WebSphere
    products will reside.

  * `eclipse_dir`: The path to the eclipse subdirectory where Installation
    Manager is installed.

  * `data_dir`: The path to the Agent Data Location directory which contains
    the metadata that tracks the history and state of all product installations
    that the Installation Manager is managing. The Agent Data Location
    directory, which is sometimes referred to as the appDataLocation, is
    critical to the healthy functioning of the Installation Manager. After the
    directory is created, it cannot be moved. If the Agent Data Location
    directory becomes corrupt, all product installations that are tracked by
    the metadata in the Agent Data Location directory become unserviceable and
    need to be reinstalled if service is needed.

  * `shared_dir`: Shared Resources Directory, this is used for two purposes:

    * It might be used to contain resources that can be shared by installed
      products at run time. WebSphere Application Server products do not have
      run time dependencies on the contents of this folder.

    * It might be used at installation time to stage the payload before it is
      installed into its target folder. In this scenario, filesum checks are
      performed on the transferred data to ensure that it is intact. By
	  default, this content remains cached in the Shared Resources Directory
	  after installation so that it can be used for future updates or rollback.

  * `passaport_advt`: If the PassportAdvantage repository is enabled.

  * `repositories`:  Specify repositories to be used, can be HTTP URL or file
    path but it must be a valid IBM repository containing entitlements, not
    required when `install_by` is set to `zipfile`.

  * `install_files`: A list of Hashes containing the name, source and checksums
    of the files to use in-place of a repository, not required when
    `install_from` is set to `:repository`.

  * `install_fixes`: indicates whether fixes available in repositories are
    installed with the product.

  * `master_passwd`: Defines the master password file to be used when
    connecting to remote IBM repositories or when using the Passport Advantage.

  * `secure_storage`: Defines the secure storage file to be used when
    connecting to remote IBM repositories or when using the Passport Advantage.

  * `preferences`: Specify a preference value or a comma-delimited list of
    preference values to be used.

  * `properties`: Properties needed for package installation.

  * `accept_license`: Indicate acceptance of the license agreement, because you
    actually have a choice, assimilate or be sued.

  * `owner`: A string or numeric ID that identifies the group owner by user
    name. If this value is not specified, existing owners will remain unchanged
    and new owner assignments will use the current user (when necessary).

  * `group`: A string or numeric ID that identifies the group owner by group
    name, if this value is not specified, existing groups will remain unchanged
    and new group assignments will use the default POSIX group (if available).

  * `admin`: Define the user as an admin, a nonAdmin or a group.

  * `verbose`: Show verbose progress from installation.

  * `response_file`: The path to the response file to execute. This file is
    auto generated by the provider and removed when the installation is
    completed.

#### Examples

The following examples demonstrate various approaches for using resources in
recipes. If you want to see examples of how Chef uses resources in recipes,
take a closer look at the cookbooks that Chef authors and maintains:
https://github.com/opscode-cookbooks.

##### Install from files

    websphere_package :was do
      install_fixes :none
      install_from  :files
      install_files [
        { name: 'offering.disk1.zip', source: '/tmp', checksum: c9af974d953e },
        { name: 'offering.disk2.zip', source: '/tmp', checksum: ac7e2d22883d },
        { name: 'offering.disk3.zip', source: '/tmp', checksum: f4b3d2cd01ea }
      ]
      action :install
    end

##### Install specifying an alternate repository and destination directory

    websphere_package :ihs do
      install_fixes :all
      repositories  'http://repo.mudbox.dev/ibm/repositorymanager'
      version       '8.5.5003.20140730_1249'
      dir           '/applications/IBM/IHS/v8.5.5'
      base_dir      '/applications/IBM'
      action :install
    end

##### Installing multiple applications with latest updates

    [:appclient, :plg, :was, :wct].each do |pkg|
      websphere_package pkg do
        install_fixes :all
        action :install
      end
    end

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
### websphere_profile

The `websphere_profile` resource/provider is used to create, delete, augment,
start and stop profiles, which define runtime environments. Using profiles
instead of multiple product installations saves disk space and simplifies
updating the product because a single set of core product files is maintained.

#### Syntax

The syntax for using the `websphere_profile` resource in a recipe is as
follows:

    websphere_profile 'name' do
      attribute 'value' # see attributes section below
      ...
      action :action # see actions section below
    end

Where:

  * `websphere_profile` tells the chef-client to use the
    `Chef::Provider::WebsphereProfile` provider during the chef-client run;
  * `name` is the name of the resource block; when the `profile_name` attribute
    is not specified as part of a recipe, `name` is also the  `profile_name`;
  * `attribute` is zero (or more) of the attributes that are available for this
    resource;
  * `:action` identifies which steps the chef-client will take to bring the
    node into the desired state.

For example:

    websphere_profile 'Dmgr01' do
      server_type   'DEPLOYMENT_MANAGER'
      profile_path  '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01'
      template_path '/opt/IBM/WebSphere/AppServer/profileTemplates/management'
      node_name     'Cell01Manager'
      cell_name     'Cell01Manager'
      host_name      node[:fqdn]
      action [:create, :start]
    end

#### Actions

  * `:create`: Default. Create a WebSphere Application Server profile.
  * `:delete`: Delete a WebSphere Application Server profile.
  * `:start`: Start a WebSphere Application Server profile.
  * `:stop`: Stop a WebSphere Application Server profile.

#### Attribute Parameters

  * `apply_perf_tuning_setting`: Specifies the performance-tuning setting that
    most closely matches the type of environment in which the application
    server will run. This parameter is only valid for the default profile
    template. Valid settings are:

    * `:standard`: the standard settings are the standard out-of-the-box
      default configuration settings that are optimized for general-purpose
      usage.

    * `:production`: the production performance settings are optimized for a
      production environment where application changes are rare and optimal
      runtime performance is important.

    * `:development`: the development settings are optimized for a development
      environment where frequent application updates are performed and system
      resources are at a minimum.

  * `:app_server_node_name`: Specifies the node name of the application server
    that you are federating into the cell. Specify this parameter when you
    create the deployment manager portion of the cell and when you create the
    application server portion of the cell.

  * `:cell_name`: Specifies the cell name of the profile. Use a unique cell
    name for each profile.

  * `default_port`: Assigns the default or base port values to the profile. Do
    not use this parameter when using the `starting_port` or `ports_file`
    parameter.

    During profile creation, the manageprofiles command uses an automatically
    generated set of recommended ports if you do not specify the
    `starting_port` parameter, the `default_ports` parameter or the
    `ports_file` parameter. The recommended port values can be different than
    the default port values based on the availability of the default ports.

    Do not use this parameter if you are using the managed profile template.

  * `dmgr_admin_password`: If you are federating a node, specify a valid user
    name for a deployment manager if administrative security is enabled on the
    deployment manager. Use this parameter with the `dmgr_admin_user_name`
    parameter and the `federate_later` parameter.

  * `dmgr_admin_username`: If you are federating a node, specify a valid
    password for a deployment manager if administrative security is enabled on
    the deployment manager. Use this parameter with the `dmgr_admin_username`
    parameter and the `federate_later` parameter.

  * `dmgr_host`: Identifies the machine where the deployment manager is
    running. Specify this parameter and the dmgrPort parameter to federate a
    custom profile as it is created. The host name can be the long or short DNS
    name or the IP address of the deployment manager machine.

    Specifying this optional parameter directs the manageprofiles command to
    attempt to federate the custom node into the deployment manager cell as it
    creates the custom profile with the managed `template_path` parameter. The
    `dmgr_host` parameter is ignored when creating a deployment manager profile
    or an Application Server profile.

    If you federate a custom node when the deployment manager is not running or
    is not available because of security being enabled or for other reasons,
    the installation indicator in the logs is `INSTCONFFAIL` to indicate a
    complete failure. The resulting custom profile is unusable. You must move
    the custom profile directory out of the profile repository (the profiles
    installation root directory) before creating another custom profile with
    the same profile name.

    If you have enabled security or changed the default JMX connector type, you
    cannot federate with the manageprofiles command. Use the `addNode` command
    instead.

  * `dmgr_port`: Identifies the SOAP port of the deployment manager. Specify
    this parameter and the `dmgrHost` parameter to federate a custom profile as
    it is created. The deployment manager must be running and accessible. If
    you have enabled security or changed the default Java Management Extensions
    (JMX) connector type, you cannot federate with the `manageprofiles`
    command. Use the `addNode` command instead.

    The default value for this parameter is `8879`. The port that you indicate
    must be a positive integer and a connection to the deployment manager must
    be available in conjunction with the `dmgrHost` parameter.

  * `dmgr_profile_path`: Specifies the profile path to the deployment manager
    portion of the cell. Specify this parameter when you create the application
    server portion of the cell.

  * `enable_admin_security`: Enables administrative security. The default value
    is false. When is set to true, you must also specify the parameters
    `admin_username` and `admin_password` along with the values for these
    parameters.

  * `enable_service`: Enables the creation of a Linux service. The default
    value is false. When set to true , the Linux service is created with the
    profile when the command is run by the root user. When a non-root user runs
    the `manageprofiles` command, the profile is created, but the Linux service
    is not. The Linux service is not created because the non-root user does not
    have sufficient permission to set up the service. An
    `INSTCONPARTIALSUCCESS` result is displayed at the end of the profile
    creation and the profile creation log
    `app_server_root/logs/manageprofiles_create_profilename.log` contains a
    message indicating the current user does not have sufficient permission to
    set up the Linux service.

  * `federate_later`: Indicates if the managed profile will be federated during
    profile creation or if you will federate it later using the addNode
    command. If the `dmgrHost`, `dmgrPort`, `dmgrAdminUserName` and
    `dmgrAdminPassword` parameters do not have values, the default value for
    this parameter is true. Valid values include true or false.

  * `host_name`: Specifies the host name where you are creating the profile.

  * `import_personal_cert_ks`: Specifies the path to the keystore file that you
    use to import a personal certificate when you create the profile. The
    personal certificate is the default personal certificate of the server.

    When you import a personal certificate as the default personal certificate,
    import the root certificate that signed the personal certificate.
	Otherwise, the `manageprofiles` command adds the public key of the
	personal certificate to the trust.p12 file and creates a root signing
	certificate.

    The `import_personal_cert_ks` parameter is mutually exclusive with the
    `personal_cert_db` parameter. If you do not specifically create or import a
    personal certificate, one is created by default.

  * `import_personal_cert_ks_alias`: Specifies the alias of the certificate
    that is in the keystore file that you specify on the
    `import_personal_cert_ks` parameter. The certificate is added to the server
    default keystore file and is used as the server default personal
    certificate.

  * `import_personal_cert_ks_password`: Specifies the password of the keystore
    file that you specify on the `import_personal_cert_ks` parameter.

  * `import_personal_cert_ks_type`: Specifies the type of the keystore file
    that you specify on the `import_personal_cert_ks` parameter. Values might
    be `JCEKS`, `CMSKS`, `PKCS12`, `PKCS11`, and `JKS`. However, this list can
    change based on the provider in the java.security file.

  * `import_signing_cert_ks`: Specifies the path to the keystore file that you
    use to import a root certificate when you create the profile. The root
    certificate is the certificate that you use as the server default root
    certificate. The `import_personal_cert_ks` parameter is mutually exclusive
    with the `signing_cert_dn` parameter. If you do not specifically create or
    import a root signing certificate, one is created by default.

  * `import_signing_cert_ks_alias`: Specifies the alias of the certificate that
    is in the keystore file that you specify on the `import_signing_cert_ks`
    parameter. The certificate is added to the server default root keystore and
    is used as the server default root certificate.

  * `import_signing_cert_ks_password`: Specifies the password of the keystore
    file that you specify on the `import_signing_cert_ks` parameter.

  * `import_signing_cert_ks_type`: Specifies the type of the keystore file that
    you specify on the `import_signing_cert_ks` parameter. Valid values might
    be `JCEKS`, `CMSKS`, `PKCS12`, `PKCS11`, and `JKS`. However, this list can
    change based on the provider in the java.security file.


  * `is_default`: Specifies that the profile identified by the accompanying
    `profile_name` parameter is to be the default profile once it is
    registered. When issuing commands that address the default profile, it is
    not necessary to use the `profile_name` attribute of the command.

  * `is_developer_server`: Specifies that the server is intended for
    development purposes only. This parameter is useful when creating profiles
    to test applications on a non-production server before deploying the
    applications on their production application servers. This parameter is
    valid only for the default profile template.

  * `key_store_password`: Specifies the password to use on all keystore files
    created during profile creation. Keystore files are created for the default
    personal certificate and the root signing certificate.

  * `node_name`: Specifies the node name for the node that is created with the
    new profile. Use a unique value on the machine. Each profile that shares
    the same set of product binaries must have a unique node name.

  * `personal_cert_dn`: Specifies the distinguished name of the personal
    certificate that you are creating when you create the profile. Specify the
    distinguished name in quotes. This default personal certificate is located
    in the server keystore file. The `import_personal_cert_ks_type` parameter
    is mutually exclusive with the `personal_cert_dn` parameter. See
    `personal_cert_validity_period` and `key_store_password` parameters.

  * `personal_cert_validity_period`: An optional parameter that specifies the
    amount of time in years that the default personal certificate is valid. If
    you do not specify this parameter with the `personal_cert_dn` parameter,
    the default personal certificate is valid for one year.

  * `ports_file`: An optional parameter that specifies the path to a file that
    defines port settings for the new profile. Do not use this parameter when
    using the `starting_port` or `default_ports` parameter. During profile
    creation, the manageprofiles command uses an automatically generated set of
    recommended ports if you do not specify the `starting_port` parameter, the
    `default_ports` parameter or the `ports_file` parameter. The recommended
    port values can be different than the default port values based on the
    availability of the default ports.

  * `profile_name`: Specifies the name of the profile. Use a unique value when
    creating a profile. Each profile that shares the same set of product
    binaries must have a unique name. The default profile name is based on the
    profile type and a trailing number.

  * `profile_path`: Specifies the fully qualified path to the profile, which is
    referred to as the profile_root. The default value is based on the
    `app_server_root` directory, the profiles subdirectory, and the name of the
    profile.

    For example, the default is: `WS_WSPROFILE_DEFAULT_PROFILE_HOME/profileName`

    The `WS_WSPROFILE_DEFAULT_PROFILE_HOME` element is defined in the
    `wasprofile.properties` file in the `app_server_root/properties` directory.

    The `wasprofile.properties` file includes the following properties:

    * `WS_CMT_PI_MODPERMS`: This property specifies if the post installer
	  should modify the permissions of any files it creates. Valid values are
	  true or false. Any other value defaults to false. Removing this property
	  from the file also causes it to default to false. When set to false, any
	  files created by the post installer have permission based on the umask
	  setting of the system.

      The value for this parameter must be a valid path for the target system
      and must not be currently in use. You must also have permissions to write
      to the directory.

    * `WS_CMT_PI_LOGS`: This property specifies if and when the post installer
      should clean up its logs for each product that is located in the
      `PROFILE_HOME/properties/service/productDir` directory. The settings for
      this property enable you to specify the following log cleanup criteria:

      * You can specify the number of logs you want to keep for each product in
        the `PROFILE_HOME/properties/service/productDir` directory. The
        specified value can be any integer between 1 and 999. For example, if
        you specify `WS_CMT_PI_LOGS=5`, the post installer keeps the five most
        recent logs for each product.

        You can specify the maximum amount of storage the logs can occupy. The
        specified value can be any integer between 1 and 999, followed by:

        * KB, if you are specifying the value in kilobytes.
        * MB, if you are specifying the value in megabytes.
        * GB, if you are specifying the value in gigabytes.

        For example, if you specify `WS_CMT_PI_LOGS=10MB`, when the amount of
        storage the logs occupy exceeds 10 megabytes, the post installer starts
        deleting the oldest logs.

      * You can specify the amount of time you want the post intaller to keep
        the logs. The specified value can be any integer between 1 and 999,
        followed by:

        * D, if you are specifying the value in days.
        * W, if you are specifying the value in weeks.
        * M, if you are specifying the value in months.
        * Y, if you are specifying the value in years.

        For example, if you specify `WS_CMT_PI_LOGS=2W`, each log is kept for
        two weeks.

      * You can specify a specific date after which a log is deleted. The value
        must be specified using numeric values, separated by dashes in the
        format `DD-MM-YYYY`. For example, `WS_CMT_PI_LOGS=12-31-2013` specifies
        that all of the logs are deleted on December31, 2013.

    * `reponse_file`: Accesses all API functions from the command line using
      the manageprofiles command. The command line interface can be driven by a
      response file that contains the input arguments for a given command in
      the properties file in key and value format. To determine which input
      arguments are required for the various types of profile templates and
      action, use the manageprofiles command with the -help parameter.

      Use the following example response file to run a create operation:

        `create`
        `profileName=testResponseFileCreate`
        `profilePath=profile_root`
        `templatePath=app_server_root/profileTemplates/default`
        `nodeName=myNodeName`
        `cellName=myCellName`
        `hostName=myHostName`
        `omitAction=myOptionalAction1,myOptionalAction2`

      When you create a response file, take into account the following set of
      guidelines:

      * When you specify values, do not specify double-quote (") characters at
        the beginning or end of a value, even if that value contains spaces.
        Note: This is a different than when you specify values on a command
        line.

      * When you specify a single value that contains a comma character, such
	    as the distinguished names for the `personalCertDN` and `signingCertDN`
        parameters, use a double-backslash before the comma character. For
        example, here is how to specify the `signingCertDN` value with a
        distinguished name:

          `signingCertDN=cn=testserver.ibm.com\\,ou=Root Certificate\\,`
          `ou=testCell\\,ou=testNode01\\,o=IBM\\,c=US`

      * When you specify multiple values, separate them with a comma character,
        and do not use double-backslashes. For example, here is how to specify
        multiple values for the omitAction parameter:

          `omitAction=deployAdminConsole,defaultAppDeployAndConfig`

      * Do not specify a blank line in a response file. This can cause an
	    error.

  * `server_name`: Specifies the name of the server. Specify this parameter
    only for the default and secureproxy templates. If you do not specify this
	parameter when using the default or secureproxy templates, the default
	server name is server1 for the default profile, and proxy1 for the secure
	proxy profile.

  * `server_type`: Specifies the type of management profile. Specify
    `ADMIN_AGENT` for an administrative agent server. This parameter is
	required when you create a management profile.

  * `service_user_name`: Specify the user ID that is used during the creation
    of the Linux service so that the Linux service runs from this user ID. The
    Linux service runs whenever the user ID is logged on.

  * `set_default_name`: Sets the default profile to one of the existing
    profiles. Must be used with the `profile_name` parameter.

  * `signing_cert_dn`: Specifies the distinguished name of the root signing
    certificate that you create when you create the profile. Specify the
    distinguished name in quotes. This default personal certificate is located
    in the server keystore file. The `import_signing_cert_ks` parameter is
    mutually exclusive with the `signing_cert_db` parameter. If you do not
    specifically create or import a root signing certificate, one is created by
    default. See the `signing_cert_validity_period` parameter and the
    `key_store_password`.

  * `signing_cert_validity_period`: An optional parameter that specifies the
    amount of time in years that the root signing certificate is valid. If you
    do not specify this parameter with the `signing_cert_dn` parameter, the
	root signing certificate is valid for 15 years.

  * `starting_port`: Specifies the starting port number for generating and
    assigning all ports for the profile. Port values are assigned sequentially
    from the `starting_port` value, omitting those ports that are already in
    use. The system recognizes and resolves ports that are currently in use and
    determines the port assignments to avoid port conflicts.

    During profile creation, the manageprofiles command uses an automatically
    generated set of recommended ports if you do not specify the
	`starting_port` parameter, the `default_ports` parameter or the
	`ports_file` parameter. The recommended port values can be different than
	the default port values based on the availability of the default ports.

    Do not use this parameter with the `default_ports` or `ports_file`
    parameters or if you are using the managed profile template.

  * `template_path`: Specifies the directory path to the template files in the
    installation root directory. Within the `profileTemplates` directory are
    various directories that correspond to different profile types and that
	vary with the type of product installed. The profile directories are the
	paths that you indicate while using the `template_path` option. You can
	specify profile templates that lie outside the installation root, if you
	happen to have any.

    You can specify a relative path for the `template_path` parameter if the
    profile templates are relative to the `app_server_root/profileTemplates`
    directory. Otherwise, specify the fully qualified template path.

  * `validate_ports`: Specifies the ports that should be validated to ensure
    they are not reserved or in use. This parameter helps you to identify ports
    that are not being used. If a port is determined to be in use, the profile
    creation stops and an error message displays. You can use this parameter at
    any time on the create command line. It is recommended that you use this
    parameter with the `ports_file` parameter.

  * `validate_registry`: Checks all of the profiles that are listed in the
    profile registry to see if the profiles are present on the file system.
    Returns a list of missing profiles.

  * `webserver_check`: Indicates if you want to set up web server definitions.
    The default value for this parameter is false.

  * `webserver_hostname`: The host name of the server. The default value for
    this parameter is the long host name of the local machine.

  * `webserver_install_path`: The installation path of the web server, local or
    remote. The default value for this parameter is dependent on the operating
    system of the local machine and the value of the webServerType parameter.
    For example:

      `webServerType=IHS`: webServerInstallPath defaulted to `/opt/IBM/HTTPServer`
      `webServerType=IIS`: webServerInstallPath defaulted to n\a
      `webServerType=SUNJAVASYSTEM`: webServerInstallPath defaults to `/opt/www`
      `webServerType=DOMINO`: webServerInstallPath defaulted to n/a
      `webServerType=APACHE`: webServerInstallPath defaulted to n/a
      `webServerType=HTTPSERVER_ZOS`: webServerInstallPath defaulted to n/a

  * `webserver_name`: The name of the web server.

  * `webserver_os`: The operating system from where the web server resides.
    Valid values include: windows, linux, solaris, aix, hpux, os390, and os400.
    Use this parameter with the webServerType parameter.

  * `webserver_plugin_path`: The path to the plug-ins that the web server uses.
    The default value for this parameter is `WAS_HOME/plugins`.

  * `webserver_port`: Indicates the port from where the web server will be
    accessed. The default value for this parameter is `80`.

  * `webserver_type`: The type of the web server. Valid values include: `IHS`,
    `SUNJAVASYSTEM`, `IIS`, `DOMINO`, `APACHE`, and `HTTPSERVER_ZOS`. Use this
    parameter with the webServerOS parameter.

  * `owner`: A string or ID that identifies the group owner by user name. If
    this value is not specified, existing owners will remain unchanged and new
    owner assignments will use the current user (when necessary).

  * `group`: A string or ID that identifies the group owner by group name, if
    this value is not specified, existing groups will remain unchanged and new
    group assignments will use the default POSIX group (if available).

#### Examples

The following examples demonstrate various approaches for using resources in
recipes. If you want to see examples of how Chef uses resources in recipes,
take a closer look at the cookbooks that Chef authors and maintains:
https://github.com/opscode-cookbooks.

##### A Profile

    websphere_profile 'Dmgr01' do
      enable_admin_security true
      server_type    'DEPLOYMENT_MANAGER'
      profile_path   '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01'
      template_path  '/opt/IBM/WebSphere/AppServer/profileTemplates/management'
      node_name      'Cell01Manager'
      cell_name      'Cell01Manager'
      host_name       node[:fqdn]
      admin_username 'wasadm'
      admin_password 'wasadm'
      action [:create, :start]
    end

    websphere_profile 'Cell01Node01' do
      enable_admin_security true
      profile_path    '/opt/IBM/WebSphere/AppServer/profiles/Cell01Node01'
      template_path   '/opt/IBM/WebSphere/AppServer/profileTemplates/managed'
      node_name       'Cell01Node01'
      host_name        node[:fqdn]
      admin_username  'wasadm'
      admin_password  'wasadm'
      dmgr_host        node[:fqdn]
      dmgr_admin_username 'wasadm'
      dmgr_admin_password 'wasadm'
      action [:create, :start]
    end

## Testing

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
+------------\ (----(   )-----------------------------------------------------+
              \_)    ) /                          A HEALTHY COMPUTING DIVISION
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
[Installation Manager]: http://www-01.ibm.com/support/knowledgecenter/#!/SSDV2W_1.8.1/com.ibm.cic.agent.ui.doc/helpindex_imic.html "Installation Manager"
