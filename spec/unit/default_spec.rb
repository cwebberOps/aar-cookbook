require 'spec_helper'

describe 'aar::default' do

  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  [
    'apache2',
    'mysql-server',
    'unzip'
  ].each do |pkg|

    it "installs #{pkg}" do
      expect(chef_run).to install_package(pkg)
    end

  end

end
