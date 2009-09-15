require 'uri'
require 'uri/generic'

$:.unshift File.dirname(__FILE__)
require 'config'

describe Koinonia::SiteConnection do
  describe 'calling establish_site_connection with a valid configuration file' do
    before :each do
      @test_options = {:environment=>'test', :load_path => File.join(File.dirname(__FILE__), '..', 'config', 'sites.yml')}
    end

    {
      'development' => URI::HTTP.build( :host=>'dev.myapp.com', :scheme=>80),
      'test'        => URI::HTTP.build( :host=>'test.myapp.com', :scheme=>80),
      'production'  => URI::HTTPS.build(:host=>'sample.myapp.com')
    }.each do |env, expected_site|
      it "should load a unique host for the #{env} environment" do
        test_options = @test_options.merge :environment=>env

        class RemoteThing < ActiveResource::Base; end
        RemoteThing.instance_eval do
          self.site = self.establish_site_connection :sample, test_options
        end

        RemoteThing.site.should == expected_site
      end
    end

    it "should support multiple named hosts per environment" do
      class RemoteThingOne < ActiveResource::Base; end
      RemoteThingOne.instance_eval do
        self.site = self.establish_site_connection :sample, @test_options
      end
      RemoteThingOne.site.should == URI::HTTP.build(:host=>'test.myapp.com', :port=>80)

      class RemoteThingTwo < ActiveResource::Base; end
      RemoteThingTwo.instance_eval do
        self.site = self.establish_site_connection :alternate, @test_options
      end
      RemoteThingTwo.site.should == URI::HTTP.build(:host=>'alt.myapp.com', :port=>80)
    end

    it "should include the http basic user if provided" do
      class UserThing < ActiveResource::Base; end
      UserThing.instance_eval do
        self.site = self.establish_site_connection :user_only, @test_options
      end
      UserThing.site.should == URI::HTTP.build(:host=>'test.myapp.com', :userinfo=>'andy')
    end

    it "should include the http basic user and password if both are provided" do
      class AnotherThing < ActiveResource::Base; end
      AnotherThing.instance_eval do
        self.site = self.establish_site_connection :user_and_password, @test_options
      end
      AnotherThing.site.should == URI::HTTP.build(:host=>'test.myapp.com', :userinfo=>'andy:secret')
    end

    it "should ignore the http basic password if it is provided without a user" do
      class PasswordThing < ActiveResource::Base; end
      PasswordThing.instance_eval do
        self.site = self.establish_site_connection :password_only, @test_options
      end
      PasswordThing.site.should == URI::HTTP.build(:host=>'test.myapp.com')
    end
  end
end
