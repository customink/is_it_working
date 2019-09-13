require 'spec_helper'

describe IsItWorking::ActiveRecordCheck do

  let(:status){ IsItWorking::Status.new(:active_record) }
  let(:abstract_conn) do
    ActiveRecord::ConnectionAdapters::AbstractAdapter.new(double(:connection))
  end

  class IsItWorking::TestActiveRecord < ActiveRecord::Base
  end

  it "succeeds if the ActiveRecord connection is active" do
    abstract_conn.stub(active?: true)
    ActiveRecord::Base.stub(connection: abstract_conn)
    check = IsItWorking::ActiveRecordCheck.new
    check.call(status)
    expect(status).to be_success
    expect(status.messages.first.message).to eq "ActiveRecord::Base.connection is active"
  end

  it "allows specifying the class to check the connection for" do
    abstract_conn.stub(active?: true)
    IsItWorking::TestActiveRecord.stub(connection: abstract_conn)
    check = IsItWorking::ActiveRecordCheck.new(:class => IsItWorking::TestActiveRecord)
    check.call(status)
    expect(status).to be_success
    expect(status.messages.first.message).to eq "IsItWorking::TestActiveRecord.connection is active"
  end

  it "succeeds if the ActiveRecord connection can be reconnected" do
    # On Rails 4, calling `disconnect!` puts the adapter in a weird state that can't be restored with `verify!`. Using `reconnect!` is ok.
    abstract_conn.reconnect!
    abstract_conn.stub(active?: true)
    ActiveRecord::Base.stub(connection: abstract_conn)
    check = IsItWorking::ActiveRecordCheck.new
    check.call(status)
    expect(status).to be_success
    expect(status.messages.first.message).to eq "ActiveRecord::Base.connection is active"
  end

  it "fails if the ActiveRecord connection is not active" do
    abstract_conn.disconnect!
    abstract_conn.stub(:verify!)
    ActiveRecord::Base.stub(connection: abstract_conn)
    check = IsItWorking::ActiveRecordCheck.new
    check.call(status)
    expect(status).not_to be_success
    expect(status.messages.first.message).to eq "ActiveRecord::Base.connection is not active"
  end

  # Use a real database, with as little stubbing as possible
  context "sqlite3" do
    let(:model_class_name) { 'IsItWorkingTestModel'.freeze }
    let(:model_class) { make_ar_klass }

    def make_ar_klass(name = model_class_name)
      klass = Class.new(ActiveRecord::Base) do |k|
        def k.name; to_s; end
      end
      klass_name = name.to_s.dup.freeze
      klass.define_singleton_method(:to_s) { klass_name }
      klass.establish_connection(adapter: 'sqlite3', database: ':memory:')
      klass
    end

    it "succeeds on active connection" do
      check = IsItWorking::ActiveRecordCheck.new(class: model_class)
      check.call(status)
      expect(status).to be_success
      expect(status.messages.first.message).to eq "#{model_class_name}.connection is active"
    end

    it "fails on dead connection" do
      model_class.connection.disconnect!
      model_class.connection.stub(:verify!)
      check = IsItWorking::ActiveRecordCheck.new(class: model_class)
      check.call(status)
      expect(status).not_to be_success
      expect(status.messages.first.message).to eq "#{model_class_name}.connection is not active"
    end
  end
end
