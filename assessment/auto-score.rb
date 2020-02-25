#!/usr/bin/env ruby

# Automated checks

require 'optparse'

@opts = {
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

  o.on('-b BRANCH') { |v| @opts[:branch] = v }
  o.on('-T TMPDIR') { |v| @opts[:tmp_dir] = v }
  o.on('-v')        { |v| @opts[:verbose] = true }
end.parse!

repo_url = ARGV.pop

@score = 0
@comments = []
@resubmit = false

def done(resubmit)
  @comments.push('After correcting the problems above you can resubmit up until the assignment closes.') if (resubmit)
  puts "#{@score}\n#{@comments}"
  exit
end

def clone(url, path)

  # Attempt to clone the repository.
  #
  # Possible results:
  # - Success: the URL clones successfuly.
  # - Failure: the URL "looks" good, but failed to clone - perhaps a private repo.
  # - Failure: the URL does not match the expected pattern.

  cmd = "#{@opts[:clone]} #{url} #{path}"

  stdout = %x( #{cmd} )

  if ($?.exitstatus == 0)
    # Success
    points = 1
    msg = ''
  else
    # XXX: clean up regexp handling - don't bury it here.
    points = 0
    msg = "Unable to clone \'#{url}\'. "
    if (url.match(/\/[Pp]rototype-*[1-5]$/))
      # URL seems plausible
      msg += "Is the repository private?"
    else
      # ...or not.
      msg += "Please check the URL."
    end
  end
  return points, msg
end

local_repo = repo_url.gsub(@opts[:base_url], '')
local_repo = "#{@opts[:tmp_dir]}/#{local_repo}" if @opts[:tmp_dir]
repo_name = local_repo.gsub(/^.*\//, '')

points, comment = clone(repo_url, local_repo)
@score += points
@comments.push(comment)
done(true) if (points == 0) # Clone failed, quit

# Confirm that .gitignore exists and the file count is reasonable.

require 'pathname'

gitignore = Pathname.new("#{local_repo}/.gitignore")
if (gitignore.file? && gitignore.size > @opts[:gitignore_size])
  items = Dir["#{local_repo}/**/*"].length
  if (items >= 20 && items <= 200)
    @score += 1
  end
end

# Confirm that the prototype scene file exists & the sample has been removed

prototype_scene = Pathname.new("#{local_repo}/Assets/Scenes/#{opts[:scene]}")
sample_scene = Pathname.new("#{local_repo}/Assets/Scenes/Sample Scene.unity")

if (prototype_scene.file? && !sample_scene.file?)
  @score += 1
end

# Check that the branch for this lesson exists.

cmd = "cd #{local_repo}; git checkout #{@opts[:branch]}"

stdout = %x( #{cmd} )

if ($?.exitstatus == 0)
  # Success
  @score += 1
else
  puts stdout
end

done
