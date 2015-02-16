# encoding: UTF-8
#
# Cookbook Name:: websphere
# Resource:: xml_generator
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

require 'builder'

module WebSphere
  # A set of helper methods shared by all resources and providers.
  #
  module XML
    # Generate XML response file for silent install of various WebSphere
    # application. You can bundle multiple applications together, for example
    # you can install IHS and WAS together.
    #
    # @param [Chef::Resource::WebspherePackage] pkg
    #   the WebSphere package resource, `new_resource`
    #
    # @return [XML]
    #   returns XML response file
    #
    # @api public
    def self.generate(pkg)
      @xml = Builder::XmlMarkup.new(indent: 2)
      profile = pkg.profile.tr(' |-', '_')
      install_location = "installLocation.#{profile}"

      header
      @xml.tag!('agent-input') do
        @xml.tag!('variables') do
          variable('sharedLocation', pkg.shared_dir)
          comment("Installation location for #{profile}")
          variable(install_location, pkg.dir)
        end
        repositories(pkg.repositories)
        profile(profile, "${#{install_location}}", pkg.properties)
        offering(profile, pkg.id, pkg.features, pkg.install_fixes, pkg.version)
        preferences(pkg.preferences)
      end
    end

    protected #      A T T E N Z I O N E   A R E A   P R O T E T T A

    # @return [XML]
    #   standard XML header <?xml version="1.0" encoding="UTF-8"?>
    #
    # @api private
    def self.header
      @xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
    end

    # Provides a method to insert comments into the XML file as needed
    #
    # @param [String] text
    #   a text comment to annotate XML file with
    #
    # @return [XML]
    #   XML formated comment
    #
    # @api private
    def self.comment(text)
      @xml.comment! text
    end

    # @yield wraps <agent-input> around block </agent-input>
    #
    # @return [XML]
    #   everything withing <agent-input> </agent-input>
    #
    # @api private
    def self.agent_input(&block)
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
    # @api private
    def self.variable(name, value)
      @xml.variable(name: name, value: value)
    end

    # @param [Array] repos
    #   a list of repositories to specify in the response file
    #
    # @return [XML]
    #   list of repositories in XML format
    #
    # @api private
    def self.repositories(*repos)
      @xml.server do |xml|
        repos.flatten.map { |repo| xml.repository(location: repo) }
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
    # @api private
    def self.profile(id, location, data, kind = nil)
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
    # @api private
    def self.offering(profile, id, features, fixes, version = nil, modify = nil)
      mod = { modify: modify } unless modify.nil?
      @xml.install(mod) do
        comment profile
        offer = { id: id,
                  profile: profile,
                  features: features,
                  installFixes: fixes }
        offer[:version] = version if version
        @xml.offering(offer)
      end
    end

    # @param [Array] preferences
    #   set of hashes containing the preferences in the response file.
    #
    # @return [XML]
    #   preferences in XML format
    #
    # @api private
    def self.preferences(preferences)
      preferences.each do |pref|
        @xml.preference(name: pref[:key], value: pref[:value])
      end
    end
  end
end
