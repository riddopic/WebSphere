# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Library:: websphere_provider
#

require 'chef/provider/lwrp_base'
require_relative 'helpers'
require_relative 'xml_generator'
require_relative 'websphere_resource'

# A Chef provider for the WebSphere packages
#
class Chef::Provider::Websphere < Chef::Provider::LWRPBase
  include WebSphere::Helpers
  include WebSphere::XMLGenerator

  attr_accessor :repositories

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
  # @return [Chef::Resource::WebsphereResource]
  #
  def load_current_resource
  end

  action :install do
    apps = []
    @new_resource.apps.each do |pkg|
      fail "Unknown type `#{pkg}`" unless node[:websphere].attribute?(pkg)
      pkg = node[:websphere][pkg.to_sym]
      make_app_dir(pkg[:install_location])
      repositories(pkg[:repositories])
      apps << pkg
    end
    write_response_file(apps, @repositories)
  end

  action :uninstall do
    fail NotImplementedError
  end

  action :modify do
    fail NotImplementedError
  end

  protected #      A T T E N Z I O N E   A R E A   P R O T E T T A

  def repositories(repos)
    @repositories ||= []
    if repos.respond_to?(:each)
      repos.map { |repo| (repo.is_a?(Proc) ? repo.call : repo) }
    end
    @repositories << (repos.is_a?(Proc) ? repos.call : repos)
  end

  def tools_dir
    ::File.join(node[:websphere][:iim][:install_location],
      'IBM/InstallationManager/eclipse/tools')
  end

  def response_file
    name = @new_resource.name.to_s
    ::File.join(node[:websphere][:iim][:install_location], "#{name}.xml")
  end

  def make_app_dir(dir)
    d = Chef::Resource::Directory.new(dir, run_context)
    d.owner node[:websphere][:user]
    d.group node[:websphere][:group]
    d.mode 00755
    d.recursive true
    d.run_action :create
  end

  def write_response_file(data, repos)
    t = Chef::Resource::Template.new(response_file, run_context)
    t.cookbook 'websphere'
    t.source 'empty.erb'
    t.owner node[:websphere][:user]
    t.group node[:websphere][:group]
    t.mode 00644
    t.variables data: xml_for(data, repos)
    t.run_action :create
  end

  # Build a command-line argument list for a silent mode installation using the
  # Installation Manager command-line (imcl) utility.
  #
  def install_cmd
    "./imcl input #{response_file} -showVerboseProgress -acceptLicense " \
      "-dataLocation #{new_resource.data_location} " \
      "-secureStorageFile #{new_resource.secure_storage_file} " \
      "-masterPasswordFile #{new_resource.master_password_file}"
  end

  # Execute the silent install using the imcl utility with the command-line
  # arguments built from the install_cmd method.
  #
  def execute_install
    e = Chef::Resource::Execute.new(install_cmd, run_context)
    e.cwd tools_dir
    e.sensitive true
    e.user node[:websphere][:user]
    e.group node[:websphere][:group]
    e.run_action :run
  end
end
