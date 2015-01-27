# encoding: UTF-8
#
# Cookbook Name:: websphere
# Libraries:: helpers
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

require 'tmpdir'
require 'thread'
require 'securerandom'

module WebSphere
  # A set of helper methods shared by all resources and providers.
  #
  module Helpers
    # Creates a temp directory executing the block provided. When done the
    # temp directory and all it's contents are garbage collected.
    #
    # @param block [Block]
    #
    def with_tmp_dir(&block)
      Dir.mktmpdir(SecureRandom.hex(3)) do |tmp_dir|
        Dir.chdir(tmp_dir, &block)
      end
    end

    # Takes a lazy path and returns a less lazy one
    #
    # @param [Chef::DelayedEvaluator, Proc] path
    # @return [String]
    # @api private
    def lazypath(path)
      if path && path.is_a?(Chef::DelayedEvaluator)
        path = path.dup
        path = instance_eval(&path.call)
      end
      path
    rescue
      path.call
    end

    # Wait the given number of seconds for the block operation to complete.
    # @note This method is intended to be a simpler and more reliable
    # replacement to the Ruby standard library `Timeout::timeout` method.
    #
    # @param [Integer] seconds
    #   the number of seconds to wait
    #
    # @return [Object]
    #   the result of the block operation
    #
    # @raise [WebSphere::TimeoutError]
    #   when the block operation does not complete in the allotted number of
    #   seconds.
    #
    # @api public
    def timeout(seconds)
      thread = Thread.new { Thread.current[:result] = yield }
      success = thread.join(seconds)
      if success
        return thread[:result]
      else
        raise TimeoutError
      end
    ensure
      Thread.kill(thread) unless thread.nil?
    end

    def hash_to(resource, spec, notifications = [], actions = [])
      spec = ::Mash.new(spec.to_hash)
      name = spec.delete 'name'

      send resource.to_sym, name do
        spec.each do |k, v|
          send k.to_sym, v
        end

        notifications.each do |notify_spec|
          raise 'Not a valid notification spec' unless notify_spec.is_a?(Array)
          notify_spec     = notify_spec.dup
          notify_action   = notify_spec.shift.to_sym
          notify_resource = notify_spec.shift
          notify_timing   = notify_spec.shift || :delayed
          send :notifies, notify_action, notify_resource, notify_timing
        end

        actions = [actions] unless actions.is_a?(Array)
        actions.each { |action| send :action, action.to_sym }
      end
    end

    def hash_each(resource, specs, notifications = [], actions = [])
      specs.each do |name, spec|
        reify resource, spec.merge({name: name}), notifications, actions
      end
    end

    def hash_packages(packages, notifications = [], actions = [])
      reify_each :package, packages, notifications, actions
    end
  end

  # Generic Namespace for custom error errors and exceptions for the Cookbook
  #
  module Exceptions
    class NotImplementedError < RuntimeError; end
    class ResourceNotFound < RuntimeError; end
    class TimeoutError < RuntimeError; end
  end

  # Adds the methods in the Odsee::Helpers module.
  #
  unless Chef::Recipe.ancestors.include?(WebSphere::Helpers)
    Chef::Recipe.send(:include,   WebSphere::Helpers)
    Chef::Resource.send(:include, WebSphere::Helpers)
    Chef::Provider.send(:include, WebSphere::Helpers)
  end
end
