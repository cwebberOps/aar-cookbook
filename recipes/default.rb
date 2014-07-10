#
# Cookbook Name:: aar
# Recipe:: default
#
# Copyright (C) 2014 
#
# 
#
[
  'apache2',
  'mysql-server',
  'unzip',
  'libapache2-mod-wsgi',
  'python-pip',
  'python-mysqldb'
].each do |pkg|

  package pkg

end

tar_extract 'https://github.com/colincam/Awesome-Appliance-Repair/archive/master.tar.gz' do
  target_dir '/var/www/'
end

directory '/var/www/Awesome-Appliance-Repair-master' do
  group 'www-data'
  owner 'www-data'
  recursive true
end

link '/var/www/AAR' do
  to '/var/www/Awesome-Appliance-Repair-master'
end

template '/var/www/AAR/AAR_config.py' do
  source 'AAR_config.py.erb'
end

python_pip 'flask'

template '/etc/apache2/sites-enabled/AAR-apache.conf' do
  source 'AAR-apache.conf.erb'
end

service 'apache2' do
  supports :restart => true, :reload => true
  action [:start, :enable]
  subscribes :reload, "template[/etc/apache2/sites-enabled/AAR-apache.conf]", :delayed
end

execute 'mysql[prep]' do
  command 'mysql < /var/www/AAR/make_AARdb.sql'
  not_if "mysql -e 'show databases;' | grep AARdb"
end

execute 'mysql[user]' do
  command "mysql -e \"CREATE USER 'aarapp'@'localhost' IDENTIFIED BY '#{node['aar']['db_password']}'\""
  not_if 'mysql -e "SELECT user FROM mysql.user" | grep aarapp'
end

