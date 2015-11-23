#!/usr/bin/env ruby
module Nagios
  class Passenger
    attr_accessor :warning, :critical

    def initialize
      warning_index = ARGV.index('-w')
      @warning = !!warning_index ? ARGV[warning_index+1].to_i : 2

      critical_index = ARGV.index('-c')
      @critical = !!critical_index ? ARGV[critical_index+1].to_i : 6
      #p "#{@critical} #{@warning}"
    end

    def nagios_exit(exit_code, message, perf_stats)
      code_strings = [ "OK", "WARNING", "CRITICAL", "UNKNOWN", "DEPEDENT" ]
      puts "PASSENGER #{code_strings[exit_code]} - #{message}|#{perf_stats}"
      exit(exit_code)
    end

    def check_status
      garbage,max,worker_count,active,inactive,waiting = `passenger-status`.split("\n")
      # Sanitize 'waiting' metric
      waiting = waiting.gsub('Waiting on global queue', 'waiting').gsub(':','=')
      # Strip white spaces
      max,worker_count,active,inactive,waiting = [max,worker_count,active,inactive,waiting].map{|metric| metric.gsub(/\s+/,'')}

      nagios_exit(exit_code_for(waiting,active),[active,waiting].join(', '),[max,worker_count,active,inactive,waiting].join(';'))
    end

    def exit_code_for(waiting,active)
      return 2 if waiting.split('=')[1].to_i > @critical
      return 1 if waiting.split('=')[1].to_i > @warning
      return 0 if active.split('=')[1].to_i == 0
      return 0
    end
  end
end

Nagios::Passenger.new().check_status
