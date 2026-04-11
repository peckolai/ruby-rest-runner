require 'spec_helper'

module RestRunner
  RSpec.describe CollectionParser do
    let(:valid_collection) do
      {
        name: 'Valid Collection',
        tests: [
          {
            name: 'Test 1',
            endpoint: 'https://api.example.com/test',
            method: 'GET',
            assertions: { status: 200 }
          }
        ]
      }
    end

    describe '.load' do
      it 'loads and validates valid collection' do
        file_path = 'spec/tmp/valid_collection.yml'
        FileUtils.mkdir_p('spec/tmp') unless Dir.exist?('spec/tmp')
        File.write(file_path, valid_collection.to_yaml)
        
        result = described_class.load(file_path)
        
        expect(result).to include(:name, :tests)
        expect(result[:name]).to eq('Valid Collection')
        expect(result[:tests].length).to eq(1)
        
        File.delete(file_path)
      end

      it 'raises error for missing file' do
        expect {
          described_class.load('nonexistent.yml')
        }.to raise_error(RuntimeError)
      end

      it 'raises error for invalid YAML syntax' do
        file_path = 'spec/tmp/invalid_syntax.yml'
        FileUtils.mkdir_p('spec/tmp') unless Dir.exist?('spec/tmp')
        File.write(file_path, "invalid: yaml: content: [")
        
        expect {
          described_class.load(file_path)
        }.to raise_error(RuntimeError)
        
        File.delete(file_path)
      end

      it 'validates required fields' do
        file_path = 'spec/tmp/missing_name.yml'
        FileUtils.mkdir_p('spec/tmp') unless Dir.exist?('spec/tmp')
        invalid = { tests: [] }
        File.write(file_path, invalid.to_yaml)
        
        expect {
          described_class.load(file_path)
        }.to raise_error(StandardError) # Dry::Validation error
        
        File.delete(file_path)
      end

      it 'validates tests array exists' do
        file_path = 'spec/tmp/missing_tests.yml'
        FileUtils.mkdir_p('spec/tmp') unless Dir.exist?('spec/tmp')
        invalid = { name: 'Test Collection' }
        File.write(file_path, invalid.to_yaml)
        
        expect {
          described_class.load(file_path)
        }.to raise_error(StandardError)
        
        File.delete(file_path)
      end

      it 'loads collection with optional fields' do
        file_path = 'spec/tmp/with_assertions.yml'
        FileUtils.mkdir_p('spec/tmp') unless Dir.exist?('spec/tmp')
        collection = {
          name: 'Test',
          tests: [
            {
              name: 'Test 1',
              endpoint: 'https://api.example.com',
              method: 'POST',
              body: { key: 'value' },
              headers: { 'Content-Type' => 'application/json' },
              assertions: {
                status: 201,
                max_latency_ms: 500,
                body_contains: 'success'
              }
            }
          ]
        }
        File.write(file_path, collection.to_yaml)
        
        result = described_class.load(file_path)
        
        expect(result[:tests][0][:body]).to eq({ key: 'value' })
        expect(result[:tests][0][:headers]).to be_a(Hash)
        expect(result[:tests][0][:assertions][:max_latency_ms]).to eq(500)
        
        File.delete(file_path)
      end

      it 'validates test structure' do
        file_path = 'spec/tmp/invalid_test.yml'
        FileUtils.mkdir_p('spec/tmp') unless Dir.exist?('spec/tmp')
        collection = {
          name: 'Invalid Test',
          tests: [
            { name: 'Missing endpoint' }
          ]
        }
        File.write(file_path, collection.to_yaml)
        
        expect {
          described_class.load(file_path)
        }.to raise_error(StandardError)
        
        File.delete(file_path)
      end

      it 'handles collection with multiple tests' do
        file_path = 'spec/tmp/multiple_tests.yml'
        FileUtils.mkdir_p('spec/tmp') unless Dir.exist?('spec/tmp')
        collection = {
          name: 'Multiple Tests',
          tests: [
            { name: 'Test 1', endpoint: 'https://api.example.com/1', method: 'GET' },
            { name: 'Test 2', endpoint: 'https://api.example.com/2', method: 'POST' },
            { name: 'Test 3', endpoint: 'https://api.example.com/3', method: 'PUT' }
          ]
        }
        File.write(file_path, collection.to_yaml)
        
        result = described_class.load(file_path)
        
        expect(result[:tests].length).to eq(3)
        
        File.delete(file_path)
      end
    end

    describe 'schema validation' do
      it 'accepts valid HTTP methods' do
        file_path = 'spec/tmp/methods.yml'
        FileUtils.mkdir_p('spec/tmp') unless Dir.exist?('spec/tmp')
        
        %w[GET POST PUT DELETE PATCH HEAD OPTIONS].each do |method|
          collection = {
            name: 'Methods',
            tests: [{ name: method, endpoint: 'https://example.com', method: method }]
          }
          File.write(file_path, collection.to_yaml)
          
          result = described_class.load(file_path)
          expect(result[:tests][0][:method]).to eq(method)
        end
        
        File.delete(file_path)
      end

      it 'validates assertion status codes' do
        file_path = 'spec/tmp/status_codes.yml'
        FileUtils.mkdir_p('spec/tmp') unless Dir.exist?('spec/tmp')
        collection = {
          name: 'Status',
          tests: [
            {
              name: 'Test',
              endpoint: 'https://example.com',
              method: 'GET',
              assertions: { status: 404 }
            }
          ]
        }
        File.write(file_path, collection.to_yaml)
        
        result = described_class.load(file_path)
        expect(result[:tests][0][:assertions][:status]).to eq(404)
        
        File.delete(file_path)
      end

      it 'handles body_contains assertions' do
        file_path = 'spec/tmp/body_contains.yml'
        FileUtils.mkdir_p('spec/tmp') unless Dir.exist?('spec/tmp')
        collection = {
          name: 'Body',
          tests: [
            {
              name: 'Test',
              endpoint: 'https://example.com',
              method: 'GET',
              assertions: { body_contains: 'success message' }
            }
          ]
        }
        File.write(file_path, collection.to_yaml)
        
        result = described_class.load(file_path)
        expect(result[:tests][0][:assertions][:body_contains]).to eq('success message')
        
        File.delete(file_path)
      end
    end
  end
end
