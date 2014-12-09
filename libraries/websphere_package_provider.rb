# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Library:: websphere_package_provider
#

require 'find' unless defined?(Find)

require_relative 'helpers'
require_relative 'xml_generator'

# A Chef provider for the WebSphere packages
#
class Chef::Provider::WebspherePackage < Chef::Provider::LWRPBase
  include Chef::Mixin::ShellOut
  include WebSphere::XMLGenerator
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
  # @return [Chef::Resource::WebsphereResource]
  #
  def load_current_resource
    @current_resource ||= Chef::Resource::WebspherePackage.new new_resource.name
    @current_resource.exists = installed?(id_for(new_resource.name))
    @current_resource.installed_packages = installed_packages
    @current_resource
  end

  action :install do
    unless current_resource.exists?
      converge_by 'Installing Package' do

        if new_resource.install_type == :cli
          pkg          = node[:websphere][new_resource.pkg.to_sym]
          tmpdir       = new_resource.tmpdir
          repositories = path_to(tmpdir, 'repository.config')
          cmd          = path_to(tmpdir, 'imcl')
          package_id   = pkg[:id]
          install_dir  = pkg[:install_location]
          install_by(cmd, package_id, repositories, install_dir)
          if (pkg.attribute?(:init) && !pkg[:init].nil?)
            init_service(pkg[:init])
          end

        else
          apps, repos = [],[]
          if new_resource.pkg.kind_of?(Array)
            new_resource.apps.each do |pkg|
              pkg = node[:websphere][new_resource.pkg.to_sym]
              repos << pkg[:repositories] || @default_repo
              apps << pkg
            end
          else
            pkg = node[:websphere][new_resource.pkg.to_sym]
            apps << node[:websphere][new_resource.pkg.to_sym]
            repos << pkg[:repositories] || @default_repo
          end

          template response_file('redrum') do
            source 'empty.erb'
            owner new_resource.owner
            group new_resource.group
            mode 00644
            variables data: xml_for(apps, repos.sort.uniq)
            run_action :create
          end

          install_by(cmd, response_file('redrum'))
          if (pkg.attribute?(:init) && !pkg[:init].nil?)
            init_service(pkg[:init])
          end
        end
      end
    else
      Chef::Log.info "#{new_resource} already exists - nothing to do"
    end
  end

  action :uninstall do
    fail NotImplementedError
  end

  action :modify do
    fail NotImplementedError
  end

  action :copy do
    unless current_resource.exists?
      converge_by 'Copying Package' do
        pkg  = node[:websphere][new_resource.pkg.to_sym]
        file = pkg[:file]["#{pkg[:install_type].to_sym}"]

        download source_from(file) do
          destination new_resource.tmpdir
          checksum file[:checksum]
          owner new_resource.owner
          group new_resource.group
          mode 00644
          action :run
        end

        new_resource.updated_by_last_action(true)
      end
    else
      Chef::Log.info "#{new_resource} already exists - nothing to do"
    end
  end

  action :unpack do
    unless current_resource.exists?
      converge_by 'Unpacking Package' do
        pkg  = node[:websphere][new_resource.pkg.to_sym]
        file = pkg[:file]["#{pkg[:install_type].to_sym}"]

        zip_file ::File.join(new_resource.tmpdir, file[:name]) do
          owner new_resource.owner
          group new_resource.group
          remove_after true
          action :unzip
        end

        new_resource.updated_by_last_action(true)
      end
    else
      Chef::Log.info "#{new_resource} already exists - nothing to do"
    end
  end

  protected #      A T T E N Z I O N E   A R E A   P R O T E T T A

  # @return [String] path to the response file.
  # @!visibility private
  def response_file(name)
    ::File.join(@home_dir, "#{name}.xml")
  end

  def imcli?
    ::File.exist?(::File.join(tools_dir, 'imcl'))
  end

  def imcli
    ::File.join(tools_dir, 'imcl') if imcli?
  end

  def tools_dir
    ::File.join(@im_dir, 'tools')
  end

  def source_from(file)
    source = unshorten(file[:source])
    if ::File.basename(URI.parse(source).path) == file[:name]
      source
    else
      uri_join(source, file[:name])
    end
  end

  def id_for(package)
    node[:websphere][new_resource.pkg.to_sym][:id]
  end

  def installed?(package)
    installed_packages.include?(package) | false
  rescue # when it's nil don't break the chef run.
    false
  end

  def installed_packages
    opts = { user: new_resource.owner, group: new_resource.group }
    shell_out!("#{imcli} listinstalledpackages -long", opts).stdout if imcli?
  end

  def path_to(dir, file)
    Find.find(dir) { |p| return p if ::File.basename(p) =~ /^#{file}$/ }
  end

  def init_service(name)
    template ::File.join('/etc/init.d', name) do
      owner 'root'
      group 'root'
      mode 00754
      notifies :start, "service[#{name}]"
      action :create
    end

    service name do
      supports status: true, start: true, stop: true, restart: true
      action :enable
    end
  end

  # Determines which install methid to use based on available arguments. If
  # passed in a package ID then it excpect a `repository` and a `install_dir`
  # also to be defined.
  #
  # @param type [String]
  #   can be the package ID or a response file. If it's a package ID
  def install_by(cmd, type = nil, repositories = nil, install_dir = nil)
    if repositories.nil? && install_dir.nil?
      cmd = __by_response__(cmd, type)
    else
      cmd = __by_package__(cmd, type, repositories, install_dir)
    end
    opts = { user: new_resource.owner, group: new_resource.group }
    shell_out!(cmd, opts)
  end

  def __by_response__(cmd, file)
    cmd = "#{imcli} input #{file} "
    cmd << '-acceptLicense -showVerboseProgress '
    cmd << "-secureStorageFile #{new_resource.storage_file} "
    cmd << "-masterPasswordFile #{new_resource.passwd_file} "
  end

  def __by_package__(cmd, id, repositories, install_dir)
    cmd = "#{cmd} install #{id} "
    cmd << "-repositories #{repositories} "
    cmd << "-installationDirectory #{install_dir} "
    cmd << "-accessRights #{admin?} "
    cmd << '-acceptLicense -showVerboseProgress '
  end

  def with_master_password
    cmd << "-secureStorageFile #{new_resource.storage_file} "
    cmd << "-masterPasswordFile #{new_resource.passwd_file} "
  end

  # @return [String] `admin` if the WebSphere applications are running as root,
  # if not then returns `nonadmin`.
  # @!visibility private
  def admin?
    (node[:websphere][:user][:name] == 'root') ? 'admin' : 'nonadmin'
  end
end
