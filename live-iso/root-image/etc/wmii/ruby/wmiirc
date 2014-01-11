#!/usr/bin/env ruby
#
# Bootloader for wmii configuration.
#
#--
# Copyright protects this work.
# See LICENSE file for details.
#++

# create a logger to aid debugging
require 'logger'
LOG = Logger.new(__FILE__ + '.log', 5)

class << LOG
  # emulate IO.write
  alias write <<

  def flush
    # ignore
  end
end

# capture standard output in logger
$stdout = $stderr = LOG

begin
  LOG.info 'birth'

  # load configuration library
    def find_config file
      base_dirs = ENV['WMII_CONFPATH'].to_s.split(/:+/)
      ruby_dirs = base_dirs.map {|dir| File.join(dir, 'ruby') }

      Dir["{#{base_dirs.zip(ruby_dirs).join(',')}}/#{file}"].first
    end

    require find_config('config.rb')

  # terminate any existing wmiirc
    fs.event.write 'Start wmiirc'

    event 'Start' do |arg|
      exit if arg == 'wmiirc'
    end

  # apply user configuration
    load_config find_config('config.yaml')

  # setup tag bar (buttons that correspond to views)
    fs.lbar.clear
    tags.each {|t| event 'CreateTag', t }
    event 'FocusTag', curr_tag

  # register key bindings
    fs.keys.write keys.join("\n")
    event('Key') {|*a| key(*a) }

  # the main event loop
    fs.event.each_line do |line|
      line.split("\n").each do |call|
        name, args = call.split(' ', 2)

        argv = args.to_s.split(' ')
        event name, *argv
      end
    end

rescue SystemExit
  # ignore it; the program wants to terminate

rescue Exception => e
  LOG.error e

  # allow the user to rescue themselves
  system '@TERMINAL@ &'

  IO.popen('xmessage -nearmouse -file - -buttons Recover,Ignore -print', 'w+') do |f|
    f.puts e.inspect, e.backtrace
    f.close_write

    if f.read.chomp == 'Recover'
      reload_config
    end
  end

ensure
  LOG.info 'death'
end
