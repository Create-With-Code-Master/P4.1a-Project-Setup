#!/usr/bin/env ruby

# Automated checks

opts = {
  tmp_dir: "tmp",
  verbose: false
}

OptionParser.new do |o|
  o.banner = "Usage: #{$0} [options]"
  
  o.on("-T TMPDIR") { |v| opts[:tmp_dir] = v }
  o.on("-v")        { |v| opts[:verbose] = true }
end.parse!

p ARGV
