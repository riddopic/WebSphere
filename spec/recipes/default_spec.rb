
require 'spec_helper'

describe 'websphere::default' do
  context 'basic system defaults' do
    cached(:chef_run) do
      ChefSpec::ServerRunner.new do |node, server|
        node.set[:wpf][:apps]  = [ 'pkgutil' ]
        # server.create_data_bag('auth', get_databag_item('auth', 'data'))
      end.converge(described_recipe)
    end

    # it 'includes prerequisite recipes' do
    #   expect(chef_run).to include_recipe('garcon::default')
    #   expect(chef_run).to include_recipe('chef_handler')
    # end

    describe 'creates the WebSphere user and group' do
      it 'creates a group with attributes' do
        expect(chef_run).to create_group('wasadm')
      end

      it 'creates a user with attributes' do
        expect(chef_run).to create_user('wasadm')
          .with(system: true)
          .with(group: 'wasadm')
          .with(home: '/home/wasadm')
      end
    end
  end
end
