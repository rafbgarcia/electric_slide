# encoding: utf-8
require 'spec_helper'
require 'electric_slide/agent'

describe ElectricSlide::Agent do
  let(:options) { { id: 1, address: '123@foo.com', presence: :available} }

  class MyAgent < ElectricSlide::Agent
    on_connect { foo }
    on_connection_failed { foo }
    on_disconnect { foo }
    on_presence_change { foo }

    def foo
      :bar
    end
  end

  subject {MyAgent.new options}

  after do
    [:connect_callback, :disconnect_callback, :connection_failed_callback, :presence_change_callback].each do |callback|
      ElectricSlide::Agent.instance_variable_set "@#{callback}", nil
    end
  end

  it 'executes a connect callback' do
    expect(subject.callback(:connect)).to eql :bar
  end

  it 'executes a disconnect callback' do
    expect(subject.callback(:disconnect)).to eql :bar
  end

  it 'executes a connection failed callback' do
    expect(subject.callback(:connection_failed)).to eql :bar
  end

  it 'executes a presence change callback' do
    expect(subject.callback(:presence_change, nil, nil, nil, nil)).to eql :bar
  end

  it 'executes the presence change callback on state change' do
    called = false
    ElectricSlide::Agent.on_presence_change { |queue, agent_call, presence| called = true }
    agent = ElectricSlide::Agent.new presence: :unavailable
    agent.presence = :busy
  end
end
