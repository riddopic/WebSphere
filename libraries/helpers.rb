# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Libraries:: helpers
#

require 'tmpdir'
require 'digest/sha2'
require 'securerandom'

module WebSphere
  # A set of helper methods shared by all resources and providers.
  #
  module Helpers
    def self.included(base)
      include(ClassMethods)

      base.send(:include, ClassMethods)
    end
    private_class_method :included

    module ClassMethods
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

      # Return a cleanly join URI/URL segments into a cleanly normalized URL
      # that we can use when constructing URIs. URI.join is pure evil.
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

      # Unshorten a URL.
      #
      # @param url [String] A shortened URL
      # @param [Hash] opts
      # @option opts [Integer] :max_level
      #   max redirect times
      # @option opts [Integer] :timeout
      #   timeout in seconds, for every request
      # @option opts [Boolean] :use_cache
      #   use cached result if available
      #
      # @return Original url, a url that does not redirects
      def unshorten(url, opts= {})
        options = {
          max_level: opts.fetch(:max_level, 10),
          timeout:   opts.fetch(:timeout, 2),
          use_cache: opts.fetch(:overflow_policy, true)
        }
        url = (url =~ /^https?:/i) ? url : "http://#{url}"
        _unshorten_(url, options)
      end

      def with_tmp_dir(&block)
        Dir.mktmpdir(SecureRandom.hex(3)) do |tmp_dir|
          Dir.chdir(tmp_dir, &block)
        end
      end

      def safe_require_rubyzip
        require 'zip' unless defined?(Zip)
      rescue LoadError
        chef_gem('rubyzip') { action :nothing }.run_action(:install)
        require 'zip'
      end

      def unzip(zip_file, unzip_dir, opts)
        remove_after = opts.fetch(:remove_after, false)
        owner        = opts.fetch(:owner, nil)
        group        = opts.fetch(:group, nil)

        Zip::File.open(zip_file) do |zip|
          zip.each do |entry|
            path = ::File.join(unzip_dir, entry.name)
            FileUtils.mkdir_p(::File.dirname(path))
            if ::File.exist?(path) && !::File.directory?(path)
              FileUtils.rm(path)
            end
            zip.extract(entry, path)
            if owner && group
              FileUtils.chown(owner, group, path)
            elsif owner
              FileUtils.chown(owner, nil, path)
            elsif group
              FileUtils.chown(nil, group, path)
            end
          end
        end
        FileUtils.rm(zip_file) if remove_after
      end

      NotImplementedError = Class.new StandardError
      class << self
        attr_reader :node
      end

      private #   P R O P R I E T À   P R I V A T A   Vietato L'accesso

      @@cache = { }

      def _unshorten_(url, options, level = 0)
        return @@cache[url] if options[:use_cache] && @@cache[url]
        return url if level >= options[:max_level]
        uri = URI.parse(url) rescue nil
        return url if uri.nil?

        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = options[:timeout]
        http.read_timeout = options[:timeout]
        http.use_ssl = true if uri.scheme == 'https'

        if uri.path && uri.query
          response = http.request_head("#{uri.path}?#{uri.query}") rescue nil
        elsif uri.path && !uri.query
          response = http.request_head(uri.path) rescue nil
        else
          response = http.request_head('/') rescue nil
        end

        if response.is_a? Net::HTTPRedirection and response['location'] then
          location = URI.encode(response['location'])
          location = (uri + location).to_s if location
          @@cache[url] = _unshorten_(location, options, level + 1)
        else
          url
        end
      end
    end
  end

  unless Chef::Recipe.ancestors.include?(WebSphere::Helpers)
    Chef::Recipe.send(:include, WebSphere::Helpers)
    Chef::Resource.send(:include, WebSphere::Helpers)
    Chef::Provider.send(:include, WebSphere::Helpers)
  end
end
