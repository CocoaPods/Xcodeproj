# encoding: UTF-8

require File.expand_path('../spec_helper', __FILE__)
require 'xcodeproj/server'

require 'rack/test'

set :environment, :test

describe 'Xcodeproj server' do
  extend Rack::Test::Methods

  def app
    Xcodeproj::Server
  end

  before do
    app.project_path = fixture_path('AFNetworking iOS Example.xcodeproj')
  end

  it "returns the items in the `main group'" do
    get '/'
    last_response.should.be.ok
    JSON.parse(last_response.body).should == {
      'F8E469B71395759C00DB05C8' => { 'type' => 'group', 'name' => 'Networking Extensions' },
      'F8E4696A1395739D00DB05C8' => { 'type' => 'group', 'name' => 'Classes' },
      'F8E469ED1395812A00DB05C8' => { 'type' => 'group', 'name' => 'Images' },
      'F8E469931395743A00DB05C8' => { 'type' => 'group', 'name' => 'Vendor' },
      'F8E469631395739D00DB05C8' => { 'type' => 'group', 'name' => 'Frameworks' },
      'F8E469611395739C00DB05C8' => { 'type' => 'group', 'name' => 'Products' },
    }
  end
end
