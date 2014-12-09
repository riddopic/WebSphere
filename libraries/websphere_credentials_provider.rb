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

  def initialize(name, run_context = nil)
    super
    @default_repo ||= ->{ node[:websphere][:repositories][:local] }.call
    @home_dir ||= ->{ node[:websphere][:user][:home] }.call
    @im_dir ||= ->{ node[:websphere][:iim][:install_location] }.call
  end

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
        if new_resource.username.nil? || new_resource.password.nil?
          Chef::Log.warn 'You must specify a username and password to store '\
                         'credentials and access the IBM live repository'
        else
          __store_credential__
        end
      end
    end
  end

  protected #      A T T E N Z I O N E   A R E A   P R O T E T T A

  # @return [TrueClass, FalseClass] true if the credentials are already set.
  # @!visibility private
  def credentials_set?
    ::File.exist?(new_resource.secure_storage_file) &&
      ::File.exist?(new_resource.master_password_file)
  end

  # Set the credentials.
  # @!visibility private
  def __store_credential__
    write_master_password_file
    save_credential
  end

  def tools_dir
    ::File.join(@im_dir, 'tools')
  end

  # Saves the specified credentials to the secure storage file.
  #
  #     -masterPasswordFile, -mPF  <masterPasswordFilePath>
  #         Defines master password file
  #     -passportAdvantage
  #         Save the credentials for the Passport Advantage repository to the
  #         secure storage file.
  #     -prompt
  #         Display prompts for user credentials, master password (if secure
  #         storage is used), or to insert disks on the console.
  #     -proxyHost  <proxyHost>
  #         Provide proxy hostname for command saveCredential.
  #     -proxyPort  <proxyPort>
  #         Provide proxy port for command saveCredential.
  #     -proxyUserName  <proxyUserName>
  #         Provide proxy user name for command saveCredential.
  #     -proxyUserPassword  <proxyUserPassword>
  #         Provide proxy user password for command saveCredential.
  #     -secureStorageFile, -sSF  <secureStorageFilePath>
  #         Defines secure storage file
  #     -userName  <userName>
  #         Provide the user name for command saveCredential.
  #     -userPassword  <userPassword>
  #         Provide user password for command saveCredential.
  #     -useSOCKS
  #         Use SOCKS proxy connection for command saveCredential.
  #     -verbose
  #         Show more information when executing command.
  #
  #   saveCredential | sC
  #     -url <url> | -passportAdvantage
  #     -userName <user name> -userPassword <user password>
  #     -secureStorageFile <secure_storage_file>
  #     -masterPasswordFile <master_password_file>
  #     [ -proxyHost <proxy host> -proxyPort <proxy port>
  #        [ -proxyUserName <proxy user name>
  #          -proxyUserPassword <proxy user password> ]
  #        [ -useSOCKS ] ]
  #     [ -verbose ]
  #
  # This command can be used only with the following commands:
  # -url  <url>
  #
  # @!visibility private
  def save_credential_cmd
    './imutilsc saveCredential ' \
      "-url #{new_resource.url} " \
      "-userName #{new_resource.username} " \
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
    f.owner new_resource.owner
    f.group new_resource.group
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
    e.user new_resource.owner
    e.group new_resource.group
    e.creates ssf
    e.run_action :run
  end
end
