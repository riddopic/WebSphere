# encoding: UTF-8
#
# Author: Stefano Harding <sharding@trace3.com>
# Cookbook Name:: websphere
# Recipe:: iim
#

single_include 'websphere::default'

iim = node[:websphere][:iim]
owner = node[:websphere][:user]
group = node[:websphere][:group]
dstdir = iim[:install_location]

[
  dstdir,
  ::File.join(dstdir, 'IBM'),
  node[:websphere][:shared_location],
  node[:websphere][:data_location]
].each do |dir|
  directory dir do
    owner node[:websphere][:user]
    group node[:websphere][:group]
    mode 00755
    recursive true
    action :create
  end
end

guard_file = ::File.join(dstdir, '/IBM/InstallationManager/eclipse/tools/imcl')

with_tmp_dir do |tmpdir|
  directory tmpdir do
    owner node[:websphere][:user]
    group node[:websphere][:group]
    mode 00755
    recursive true
    # TODO: Fix guard
    not_if { ::File.exist?(guard_file) }
    notifies :delete, "directory[#{tmpdir}]"
    action :create
  end

  file = iim[:file]["#{node[:websphere][:iim][:install_type]}"]
  zip_file = ::File.join(tmpdir, file[:name])
  response_file = ::File.join(iim[:install_location], 'install.xml')

  source = unshorten(file[:source])
  files = if ::File.basename(URI.parse(source).path) == file[:name]
    [source]
  else
    [uri_join(source, file[:name])]
  end
  server = URI.parse(source).host

  ruby_block :remote_files do
    block { remote_files(files, tmpdir, server, owner: owner, group: group) }
    not_if { ::File.exist?(guard_file) }
    notifies :run, 'ruby_block[unzip]', :immediately
    action :create
  end

  ruby_block :unzip do
    block { unzip(zip_file, tmpdir, owner: owner, group: group, purge: true) }
    notifies :create, "template[#{response_file}]", :immediately
    notifies :create, "directory[#{dstdir}]", :immediately
    notifies :create, "directory[#{dstdir}]", :immediately
    notifies :create, "directory[#{::File.join(dstdir, 'IBM')}]", :immediately
    notifies :create, "directory[#{node[:websphere][:shared_location]}]", :immediately
    notifies :create, "directory[#{node[:websphere][:data_location]}]", :immediately
    action :nothing
  end

  template response_file do
    source 'empty.erb'
    owner node[:websphere][:user]
    group node[:websphere][:group]
    mode 00644
    variables data: iim_response_file(iim, true, true)
    notifies :run, 'execute[splines reticulate]', :immediately
    action :nothing
  end

  cmd = lambda do
    if node[:websphere][:user] == 'root'
      "./installc -acceptLicense -showProgress " \
        "-dataLocation #{node[:websphere][:data_location]}"
    else
      "./userinstc -acceptLicense -showProgress " \
        "-dataLocation #{node[:websphere][:data_location]}"
    end
  end

  work_dir = file.attribute?(:work_dir) ?
    ::File.join(tmpdir, file[:work_dir]) : tmpdir

  execute 'splines reticulate' do
    command cmd.call
    cwd work_dir
    user node[:websphere][:user]
    group node[:websphere][:group]
    not_if { ::File.exist?(guard_file) }
    notifies :delete, "directory[#{tmpdir}]"
    action :nothing
  end
end

creds = node[:websphere][:credential]

websphere_credentials :secret do
  master_password_file creds[:master_password_file].call
  secure_storage_file creds[:secure_storage_file].call
  user creds[:username]
  password creds[:password]
  sensitive true
  not_if { creds[:username].nil? }
  action :store
end
