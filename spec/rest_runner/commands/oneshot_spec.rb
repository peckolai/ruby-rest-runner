# frozen_string_literal: true

require 'spec_helper'
require 'tty-prompt'
require 'rest_runner/commands/oneshot'

describe RestRunner::Commands::Oneshot do
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:options) { { debug: false } }

  before do
    allow(TTY::Prompt).to receive(:new).and_return(prompt)
    allow(prompt).to receive(:select).and_return('GET')
    allow(prompt).to receive(:ask).and_return('http://example.com')
    allow(prompt).to receive(:yes?).and_return(false)
    allow(prompt).to receive(:multiline).and_return("")
    stub_const('AuthHelper', Module.new)
    AuthHelper.define_singleton_method(:apply_auth!) { |headers, _prompt| headers['Authorization'] = 'Bearer testtoken' }
    allow_any_instance_of(RestRunner::Executor).to receive(:run_test).and_return({ name: 'oneshot', success: true, status: 200, latency_ms: 10, body: '{}' })
  end

  it 'runs an interactive oneshot request and applies auth' do
    expect { described_class.new(options).execute }.not_to raise_error
  end
end
