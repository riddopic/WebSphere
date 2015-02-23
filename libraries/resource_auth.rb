# encoding: UTF-8
#
# Cookbook Name:: websphere
# Resource:: repository_auth
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

# A Chef provider for the WebSphere Repository Credentials
#
class Chef::Resource::RepositoryAuth < Chef::Resource
  include WebSphere

  # The module where Chef should look for providers for this resource
  #
  # @param [Module] arg
  #   the module containing providers for this resource
  # @return [Module]
  #   the module containing providers for this resource
  # @api private
  provider_base Chef::Provider::RepositoryAuth

  # The value of the identity attribute
  #
  # @return [String]
  #   the value of the identity attribute.
  # @api private
  identity_attr :url

  # Maps a short_name (and optionally a platform and version) to a
  # Chef::Resource
  #
  # @param [Symbol] arg
  #   short_name of the resource
  # @return [Chef::Resource::RepositoryAuth]
  #   the class of the Chef::Resource based on the short name
  # @api private
  provides :repository_auth, os: 'linux'

  # Set or return the list of `state attributes` implemented by the Resource,
  # these are attributes that describe the desired state of the system
  #
  # @return [Chef::Resource::RepositoryAuth]
  # @api private
  state_attrs :exists

  # Adds actions to the list of valid actions for this resource
  #
  # @return [Chef::Provider::RepositoryAuth]
  # @api public
  actions :store

  # Sets the default action
  #
  # @return [undefined]
  # @api private
  default_action :store

  def initialize(name, run_context = nil)
    super
    @sensitive = true
  end

  attribute :exists, kind_of: [TrueClass, FalseClass]

  # Specify the password for the online product repository access. This allows
  # you to use Installation Manager to access online product repositories to
  # install and maintain your Servers or to use the Package Utility to copy the
  # latest updates and patches to a local repository.
  #
  # @param [String] admin_password
  # @return [String]
  # @api public
  attribute :password,
            kind_of: String,
            default: lazy { node[:wpf][:authorize][:password] }

  # Specify the username for the online product repository access. This allows
  # you to use Installation Manager to access online product repositories to
  # install and maintain your Servers or to use the Package Utility to copy the
  # latest updates and patches to a local repository.
  #
  # @param [String] admin_username
  # @return [String]
  # @api public
  attribute :username,
            kind_of: String,
            default: lazy { node[:wpf][:authorize][:username] }

  # Specify repositories to be used, can be HTTP URL or file path but it must be
  # a valid IBM reposiotry containing entitlements, not required when
  # `install_by` is set to `zipfile`
  #
  # @param [URI::HTTP, String] authorizing_url
  # @return [URI::HTTP, String]
  # @api public
  attribute :authorizing_url,
            kind_of: String,
            name_attribute: true,
            default: lazy { node[:wpf][:authorize][:url] }

  # Defines the path to the master password file
  #
  # @param [String] master_passwd
  # @return [String]
  # @api public
  attribute :master_passwd,
            kind_of: String,
            default: lazy { ::File.join(eclipse_dir, 'tools/.mPF') }

  # Defines the path to the secure storage file
  #
  # @param [String] secure_storage
  # @return [String]
  # @api public
  attribute :secure_storage,
            kind_of: String,
            default: lazy { ::File.join(eclipse_dir, 'tools/.sSF') }

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

  private #   P R O P R I E T À   P R I V A T A   Vietato L'accesso

  def eclipse_dir
    lazy_evel(node[:wpf][:eclipse_dir])
  end
end
