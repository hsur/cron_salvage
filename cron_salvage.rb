#!/usr/bin/env ruby
# Salvaging crontab from /var/log/cron

require 'optparse'
require 'time'

opts = OptionParser.new
conf = Hash.new
conf[:file] = '/var/log/cron'
opts.on("-f", "--file CRONLOG", "cron log file (default: /var/log/cron)"){ |f| conf[:file] = f }
conf[:user] = 'root'
opts.on("-u", "--user USER", "cron user (default: root)"){ |u| conf[:user] = u }
opts.parse!

unless File.exist?( conf[:file] )
  puts "logfile not found. (--file: #{conf[:file]})"
  exit 1
end

cmds = {}
open(conf[:file]) do |file|
  while line = file.gets
    month, day, time, host, proc, user, op, cmd = line.split(' ',8)
    user = user[1..-2]
    cmd = cmd[1..-3]
   
    next unless op == 'CMD' && user == conf[:user]
    cmds[cmd] = {} unless cmds.has_key? cmd
    cmds[cmd].store( (Time.parse("#{month} #{day} #{time}").to_a)[2..3].reverse, true)
  end
end

cmds.each do |cmd, timing|
  timing.keys.sort.each do |k|
    hour, min = k
    puts "#{min} #{hour} * * * #{cmd.gsub('%', '\%')}"
  end
end
