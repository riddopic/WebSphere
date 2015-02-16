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
  # @return [Chef::Provider::WebspherePackage]
  #
  # @api public
  def action_install
    if @current_resource.installed
      Chef::Log.debug "#{new_resource.id_ver} already installed"
    else
      converge_by "Installed #{new_resource.profile} : #{new_resource.id_ver}" do
        imcl install_by(new_resource.install_from).join(' '),
              new_resource._?(:dir,   '-iD'),
              new_resource._?(:admin, '-aR')
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
  # @return [Chef::Provider::WebspherePackage]
  #
  # @api public
  def action_uninstall
    if @current_resource.installed
      converge_by "Removed #{new_resource.profile} : #{new_resource.id_ver}" do
        imcl :uninstall, new_resource.id,
              new_resource._?(:dir, '-iD'),
              base_options
 	    end
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info "#{new_resource.id_ver} not installed - nothing to do"
    end
    load_new_resource_state
    new_resource.installed(false)
  end

  # Update all WebSphere packages from the service repository
  #
  # @return [Chef::Provider::WebspherePackage]
  #
  # @api public
  def action_update_all
    if @current_resource.installed
      converge_by "Updated #{installed.map { |h| h[:id_ver] }.join (', ')}" do
        imcl :updateAll,
              new_resource._?(:install_fixes,          '-iF'),
              new_resource._?(:repositories, '-repositories'),
              base_options
      end
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info "#{new_resource.id_ver} not installed - nothing to do"
    end
    load_new_resource_state
    new_resource.installed(true)
  end

  # Update a WebSphere packages from the service repository using the product ID
  #
  # @return [Chef::Provider::WebspherePackage]
  #
  # @api public
  def action_update
    if @current_resource.installed
      converge_by "Updated #{new_resource.id}" do
        imcl :install, new_resource.id,
              update_by(new_resource.service_repository).join(' '),
              base_options
      end
      new_resource.updated_by_last_action(true)
    else
      Chef::Log.info "#{new_resource.id_ver} not installed - nothing to do"
    end
    load_new_resource_state
    new_resource.installed(true)
  end

  private #   P R O P R I E T À   P R I V A T A   Vietato L'accesso

  # Return correct set of update options based on the service_repository
  # settings, in simple terms, whether or not we update from IBM, can they
  # really be trusted?
  #
  # @param [TrueClass, FalseClass] service_repository
  #   when true we use the offerings service repository, when false we only
  #   use the local repository
  #
  # @return [Array]
  #   installation options for source
  #
  # @api private
  def update_by(service_repository)
    if service_repository
      [new_resource._?(:install_fixes,          '-iF'),
       valid?(new_resource._?(:secure_storage,'-sSF')),
       valid?(new_resource._?(:master_passwd, '-mPF')),
       base_options]
    else
      new_resource.preferences(
        key:  'offering.service.repositories.areUsed',
        value: false )
      [new_resource._?(:install_fixes,          '-iF'),
       new_resource._?(:repositories, '-repositories'),
       new_resource._?(:preferences,   '-preferences'),
       base_options]
    end
  end

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
        new_resource._?(:repositories,   '-repositories'),
        base_options]

    elsif source == :repository
      install_options = [:input, response_file, base_options]

    else
      raise "Unknown source, `#{source}` to install with"
    end
    install_options
  end

  # Base set of options common to all `imcl` commands
  #
  # @return [Array]
  # @api private
  def base_options
    [valid?(new_resource._?(:secure_storage,   '-sSF')),
     valid?(new_resource._?(:master_passwd,    '-mPF')),
     new_resource._?(:accept_license, '-acceptLicense'),
     ((new_resource.output == :silent)  ? '-s'   :
      (new_resource.output == :verbose) ? '-sP'  :
      (new_resource.output == :debug)   ? '-sVP' : '-sP')]
  end

  # Checks if the argument is valid by the presence of the file, when the file
  # exists returns the value object supplied, else undefined
  #
  # @param [Array<String, Symbol, #read>] arg
  #   method or object that responds to #call to validate
  #
  # @return [Object, undefined]
  #   when the file exists returns the Object#call, else undefined
  #
  # @api private
   def valid?(arg)
     ::File.exist?(arg.split.last) ? arg : nil
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
    t.not_if  {
      @current_resource.installed || new_resource.install_from == :files
    }
    t.run_action(:create)
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
