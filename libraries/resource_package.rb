# encoding: UTF-8
#
# Cookbook Name:: websphere
# Resource:: websphere_package
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

# A Chef resource for the WebSphere packages
#
class Chef::Resource::WebspherePackage < Chef::Resource
  include WebSphere

  # The module where Chef should look for providers for this resource
  #
  # @param [Module] arg
  #   the module containing providers for this resource
  # @return [Module]
  #   the module containing providers for this resource
  # @api private
  provider_base Chef::Provider::WebspherePackage

  # The value of the identity attribute
  #
  # @return [String]
  #   the value of the identity attribute.
  # @api private
  identity_attr :namespace

  # Maps a short_name (and optionally a platform and version) to a
  # Chef::Resource
  #
  # @param [Symbol] arg
  #   short_name of the resource
  # @return [Chef::Resource::WebspherePackage]
  #   the class of the Chef::Resource based on the short name
  # @api private
  provides :websphere_package, os: 'linux'

  # Set or return the list of `state attributes` implemented by the Resource,
  # these are attributes that describe the desired state of the system
  #
  # @return [Chef::Resource::WebspherePackage]
  # @api private
  state_attrs :installed

  # Adds actions to the list of valid actions for this resource
  #
  # @return [Chef::Provider::WebspherePackage]
  # @api public
  actions :install, :uninstall

  # Sets the default action
  #
  # @return [undefined]
  # @api private
  default_action :install

  # Boolean, when `true` the resource exists on the system, otherwise `false`
  #
  # @param [TrueClass, FalseClass]
  # @return [TrueClass, FalseClass]
  # @api public
  attribute :installed,
            kind_of: [TrueClass, FalseClass]

  # The ID of the WebSphere package to act on, corresponds to the attribute key
  #
  # @param [String, Symbol] namespace
  # @return [String, Symbol]
  # @api public
  attribute :namespace,
            kind_of: [String, Symbol],
            name_attribute: true

  # The uniq IBM package ID
  #
  # @param [String] id
  # @return [String]
  # @api public
  attribute :id,
            kind_of: String,
            default: lazy { node[namespace][:id] }

  # The version number of the package.
  #
  # @param [String] version
  # @return [String]
  # @api public
  attribute :version,
            kind_of: String,
            default: lazy { node[namespace][:version] }

  # Each WebSphere package offerings can have multiple features but always have
  # at least one; a required core feature which is installed regardless of
  # whether it is explicitly specified. If other feature names are provided,
  # then only those features will be installed. Features must be comma
  # delimited without spaces
  #
  # @param [String] features
  # @return [String]
  # @api public
  attribute :features,
            kind_of: String,
            default: lazy { node[namespace][:features] }

  # The profile attribute is required and typically is unique to the offering.
  # If modifying or updating an existing installation, the profile attribute
  # must match the profile ID of the targeted installation.
  #
  # @param [String] profile
  # @return [String]
  # @api public
  attribute :profile,
            kind_of: String,
            default: lazy { node[namespace][:profile] }

  # The full package name with version number
  #
  # @param [String] version
  # @return [String]
  # @api public
  attribute :id_ver,
            kind_of: String,
            default: lazy { "#{id}.#{version}" }

  # What type of media should the installation use, supported types are
  # `:repository` or `:files`, when `:files` is selected you must also include
  # `:install_files`. The default is `:repository`
  #
  # @param [String] install_from
  # @return [String]
  # @api public
  attribute :install_from,
            kind_of: Symbol,
            equal_to: [:files, :repository],
            default: :repository

  # The package installation directory
  #
  # @param [String] dir
  # @return [String]
  # @api public
  attribute :dir,
            kind_of: String,
            default: lazy { node[namespace][:dir] }

  # Target base directory, default is `/opt/IBM`
  #
  # @param [String] base_dir
  # @return [String]
  # @api public
  attribute :base_dir,
            kind_of: String,
            default: lazy { node[:wpf][:base] }

  # Target eclipse directory.
  #
  # @param [String] eclipse_dir
  # @return [String]
  # @api public
  attribute :eclipse_dir,
            kind_of: String,
            default: lazy { node[:iim][:dir] }

  # Path where to hold internal Installation Manager data. Default is
  # `/opt/IBM/DataLocation`
  #
  # @param [String] data_dir
  # @return [String]
  # @api public
  attribute :data_dir,
            kind_of: String,
            default: lazy { node[:wpf][:data_dir] }

  # Shared resources directory. Default is `/opt/IBM/Shared`
  #
  # @param [String] shared_dir
  # @return [String]
  # @api public
  attribute :shared_dir,
            kind_of: String,
            default: lazy { node[:wpf][:shared_dir] }

  # Append the PassportAdvantage repository to the repository list, the default
  # is `false`
  #
  # @param [TrueClass, FalseClass]
  # @return [TrueClass, FalseClass]
  # @api public
  attribute :passport_advt,
            kind_of: [TrueClass, FalseClass],
            default: false

  # Specify repositories to be used, can be HTTP URL or file path but it must be
  # a valid IBM reposiotry containing entitlements, not required when
  # `install_by` is set to `zipfile`
  #
  # @param [URI::HTTP, String] repositories
  # @return [URI::HTTP, String]
  # @api public
  attribute :repositories,
            kind_of: String,
            default: lazy { node[:wpf][:local_repository] }

  # A list of Hashes containing the name, source and checksums of the files to
  # use inplace of a repository, not required when `install_from` is set to
  # `:repository`
  #
  # @param [Hash] install_files
  # @return [Hash]
  # @api public
  attribute :install_files,
            kind_of: Array

  # Install fixes, one of `:none`, `:recommended` or `:all`, default is `:none`
  #
  # @param [Symbol] install_fixes
  # @return [Symbol]
  # @api public
  attribute :install_fixes,
            kind_of: Symbol,
            equal_to: [:none, :recommended, :all],
            default: lazy { node[namespace][:fixes] }

  # Defines master password file
  #
  # @param [String] master_passwd
  # @return [String]
  # @api public
  attribute :master_passwd,
            kind_of: String,
            default: lazy { node[:wpf][:credential][:master_passwd] }

  # Defines secure storage file
  #
  # @param [String] secure_storage
  # @return [String]
  # @api public
  attribute :secure_storage,
            kind_of: String,
            default: lazy { node[:wpf][:credential][:secure_storage] }

  # Specify a preference value or a comma-delimited list of preference values
  # to be used
  #
  # @param [String, Hash] preferences
  # @return [String, Hash]
  # @api public
  attribute :preferences,
            kind_of: [String, Hash],
            default: lazy { node[:wpf][:preferences] }

  # Properties needed for package installation
  #
  # @param [String, Hash] data
  # @return [String, Hash]
  # @api public
  attribute :properties,
            kind_of: [String, Symbol, Hash],
            default: lazy { node[namespace][:data] }

  # Indicate acceptance of the license agreement, because you actually have a
  # choice...
  #
  # @param [TrueClass, FalseClass] accept_license
  # @return [TrueClass, FalseClass]
  # @api public
  attribute :accept_license,
            kind_of: [TrueClass, FalseClass],
            default: true

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

  # Define the user as an admin, a nonAdmin or a group, the default is admin
  #
  # @param [String, Symbol] admin
  # @return [String, Symbol]
  # @api public
  attribute :admin,
    kind_of: Symbol,
    equal_to: [:admin, :nonadmin],
    default: lazy { (node[:wpf][:user][:name] == 'root') ? :admin : :nonadmin }

  # Show verbose progress from installation
  #
  # @param [TrueClass, FalseClass] output
  # @return [TrueClass, FalseClass]
  # @api public
  attribute :output,
            equal_to: [:silent, :verbose, :debug],
            kind_of: Symbol,
            default: :verbose

  # Path to the response file to execute
  #
  # @param [String] response_file
  # @return [String]
  # @api public
  attribute :response_file,
            kind_of: [String],
            default: lazy { ::File.join(base_dir, "#{namespace}.xml") }
end
