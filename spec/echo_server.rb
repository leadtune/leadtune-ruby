#!/usr/bin/env ruby

require "rubygems"
require "ruby-debug"
require "webrick"
require "json"
require "pp"

server = WEBrick::HTTPServer.new({:Port => 8080})
trap("INT"){server.shutdown}
trap("TERM"){server.shutdown}

def random_buyers(target_buyers)
  target_buyers.map {|name| {"target_buyer" => name, :value => [0, 1].choice}}
end

server.mount_proc("/prospects") do |request, response|
  json = JSON.parse(request.body)

  pp(json)

  if json.include?("sleep")
    $stderr.puts "sleeping..."
    sleep json["sleep"].to_i 
  end

  response.status = 201
  response["Content-Type"] = "application/json"
  r = {
    "prospect_id" => "deadbeef",
    "decision" => {
      "decision_id" => "deadbeef",
      "organization" => json["organization"],
      "created_at" => Time.now,
      "appraisals" => random_buyers(json["decision"]["target_buyers"]),
    },
    "organization" => json["organization"],
    "event" => json["event"],
    "email_hash" => "deadbeef",
    "created_at" => Time.now,
  }
  response.body = r.to_json
end

server.start
