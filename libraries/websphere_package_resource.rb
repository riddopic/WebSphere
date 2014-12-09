# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Library:: websphere_package_resource
#

# A Chef resource for the WebSphere packages
#
class Chef::Resource::WebspherePackage < Chef::Resource::LWRPBase
  # Chef attributes
  identity_attr :pkg
  provides :websphere_package
  state_attrs :installed

  # Set the resource name
  self.resource_name = :websphere_package

  # Actionss
  actions :install, :uninstall, :modify, :copy, :unpack
  default_action :install

  attribute :pkg, kind_of: [String, Symbol, Array], name_attribute: true

  attribute :install_type, kind_of: Symbol, equal_to: [:cli, :response_file],
            default: :response_file

  # Package ID to install, optionally with version and feature list.
  attribute :package_id, kind_of: [String, Array], default: nil

  # Version of the package to install.
  attribute :version, kind_of: String, default: nil

  # Feature list to install, features must be comma delimited without spaces.
  attribute :features, kind_of: String, default: nil

  # Append the PassportAdvantage repository to the repository list.
  attribute :passport_advt, kind_of: [TrueClass, FalseClass], default: false

  # Target eclipse directory path.
  attribute :eclipse_dir, kind_of: String, default: nil

  # The installation directory.
  attribute :install_dir, kind_of: String, default: nil

  # Install fixes.
  attribute :install_fixes, kind_of: Symbol,
            equal_to: [:none, :recommended, :all], default: :none

  # Specify a preference value or a comma-delimited list of preference values
  # to be used.
  attribute :preferences, kind_of: String, default: nil

  # Properties needed for package installation
  attribute :properties, kind_of: [String, Hash], default: nil

  attribute :profile, kind_of: String, default: nil

  # Specify repositories to be used
  attribute :repositories, kind_of: String, default: nil

  # Shared resources directory
  attribute :shared_res_dir, kind_of: String, default: nil

  # Specify to search service repositories
  attribute :use_svs_repo, kind_of: String, default: nil

  # Defines master password file
  attribute :passwd_file, kind_of: String, default: nil

  # Defines secure storage file
  attribute :storage_file, kind_of: String, default: nil

  # Username for IBM Live reposiotry.
  attribute :user, kind_of: String, default: nil

  # Password for IBM Live repository.
  attribute :password, kind_of: String, default: nil

  # Generic service repository
  attribute :url, kind_of: URI::HTTP, default:
    'http://www.ibm.com/software/repositorymanager/entitled/repository.xml'

  # File name containing package.
  attribute :name, kind_of: String, default: nil

  # Source to file.
  attribute :source, kind_of: String, default: nil

  # Checksum of file.
  attribute :checksum, kind_of: String, default: nil

  # Structure of unzip dir where to work magic.
  attribute :tmpdir, kind_of: String, default: nil

  def owner(arg = nil)
    from_attributes = run_context.node[:websphere][:user][:name]
    from_resource_block = self.instance_variable_get('@owner')

    arg = from_resource_block ||= from_attributes if arg == nil
    set_or_return(:owner, arg, kind_of: String)
  end

  def group(arg = nil)
    from_attributes = run_context.node[:websphere][:user][:group]
    from_resource_block = self.instance_variable_get('@group')

    arg = from_resource_block ||= from_attributes if arg == nil
    set_or_return(:group, arg, kind_of: String)
  end

  attr_writer :exists, :installed_packages

  # Determine if the resource already exists. This value is set by
  # the provider when the current resource is loaded.
  #
  # @return [Boolean]
  #
  def exists?
    !!@exists
  end
end
