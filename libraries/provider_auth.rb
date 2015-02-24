# encoding: UTF-8
#
# Cookbook Name:: websphere
# Provider:: repository_auth
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
class Chef::Provider::RepositoryAuth < Chef::Provider
  include WebSphere

  provides :repository_auth

  def initialize(new_resource, run_context)
    super(new_resource, run_context)
  end

  # Boolean indicating if WhyRun is supported by this provider
  #
  # @return [TrueClass, FalseClass]
  #
  # @api private
  def whyrun_supported?
    true
  end

  # Reload the resource state when something changes
  #
  # @return [undefined]
  #
  # @api private
  def load_new_resource_state
    if new_resource.exists.nil?
      new_resource.exists(@current_resource.exists)
    end
  end

  # Load and return the current resource
  #
  # @return [Chef::Resource::RepositoryAuth]
  #
  # @raise [Odsee::Exceptions::ResourceNotFound]
  #
  # @api private
  def load_current_resource
    @current_resource = Chef::Resource::RepositoryAuth.new(new_resource.name)
    @current_resource.exists(exists?)
    @current_resource
  end

  # Saves the specified credentials to the secure storage file.
  #
  # @return [Chef::Provider::RepositoryAuth]
  #
  # @api private
  def action_store
    if @current_resource.exists
      Chef::Log.debug 'Credentials already stored - nothing to do'
    else
      converge_by 'Saving specified credentials to the secure storage file' do
        generate(new_resource.master_passwd, obfuscate(SecureRandom.hex))
        imutilsc :saveCredential,
                  new_resource._?(:authorizing_url, '-url'),
                  new_resource._?(:username,        '-userName'),
                  new_resource._?(:password,        '-userPassword'),
                  new_resource._?(:secure_storage,  '-secureStorageFile'),
                  new_resource._?(:master_passwd,   '-masterPasswordFile')
      end
      new_resource.updated_by_last_action(true)
    end
    load_new_resource_state
    new_resource.exists(true)
  end

  private #   P R O P R I E T À   P R I V A T A   Vietato L'accesso

  def exists?
    ::File.exist?(new_resource.master_passwd) &&
      ::File.exist?(new_resource.secure_storage)
  end

  # Generates a onetime random strings as the passphrase, which is saved to the
  # master password file.
  #
  # @!visibility private
  def generate(file, content)
    f = Chef::Resource::File.new(file, run_context)
    f.sensitive true
    f.owner     new_resource.owner
    f.group     new_resource.group
    f.mode      00600
    f.content   content
    f.run_action :create
  end
end
