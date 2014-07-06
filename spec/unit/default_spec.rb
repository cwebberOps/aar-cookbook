require 'spec_helper'

describe 'aar::default' do

  let(:chef_run) do
    ChefSpec::Runner.new.converge(described_recipe)
  end

  [
    'apache2',
    'mysql-server',
    'unzip',
    'libapache2-mod-wsgi',
    'python-pip',
    'python-mysqldb'
  ].each do |pkg|

    it "installs #{pkg}" do
      expect(chef_run).to install_package(pkg)
    end

  end

  it "installs flask" do
    expect(chef_run).to install_python_pip('flask')
  end

  it "configures apache" do
    expect(chef_run).to render_file('/etc/apache2/sites-enabled/AAR-apache.conf') \
      .with_content(%r{Directory /var/www/AAR})
  end

end
