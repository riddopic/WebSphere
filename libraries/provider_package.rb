# encoding: UTF-8
#
# Cookbook Name:: websphere
# Provider:: websphere_package
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

require 'fileutils' unless defined?(FileUtils)

# A Chef provider for the WebSphere packages
#
class Chef::Provider::WebspherePackage < Chef::Provider
  include WebSphere

  provides :websphere_package

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
    if new_resource.installed.nil?
      new_resource.installed(@current_resource.installed)
    end
  end

  # Load and return the current resource
  #
  # @return [Chef::Resource::WebspherePackage]
  #
  # @raise [Odsee::Exceptions::ResourceNotFound]
  #
  # @api private
  def load_current_resource
    @current_resource = Chef::Resource::WebspherePackage.new(new_resource.name)
    @current_resource.installed(installed?)
    @current_resource
  end

  # Install WebSphere package specified by a package ID
  #
  # @param [String, Symbol] namespace
  #   package ID to install
  #
  # @param [String] id
  #   the Uniq IBM product ID
  #
  # @param [String, Symbol] install_from
  #   the type of installation to perform, supports `:files` or `:repository`
  #   default is `:repository`
  #
  # @param [String] dir
  #  the package installation directory
  #
  # @param [String] eclipse_dir
  #   target eclipse directory, default is `/opt/IBM/`
  #
  # @param [String] data_dir
  #   path where to hold internal Installation Manager data, default is
  #   `/opt/IBM/DataLocation`
  #
  # @param [String] shared_dir
  #   shared resources directory, default is `/opt/IBM/Shared`
  #
  # @param [URI::HTTP] passaport_advt
  #   append the PassportAdvantage repository to the repository list
  #
  # @param [Array] repositories
  #   list of repositories to be used
  #
  # @param [Hash] install_files
  #   Hash containing the name, source and checksums of Zip files to use if
  #   `install_from` is set to `zipfile`
  #
  # @param [Symbol] install_fixes
  #   install Fixes, can be :none, :recommended or :all
  #
  # @param [String] master_passwd
  #   defines master password file
  #
  # @param [Hash] preferences
  #   specify a list of preference as <key>=<value>, <key>=<value>
  #
  # @param [Hash] properties
  #   properties required for the package install, as <key>=<value>
  #
  # @param [String] secure_storage
  #   defines secure storage file
  #
  # @param [TrueClass, FalseClass] accept_license
  #   indicate acceptance of the license agreement
  #
  # @param [Symbol] admin
  #   define the user as an admin, a nonAdmin or a group, the default is admin
  #
  # @param [String] shared_dir
  #   specify a directory to hold internal Installation Manager data
  #
  # @param [String] log_file
  #   specify a log file that records the result of Installation Manager
  #   operations. The log file is an XML file.
  #
  # @param [String] master_password_file
  #   defines master password file
  #
  # @param [Symbol] language
  #   specify desired language to be used
  #
  # @param [TrueClass, FalseClass] show_progress
  #   show progress
  #
  # @param [TrueClass, FalseClass] show_verbose_progress
  #   show verbose progress
  #
  # @param [TrueClass, FalseClass] silent
  #   run in silent mode
  #
  # @param [String] url
  #   the URL of a repository
  #
  # @return [Chef::Provider::WebspherePackage]
  #
  # @api private
  def action_install
    if @current_resource.installed
      Chef::Log.debug "#{new_resource.id_ver} already installed"
    else
      converge_by "Installed #{new_resource.id_ver}" do
        imcl install_by(new_resource.install_from).join(' '),
          new_resource._?(:dir,                       '-iD'),
          new_resource._?(:accept_license, '-acceptLicense'),
          new_resource._?(:admin,                     '-aR'),
          ((new_resource.output == :silent)  ? '-s'   :
           (new_resource.output == :verbose) ? '-sP'  :
           (new_resource.output == :debug)   ? '-sVP' : '-sP')
      end
      new_resource.updated_by_last_action(true)
    end
    load_new_resource_state
    new_resource.installed(true)
  ensure
    [tmpdir, response_file].map { |f| FileUtils.rm_r(f) if ::File.exist?(f) }
  end

  # Uninstall a WebSphere package specified by package ID
  #
  # @param [String] id
  #   package ID to uninstall
  #
  # @return [Chef::Provider::WebspherePackage]
  #
  # @api private
  def action_uninstall
    if @current_resource.installed
      converge_by "Removing #{new_resource.id_ver}" do
        # code...
      end
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info "#{new_resource.id_ver} not installed - nothing to do"
    end
    load_new_resource_state
    new_resource.installed(false)
  end

  private #   P R O P R I E T À   P R I V A T A   Vietato L'accesso

  # Return correct set of install options for the different install sources
  #
  # @param [Symbol] source
  #   the install source
  #
  # @return [Array]
  #   installation options for source
  #
  # @api private
  def install_by(source)
    if source == :files
      new_resource.install_files.map { |file| unzip(file, tmpdir) }
      new_resource.repositories(path_to(tmpdir, 'repository.config'))
      install_options = [:install, new_resource.id,
        new_resource._?(:data_dir,                 '-dL'),
        new_resource._?(:shared_dir,              '-sRD'),
        new_resource._?(:eclipse_dir, '-eclipseLocation'),
        new_resource._?(:repositories,   '-repositories')]

    elsif source == :repository
      install_options = [:input, response_file]

    else
      raise "Unknown install from source, `#{source}`"
    end
    install_options
  end

  # Generates response file from template
  #
  # @return [undefined]
  # @api private
  def response_file
    t = Chef::Resource::Template.new(new_resource.response_file, run_context)
    t.source   'empty.erb'
    t.cookbook 'websphere'
    t.owner     new_resource.owner
    t.group     new_resource.group
    t.mode      00644
    t.variables data: XML.generate(new_resource)
    t.run_action(:create) unless @current_resource.installed
    new_resource.response_file
  end

  # Copy and unzip files for local install
  #
  # @return [undefined]
  # @api private
  def unzip(file, destination)
    zf = Chef::Resource::ZipFile.new(destination, run_context)
    zf.checksum     file[:checksum]
    zf.source       source_from(file)
    zf.owner        new_resource.owner
    zf.group        new_resource.group
    zf.overwrite    true
    zf.remove_after true
    zf.run_action(:unzip)
  end
end
