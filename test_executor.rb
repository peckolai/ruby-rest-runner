#!/usr/bin/env ruby
# Quick test script for Phase 1: Async IO Integration
require "bundler/setup"
require_relative "lib/rest_runner"

puts "=" * 60
puts "Testing Phase 1: Async IO Integration (Executor)"
puts "=" * 60

# Safe test 1: Simple GET request with status assertion
test_case_1 = {
  name: "Simple GET - Health Check",
  method: "GET",
  endpoint: "https://jsonplaceholder.typicode.com/posts/1",
  headers: {},
  body: nil,
  assertions: {
    status: 200
  }
}

# Safe test 2: POST with body assertion
test_case_2 = {
  name: "POST - Create Resource",
  method: "POST",
  endpoint: "https://jsonplaceholder.typicode.com/posts",
  headers: { "Content-Type" => "application/json" },
  body: { title: "Test Post", body: "Testing async executor", userId: 1 },
  assertions: {
    status: 201,
    body_contains: "Test Post"
  }
}

begin
  puts "\n[Test 1] Running: #{test_case_1[:name]}"
  executor_1 = RestRunner::Executor.new(test_case_1)
  result_1 = executor_1.run_test
  puts "  Status: #{result_1[:status]}"
  puts "  Success: #{result_1[:success]} ✓" if result_1[:success]
  puts "  Latency: #{result_1[:latency_ms]}ms"
  puts "  Error: #{result_1[:error]}" if result_1[:error]

  puts "\n[Test 2] Running: #{test_case_2[:name]}"
  executor_2 = RestRunner::Executor.new(test_case_2)
  result_2 = executor_2.run_test
  puts "  Status: #{result_2[:status]}"
  puts "  Success: #{result_2[:success]} ✓" if result_2[:success]
  puts "  Latency: #{result_2[:latency_ms]}ms"
  puts "  Error: #{result_2[:error]}" if result_2[:error]

  puts "\n" + "=" * 60
  puts "Summary: Both tests executed via Async IO (Fiber Scheduler)"
  puts "=" * 60

rescue => e
  puts "\n❌ Error during test: #{e.message}"
  puts e.backtrace.first(5)
end
