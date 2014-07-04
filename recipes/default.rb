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
  'unzip'
].each do |pkg|

  package pkg

end
