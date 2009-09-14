require File.join(File.dirname(__FILE__), 'config')

class RemoteResource < ActiveResource::Base
end

describe Koinonia::SiteConnection do
  before :all do
    @no_site_defined = {
      :environment => 'test',
      :load_path   => File.join( '..', 'config', 'no_sample.yml' )
    }

    @no_environment_defined = {
      :environment => 'test',
      :load_path   => File.join( '..', 'config', 'no_test.yml' )
    }
  end

  describe 'calling establish_site_connection' do
    it 'should raise an argument error if the requested Rails environment is not configured' do
      lambda{ RemoteResource.establish_site_connection(:sample, @no_environment_defined) }.
        should raise_error(ArgumentError, "Test is not defined in #{@no_environment_defined[:load_path]}")
    end

    it 'should raise an argument error if the requested connection is not defined for the Rails environment' do
      lambda{ RemoteResource.establish_site_connection(:sample, @no_site_defined) }.
        should raise_error(ArgumentError, 'Sample is not defined for test environment')
    end

    it 'should raise an argument error if no parameters are provided' do
      lambda{ RemoteResource.establish_site_connection }.should raise_error(ArgumentError, 'Must provide a site id or URI options')
    end
  end
end
