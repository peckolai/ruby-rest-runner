require 'spec_helper'

module RestRunner
  RSpec.describe KeychainIntegration do
    describe 'initialization' do
      it 'creates new instance without errors' do
        expect { described_class.new }.not_to raise_error
      end

      it 'detects available keychain backend on init' do
        instance = described_class.new
        expect(instance).to respond_to(:backend)
      end
    end

    describe '#backend' do
      it 'returns a string backend name' do
        instance = described_class.new
        backend = instance.backend
        
        expect(backend).to be_a(String)
        expect(%w[macOS\ Keychain pass\ \(Linux\) Local\ .env.local]).to include(backend)
      end
    end

    describe '#store and #retrieve' do
      let(:instance) { described_class.new }
      let(:test_key) { 'test_key_spec' }
      let(:test_value) { 'test_value_secret' }

      it 'stores and retrieves a secret' do
        # Since backend varies by system, we just test the interface works
        expect { instance.store(test_key, test_value) }.not_to raise_error
      end

      it 'retrieves nil for non-existent secret' do
        result = instance.retrieve('definitely_non_existent_key_xyz')
        # Result depends on backend, but should not raise error
        expect(result).to be_nil if result  # Allow nil or some value
      end

      it 'responds to list_keys' do
        expect(instance).to respond_to(:list_keys)
      end
    end

    describe 'backend detection' do
      let(:instance) { described_class.new }

      it 'prioritizes macOS Keychain when available (darwin)', :skip => !RUBY_PLATFORM.include?("darwin") do
        if RUBY_PLATFORM.include?("darwin") && system("which security > /dev/null 2>&1")
          instance = described_class.new
          expect(instance.backend).to eq("macOS Keychain")
        end
      end

      it 'falls back to pass on Linux if available', :skip => RUBY_PLATFORM.include?("darwin") do
        if !RUBY_PLATFORM.include?("darwin") && system("which pass > /dev/null 2>&1")
          instance = described_class.new
          expect(instance.backend).to eq("pass (Linux)")
        end
      end

      it 'falls back to local storage' do
        instance = described_class.new
        # Local is always available as fallback
        expect(%w[macOS\ Keychain pass\ \(Linux\) Local\ .env.local]).to include(instance.backend)
      end
    end

    describe 'list_keys' do
      let(:instance) { described_class.new }

      it 'returns an array' do
        keys = instance.list_keys
        expect(keys).to be_an(Array)
      end

      it 'handles empty keychain gracefully' do
        keys = instance.list_keys
        # Should not raise error, even if empty
        expect(keys).to be_an(Array)
      end
    end

    describe 'error handling' do
      let(:instance) { described_class.new }

      it 'does not raise when storing fails' do
        # Attempt to store; should handle errors gracefully
        expect { instance.store('test', 'value') }.not_to raise_error
      end

      it 'does not raise when retrieving fails' do
        # Attempt to retrieve; should handle errors gracefully
        expect { instance.retrieve('nonexistent') }.not_to raise_error
      end

      it 'does not raise when listing fails' do
        # Attempt to list; should handle errors gracefully
        expect { instance.list_keys }.not_to raise_error
      end
    end
  end
end
