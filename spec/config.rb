require 'rubygems'
require 'active_resource'

require File.join(File.dirname(__FILE__), '..', 'init.rb')

require 'spec'

unless defined? Rails
  class Rails
    class << self
      def root
        @root ||= File.join(File.dirname(__FILE__), '..')
      end

      def root=(filepath)
        @root = filepath
      end

      def env
        @env ||= 'test'
      end

      def env=(environment)
        @env = environment
      end
    end
  end
end
