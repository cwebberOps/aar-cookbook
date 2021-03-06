require 'spec_helper'

describe 'aar::default' do

  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['aar']['db_password'] = 'dbpass'
      node.set['aar']['secret_key'] = 'an_key'
    end.converge(described_recipe)
  end

  before do
    stub_command("mysql -e 'show databases;' | grep AARdb").and_return(true)
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

  it "creates /etc/apache2/sites-enabled/AAR-apache.conf" do
    expect(chef_run).to create_template('/etc/apache2/sites-enabled/AAR-apache.conf') 
  end

  it "configures apache" do
    expect(chef_run).to render_file('/etc/apache2/sites-enabled/AAR-apache.conf') \
      .with_content(%r{Directory /var/www/AAR})
  end

  it "starts apache" do
    expect(chef_run).to start_service('apache2')
  end

  it "enables apache" do
    expect(chef_run).to enable_service('apache2')
  end

  it "subscribes to AAR-apache.conf" do
    resource = chef_run.service('apache2')
    expect(resource).to subscribe_to('template[/etc/apache2/sites-enabled/AAR-apache.conf]')
  end

  it 'downloads the tarball' do
    expect(chef_run).to extract_tar_extract('https://github.com/colincam/Awesome-Appliance-Repair/archive/master.tar.gz') \
      .with_target_dir('/var/www/')
  end

  it 'chowns the app directory' do
    expect(chef_run).to create_directory('/var/www/Awesome-Appliance-Repair-master') \
      .with_group('www-data') \
      .with_user('www-data')
  end

  it 'creates a symlink for cheating' do
    expect(chef_run).to create_link('/var/www/AAR') \
      .with_to('/var/www/Awesome-Appliance-Repair-master')
  end

  it 'creates AAR_config.py' do
    expect(chef_run).to create_template('/var/www/AAR/AAR_config.py')
  end

  it 'sets the database app user password' do
    expect(chef_run).to render_file('/var/www/AAR/AAR_config.py') \
      .with_content(%r{"passwd":"dbpass"})
  end

  it 'sets the secret key' do
    expect(chef_run).to render_file('/var/www/AAR/AAR_config.py') \
      .with_content(%r{SECRET_KEY = "an_key"})
  end
