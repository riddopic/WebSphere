# encoding: UTF-8
#
# Cookbook Name:: websphere
# Provider:: websphere_profile
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

# A Chef provider for the WebSphere profile
#
class Chef::Provider::WebsphereProfile < Chef::Provider
  include WebSphere

  provides :websphere_profile

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
    if new_resource.created.nil?
      new_resource.created(@current_resource.created)
    end
    if new_resource.running.nil?
      new_resource.running(@current_resource.running)
    end
  end

  # Load and return the current resource
  #
  # @return [Chef::Resource::WebsphereProfile]
  #
  # @raise [Odsee::Exceptions::ResourceNotFound]
  #
  # @api private
  def load_current_resource
    @current_resource = Chef::Resource::WebsphereProfile.new(new_resource.name)
    @current_resource.profile_name(new_resource.profile_name)

    @current_resource.created(created?)
    @current_resource.running(running?)
    @current_resource
  end

  # Creates the WebSphere Application Server profile.
  #
  # @param [String] admin_user
  #   Specify the user ID that is used for administrative security
  # @param [String] admin_password
  #   Specify the password for the administrative security user ID
  # @param [Symbol] apply_perf_tuning_setting
  #   Specifies the performance-tuning setting that most closely matches the
  #   type of environment in which the application server will run. This
  #   parameter is only valid for the default profile template. Valid settings
  #   are; valid values are `:standard`, `:production`, and `:development`
  #
  # @api public
  def action_create
    if @current_resource.created
      Chef::Log.debug "#{new_resource.profile_name} already created"
    else
      converge_by "Creating WebSphere profile #{new_resource.profile_name}" do
        manageprofiles :create,
          new_resource._?(:admin_password,                    '-adminPassword'),
          new_resource._?(:admin_username,                    '-adminUserName'),
          new_resource._?(:apply_perf_tuning_setting,'-applyPerfTuningSetting'),
          new_resource._?(:app_server_node_name,          '-appServerNodeName'),
          new_resource._?(:cell_name,                              '-cellName'),
          new_resource._?(:default_port,                       '-defaultPorts'),
          new_resource._?(:dmgr_admin_password,           '-dmgrAdminPassword'),
          new_resource._?(:dmgr_admin_username,           '-dmgrAdminUserName'),
          new_resource._?(:dmgr_host,                              '-dmgrHost'),
          new_resource._?(:dmgr_port,                              '-dmgrPort'),
          new_resource._?(:dmgr_profile_path,               '-dmgrProfilePath'),
          new_resource._?(:enable_admin_security,       '-enableAdminSecurity'),
          new_resource._?(:enable_service,                    '-enableService'),
          new_resource._?(:federate_later,                    '-federateLater'),
          new_resource._?(:host_name,                              '-hostName'),
          new_resource._?(:import_personal_cert_ks,    '-importPersonalCertKS'),
          new_resource._?(:import_personal_cert_ks_alias,
                                                  '-importPersonalCertKSAlias'),
          new_resource._?(:import_personal_cert_ks_password,
                                               '-importPersonalCertKSPassword'),
          new_resource._?(:import_personal_cert_ks_type,
                                                   '-importPersonalCertKSType'),
          new_resource._?(:import_signing_cert_ks,      '-importSigningCertKS'),
          new_resource._?(:import_signing_cert_ks_alias,
                                                   '-importSigningCertKSAlias'),
          new_resource._?(:import_signing_cert_ks_password,
                                                '-importSigningCertKSPassword'),
          new_resource._?(:import_signing_cert_ks_type,
                                                    '-importSigningCertKSType'),
          new_resource._?(:is_default,                            '-isDefault'),
          new_resource._?(:is_developer_server,            '-isDeveloperServer'),
          new_resource._?(:key_store_password,             '-keyStorePassword'),
          new_resource._?(:node_name,                              '-nodeName'),
          new_resource._?(:personal_cert_dn,                 '-personalCertDN'),
          new_resource._?(:personal_cert_validity_period,
                                                 '-personalCertValidityPeriod'),
          new_resource._?(:ports_file,                            '-portsFile'),
          new_resource._?(:profile_name,                        '-profileName'),
          new_resource._?(:profile_path,                        '-profilePath'),
          new_resource._?(:reponse_file,                           '-response'),
          new_resource._?(:server_name,                          '-serverName'),
          new_resource._?(:server_type,                          '-serverType'),
          new_resource._?(:service_user_name,               '-serviceUserName'),
          new_resource._?(:set_default_name,                 '-setDefaultName'),
          new_resource._?(:signing_cert_dn,                   '-signingCertDN'),
          new_resource._?(:signing_cert_validity_period,
                                                  '-signingCertValidityPeriod'),
          new_resource._?(:starting_port,                      '-startingPort'),
          new_resource._?(:template_path,                      '-templatePath'),
          new_resource._?(:validate_ports,                    '-validatePorts'),
          new_resource._?(:validate_registry,              '-validateRegistry'),
          new_resource._?(:webserver_check,                  '-webServerCheck'),
          new_resource._?(:webserver_hostname,            '-webServerHostname'),
          new_resource._?(:webserver_install_path,     '-webServerInstallPath'),
          new_resource._?(:webserver_name,                    '-webServerName'),
          new_resource._?(:webserver_os,                        '-webServerOS'),
          new_resource._?(:webserver_plugin_path,       '-webServerPluginPath'),
          new_resource._?(:webserver_port,                    '-webServerPort'),
          new_resource._?(:webserver_type,                    '-webServerType')
      end
      new_resource.updated_by_last_action(true)
    end
    load_new_resource_state
    new_resource.created(true)
  end

  # Deletes the WebSphere Application Server profile.
  #
  # @return [Chef::Provider::WebsphereProfile]
  #
  # @api public
  def action_delete
    if @current_resource.created
      converge_by "Deleting #{new_resource.profile_name}" do
        # code...
      end
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info "#{new_resource.profile_name} not created - nothing to do"
    end
    load_new_resource_state
    new_resource.created(false)
  end

  # Starts the WebSphere Application Server profile.
  #
  # @return [Chef::Provider::WebsphereProfile]
  #
  # @api public
  def action_start
    if @current_resource.running
      Chef::Log.debug "#{new_resource.profile_name} already running"
    else
      converge_by "Starting WebSphere profile #{new_resource.profile_name}" do
        profile start
      end
      new_resource.updated_by_last_action(true)
    end
    load_new_resource_state
    new_resource.running(true)
  end

  # Stops the WebSphere Application Server profile.
  #
  # @return [Chef::Provider::WebsphereProfile]
  #
  # @api public
  def action_stop
    if @current_resource.running
      converge_by "Stopping WebSphere profile #{new_resource.profile_name}" do
        profile stop
      end
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info "#{new_resource.profile_name} not running - nothing to do"
    end
    load_new_resource_state
    new_resource.running(false)
  end

  private #   P R O P R I E T À   P R I V A T A   Vietato L'accesso

  # @api private
  def start
    (run ||= []) << path_to(new_resource.profile_path, 'startManager.sh')
    run << new_resource._?(:profile_name, '-profileName')
  end

  # @api private
  def stop
    (run ||= []) << path_to(new_resource.profile_path, 'stopManager.sh')
    run << new_resource._?(:admin_username,  '-username')
    run << new_resource._?(:admin_password,  '-password')
    run << new_resource._?(:profile_name, '-profileName')
  end

  # @api private
  def status
    (run ||= []) << path_to(new_resource.profile_path, 'serverStatus.sh')
    run << '-all'
    run << new_resource._?(:admin_username,  '-username')
    run << new_resource._?(:admin_password,  '-password')
    run << new_resource._?(:profile_name, '-profileName')
  end
end
