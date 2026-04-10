require 'net/http'
require 'json'

begin
  uri = URI('https://jsonplaceholder.typicode.com/posts/1')
  response = Net::HTTP.get(uri)
  puts "✅ Connection Successful!"
    puts "Response Data: #{JSON.parse(response)['title']}"
rescue => e
    puts "❌ Connection Failed: #{e.message}"
end

