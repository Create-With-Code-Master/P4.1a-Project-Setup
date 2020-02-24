#!/usr/bin/env ruby

# Automated checks

require 'optparse'

opts = {
  base_url: 'https://github.com/',
  branch: 'lesson-1',
  clone: 'git clone',
  gitignore_size: 500,
  scene: "Prototype 4.unity",
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

# Confirm that .gitignore exists and the file count is reasonable.

require 'pathname'

gitignore = Pathname.new("#{local_repo}/.gitignore")
if (gitignore.file? && gitignore.size > opts[:gitignore_size])
  items = Dir["#{local_repo}/**/*"].length
  if (items >= 20 && items <= 200)
    score += 1
  end
end

# Confirm that the prototype scene file exists & the sample has been removed

prototype_scene = Pathname.new("#{local_repo}/Assets/Scenes/#{opts[:scene]}")
sample_scene = Pathname.new("#{local_repo}/Assets/Scenes/Sample Scene.unity")

if (prototype_scene.file? && !sample_scene.file?)
  score += 1
end

# Check that the branch for this lesson exists.

cmd = "cd #{local_repo}; git checkout #{opts[:branch]}"

stdout = %x( #{cmd} )

if ($?.exitstatus == 0)
  # Success
  score += 1
else
  puts stdout
end

puts score
