require 'site_connection'
ActiveResource::Base.send(:include, Pcss::SiteConnection)
