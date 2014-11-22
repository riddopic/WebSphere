# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Recipe:: default
#

chef_gem('rubyzip') { action :nothing }.run_action(:install)

single_include 'garcon::default'
single_include 'chef_handler'

require 'timeout'      unless defined?(Timeout)
require 'zip'          unless defined?(Zip)

# ohai 'reload_was_plugin' do
#   plugin 'websphere'
#   action :nothing
# end
#
# template ::File.join(node[:ohai][:plugin_path], 'websphere.rb') do
#   owner 'root'
#   group 'root'
#   mode 00755
#   notifies :reload, 'ohai[reload_was_plugin]', :immediately
# end
#
# include_recipe 'ohai::default'

user = Concurrent::Promise.execute do
  group node[:websphere][:group] do
    not_if { node[:websphere][:group] == 'root' }
    action :create
  end

  user node[:websphere][:user] do
    comment 'Websphere Application Server'
    gid node[:websphere][:group]
    home node[:websphere][:home].call
    system true
    not_if { node[:websphere][:user] == 'root' }
    action :create
  end

  file '/etc/profile.d/websphere.sh' do
    owner 'root'
    group 'root'
    mode 00755
    content <<-EOD
      # Increase the file descriptor limit to support WAS
      ulimit -n 20480
    EOD
    action :create
  end

  file '/etc/security/limits.d/websphere.conf' do
    owner 'root'
    group 'root'
    mode 00755
    content <<-EOD
      # Increase the limits for the number of open files for the pam_limits
      # module to support WAS
      * soft nofile 20480
      * hard nofile 20480
    EOD
    action :create
  end
end

iim = Concurrent::Promise.execute { single_include 'websphere::iim' }

pkgs = Concurrent::Promise.execute do
  %w(gtk2-engines).each { |pkg| package pkg }

  multiarch = %w(gtk2 libgcc glibc)

  archs = node[:platform_version].to_i >= 6 ? %w(x86_64 i686) : %w(x86_64 i386)

  multiarch.each do |pkg|
    archs.each do |arch|
      yum_package pkg do
        arch arch
      end
    end
  end
end

timers = Hoodie::Timers::Group.new
jobs = [user, iim, pkgs]
jobs.each.with_index(1) do |job, i|
  timers.every(10+i+i) do
    Chef::Log.info "#{job}: #{job.state}" unless job.fulfilled?
  end
end

begin
  Timeout.timeout(300) do
    until user.fulfilled? && iim.fulfilled? && pkgs.fulfilled?
      jobs.each { |j| fail "#{j} #{j.state}: #{j.reason}" if j.rejected? }
      sleep 3
      timers.wait
    end
  end
rescue Timeout::Error
  Chef::Log.error 'Timeout waiting for threads:'
  jobs.each { |j| Chef::Log.error "#{j}: #{j.state}" }
  fail 'Failure due to Timeout::Error waiting on threads.'
ensure
  timers.cancel
end

creds = node[:websphere][:credential]

node[:websphere][:apps].each do |app|
  websphere app.to_sym do
    master_password_file creds[:master_password_file].call
    secure_storage_file creds[:secure_storage_file].call
    apps [app.to_sym]
    action :install
  end
end

websphere 'splines.reticulate' do
  master_password_file creds[:master_password_file].call
  secure_storage_file creds[:secure_storage_file].call
  apps node[:websphere][:apps]
  action :install
end
