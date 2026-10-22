# Search activities in a city. Usage: ruby search.rb <city> [query]
require 'json'
require 'net/http'
require 'uri'

base = ENV.fetch('TOURSCANNER_BASE_URL', 'https://tourscanner.ai')
key = ENV['TOURSCANNER_API_KEY'] or abort('Set TOURSCANNER_API_KEY first')

city = ARGV[0] || 'rome'
params = { city: city, limit: 5 }
params[:q] = ARGV[1] if ARGV[1]

uri = URI("#{base}/api/search/activities")
uri.query = URI.encode_www_form(params)
req = Net::HTTP::Get.new(uri)
req['X-API-Key'] = key
res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(req) }
abort("#{res.code} #{res.body}") unless res.is_a?(Net::HTTPSuccess)

data = JSON.parse(res.body)
puts "#{data['total']} activities in #{city}\n\n"
data['activities'].each do |a|
  # price is in minor units: 5400 means 54.00
  p = a['price']
  price = p ? format('%.2f %s', p['price'] / 100.0, p['currency']) : 'no price'
  puts "#{a['id']}  #{a['name']}  (#{a['reviews_avg'] || '-'} stars, #{price})"
end
