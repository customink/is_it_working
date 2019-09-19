require 'spec_helper'

describe IsItWorking::Handler do

  it "should lookup filters from the pre-defined checks" do
    handler = IsItWorking::Handler.new do |h|
      h.check :directory, :path => ".", :permissions => :read
    end
    response = handler.call({})
    response.first.should == 200
    response.last.flatten.join("").should include("OK")
    response.last.flatten.join("").should include("directory")
  end

  it "should use blocks as filters" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block do |status|
        status.ok("Okey dokey")
      end
    end
    response = handler.call({})
    response.first.should == 200
    response.last.flatten.join("").should include("OK")
    response.last.flatten.join("").should include("block - Okey dokey")
  end

  it "should use object as filters" do
    handler = IsItWorking::Handler.new do |h|
      h.check :lambda, lambda{|status| status.ok("A-okay")}
    end
    response = handler.call({})
    response.first.should == 200
    response.last.flatten.join("").should include("OK")
    response.last.flatten.join("").should include("lambda - A-okay")
  end

  it "should create asynchronous filters by default" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block do |status|
        status.ok("Okey dokey")
      end
    end
    runner = IsItWorking::Filter::AsyncRunner.new{}
    IsItWorking::Filter::AsyncRunner.should_receive(:new).and_return(runner)
    response = handler.call({})
  end

  it "should be able to create synchronous filters" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block, :async => false do |status|
        status.ok("Okey dokey")
      end
    end
    runner = IsItWorking::Filter::SyncRunner.new{}
    IsItWorking::Filter::SyncRunner.should_receive(:new).and_return(runner)
    response = handler.call({})
  end

  it "should work with synchronous checks" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block, :async => false do |status|
        status.ok("Okey dokey")
      end
    end
    response = handler.call({})
    response.first.should == 200
    response.last.flatten.join("").should include("OK")
    response.last.flatten.join("").should include("block - Okey dokey")
  end

  it "should return a success response if all checks pass" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block do |status|
        status.ok("success")
      end
      h.check :block do |status|
        status.ok("worked")
      end
    end
    response = handler.call({})
    response.first.should == 200
    response.last.flatten.join("").should include("block - success")
    response.last.flatten.join("").should include("block - worked")
  end

  it "should return an error response if any check fails" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block do |status|
        status.ok("success")
      end
      h.check :block do |status|
        status.fail("down")
      end
    end
    response = handler.call({})
    response.first.should == 500
    response.last.flatten.join("").should include("block - success")
    response.last.flatten.join("").should include("block - down")
  end

  it "should return a warning status if a check exceeds a warning timeout" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block, warn_timeout: 900 do |status|
        sleep 1
        status.ok('That took a while! 😅')
      end
    end
    response = handler.call({})
    response.first.should == 203
    response.last.flatten.join.should include("OK: block - That took a while")
    response.last.flatten.join.should include("WARN: block - runtime exceeded warning threshold")
  end

    it "should return a failure status if a check exceeds a warning timeout and a timeout" do
    handler = IsItWorking::Handler.new do |h|
      h.check :block,  warn_timeout: 500, timeout: 900 do |status|
        sleep 1
        status.ok('That took a while! 😅')
      end
    end
    response = handler.call({})
    response.first.should == 500
    response.last.flatten.join.should include("OK: block - That took a while")
    response.last.flatten.join.should include("FAIL: block - runtime exceeded critical threshold")
  end

  it "should be able to be used in a middleware stack with the route /is_it_working" do
    app_response = [200, {"Content-Type" => "text/plain"}, ["OK"]]
    app = lambda{|env| app_response}
    check_called = false
    stack = IsItWorking::Handler.new(app) do |h|
      h.check(:test){|status| check_called = true; status.ok("Woot!")}
    end

    stack.call("PATH_INFO" => "/").should == app_response
    check_called.should == false
    stack.call("PATH_INFO" => "/is_it_working").last.flatten.join("").should include("Woot!")
    check_called.should == true
  end

  it "should be able to be used in a middleware stack with a custom route" do
    app_response = [200, {"Content-Type" => "text/plain"}, ["OK"]]
    app = lambda{|env| app_response}
    check_called = false
    stack = IsItWorking::Handler.new(app, "/woot") do |h|
      h.check(:test){|status| check_called = true; status.ok("Woot!")}
    end

    stack.call("PATH_INFO" => "/is_it_working").should == app_response
    check_called.should == false
    stack.call("PATH_INFO" => "/woot").last.flatten.join("").should include("Woot!")
    check_called.should == true
  end

  it "should be able to synchronize access to a block" do
    handler = IsItWorking::Handler.new
    handler.synchronize{1}.should == 1
    handler.synchronize{2}.should == 2
  end

  it "should be able to set the host name reported in the output" do
    handler = IsItWorking::Handler.new
    handler.hostname = "woot"
    handler.call("PATH_INFO" => "/is_it_working").last.join("").should include("woot")
  end

  # NOTE: these tests are only to document existing behavior, not actual requirements.
  context "Adding filters:" do
    let(:handler) do
      described_class.allocate.tap do |h|
        h.instance_variable_set(:@filters, filters)
      end
    end
    let(:opts) { {myopt: 'myval'.freeze}.freeze }
    let(:opts_with_async) { {async: true}.merge(opts).freeze }
    let(:opts_without_async) { {async: false}.merge(opts).freeze }
    let(:filters) { [] }
    let(:ck_name) { :look_me_up }
    let(:looked_up_check) { double(:looked_up_check) }
    let(:example_full_desc) { RSpec.current_example.full_description.dup.freeze }
    let(:passed_proc) { proc{|stat| example_full_desc } }

    before :each do
      handler.stub(:lookup_check) { raise 'Unexpected lookup_check call' }
    end

    context "check(name, &block)" do
      it "uses block as check" do
        handler.check(ck_name, &passed_proc)
        expect(filters[0].name).to eq ck_name
        expect(filters[0].instance_variable_get(:@check).call(nil)).to eq example_full_desc
        expect(filters[0].async).to be true
      end

      context "check(name, options, &block)" do
        it "allows disabling of async" do
          handler.check(ck_name, async: false, &passed_proc)
          expect(filters[0].name).to eq ck_name
          expect(filters[0].instance_variable_get(:@check).call(nil)).to eq example_full_desc
          expect(filters[0].async).to be false
        end
      end
    end

    context "check(name, options)" do
      it "uses looked-up class with passed-in options" do
        handler.should_receive(:lookup_check).with(ck_name, opts_with_async).and_return looked_up_check
        handler.check(ck_name, opts)
        expect(filters[0].name).to eq ck_name
        expect(filters[0].instance_variable_get(:@check)).to be looked_up_check
        expect(filters[0].async).to be true
      end

      it "allows disabling of async" do
        handler.should_receive(:lookup_check).with(ck_name, opts_without_async).and_return looked_up_check
        handler.check(ck_name, opts_without_async)
        expect(filters[0].name).to eq ck_name
        expect(filters[0].instance_variable_get(:@check)).to be looked_up_check
        expect(filters[0].async).to be false
      end
    end

    context "check(name, check)" do
      it "uses passed-in check" do
        handler.check(ck_name, passed_proc)
        expect(filters[0].name).to eq ck_name
        expect(filters[0].instance_variable_get(:@check)).to be passed_proc
        expect(filters[0].async).to be true
      end

      it "ignores block" do
        handler.check(ck_name, passed_proc) { raise "don't call me" }
        expect(filters[0].name).to eq ck_name
        expect(filters[0].instance_variable_get(:@check)).to be passed_proc
        expect(filters[0].async).to be true
      end

      context "check(name, check, options)" do
        it "allows disabling of async" do
          handler.check(ck_name, passed_proc, opts_without_async)
          expect(filters[0].name).to eq ck_name
          expect(filters[0].instance_variable_get(:@check)).to be passed_proc
          expect(filters[0].async).to be false
        end
      end
    end

  end

  context "lookup_check (non-public)" do
    let(:handler) { described_class.allocate }
    let(:check_data) do
      [
        [:action_mailer, IsItWorking::ActionMailerCheck],
        [:active_record, IsItWorking::ActiveRecordCheck],
        [:dalli,         IsItWorking::DalliCheck       ],
        [:directory,     IsItWorking::DirectoryCheck   ],
        [:ping,          IsItWorking::PingCheck        ],
        [:url,           IsItWorking::UrlCheck         ],
      ].each_with_object(Hash.new) do |(ck_name, ck_class), map|
        map[ck_name] = {
          class:    ck_class,
          opts:     double("#{ck_name} opts"),
          instance: double("#{ck_class} instance")
        }
      end
    end

    it "works for built-in check classes" do
      check_data.each do |ck_name, data|
        data[:class].should_receive(:new).with(data[:opts]).and_return data[:instance]
      end

      check_data.each do |ck_name, data|
        expect(handler.send(:lookup_check, ck_name, data[:opts])).to be data[:instance]
      end
    end

    it "raises on undefined check class" do
      expect{ handler.send(:lookup_check, :foobar, {}) }.to raise_error(/Check not defined FoobarCheck/i)
    end
  end
end
