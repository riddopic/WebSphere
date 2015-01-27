# encoding: UTF-8
#
# Cookbook Name:: websphere
# Libraries:: cli_helpers
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

require 'find' unless defined?(Find)

module WebSphere
  # Instance methods that are added when you include WebSphere::CliHelpers
  #
  module CliHelpers
    # Returns a hash using col1 as keys and col2 as values.
    #
    # @example zip_hash([:name, :age, :sex], ['Earl', 30, 'male'])
    #   => { :age => 30, :name => "Earl", :sex => "male" }
    #
    # @param [Array] col1
    #   Containing the keys.
    # @param [Array] col2
    #   Values for hash.
    #
    # @return [Hash]
    #
    # @api public
    def zip_hash(col1, col2)
      col1.zip(col2).inject({}) { |r, i| r[i[0]] = i[1]; r }
    end

    # Recursivly searh a path for a file
    #
    # @param [String] dir
    #   a directory to recusivly search
    # @param [String] file
    #   the name of a file to search for
    #
    # @return [String]
    #   the full path to the file if found
    #
    # @api private
    def path_to(dir, file)
      Find.find(dir) { |p| return p if ::File.basename(p) =~ /^#{file}$/ }
    rescue Errno::ENOENT
      nil
    end

    # Finds a command in $PATH
    #
    # @param [String] cmd
    #   the command to searh for
    #
    # @return [String, NilClass]
    #
    # @api public
    def which(cmd)
      if Pathname.new(cmd).absolute?
        ::File.executable?(cmd) ? cmd : nil
      else
        paths = %w(/bin /usr/bin /sbin /usr/sbin)
        paths << ::File.join(lazypath(node[:wpf][:eclipse_dir]), 'tools')
        paths << ::File.join(lazypath(node[:was][:dir]), 'bin')
        paths << ENV.fetch('PATH').split(::File::PATH_SEPARATOR)
        paths.flatten.uniq.each do |path|
          possible = ::File.join(path, cmd)
          return possible if ::File.executable?(possible)
        end
        nil
      end
    end

    # Return a tempfile
    #
    # @return [String]
    # @api private
    def tmpdir
      @tmpdir ||= Dir.mktmpdir(SecureRandom.hex(3))
    end

    # Return the full path to the command
    #
    # @return [String]
    #
    # @api private
    [:__imcl__].each do |cmd|
      define_method(cmd) do
        which(cmd.to_s.tr!('_', ''))
      end
    end

    # Handler for the `imcl` command line utility
    #
    # @param [String, Array] args
    #   additional arguments and/or operand
    #
    # @return [String]
    #   `#stdout` with results of the command
    #
    # @raise [Errno::EACCES]
    #   When you are not privileged to execute the command
    # @raise [Errno::ENOENT]
    #   When the command is not available on the system (or in the $PATH)
    # @raise [Chef::Exceptions::CommandTimeout]
    #   When the command does not complete within timeout (default: 60s)
    #
    # @api public
    def imcl(*args)
      (run ||= []) << (which('imcl') || path_to(tmpdir, 'imcl'))
      run << args.flatten.join(' ')
      opts = { user: new_resource.owner, group: new_resource.group }
      Chef::Log.info shell_out!(run.flatten.join(' '), opts).stdout
    end

    # Returns an Array of Hashes with currently installed WebSphere
    # applications, path to the installation, package ID and version number
    #
    # @example
    #   installed
    #   # => [{:path=>"/opt/IBM/InstallationManager/eclipse",
    #         :id_ver=>"com.ibm.cic.agent_1.8.1000.20141125_2157",
    #         :name=>"IBM Installation Manager",
    #         :version=>"1.8.1"},
    #        {:path=>"/opt/IBM/WebSphere/AppServer",
    #         :id_ver=>"com.ibm.websphere.ND.v85_8.5.5003.20140730_1249",
    #         :name=>"IBM WebSphere Application Server Network Deployment",
    #         :version=>"8.5.5.3"}]
    #
    # @return [Array]
    #   with keys :path, :package_id, :name, :version
    #
    # @api public
    def installed
      return nil if __imcl__.nil?
      cmd = "#{__imcl__} listinstalledpackages -long"
      opts = { user: new_resource.owner, group: new_resource.group }
      keys = [:path, :id_ver, :name, :version]
      lines = shell_out!(cmd, opts).stdout.split("\n")
      lines.map do |line|
        line = line.encode('UTF-8', replace: '')
        zip_hash(keys, line.split(':').map(&:strip))
      end
    end

    # Check to see if the package is already installed on the system. Returns
    # true when a match is found. You must pass the package ID and version
    # number, pay careful attention, some packages use a dot to seperate ID and
    # version while others use an underscore (thanks WebSphere!). We match the
    # first half (id) and the last half (version) with any single character
    # a literal dot '.'
    #
    # @example
    #   installed?('com.ibm.websphere.PLG', 'v85_8.5.5003.20140730_1249')
    #   # => true
    #
    # @param [String] id
    #   the uniq IBM product ID
    # @param [String] ver
    #   the product version number
    #
    # @return [TrueClass, FalseClass]
    #
    # @api public
    def installed?(id = new_resource.id, ver = new_resource.version)
      installed.map { |i| return true if i[:id_ver].match(/^#{id}.#{ver}$/) }
      false
    rescue # blow chunks avoidance, don't blow chunks when it's nil
      false
    end

    # Validate and return an unshortened URL, checks to see if the URL supplied
    # has been shortened return the original URL
    #
    # @param[Hash] file
    #   file will have the keys :name, :source and :checksum
    #
    # @return[String]
    #
    # @api public
    def source_from(file)
      source = unshorten(file[:source])
      if ::File.basename(URI.parse(source).path) == file[:name]
        source
      else
        uri_join(source, file[:name])
      end
    end

    # Return the full path to the command
    #
    # @return [String]
    #
    # @api private
    [:__manageprofiles__].each do |cmd|
      define_method(cmd) do
        which("#{cmd}.sh".tr!('_', ''))
      end
    end

    # Handler for the `manageprofiles.sh` command line utility
    #
    # @param [String, Array] args
    #   additional arguments and/or operand
    #
    # @return [String]
    #   `#stdout` with results of the command
    #
    # @raise [Errno::EACCES]
    #   When you are not privileged to execute the command
    # @raise [Errno::ENOENT]
    #   When the command is not available on the system (or in the $PATH)
    # @raise [Chef::Exceptions::CommandTimeout]
    #   When the command does not complete within timeout (default: 60s)
    #
    # @api public
    def manageprofiles(*args)
      subcmd = Hoodie::Inflections.dasherize("-#{args.shift.to_s}")
      (run ||= []) << which('manageprofiles.sh')
      run << subcmd << args.flatten.join(' ')
      opts = { user: new_resource.owner, group: new_resource.group }
      Chef::Log.info shell_out!(run.flatten.join(' '), opts).stdout
    end

    # Boolean, checks to see if the profile has already been created, returns
    # `true` if it has, otherwise `false`
    #
    # @param [String] profile_name
    #   the name of the profile
    #
    # @return [TrueClass, FalseClass]
    #
    # @api public
    def created?(profile_name = new_resource.profile_name)
      profiles.map { |p| return true if p.include?(profile_name) }
      false
    end

    # List the WebSphere Application Server profiles
    #
    # @return [Array]
    #
    # @api public
    def profiles
      return nil if __manageprofiles__.nil?
      cmd  = "#{__manageprofiles__} -listProfiles"
      opts = { user: new_resource.owner, group: new_resource.group }
      shell_out!(cmd, opts).stdout.split("\n")
    end

    # Boolean, true when the WebSphere profile instance is running, otherwise
    # false
    #
    # @return [TrueClass, FalseClass]
    # @api public
    def running?
      return false unless @current_resource.created
      profile(status).map { |l| return true if l.include?('is STARTED') }

      false
    end

    # Start, stop or return the status of a WebSphere profile instance
    #
    # @param [Symbol] run_action
    #   the action to perform of type `:start`, `:stop`, `:status`
    #
    # @return [Array]
    #   result of action
    #
    # @api public
    def profile(run_action)
      opts = { user: new_resource.owner, group: new_resource.group }
      shell_out!(run_action.flatten.join(' '), opts).stdout.split("\n")
    end

    private #   P R O P R I E T À   P R I V A T A   Vietato L'accesso

    # @api private
    define_method(:start) do
      (run ||= []) << path_to(new_resource.profile_path, 'startManager.sh')
      run << new_resource._?(:profile_name, '-profileName')
    end

    # @api private
    define_method(:stop) do
      (run ||= []) << path_to(new_resource.profile_path, 'stopManager.sh')
      run << new_resource._?(:admin_username,  '-username')
      run << new_resource._?(:admin_password,  '-password')
      run << new_resource._?(:profile_name, '-profileName')
    end

    # @api private
    define_method(:status) do
      (run ||= []) << path_to(new_resource.profile_path, 'serverStatus.sh')
      run << '-all'
      run << new_resource._?(:admin_username,  '-username')
      run << new_resource._?(:admin_password,  '-password')
      run << new_resource._?(:profile_name, '-profileName')
    end
  end
end
