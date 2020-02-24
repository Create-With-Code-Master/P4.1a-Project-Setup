#!/usr/bin/env ruby

# Automated checks

require 'optparse'

opts = {
  base_url: 'https://github.com/',
  clone: 'git clone',
  tmp_dir: 'tmp',
  verbose: false
}

OptionParser.new do |o|
  o.banner = "Usage: #{$0} [options]"

  o.on('-T TMPDIR') { |v| opts[:tmp_dir] = v }
  o.on('-v')        { |v| opts[:verbose] = true }
end.parse!

score = 0

github_repo = ARGV.pop

# Attempt to clone the repository.
local_repo = github_repo.gsub(opts[:base_url], '')
local_repo = "#{opts[:tmp_dir]}/#{local_repo}" if opts[:tmp_dir]
repo_name = local_repo.gsub(/^.*\//, '')

cmd = "#{opts[:clone]} #{github_repo} #{local_repo}"

stdout = %x( #{cmd} )

if ($?.exitstatus == 0)
  # Success
  score += 1
end

puts score
