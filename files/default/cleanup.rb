# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Handler:: cleanup
#

require 'chef'
require 'chef/handler'

class Cleanup < Chef::Handler
  attr_reader :files

  def initialize(files)
    @files = files
  end

  def report
    unless success?
      Chef::Log.info 'Cleanup handler is mopping up your mess!'
      cleanup
    end
  end

  def cleanup
    @files.each do |file|
      if ::File.exist? file
        Chef::Log.debug "Deleting #{file} ..."
        FileUtils.remove_entry file
      end
    end
  end
end
