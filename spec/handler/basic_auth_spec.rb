require 'spec_helper'

describe IsItWorking::Handler::BasicAuth do
  let(:credential) { 'test' }
  let(:auth) { 'Basic dGVzdDp0ZXN0' }
  let(:invalid_auth) { 'Basic abcdefg' }
  let(:path) { '/is_it_working' }
  let(:unmatched_path) { '/' }
  let(:handler) do
    IsItWorking::Handler::BasicAuth.new do |h|
      h.check :directory, :path => ".", :permissions => :read
    end
  end

  before do
    ENV['IS_IT_WORKING_USERNAME'] = ENV['IS_IT_WORKING_PASSWORD'] = credential
  end

  it 'should challenge with a 401 if credentials are not provided' do
    env = { 'PATH_INFO' => path }
    response = handler.call(env)

    response.first.should == 401
    response.last.flatten.join("").should == ""
    response.second.keys.should include('WWW-Authenticate')
  end

  it 'should call the handler if correct credentials are provided' do
    env = { 'PATH_INFO' => path, 'HTTP_AUTHORIZATION' => auth }
    response = handler.call(env)

    response.first.should == 200
    response.last.flatten.join("").should include("OK")
    response.last.flatten.join("").should include("directory")
  end

  it 'should challenge with a 401 if incorrect credentials are provided' do
    env = { 'PATH_INFO' => path, 'HTTP_AUTHORIZATION' => invalid_auth }
    response = handler.call(env)

    response.first.should == 401
    response.last.flatten.join("").should == ""
    response.second.keys.should include('WWW-Authenticate')
  end

  it "should challenge with a 401 if @app is nil and the path does not match" do
    env = { 'PATH_INFO' => unmatched_path }
    response = handler.call(env)

    response.first.should == 401
    response.last.flatten.join("").should == ""
    response.second.keys.should include('WWW-Authenticate')
  end

  context "when @app is present" do
    let(:app) { double('@app') }
    let(:handler) do
      IsItWorking::Handler::BasicAuth.new(app) do |h|
        h.check :directory, :path => ".", :permissions => :read
      end
    end

    it "should delegate to @app if the path does not match" do
      env = { 'PATH_INFO' => unmatched_path }
      app.should receive(:call).with(env).and_return([200, {}, ['OK']])
      response = handler.call(env)

      response.first.should == 200
      response.last.flatten.join("").should include("OK")
    end

    it "should challenge with a 401 if the path does match" do
      env = { 'PATH_INFO' => path }
      app.should_not receive(:call)
      response = handler.call(env)

      response.first.should == 401
      response.last.flatten.join("").should == ""
      response.second.keys.should include('WWW-Authenticate')
    end
  end
end
