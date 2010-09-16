#!/usr/bin/env ruby

require "rubygems"
require "curb"


c = Curl::Easy.new("http://kill-0.com/does_not_exist")

c.on_failure do |curl, code|
  puts "failure!"
  puts "code: #{code.inspect}"
  puts "response code: #{curl.response_code}"
  puts "response headers:\n#{curl.header_str}"
end

c.on_success do |curl|
  puts "success!"
end

c.http(:post)
