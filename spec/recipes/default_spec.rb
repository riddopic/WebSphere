require 'spec_helper'
describe 'websphere::default' do
  context 'basic system defaults' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new do |node|
        node.set[:websphere][:apps]  = ['pkgutil']
      end.converge(described_recipe)
    end

    # doesn't show up in tally/total report from rspec
    it 'includes prerequisite recipes' do
      expect(chef_run).to include_recipe('garcon::default')
      expect(chef_run).to include_recipe('chef_handler')
    end

    it 'creates a group with attributes' do
      expect(chef_run).to create_group('wasadm')
    end

    it 'creates a user with attributes' do
      expect(chef_run).to create_user('wasadm')
        .with(system: true)
        .with(group: 'wasadm')
        .with(home: '/home/wasadm')
    end

    it 'creates a websphere.sh file in /etc/profile.d' do
      expect(chef_run).to create_file('/etc/profile.d/websphere.sh')
    end

    it 'creates a websphere-specific entry in security limit' do
      expect(chef_run).to create_file('/etc/security/limits.d/websphere.conf')
    end

    it 'creates a websphere.sh file in /etc/profile.d' do
      expect(chef_run).to create_directory('/opt/IBM')
    end

    it 'installs some packages via yum' do
      expect(chef_run).to install_yum_package('gtk2')
      expect(chef_run).to install_yum_package('glibc')
      expect(chef_run).to install_yum_package('libgcc')
    end
    it 'installs some packages' do
      expect(chef_run).to install_package('gtk2-engines')
      expect(chef_run).to install_package('lynx')
    end

    it 'creates a template' do
      expect(chef_run).to create_template('/opt/IBM/WebSphere/HTTPServer/conf/httpd.conf')
    end

    it 'installs a chef_gem' do
      expect(chef_run).to install_chef_gem('hashie')
    end

    # it 'installs websphere packages' do
    #   expect(chef_run).to install_websphere_package('iim')
    # end
  end
end
