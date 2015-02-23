require 'spec_helper'

describe 'websphere::iim' do
  cached(:chef_run) do
    ChefSpec::ServerRunner.new do |node|
      node.set[:websphere][:apps]  = ['pkgutil']
    end.converge(described_recipe)
  end

  it 'creates a base directory for websphere' do
    expect(chef_run).to create_directory('/opt/IBM')
    # expect(chef_run).to create_directory(chef_run.node[:websphere][:base_dir])
  end
end
