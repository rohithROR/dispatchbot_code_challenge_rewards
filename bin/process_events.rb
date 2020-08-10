#!/usr/bin/env ruby

require 'optparse'
require 'json'
require 'logger'

require_relative "../lib/ruby/customer"
require_relative "../lib/ruby/order"
require_relative "../lib/ruby/event_exception"
require_relative "../lib/ruby/constants"

def parse_args()
    options = {}
    OptionParser.new do |parser|
      parser.banner = "Usage: process_events.rb [options]" 
      parser.on('-f', '--file FILE', "Input for reading events json file") do |file|
        options[:input_file] = file
      end
      parser.on("-l", "--log LOGFILE", "Path to log file for dumping output") do |logfile|
          options[:logger] = Logger.new(logfile)
      end 
      options[:logger] ||= Logger.new(STDOUT)
      options[:logger].level = Logger::ERROR

      parser.on('-v', '--verbose', "Increase log output messages to info") do |quiet|
        options[:logger].level = Logger::INFO
      end 
    end.parse!
    options
end

def logger
    options[:logger]
end 

def options
    @options ||= parse_args
end

def parse_json_file(json_file)
    logger.info("Parsing given input json file: #{json_file}")
    JSON.parse(File.read(json_file))
end

def events_data()
   parse_json_file(options[:input_file])[RewardsConstants::EVENTS]
end

def parse_each_event()
    events_data do |event|
        yield event
    end
end

def customers
   @customers ||= {}
end

def find_or_create_customer(name)
   customers[name] ||= Customer.new(name)
end

def process_event(event_hash)
    case event_hash[RewardsConstants::ACTION]
      when "new_customer"
        find_or_create_customer(event_hash[RewardsConstants::NAME])
      when "new_order"
        customer = find_or_create_customer(event_hash[RewardsConstants::CUSTOMER])
        customer.add_order(event_hash)
      else
        raise EventException.new("Event with invalid action: #{event_hash[RewardsConstants::ACTION]}, Please check")
    end
end

if !options[:input_file]
    logger.fatal("Required argument -f/--file missing")
    exit(1)
elsif !File.file?(options[:input_file])
    logger.fatal("Given input json file doesn't exist, Please check and try again")
    exit(2)
end

parse_each_event.each do |event|
   logger.info("Processing event: #{event}")
   
   begin
      process_event(event)
   rescue EventException => event_exception
      logger.error("Processing event failed due to invalid event data: #{event_exception.message}")
   else
      logger.info("Finished processing event")
   end

end

customers.values.sort.each do |customer|
   print "#{customer.name}: #{customer.total_reward_points} points with ",
        "#{customer.average_points_per_order} points per order.\n"
end

