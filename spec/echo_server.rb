#!/usr/bin/env ruby

require "rubygems"
require "ruby-debug"
require "webrick"
require "json"
require "pp"

server = WEBrick::HTTPServer.new({:Port => 8080})
trap("INT"){server.shutdown}
trap("TERM"){server.shutdown}

server.mount_proc("/prospects") do |request, response|
  debugger
  json = JSON.parse(request.body)
  pp(request.header)
  pp(json)
end

server.start
