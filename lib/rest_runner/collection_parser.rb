require "yaml"

module RestRunner
  class CollectionParser
    def self.load(path)
      raw_data = YAML.load_file(path, symbolize_names: true)
      contract = CollectionSchema.new
      result = contract.call(raw_data)

      if result.success?
        result.to_h
      else
        raise "Invalid Collection YAML:\n#{result.errors.messages.map(&:text)}"
      end
    rescue Errno::ENOENT
      raise "Collection file not found: #{path}"
    rescue Psych::SyntaxError => e
      raise "YAML Syntax Error: #{e.message}"
    end
  end
end