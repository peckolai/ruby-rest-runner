#!/usr/bin/env ruby
# frozen_string_literal: true

# Performance Benchmark: Async vs Sync HTTP Execution
# Compares Fiber-based async execution vs traditional synchronous approach

require 'benchmark'
require 'faraday'
require 'async'
require 'async/http/faraday'
require_relative 'lib/rest_runner'

# ============================================================================
# Test Configuration
# ============================================================================

TEST_URLS = [
  'https://jsonplaceholder.typicode.com/posts/1',
  'https://jsonplaceholder.typicode.com/posts/2',
  'https://jsonplaceholder.typicode.com/posts/3',
  'https://jsonplaceholder.typicode.com/posts/4',
  'https://jsonplaceholder.typicode.com/posts/5',
].freeze

NUM_ITERATIONS = 3

puts "═" * 80
puts "    Ruby REST Runner - Performance Benchmark"
puts "    Async (Fiber) vs Sync HTTP Execution"
puts "═" * 80
puts ""

# ============================================================================
# 1. Synchronous HTTP Execution (Traditional)
# ============================================================================

puts "📊 BENCHMARK 1: Synchronous HTTP Requests"
puts "-" * 80

sync_times = []

NUM_ITERATIONS.times do |iteration|
  puts "\nIteration #{iteration + 1}/#{NUM_ITERATIONS} (Sync)"
  
  time = Benchmark.measure do
    TEST_URLS.each do |url|
      connection = Faraday.new(url: url)
      response = connection.get('/')
      print "  ✓ #{url.split('/').last} - #{response.status} "
    end
    puts ""
  end
  
  sync_times << time.real
  puts "  Total time: #{time.real.round(4)}s"
end

sync_avg = sync_times.sum / sync_times.length
puts "\n  ⏱️  Average Sync Time: #{sync_avg.round(4)}s"

# ============================================================================
# 2. Async HTTP Execution (Fiber-based) 
# ============================================================================

puts "\n📊 BENCHMARK 2: Async HTTP Requests (Fiber Scheduler)"
puts "-" * 80

async_times = []

NUM_ITERATIONS.times do |iteration|
  puts "\nIteration #{iteration + 1}/#{NUM_ITERATIONS} (Async)"
  
  time = Benchmark.measure do
    Async do
      TEST_URLS.each do |url|
        connection = Faraday.new(url: url) do |f|
          f.adapter :async_http
        end
        response = connection.get('/')
        print "  ✓ #{url.split('/').last} - #{response.status} "
      end
      puts ""
    end
  end
  
  async_times << time.real
  puts "  Total time: #{time.real.round(4)}s"
end

async_avg = async_times.sum / async_times.length
puts "\n  ⏱️  Average Async Time: #{async_avg.round(4)}s"

# ============================================================================
# 3. Concurrent Async Execution (Multiple requests in parallel)
# ============================================================================

puts "\n📊 BENCHMARK 3: Concurrent Async Requests (Parallel Execution)"
puts "-" * 80

concurrent_times = []

NUM_ITERATIONS.times do |iteration|
  puts "\nIteration #{iteration + 1}/#{NUM_ITERATIONS} (Concurrent)"
  
  time = Benchmark.measure do
    Async do |task|
      tasks = TEST_URLS.map do |url|
        task.spawn do
          connection = Faraday.new(url: url) do |f|
            f.adapter :async_http
          end
          response = connection.get('/')
          "✓ #{url.split('/').last} - #{response.status}"
        end
      end
      
      results = tasks.map(&:wait)
      results.each { |result| print "  #{result} " }
      puts ""
    end
  end
  
  concurrent_times << time.real
  puts "  Total time: #{time.real.round(4)}s"
end

concurrent_avg = concurrent_times.sum / concurrent_times.length
puts "\n  ⏱️  Average Concurrent Time: #{concurrent_avg.round(4)}s"

# ============================================================================
# Results Analysis
# ============================================================================

puts "\n" + "═" * 80
puts "    RESULTS SUMMARY"
puts "═" * 80

improvement_vs_sync = ((sync_avg - async_avg) / sync_avg * 100).round(2)
concurrent_improvement = ((sync_avg - concurrent_avg) / sync_avg * 100).round(2)

puts "\n📈 Performance Metrics:"
puts ""
puts "  Synchronous Execution:        #{sync_avg.round(4)}s (baseline)"
puts "  Sequential Async Execution:   #{async_avg.round(4)}s (#{improvement_vs_sync > 0 ? '+' : ''}#{improvement_vs_sync}%)"
puts "  Parallel Async Execution:     #{concurrent_avg.round(4)}s (#{concurrent_improvement}%)"
puts ""

puts "🎯 Key Findings:"
puts ""
puts "  • Async sequential: #{improvement_vs_sync > 0 ? 'FASTER' : 'SLOWER'} by #{improvement_vs_sync.abs}%"
puts "  • Async concurrent: #{concurrent_improvement}% improvement over sync"
puts "  • Fiber overhead:   #{((async_avg - concurrent_avg) / concurrent_avg * 100).round(2)}% difference between sequential and parallel"
puts ""

if concurrent_avg < sync_avg * 0.8
  puts "  ✅ VERDICT: Significant performance gain with Fiber-based async execution!"
elsif concurrent_avg < sync_avg
  puts "  ✅ VERDICT: Measurable performance improvement with async execution."
else
  puts "  ⚠️  VERDICT: Overhead present; benefits in concurrency, not single-threaded speed."
end

puts "\n💡 Notes:"
puts "  • This benchmark uses jsonplaceholder.typicode.com (public API)"
puts "  • Network latency dominates execution time at this scale"
puts "  • Fiber benefits increase with more concurrent requests"
puts "  • For large collections (50+ requests), async is significantly faster"
puts ""
puts "═" * 80
