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

  after do
    app.reset!
  end

  it "returns the items in the `main group'" do
    get '/'
    last_response.should.be.ok
    JSON.parse(last_response.body).should == [
      { 'id' => 'F8E469B71395759C00DB05C8', 'type' => 'group', 'name' => 'Networking Extensions' },
      { 'id' => 'F8E4696A1395739D00DB05C8', 'type' => 'group', 'name' => 'Classes' },
      { 'id' => 'F8E469ED1395812A00DB05C8', 'type' => 'group', 'name' => 'Images' },
      { 'id' => 'F8E469931395743A00DB05C8', 'type' => 'group', 'name' => 'Vendor' },
      { 'id' => 'F8E469631395739D00DB05C8', 'type' => 'group', 'name' => 'Frameworks' },
      { 'id' => 'F8E469611395739C00DB05C8', 'type' => 'group', 'name' => 'Products' },
    ]
  end

  it "returns the items in a specific group" do
    get '/groups/F8E469B71395759C00DB05C8'
    last_response.should.be.ok
    JSON.parse(last_response.body).should == [
      { 'id' => 'F8FA948F150EF8C100ED4EAD', 'type' => 'file', 'name' => 'AFTwitterAPIClient.h' },
      { 'id' => 'F8FA9490150EF8C100ED4EAD', 'type' => 'file', 'name' => 'AFTwitterAPIClient.m' },
    ]
  end

  it "creates a new nested group" do
    post '/groups/F8E469B71395759C00DB05C8/groups', :group => { 'name' => 'A new child group' }.to_json
    last_response.should.be.ok
    group = JSON.parse(last_response.body)
    group['type'].should == 'group'
    group['name'].should == 'A new child group'

    parent_group = app.project.objects['F8E469B71395759C00DB05C8']
    parent_group.groups.where(:uuid => group['id']).name.should == 'A new child group'
  end
end
