require 'json'

module RestRunner
  module Commands
    # Parse Postman Collection v2.1 format into RestRunner YAML structure.
    class PostmanParser
      # Parse a Postman collection file.
      # @param path [String] Path to Postman JSON file
      # @return [Hash] RestRunner collection hash
      def parse(path)
        data = JSON.parse(File.read(path), symbolize_names: true)

        {
          name: extract_name(data),
          description: data[:description] || "Imported from Postman",
          tests: extract_tests(data)
        }
      end

      private

      # Extract collection name from Postman metadata.
      # @param data [Hash] Parsed Postman JSON
      # @return [String] Collection name
      def extract_name(data)
        case data[:info]
        when String
          data[:info]
        when Hash
          data[:info][:name] || "Postman Collection"
        else
          "Postman Collection"
        end
      end

      # Extract tests from Postman items (requests).
      # @param data [Hash] Parsed Postman JSON
      # @return [Array<Hash>] Array of test specifications
      def extract_tests(data)
        items = data[:item] || []
        tests = []

        items.each do |item|
          test = parse_item(item)
          tests << test if test
        end

        tests
      end

      # Parse a single Postman item (may be folder or request).
      # @param item [Hash] Postman item
      # @return [Hash, nil] Test specification or nil if folder
      def parse_item(item)
        # Skip folders; only process requests
        return nil if item[:item]  # Folder has nested items

        request = item[:request]
        return nil unless request

        endpoint = extract_url(request[:url])
        method = (request[:method] || "GET").upcase

        test = {
          name: item[:name],
          method: method,
          endpoint: endpoint,
          headers: extract_headers(request[:header]),
          body: extract_body(request[:body]),
          assertions: extract_assertions(item)
        }

        # Remove nil values
        test.compact!
        test
      end

      # Extract URL from Postman format (may be string or object).
      # @param url [String, Hash] Postman URL
      # @return [String] URL string
      def extract_url(url)
        case url
        when String
          url
        when Hash
          url[:raw] || build_url_from_parts(url)
        else
          "https://example.com"
        end
      end

      # Build URL from Postman URL object parts.
      # @param url_obj [Hash] Postman URL object
      # @return [String] Constructed URL
      def build_url_from_parts(url_obj)
        scheme = (url_obj[:protocol] || "https").to_s
        host = (url_obj[:host] || []).join(".")
        path = (url_obj[:path] || []).join("/")
        query = (url_obj[:query] || []).map { |q| "#{q[:key]}=#{q[:value]}" }.join("&")

        url = "#{scheme}://#{host}"
        url += "/#{path}" if path.present?
        url += "?#{query}" if query.present?
        url
      end

      # Extract headers from Postman request.
      # @param headers [Array] Postman headers array
      # @return [Hash, nil] Headers hash or nil if empty
      def extract_headers(headers)
        return nil unless headers&.any?

        headers_hash = {}
        headers.each do |h|
          headers_hash[h[:key]] = h[:value] if h[:key] && h[:value]
        end

        headers_hash.empty? ? nil : headers_hash
      end

      # Extract body from Postman request.
      # @param body [Hash] Postman body object
      # @return [Hash, String, nil] Parsed body or nil
      def extract_body(body)
        return nil unless body

        case body[:mode]
        when "raw"
          parse_json_safe(body[:raw])
        when "formdata"
          # Convert form data to hash
          form_hash = {}
          (body[:formdata] || []).each do |field|
            form_hash[field[:key]] = field[:value] if field[:key]
          end
          form_hash.empty? ? nil : form_hash
        when "urlencoded"
          # Similar to formdata
          form_hash = {}
          (body[:urlencoded] || []).each do |field|
            form_hash[field[:key]] = field[:value] if field[:key]
          end
          form_hash.empty? ? nil : form_hash
        else
          nil
        end
      end

      # Safely parse JSON string.
      # @param json_str [String] JSON string
      # @return [Hash, Array, String, nil] Parsed JSON or original string
      def parse_json_safe(json_str)
        return nil unless json_str
        JSON.parse(json_str)
      rescue JSON::ParserError
        json_str  # Return as string if not valid JSON
      end

      # Extract assertions from Postman tests (if any).
      # @param item [Hash] Postman item
      # @return [Hash, nil] Assertions or nil
      def extract_assertions(item)
        # Postman doesn't have built-in assertions like RestRunner
        # We can extract from response structure if present
        nil
      end
    end
  end
end
