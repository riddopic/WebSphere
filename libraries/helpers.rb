# encoding: UTF-8
#
# Author: Stefano Harding <riddopic@gmail.com>
# Cookbook Name:: websphere
# Libraries:: helpers
#
# Copyright (C) 2014 Stefano Harding
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

require 'digest/sha2'

# Helper methods for cookbook.
#
module Helpers
  # Returns the version of the cookbook in the current run list.
  #
  # @param [String] cookbook
  #   name to retrieve version on
  #
  # @return [Integer]
  #   version of cookbook from metadata
  #
  def cookbook_version(cookbook)
    node.run_context.cookbook_collection[cookbook].metadata.version
  end

  # Return a cleanly join URI/URL segments into a cleanly normalized URL that
  # the libraries can use when constructing URIs. URI.join is pure evil.
  #
  # @param [Array<String>] paths
  #   the list of parts to join
  #
  # @return [URI]
  #
  def uri_join(*paths)
    return nil if paths.length == 0
    leadingslash = paths[0][0] == '/' ? '/' : ''
    trailingslash = paths[-1][-1] == '/' ? '/' : ''
    paths.map! { |path| path.sub(/^\/+/, '').sub(/\/+$/, '') }
    leadingslash + paths.join('/') + trailingslash
  end

  def safe_require_rubyzip
    begin
      require 'zip' unless defined?(Zip)
    rescue LoadError
      chef_gem('rubyzip'){action :nothing}.run_action(:install)
      require 'zip'
    end
  end

  def unzip(zip_file, unzip_dir, remove_after = false)
    safe_require_rubyzip

    Zip::File.open(zip_file) do |zip|
      zip.each do |entry|
        path = ::File.join(unzip_dir, entry.name)
        FileUtils.mkdir_p(::File.dirname(path))
        if ::File.exists?(path) && !::File.directory?(path)
          FileUtils.rm(path)
        end
        zip.extract(entry, path)
      end
    end
    FileUtils.rm(zip) if remove_after
  end
end

# Include the helpers module into the main recipe DSL
Chef::Recipe.send(:include, Helpers)
Chef::Resource.send(:include, Helpers)
Chef::Provider.send(:include, Helpers)
