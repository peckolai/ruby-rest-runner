require 'spec_helper'

module RestRunner
  RSpec.describe VariableResolver do
    describe '.resolve!' do
      it 'resolves single variable' do
        data = '${api_key}'
        vars = { api_key: 'secret_key_123' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq('secret_key_123')
      end

      it 'resolves variable within string' do
        data = 'Authorization: Bearer ${token}'
        vars = { token: 'abc123def456' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq('Authorization: Bearer abc123def456')
      end

      it 'resolves multiple variables' do
        data = '${scheme}://${host}:${port}/api'
        vars = { scheme: 'https', host: 'localhost', port: 3000 }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq('https://localhost:3000/api')
      end

      it 'leaves unresolved variables unchanged' do
        data = 'base_url: ${undefined_var}'
        vars = { other_var: 'value' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq(data)
      end

      it 'resolves in nested hash' do
        data = {
          request: {
            url: '${base_url}/endpoint',
            headers: { Authorization: 'Bearer ${api_key}' }
          }
        }
        vars = { base_url: 'https://api.example.com', api_key: 'token123' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result[:request][:url]).to eq('https://api.example.com/endpoint')
        expect(result[:request][:headers][:Authorization]).to eq('Bearer token123')
      end

      it 'resolves in array' do
        data = ['${item1}', '${item2}', 'literal']
        vars = { item1: 'value1', item2: 'value2' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq(['value1', 'value2', 'literal'])
      end

      it 'handles complex nested structures' do
        data = {
          tests: [
            { endpoint: '${base_url}/test1', headers: { key: '${api_key}' } },
            { endpoint: '${base_url}/test2', headers: { key: '${api_key}' } }
          ]
        }
        vars = { base_url: 'https://api.example.com', api_key: 'secret' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result[:tests][0][:endpoint]).to eq('https://api.example.com/test1')
        expect(result[:tests][1][:endpoint]).to eq('https://api.example.com/test2')
      end

      it 'modifies data structure in place' do
        original = { url: '${base_url}' }
        vars = { base_url: 'https://example.com' }
        
        result = described_class.resolve!(original, vars)
        
        expect(original[:url]).to eq('https://example.com')
        expect(result).to eq(original)
      end

      it 'handles variable with symbol names in custom_vars' do
        data = '${api_key}'
        vars = { api_key: 'symbol_value' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq('symbol_value')
      end

      it 'handles variable with string names in custom_vars' do
        data = '${api_key}'
        vars = { 'api_key' => 'string_value' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq('string_value')
      end
    end

    describe 'variable priority' do
      it 'prioritizes custom vars over ENV' do
        allow(ENV).to receive(:[]).with('API_KEY').and_return('env_value')
        data = 'key: ${API_KEY}'
        vars = { 'API_KEY' => 'custom_value' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq('key: custom_value')
      end

      it 'tries symbol first then string in custom vars' do
        data = 'key: ${VAR}'
        # Only provide string key, not symbol
        vars = { 'VAR' => 'string_var_value' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq('key: string_var_value')
      end

      it 'falls back to ENV if not in custom vars' do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with('EXTERNAL_VAR').and_return('from_env')
        data = 'key: ${EXTERNAL_VAR}'
        
        result = described_class.resolve!(data, {})
        
        expect(result).to eq('key: from_env')
      end

      it 'leaves variable if not in custom vars and not in ENV' do
        allow(ENV).to receive(:[]).with('UNDEFINED').and_return(nil)
        data = 'key: ${UNDEFINED}'
        
        result = described_class.resolve!(data, {})
        
        expect(result).to eq('key: ${UNDEFINED}')
      end
    end

    describe 'edge cases' do
      it 'handles empty string' do
        result = described_class.resolve!('', {})
        expect(result).to eq('')
      end

      it 'handles string with no variables' do
        result = described_class.resolve!('plain text', {})
        expect(result).to eq('plain text')
      end

      it 'handles variable with same name appearing multiple times' do
        data = '${url}/path1 and ${url}/path2'
        vars = { url: 'https://example.com' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq('https://example.com/path1 and https://example.com/path2')
      end

      it 'handles variable name with underscores and numbers' do
        data = '${api_key_v2}'
        vars = { api_key_v2: 'key_value' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq('key_value')
      end

      it 'handles nil values gracefully' do
        result = described_class.resolve!(nil, {})
        expect(result).to be_nil
      end

      it 'handles numeric values' do
        data = { port: 3000, timeout: 5000 }
        result = described_class.resolve!(data, {})
        
        expect(result[:port]).to eq(3000)
        expect(result[:timeout]).to eq(5000)
      end

      it 'handles boolean values' do
        data = { verbose: true, debug: false }
        result = described_class.resolve!(data, {})
        
        expect(result[:verbose]).to be true
        expect(result[:debug]).to be false
      end

      it 'resolves variables in integer-keyed arrays' do
        data = ['${first}', '${second}', 'static']
        vars = { first: 'resolved_first', second: 'resolved_second' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result[0]).to eq('resolved_first')
        expect(result[1]).to eq('resolved_second')
        expect(result[2]).to eq('static')
      end
    end

    describe 'token format' do
      it 'resolves standard ${VAR} format' do
        data = 'Bearer ${token}'
        vars = { token: 'abc123' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq('Bearer abc123')
      end

      it 'handles variables with hyphens in names' do
        data = '${base-url}'
        vars = { 'base-url' => 'https://example.com' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq('https://example.com')
      end

      it 'does not resolve variables with invalid syntax' do
        data = '$VAR or {VAR}'
        vars = { VAR: 'value' }
        
        result = described_class.resolve!(data, vars)
        
        expect(result).to eq(data)
      end
    end
  end
end
