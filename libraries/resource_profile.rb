# encoding: UTF-8
#
# Cookbook Name:: websphere
# Resource:: websphere_profile
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

# A Chef resource for the WebSphere Profile
#
class Chef::Resource::WebsphereProfile < Chef::Resource
  include WebSphere

  # The module where Chef should look for providers for this resource
  #
  # @param [Module] arg
  #   the module containing providers for this resource
  # @return [Module]
  #   the module containing providers for this resource
  # @api private
  provider_base Chef::Provider::WebsphereProfile

  # The value of the identity attribute
  #
  # @return [String]
  #   the value of the identity attribute.
  # @api private
  identity_attr :profile_name

  # Maps a short_name (and optionally a platform and version) to a
  # Chef::Resource
  #
  # @param [Symbol] arg
  #   short_name of the resource
  # @return [Chef::Resource::WebsphereProfile]
  #   the class of the Chef::Resource based on the short name
  # @api private
  provides :websphere_profile, os: 'linux'

  # Set or return the list of `state attributes` implemented by the Resource,
  # these are attributes that describe the desired state of the system
  #
  # @return [Chef::Resource::WebsphereProfile]
  # @api private
  state_attrs :created

  # Adds actions to the list of valid actions for this resource
  #
  # @return [Chef::Provider::WebsphereProfile]
  # @api public
  actions :create, :delete, :start, :stop

  # Sets the default action
  #
  # @return [undefined]
  # @api private
  default_action :create

  # Boolean, when `true` the resource exists on the system, otherwise `false`
  #
  # @param [TrueClass, FalseClass]
  # @return [TrueClass, FalseClass]
  # @api public
  attribute :created,
            kind_of: [TrueClass, FalseClass]

  # Boolean, `true` when the resource is running, otherwise `false`
  #
  # @param [TrueClass, FalseClass]
  # @return [TrueClass, FalseClass]
  # @api public
  attribute :running,
            kind_of: [TrueClass, FalseClass]

  # Specify the password for the administrative security user ID specified
  # with the `admin_username` parameter
  #
  # @param [String] admin_password
  # @return [String]
  # @api public
  attribute :admin_password,
            kind_of: String

  # Specify the user ID that is used for administrative security
  #
  # @param [String] admin_username
  # @return [String]
  # @api public
  attribute :admin_username,
            kind_of: String

  # Specifies the performance-tuning setting that most closely matches the
  # type of environment in which the application server will run. This
  # parameter is only valid for the default profile template. Valid settings
  # are:
  #
  # * `:standard`: the standard settings are the standard out-of-the-box
  #   default configuration settings that are optimized for general-purpose
  #   usage.
  #
  # * `:production`: the production performance settings are optimized for a
  #   production environment where application changes are rare and optimal
  #   runtime performance is important.
  #
  # * `:development`: the development settings are optimized for a development
  #   environment where frequent application updates are performed and system
  #   resources are at a minimum.
  #
  # @param [Symbol] apply_perf_tuning_setting
  # @return [Symbol]
  # @api public
  attribute :apply_perf_tuning_setting,
            kind_of: Symbol,
            equal_to: [:standard, :production, :development],
            default: :standard

  # Specifies the node name of the application server that you are federating
  # into the cell. Specify this parameter when you create the deployment
  # manager portion of the cell and when you create the application server
  # portion of the cell.
  #
  # @param [Symbol] app_server_node_name
  # @return [Symbol]
  # @api public
  attribute :app_server_node_name,
            kind_of: Symbol

  # Specifies the cell name of the profile. Use a unique cell name for each
  # profile.
  #
  # @param [String] cell_name
  # @return [String]
  # @api public
  attribute :cell_name,
            kind_of: String

  # Assigns the default or base port values to the profile. Do not use this
  # parameter when using the `starting_port` or `ports_file` parameter.
  #
  # During profile creation, the manageprofiles command uses an automatically
  # generated set of recommended ports if you do not specify the `starting_port`
  # parameter, the `default_ports` parameter or the `ports_file` parameter. The
  # recommended port values can be different than the default port values based
  # on the availability of the default ports.
  #
  # @note: Do not use this parameter if you are using the managed profile
  # template.
  #
  # @param [Integer] default_port
  # @return [Integer]
  # @api public
  attribute :default_port,
            kind_of: Integer

  # If you are federating a node, specify a valid user name for a deployment
  # manager if administrative security is enabled on the deployment manager.
  # Use this parameter with the `dmgr_admin_user_name` parameter and the
  # `federate_later` parameter.
  #
  # @param [String] dmgr_admin_password
  # @return [String]
  # @api public
  attribute :dmgr_admin_password,
            kind_of: [String]

  # If you are federating a node, specify a valid password for a deployment
  # manager if administrative security is enabled on the deployment manager.
  # Use this parameter with the `dmgr_admin_username` parameter and the
  # `federate_later` parameter.
  #
  # @param [String] dmgr_admin_username
  # @return [String]
  # @api public
  attribute :dmgr_admin_username,
            kind_of: [String]

  # Identifies the machine where the deployment manager is running. Specify
  # this parameter and the dmgrPort parameter to federate a custom profile as
  # it is created. The host name can be the long or short DNS name or the IP
  # address of the deployment manager machine.
  #
  # Specifying this optional parameter directs the manageprofiles command to
  # attempt to federate the custom node into the deployment manager cell as it
  # creates the custom profile with the managed `template_path` parameter. The
  # `dmgr_host` parameter is ignored when creating a deployment manager profile
  # or an Application Server profile.
  #
  # If you federate a custom node when the deployment manager is not running or
  # is not available because of security being enabled or for other reasons,
  # the installation indicator in the logs is `INSTCONFFAIL` to indicate a
  # complete failure. The resulting custom profile is unusable. You must move
  # the custom profile directory out of the profile repository (the profiles
  # installation root directory) before creating another custom profile with
  # the same profile name.
  #
  # If you have enabled security or changed the default JMX connector type, you
  # cannot federate with the manageprofiles command. Use the `addNode` command
  # instead.
  #
  # @param [String] dmgr_host
  # @return [String]
  # @api public
  attribute :dmgr_host,
            kind_of: [String]

  # Identifies the SOAP port of the deployment manager. Specify this parameter
  # and the `dmgrHost` parameter to federate a custom profile as it is created.
  # The deployment manager must be running and accessible. If you have enabled
  # security or changed the default Java Management Extensions (JMX) connector
  # type, you cannot federate with the `manageprofiles` command. Use the
  # `addNode` command instead.
  #
  # The default value for this parameter is `8879`. The port that you indicate
  # must be a positive integer and a connection to the deployment manager must
  # be available in conjunction with the `dmgrHost` parameter.
  #
  # @param [String] dmgr_port
  # @return [String]
  # @api public
  attribute :dmgr_port,
            kind_of: [String]

  # Specifies the profile path to the deployment manager portion of the cell.
  # Specify this parameter when you create the application server portion of
  # the cell.
  #
  # @param [String] dmgr_profile_path
  # @return [String]
  # @api public
  attribute :dmgr_profile_path,
            kind_of: [String]

  # Enables administrative security. The default value is false. When is set to
  # true, you must also specify the parameters `admin_username` and
  # `admin_password` along with the values for these parameters.
  #
  # @param [TrueClass, FalseClass] enable_admin_security
  # @return [TrueClass, FalseClass]
  # @api public
  attribute :enable_admin_security,
            kind_of: [TrueClass, FalseClass]

  # Enables the creation of a Linux service. The default value is false. When
  # set to true , the Linux service is created with the profile when the command
  # is run by the root user. When a non-root user runs the `manageprofiles`
  # command, the profile is created, but the Linux service is not. The Linux
  # service is not created because the non-root user does not have sufficient
  # permission to set up the service. An `INSTCONPARTIALSUCCESS` result is
  # displayed at the end of the profile creation and the profile creation log
  # `app_server_root/logs/manageprofiles_create_profilename.log` contains a
  # message indicating the current user does not have sufficient permission to
  # set up the Linux service.
  #
  # @param [TrueClass, FalseClass] enable_service
  # @return [TrueClass, FalseClass]
  # @api public
  attribute :enable_service,
            kind_of: [TrueClass, FalseClass]

  # Indicates if the managed profile will be federated during profile creation
  # or if you will federate it later using the addNode command. If the
  # `dmgrHost`, `dmgrPort`, `dmgrAdminUserName` and `dmgrAdminPassword`
  # parameters do not have values, the default value for this parameter is
  # true. Valid values include true or false.
  #
  # @param [TrueClass, FalseClass] federate_later
  # @return [TrueClass, FalseClass]
  # @api public
  attribute :enable_service,
            kind_of: [TrueClass, FalseClass]

  # Specifies the host name where you are creating the profile.
  #
  # @param [String] host_name
  # @return [String]
  # @api public
  attribute :host_name,
            kind_of: String

  # Specifies the path to the keystore file that you use to import a personal
  # certificate when you create the profile. The personal certificate is the
  # default personal certificate of the server.
  #
  # When you import a personal certificate as the default personal certificate,
  # import the root certificate that signed the personal certificate. Otherwise,
  # the manageprofiles command adds the public key of the personal certificate
  # to the trust.p12 file and creates a root signing certificate.
  #
  # The `import_personal_cert_ks` parameter is mutually exclusive with the
  # `personal_cert_db` parameter. If you do not specifically create or import a
  # personal certificate, one is created by default.
  #
  # @param [String] import_personal_cert_ks
  # @return [String]
  # @api public
  attribute :import_personal_cert_ks,
            kind_of: String

  # Specifies the alias of the certificate that is in the keystore file that you
  # specify on the `import_personal_cert_ks` parameter. The certificate is added
  # to the server default keystore file and is used as the server default
  # personal certificate.
  #
  # @param [String] import_personal_cert_ks_alias
  # @return [String]
  # @api public
  attribute :import_personal_cert_ks_alias,
            kind_of: String

  # Specifies the password of the keystore file that you specify on the
  # `import_personal_cert_ks` parameter.
  #
  # @param [String] import_personal_cert_ks_password
  # @return [String]
  # @api public
  attribute :import_personal_cert_ks_password,
            kind_of: String

  # Specifies the type of the keystore file that you specify on the
  # `import_personal_cert_ks` parameter. Values might be `JCEKS`, `CMSKS`,
  # `PKCS12`, `PKCS11`, and `JKS`. However, this list can change based on the
  # provider in the java.security file.
  #
  # @param [String] import_personal_cert_ks_type
  # @return [String]
  # @api public
  attribute :import_personal_cert_ks_type,
            kind_of: String

  # Specifies the path to the keystore file that you use to import a root
  # certificate when you create the profile. The root certificate is the
  # certificate that you use as the server default root certificate. The
  # `import_personal_cert_ks` parameter is mutually exclusive with the
  # `signing_cert_dn` parameter. If you do not specifically create or import a
  # root signing certificate, one is created by default.
  #
  # @param [String] import_signing_cert_ks
  # @return [String]
  # @api public
  attribute :import_signing_cert_ks,
            kind_of: String

  # Specifies the alias of the certificate that is in the keystore file that you
  # specify on the `import_signing_cert_ks` parameter. The certificate is added
  # to the server default root keystore and is used as the server default root
  # certificate.
  #
  # @param [String] import_signing_cert_ks_alias
  # @return [String]
  # @api public
  attribute :import_signing_cert_ks_alias,
            kind_of: String

  # Specifies the password of the keystore file that you specify on the
  # `import_signing_cert_ks` parameter.
  #
  # @param [String] import_signing_cert_ks_password
  # @return [String]
  # @api public
  attribute :import_signing_cert_ks_password,
            kind_of: String

  # Specifies the type of the keystore file that you specify on the
  # `import_signing_cert_ks` parameter. Valid values might be `JCEKS`, `CMSKS`,
  # `PKCS12`, `PKCS11`, and `JKS`. However, this list can change based on the
  # provider in the java.security file.
  #
  # @param [String] import_signing_cert_ks_type
  # @return [String]
  # @api public
  attribute :import_signing_cert_ks_type,
            kind_of: String

  # Specifies that the profile identified by the accompanying `profile_name`
  # parameter is to be the default profile once it is registered. When issuing
  # commands that address the default profile, it is not necessary to use the
  # `profile_name` attribute of the command.
  #
  # @param [TrueClass, FalseClass]
  # @return [TrueClass, FalseClass]
  # @api public
  attribute :is_default,
            kind_of: [TrueClass, FalseClass]

  # Specifies that the server is intended for development purposes only. This
  # parameter is useful when creating profiles to test applications on a
  # nonproduction server before deploying the applications on their production
  # application servers. This parameter is valid only for the default profile
  # template.
  #
  # @param [TrueClass, FalseClass]
  # @return [TrueClass, FalseClass]
  # @api public
  attribute :is_developer_server,
            kind_of: [TrueClass, FalseClass]

  # Specifies the password to use on all keystore files created during profile
  # creation. Keystore files are created for the default personal certificate
  # and the root signing certificate.
  #
  # @param [String] key_store_password
  # @return [String]
  # @api public
  attribute :key_store_password,
            kind_of: String

  # Specifies the node name for the node that is created with the new profile.
  # Use a unique value on the machine. Each profile that shares the same set of
  # product binaries must have a unique node name.
  #
  # @param [String] node_name
  # @return [String]
  # @api public
  attribute :node_name,
            kind_of: String

  # Specifies the distinguished name of the personal certificate that you are
  # creating when you create the profile. Specify the distinguished name in
  # quotes. This default personal certificate is located in the server keystore
  # file. The `import_personal_cert_ks_type` parameter is mutually exclusive
  # with the `personal_cert_dn` parameter. See `personal_cert_validity_period`
  # and `key_store_password` parameters.
  #
  # @param [String] personal_cert_dn
  # @return [String]
  # @api public
  attribute :personal_cert_dn,
            kind_of: String

  # An optional parameter that specifies the amount of time in years that the
  # default personal certificate is valid. If you do not specify this parameter
  # with the `personal_cert_dn` parameter, the default personal certificate is
  # valid for one year.
  #
  # @param [Integer] personal_cert_validity_period
  # @return [Integer]
  # @api public
  attribute :personal_cert_validity_period,
            kind_of: Integer

  # An optional parameter that specifies the path to a file that defines port
  # settings for the new profile. Do not use this parameter when using the
  # `starting_port` or `default_ports` parameter. During profile creation, the
  # manageprofiles command uses an automatically generated set of recommended
  # ports if you do not specify the `starting_port` parameter, the
  # `default_ports` parameter or the `ports_file` parameter. The recommended
  # port values can be different than the default port values based on the
  # availability of the default ports.
  #
  # @param [String] ports_file
  # @return [String]
  # @api public
  attribute :ports_file,
            kind_of: String

  # Specifies the name of the profile. Use a unique value when creating a
  # profile. Each profile that shares the same set of product binaries must have
  # a unique name. The default profile name is based on the profile type and a
  # trailing number.
  #
  # @param [String] profile_name
  # @return [String]
  # @api public
  attribute :profile_name,
            kind_of: String,
            name_attribute: true

  # Specifies the fully qualified path to the profile, which is referred to as
  # the profile_root. The default value is based on the app_server_root
  # directory, the profiles subdirectory, and the name of the profile.
  #
  # For example, the default is: `WS_WSPROFILE_DEFAULT_PROFILE_HOME/profileName`
  #
  # The `WS_WSPROFILE_DEFAULT_PROFILE_HOME` element is defined in the
  # `wasprofile.properties` file in the `app_server_root/properties` directory.
  #
  # @note The `wasprofile.properties` file includes the following properties:
  #
  # * `WS_CMT_PI_MODPERMS`: This property specifies if the post installer should
  #   modify the permissions of any files it creates. Valid values are true or
  #   false. Any other value defaults to false. Removing this property from the
  #   file also causes it to default to false. When set to false, any files
  #   created by the post installer have permission based on the umask setting
  #   of the system.
  #
  #   The value for this parameter must be a valid path for the target system
  #   and must not be currently in use. You must also have permissions to write
  #   to the directory.
  #
  # * `WS_CMT_PI_LOGS`: This property specifies if and when the post installer
  #   should clean up its logs for each product that is located in the
  #   `PROFILE_HOME/properties/service/productDir` directory. The settings for
  #   this property enable you to specify the following log cleanup criteria:
  #
  #   * You can specify the number of logs you want to keep for each product in
  #     the `PROFILE_HOME/properties/service/productDir` directory. The
  #     specified value can be any integer between 1 and 999. For example, if
  #     you specify `WS_CMT_PI_LOGS=5`, the post installer keeps the five most
  #     recent logs for each product.
  #
  #     You can specify the maximum amount of storage the logs can occupy. The
  #     specified value can be any integer between 1 and 999, followed by:
  #
  #     * KB, if you are specifying the value in kilobytes.
  #     * MB, if you are specifying the value in megabytes.
  #     * GB, if you are specifying the value in gigabytes.
  #
  #     For example, if you specify `WS_CMT_PI_LOGS=10MB`, when the amount of
  #     storage the logs occupy exceeds 10 megabytes, the post installer starts
  #     deleting the oldest logs.
  #
  #   * You can specify the amount of time you want the post intaller to keep
  #     the logs. The specified value can be any integer between 1 and 999,
  #     followed by:
  #
  #     * D, if you are specifying the value in days.
  #     * W, if you are specifying the value inweeks.
  #     * M, if you are specifying the value in months.
  #     * Y, if you are specifying the value in years.
  #
  #     For example, if you specify `WS_CMT_PI_LOGS=2W`, each log is kept for
  #     two weeks.
  #
  #   * You can specify a specific date after which a log is deleted. The value
  #     must be specified using numeric values, separated by dashes in the
  #     format `DD-MM-YYYY`. For example, `WS_CMT_PI_LOGS=12-31-2013` specifies
  #     that all of the logs are deleted on December31, 2013.
  #
  # @param [String] profile_path
  # @return [String]
  # @api public
  attribute :profile_path,
            kind_of: String,
    default: lazy { ::File.join(lazy_evel(node[:was][:dir]), 'profiles', profile_name) }

  # Accesses all API functions from the command line using the manageprofiles
  # command. The command line interface can be driven by a response file that
  # contains the input arguments for a given command in the properties file in
  # key and value format. To determine which input arguments are required for
  # the various types of profile templates and action, use the manageprofiles
  # command with the -help parameter.
  #
  # Use the following example response file to run a create operation:
  #     create
  #     profileName=testResponseFileCreate
  #     profilePath=profile_root
  #     templatePath=app_server_root/profileTemplates/default
  #     nodeName=myNodeName
  #     cellName=myCellName
  #     hostName=myHostName
  #     omitAction=myOptionalAction1,myOptionalAction2
  #
  # When you create a response file, take into account the following set of
  # guidelines:
  #
  # * When you specify values, do not specify double-quote (") characters at the
  #   beginning or end of a value, even if that value contains spaces.
  #   Note: This is a different than when you specify values on a command line.
  #
  # * When you specify a single value that contains a comma character, such as
  #   the distinguished names for the `personalCertDN` and `signingCertDN`
  #   parameters, use a double-backslash before the comma character. For
  #   example, here is how to specify the `signingCertDN` value with a
  #   distinguished name:
  #
  #     signingCertDN=cn=testserver.ibm.com\\,ou=Root Certificate\\,
  #       ou=testCell\\,ou=testNode01\\,o=IBM\\,c=US
  #
  # * When you specify multiple values, separate them with a comma character,
  #   and do not use double-backslashes. For example, here is how to specify
  #   multiple values for the omitAction parameter:
  #
  #     omitAction=deployAdminConsole,defaultAppDeployAndConfig
  #
  # * Do not specify a blank line in a response file. This can cause an error.
  #
  # @param [String] response_file
  # @return [String]
  # @api public
  attribute :reponse_file,
            kind_of: String

  # Specifies the name of the server. Specify this parameter only for the
  # default and secureproxy templates. If you do not specify this parameter when
  # using the default or secureproxy templates, the default server name is
  # server1 for the default profile, and proxy1 for the secure proxy profile.
  #
  # @param [String] server_name
  # @return [String]
  # @api public
  attribute :server_name,
            kind_of: String

  # Specifies the type of management profile. Specify `ADMIN_AGENT` for an
  # administrative agent server. This parameter is required when you create a
  # management profile.
  #
  # @param [String] server_type
  # @return [String]
  # @api public
  attribute :server_type,
            kind_of: String

  # Specify the user ID that is used during the creation of the Linux service so
  # that the Linux service runs from this user ID. The Linux service runs
  # whenever the user ID is logged on.
  #
  # @param [String] service_user_name
  # @return [String]
  # @api public
  attribute :service_user_name,
            kind_of: String

  # Sets the default profile to one of the existing profiles. Must be used with
  # the `profile_name` parameter.
  #
  # @param [String] set_default_name
  # @return [String]
  # @api public
  attribute :set_default_name,
            kind_of: String

  # Specifies the distinguished name of the root signing certificate that you
  # create when you create the profile. Specify the distinguished name in
  # quotes. This default personal certificate is located in the server keystore
  # file. The `import_signing_cert_ks` parameter is mutually exclusive with the
  # `signing_cert_db` parameter. If you do not specifically create or import a
  # root signing certificate, one is created by default. See the
  # `signing_cert_validity_period` parameter and the `key_store_password`.
  #
  # @param [String] signing_cert_dn
  # @return [String]
  # @api public
  attribute :signing_cert_dn,
            kind_of: String

  # An optional parameter that specifies the amount of time in years that the
  # root signing certificate is valid. If you do not specify this parameter with
  # the `signing_cert_dn` parameter, the root signing certificate is valid for
  # 15 years.
  #
  # @param [String] signing_cert_validity_period
  # @return [String]
  # @api public
  attribute :signing_cert_validity_period,
            kind_of: String

  # Specifies the starting port number for generating and assigning all ports
  # for the profile. Port values are assigned sequentially from the
  # `starting_port` value, omitting those ports that are already in use. The
  # system recognizes and resolves ports that are currently in use and
  # determines the port assignments to avoid port conflicts.
  #
  # During profile creation, the manageprofiles command uses an automatically
  # generated set of recommended ports if you do not specify the `starting_port`
  # parameter, the `default_ports` parameter or the `ports_file` parameter. The
  # recommended port values can be different than the default port values based
  # on the availability of the default ports.
  #
  # Do not use this parameter with the `default_ports` or `ports_file`
  # parameters or if you are using the managed profile template.
  #
  # @param [Integer] starting_port
  # @return [Integer]
  # @api public
  attribute :starting_port,
            kind_of: Integer

  # Specifies the directory path to the template files in the installation root
  # directory. Within the `profileTemplates` directory are various directories
  # that correspond to different profile types and that vary with the type of
  # product installed. The profile directories are the paths that you indicate
  # while using the `template_path` option. You can specify profile templates
  # that lie outside the installation root, if you happen to have any.
  #
  # You can specify a relative path for the `template_path` parameter if the
  # profile templates are relative to the `app_server_root/profileTemplates`
  # directory. Otherwise, specify the fully qualified template path.
  #
  # @param [String] template_path
  # @return [String]
  # @api public
  attribute :template_path,
            kind_of: String

  # Specifies the ports that should be validated to ensure they are not reserved
  # or in use. This parameter helps you to identify ports that are not being
  # used. If a port is determined to be in use, the profile creation stops and
  # an error message displays. You can use this parameter at any time on the
  # create command line. It is recommended that you use this parameter with the
  # `ports_file` parameter.
  #
  # @param [String] validate_ports
  # @return [String]
  # @api public
  attribute :validate_ports,
            kind_of: String

  # Checks all of the profiles that are listed in the profile registry to see if
  # the profiles are present on the file system. Returns a list of missing
  # profiles.
  #
  # @param [String] validate_registry
  # @return [String]
  # @api public
  attribute :validate_registry,
            kind_of: String

  # Indicates if you want to set up web server definitions. The default value
  # for this parameter is false.
  #
  # @param [TrueClass, FalseClass]
  # @return [TrueClass, FalseClass]
  # @api public
  attribute :webserver_check,
            kind_of: [TrueClass, FalseClass]

  # The host name of the server. The default value for this parameter is the
  # long host name of the local machine.
  #
  # @param [String] webserver_hostname
  # @return [String]
  # @api public
  attribute :webserver_hostname,
            kind_of: String

  # The installation path of the web server, local or remote. The default value
  # for this parameter is dependent on the operating system of the local machine
  # and the value of the webServerType parameter. For example:
  #
  #     webServerType=IHS: webServerInstallPath defaulted to /opt/IBM/HTTPServer
  #     webServerType=IIS: webServerInstallPath defaulted to n\a
  #     webServerType=SUNJAVASYSTEM: webServerInstallPath defaulted to /opt/www
  #     webServerType=DOMINO: webServerInstallPath defaulted to
  #     webServerType=APACHE: webServerInstallPath defaulted to
  #     webServerType=HTTPSERVER_ZOS: webServerInstallPath defaulted to n/a
  #
  # @param [String] webserver_install_path
  # @return [String]
  # @api public
  attribute :webserver_install_path,
            kind_of: String

  # The name of the web server. The default value for this parameter is
  # webserver1.
  #
  # @param [String] webserver_name
  # @return [String]
  # @api public
  attribute :webserver_name,
            kind_of: String

  # The operating system from where the web server resides. Valid values
  # include: windows, linux, solaris, aix, hpux, os390, and os400. Use this
  # parameter with the webServerType parameter.
  #
  # @param [String] webserver_os
  # @return [String]
  # @api public
  attribute :webserver_os,
            kind_of: String

  # The path to the plug-ins that the web server uses. The default value for
  # this parameter is `WAS_HOME/plugins`.
  #
  # @param [String] webserver_plugin_path
  # @return [String]
  # @api public
  attribute :webserver_plugin_path,
            kind_of: String

  # Indicates the port from where the web server will be accessed. The default
  # value for this parameter is `80`.
  #
  # @param [String] webserver_port
  # @return [String]
  # @api public
  attribute :webserver_port,
            kind_of: String

  # The type of the web server. Valid values include: `IHS`, `SUNJAVASYSTEM`,
  # `IIS`, `DOMINO`, `APACHE`, and `HTTPSERVER_ZOS`. Use this parameter with the
  # webServerOS parameter.
  #
  # @param [String] webserver_type
  # @return [String]
  # @api public
  attribute :webserver_type,
            kind_of: String

  # A string or ID that identifies the group owner by user name. If this value
  # is not specified, existing owners will remain unchanged and new owner
  # assignments will use the current user (when necessary).
  #
  # @param [String, Integer] owne
  # @return [String, Integer]
  # @api public
  attribute :owner,
            kind_of: [String, Integer],
            default: lazy { node[:wpf][:user][:name] }

  # A string or ID that identifies the group owner by group name, if this value
  # is not specified, existing groups will remain unchanged and new group
  # assignments will use the default POSIX group (if available)
  #
  # @param [String, Integer] group
  # @return [String, Integer]
  # @api public
  attribute :group,
            kind_of: [String, Integer],
            default: lazy { node[:wpf][:user][:group] }
end
