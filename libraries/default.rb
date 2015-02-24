# encoding: UTF-8
#
# Cookbook Name:: websphere
# Libraries:: default
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

require_relative 'xml_generator'

# Include hooks to extend with class and instance methods.
#
module WebSphere
  # Include hooks to extend Resource with class and instance methods.
  #
  module Resource
  end

  # Include hooks to extend Providers with class and instance methods.
  #
  module Provider
    include Chef::Mixin::ShellOut
    include WebSphere::XML
    include WebSphere::CliHelpers

    # Wraps shell_out in a monitor for thread safety.
    # @api private
    __shell_out__ = instance_method(:shell_out!)
    define_method(:shell_out!) do |*args, &_block|
      lock.synchronize { __shell_out__.bind(self).call(*args) }
    end
  end

  # Extends a descendant with class and instance methods
  #
  # @param [Class] descendant
  # @return [undefined]
  # @api private
  def self.included(descendant)
    super

    descendant.class_exec { include WebSphere::Helpers }
    descendant.class_exec { include WebSphere::Exceptions }

    if descendant < Chef::Resource
      descendant.class_exec { include Garcon::Resource }
      descendant.class_exec { include WebSphere::Resource }

    elsif descendant < Chef::Provider
      descendant.class_exec { include Garcon::Provider }
      descendant.class_exec { include WebSphere::Provider }
    end
  end
  private_class_method :included
end
