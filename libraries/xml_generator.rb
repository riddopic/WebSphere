# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Library:: xml_generator
#

require 'builder'
require_relative 'helpers'

module WebSphere
  # A set of helper methods shared by all resources and providers.
  #
  module XMLGenerator
    # Setup include hooks
    #
    def self.included(base)
      include(ClassMethods)

      base.send(:include, ClassMethods)
    end
    private_class_method :included

    # Set of methods to generate a response file in XML using the buider gem.
    #
    module ClassMethods
      include WebSphere::Helpers

      # Generate XML response file for silent install of various WebSphere
      # application. You can bundle multiple applications together, for example
      # you can install IHS and WAS together.
      #
      # @param [Array] pkg
      #   the contents of the attribute for each application being passed in
      # @param [Array]  repos
      #   a list of repositories to specify in the response file
      #
      # @return [XML]
      #   returns XML response file
      #
      def xml_for(pkg, repos)
        @xml = Builder::XmlMarkup.new(indent: 2)
        header
        @xml.tag!('agent-input') do
          @xml.tag!('variables') do
            variable('sharedLocation', node[:websphere][:shared_dir])

            pkg.each do |p|
              name = "installLocation.#{p[:profile].tr(' |-', '_')}"
              value = p[:install_location]
              comment "Installation location for #{p[:profile]}"
              variable(name, value)
            end
          end

          repos(repos)
          pkg.each do |p|
            dir = "${installLocation.#{p[:profile].tr(' |-', '_')}}"
            profile(p[:profile], dir, p[:data])
            offering(p[:profile], p[:id], p[:version],
                     p[:features], p[:fixes], false)
          end
          preferences(node[:websphere][:preferences])
        end
      end

      protected #      A T T E N Z I O N E   A R E A   P R O T E T T A

      # @return [XML]
      #   standard XML header <?xml version="1.0" encoding="UTF-8"?>
      #
      # @!visibility private
      def header
        @xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
      end

      # @param [String] text
      #   provides a way to add a text comment to the XML
      #
      # @return [XML]
      #   XML formated comment
      #
      # @!visibility private
      def comment(text)
        @xml.comment! text
      end

      # @yield wraps <agent-input> around block </agent-input>
      #
      # @return [XML]
      #   everything withing <agent-input> </agent-input>
      #
      # @!visibility private
      def agent_input(&block)
        @xml.tag!('agent-input') { block.call }
      end

      # @param [String] name
      #   name of the variable
      # @param [String] value
      #   value for variable
      #
      # @return [XML]
      #   XML representation of `variable`
      #
      # @!visibility private
      def variable(name, value)
        @xml.variable(name: name, value: value)
      end

      # @param [Array] repos
      #   a list of repositories to specify in the response file
      #
      # @return [XML]
      #   list of repositories in XML format
      #
      # @!visibility private
      def repos(repos)
        @xml.server do |x|
          if repos.respond_to?(:each)
            repos.each { |repo| x.repository(location: repo) }
          else
            x.repository(location: repos)
          end
        end
      end

      # @param [String] id
      #   the Uniq product ID of the targeted installation
      # @param [String] location
      #   installation directory for the selected application
      # @param [Array] data
      #   data attributes for the specific application offering
      # @param [String] kind
      #   IIM sets a kind=self, has no other use
      #
      # @return [XML]
      #   profile in XML format
      #
      # @!visibility private
      def profile(id, location, data, kind = nil)
        prof = { id: id, installLocation: location }
        prof = { kind: kind }.merge(prof) if kind
        @xml.profile(prof) do
          comment 'Common Data:'
          data.each do |d|
            @xml.data(key: d[:key], value: d[:value])
          end
        end
      end

      # @param [String] profile
      #   the unique profile ID of the targeted installation
      # @param [String] id
      #   the Uniq product ID of the targeted installation
      # @param [String, Integer] version
      #   version number of the targeted installation
      # @param [String]  features
      #   feature provided by the targeted application
      # @param [String] fixes
      #   valid values are none, do not install any fixes; all, install all
      #   available fixes; recommended, install recommended fixes
      # @param [TrueClass, FalseClass] modify
      #   if true, IIM will modify an existing application installation
      #
      # @return [XML]
      #   offering in XML format
      #
      # @!visibility private
      def offering(profile, id, version, features, fixes, modify = nil)
        mod = { modify: modify } unless modify.nil?
        @xml.install(mod) do
          comment profile
          offer = { profile: profile, id: id,
                    features: features, installFixes: fixes }
          offer.merge(version: version) if version
          @xml.offering(offer)
        end
      end

      # @param [Array] preferences
      #   set of hashes containing the preferences in the response file.
      #
      # @return [XML]
      #   preferences in XML format
      #
      # @!visibility private
      def preferences(preferences)
        preferences.each do |pref|
          @xml.preference(name: pref[:key], value: pref[:value])
        end
      end
    end
  end

  unless Chef::Recipe.ancestors.include?(WebSphere::XMLGenerator)
    Chef::Recipe.send(:include, WebSphere::XMLGenerator)
    Chef::Resource.send(:include, WebSphere::XMLGenerator)
    Chef::Provider.send(:include, WebSphere::XMLGenerator)
  end
end
