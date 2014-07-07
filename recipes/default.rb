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

python_pip 'flask'

template '/etc/apache2/sites-enabled/AAR-apache.conf' do
  source 'AAR-apache.conf.erb'
end

service 'apache2' do
  supports :restart => true, :reload => true
  action [:start, :enable]
  subscribes :reload, "template[/etc/apache2/sites-enabled/AAR-apache.conf]", :delayed
end
