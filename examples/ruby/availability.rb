# Live slots for one activity on one date.
# Usage: ruby availability.rb <activityId> <YYYY-MM-DD> [adults]
require 'json'
require 'net/http'
require 'uri'

base = ENV.fetch('TOURSCANNER_BASE_URL', 'https://tourscanner.ai')
key = ENV['TOURSCANNER_API_KEY'] or abort('Set TOURSCANNER_API_KEY first')
abort('Usage: ruby availability.rb <activityId> <YYYY-MM-DD> [adults]') if ARGV.length < 2

body = { activityId: ARGV[0].to_i, date: ARGV[1], adults: (ARGV[2] || 2).to_i }
res = Net::HTTP.post(URI("#{base}/api/availability/slots"), body.to_json,
                     'X-API-Key' => key, 'Content-Type' => 'application/json')
abort("#{res.code} #{res.body}") unless res.is_a?(Net::HTTPSuccess)

slots = JSON.parse(res.body)['slots'] || []
puts 'No slots on that date. Try another one.' if slots.empty?
slots.each do |s|
  state = s['available'] ? 'open    ' : 'sold out'
  puts format('%s  %s  %.2f %s  %s', s['startTime'], state, s['totalPrice'] / 100.0, s['currency'], s['label'])
end
