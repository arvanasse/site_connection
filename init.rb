$:.unshift "#{File.dirname(__FILE__)}/lib"
require 'site_connection.rb'
ActiveResource::Base.send(:include, Koinonia::SiteConnection)
