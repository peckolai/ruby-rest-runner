require "dry-validation"

module RestRunner
  class CollectionSchema < Dry::Validation::Contract
    # Custom macro for HTTP methods
    HTTP_METHODS = %w[GET POST PUT DELETE PATCH OPTIONS HEAD].freeze

    params do
      required(:name).filled(:string)
      optional(:description).maybe(:string)
      optional(:hooks_path).maybe(:string)
      required(:tests).array(:hash) do
        required(:name).filled(:string)
        required(:endpoint).filled(:string)
        required(:method).value(included_in?: HTTP_METHODS)
        optional(:headers).hash
        optional(:body).hash
        optional(:assertions).hash do
          optional(:status).filled(:integer)
          optional(:max_latency_ms).filled(:integer)
          optional(:body_contains).filled(:string)
        end
      end
    end

    rule(:hooks_path) do
      if value && !File.exist?(value)
        key.failure("file does not exist at #{value}")
      end
    end
  end
end