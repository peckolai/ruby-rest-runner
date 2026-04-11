module FileHelpers
  # Create a temporary test file with given content
  def create_temp_file(name, content = '')
    path = File.join('spec/tmp', name)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    path
  end

  # Cleanup temporary test files
  def cleanup_temp_files
    FileUtils.rm_rf('spec/tmp') if Dir.exist?('spec/tmp')
  end

  # Load YAML fixture
  def load_fixture(name)
    path = File.join(__dir__, '..', 'fixtures', "#{name}.yml")
    YAML.load_file(path, symbolize_names: true)
  end

  # Create environment fixture directory
  def setup_env_fixtures
    env_dir = 'spec/tmp/config/envs'
    FileUtils.mkdir_p(env_dir)
    
    # Create test environment file
    File.write(
      File.join(env_dir, 'test.yml'),
      { base_url: 'http://localhost:3000', api_key: 'test_key_12345' }.to_yaml
    )
    
    env_dir
  end

  # Create collection fixture directory
  def setup_collection_fixtures
    col_dir = 'spec/tmp/collections'
    FileUtils.mkdir_p(col_dir)
    
    # Create simple test collection
    collection = {
      name: 'Test Collection',
      tests: [
        {
          name: 'GET test',
          endpoint: '${base_url}/api/test',
          method: 'GET',
          assertions: { status: 200 }
        }
      ]
    }
    
    File.write(
      File.join(col_dir, 'test.yml'),
      collection.to_yaml
    )
    
    col_dir
  end
end
