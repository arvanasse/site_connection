module Pcss
  module SiteConnection
    def self.included(base)
      base.extend Pcss::ClassMethods
    end
  end
  
  module ClassMethods
    def establish_site_connection(site_id)
      raise(ArgumentError, "#{site_id} is not defined for #{RAILS_ENV}") unless AppConfig.sites.respond_to?(site_id)
      site_info = AppConfig.sites.send(site_id)
      site_info.respond_to?(:url) ? build_site_string_from_parts(site_info) : site_info
    end
    
    protected
    def build_site_string_from_parts(site_info)
      site = URI.parse(site_info.url)
      site.userinfo = "#{site_info.username}:#{site_info.password}"
      return site.to_s
    end
  end
end
