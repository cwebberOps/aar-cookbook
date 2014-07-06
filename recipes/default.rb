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

python_pip 'flask'
