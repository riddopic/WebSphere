# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Library:: websphere_credentials_provider
#

require 'chef/provider/lwrp_base'
require 'securerandom'
require_relative 'helpers'
require_relative 'websphere_credentials_resource'

# For repositories that require authentication this creates a storage file.
# Once created the use of the -secureStorageFile and -masterPasswordFile
# options to store and retrieve credentials will be avaliable.
#
class Chef::Provider::WebsphereCredentials < Chef::Provider::LWRPBase
  include WebSphere::Helpers

  use_inline_resources if defined?(:use_inline_resources)

  # WhyRun is supported by this provider
  #
  # @return [TrueClass, FalseClass]
  #
  def whyrun_supported?
    true
  end

  # Load and return the current resource
  #
  # @return [Chef::Resource::WebsphereCredentials]
  #
  def load_current_resource
  end

  # Default action, stores the credentials for a service repository. NOTE: you
  # must have an IBM user name and password. To register for an IBM user name
  # and password, go to: http://www.ibm.com/account/profile
  #
  action :store do
    if credentials_set?
      Chef::Log.info 'Credentials already stored - nothing to do.'
    else
      converge_by 'Create secure storage file credentials' do
        set_credential
      end
    end
  end

  protected #      A T T E N Z I O N E   A R E A   P R O T E T T A

  # @return [TrueClass, FalseClass]
  #   true if the credentials are already set, false if not
  #
  # @!visibility private
  def credentials_set?
    ::File.exist?(new_resource.secure_storage_file) &&
      ::File.exist?(new_resource.master_password_file)
  end

  def tools_dir
    ::File.join(node[:websphere][:iim][:install_location],
      'IBM/InstallationManager/eclipse/tools')
  end

  def set_credential
    write_master_password_file
    save_credential
  end

  # The command to save the credentials
  #
  # @!visibility private
  def save_credential_cmd
    './imutilsc saveCredential ' \
      "-url #{new_resource.url} " \
      "-userName #{new_resource.user} " \
      "-userPassword #{new_resource.password} " \
      "-secureStorageFile #{new_resource.secure_storage_file} " \
      "-masterPasswordFile #{new_resource.master_password_file}"
  end

  # Generates a onetime random strings as the passphrase, which is saved to the
  # master password file.
  #
  # @!visibility private
  def write_master_password_file
    mpf = new_resource.master_password_file
    return if ::File.exist?(mpf)
    f = Chef::Resource::File.new(mpf, run_context)
    f.owner node[:websphere][:user]
    f.group node[:websphere][:group]
    f.sensitive true
    f.mode 00600
    f.content SecureRandom.hex
    f.run_action :create
  end

  # Saves the credentials for future use.
  #
  # @!visibility private
  def save_credential
    ssf = new_resource.secure_storage_file
    return if ::File.exist?(ssf)
    e = Chef::Resource::Execute.new(save_credential_cmd, run_context)
    e.cwd tools_dir
    e.sensitive true
    e.user node[:websphere][:user]
    e.group node[:websphere][:group]
    e.creates ssf
    e.run_action :run
  end
end
