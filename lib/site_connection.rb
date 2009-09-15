require 'yaml'
require 'erb'
require 'uri'
module Koinonia
  module SiteConnection
    def self.included(receiver)
      receiver.class_eval do
        extend Koinonia::SiteConnection::ClassMethods
      end
    end

    module ClassMethods
      def establish_site_connection(*args)
        @site_options = args.last.is_a?(Hash) ? args.pop : {}
        initialize_from_site_options

        @site_id = args.shift
        if @site_id.nil? && @site_options.empty?
          raise(ArgumentError, "Must provide a site id or URI options")
        end

        add_site_options_from_config_file if @site_id.is_a?(Symbol)
        @attributes_only ? @site_options : location_with_http_user
      end

      private
      def initialize_from_site_options
        @attributes_only = @site_options.delete(:attributes_only)

        @load_path = @site_options.delete(:load_path) || File.join(Rails.root, 'config', 'sites.yml')
        @environment = (@site_options.delete(:environment) || Rails.env).to_sym
      end

      def add_site_options_from_config_file
        load_environment

        raise(ArgumentError, "#{@site_id.to_s.capitalize} is not defined for #{@environment} in #{@load_path}") unless @@sites[@site_id]
        @site_options.merge!( @@sites[@site_id].dup  )
      end

      def load_environment
        if configuration_file_exists?
          environment_configuration = load_environment_from_configuration_file

          @@sites = environment_configuration.inject({}) do |sites, (site_key, site_attr)|
            sites.merge(site_key.to_sym => symbolize_keys(site_attr))
          end
        end
      end

      def configuration_file_exists?
        unless File.exists?(@load_path)
          raise ArgumentError, "Configuration file does not exist: #{@load_path}"
        end
        true
      end

      def load_environment_from_configuration_file
        environment_configuration = symbolize_keys(YAML.load(ERB.new(IO.read(@load_path)).result))

        unless environment_configuration.include? @environment
          raise ArgumentError, "#{@environment.to_s.capitalize} is not defined in #{@load_path}"
        end

        environment_configuration[@environment]
      end

      def symbolize_keys(hash)
        hash.inject({}) do |symbolized, (key, val)|
          key_id = key.respond_to?(:to_sym) ? key.to_sym : key
          symbolized.merge key_id => val
        end
      end

      def location_with_http_user
        uri = URI.parse( domain_location )
        if @site_options[:user]
          uri.user = URI.encode(@site_options[:user])
          uri.password = URI.encode(@site_options[:password]) if @site_options[:password]
        end
        return uri
      end

      def domain_location
        url = ''

        url << (@site_options.delete(:protocol) || 'http')
        url << '://' unless url.match("://")

        raise "Missing host to link to! Please provide :host parameter with\n#{@site_options}" unless @site_options[:host]

        url << @site_options.delete(:host)
        url << ":#{@site_options.delete(:port)}" if @site_options.key?(:port)
        return url
      end
    end
  end
end
