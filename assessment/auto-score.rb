#!/usr/bin/env ruby

# Automated checks

require 'optparse'
require 'open3'         # Used by clone().
include Open3
require 'pathname'

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
  @comments.push('After correcting any problems you may resubmit up until the assignment closes.') if (resubmit)
  puts @score
  if ( @comments[0].length > 0 )
    @comments.each do |c|
      puts "#{c}\n\n"
    end
  end
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

  #stdout = %x( #{cmd} )
  fd0, fd1, fd2, wait = popen3(cmd)
  fd0.close

  stdout = fd1.read ; fd1.close
  stderr = fd2.read ; fd2.close

  if (wait.value == 0)
    # Success
    points = 1
    msg = ''
  else
    # XXX: clean up regexp handling - don't bury it here.
    points = 0
    msg = "Unable to clone \'#{url}\'. "
    if (url.match(/\/[Pp]rototype-*[1-5]$/))
      # URL seems plausible
      msg += "Please check the URL and make sure the repository isn't private."
    else
      # ...or not.
      msg += "Please check the URL."
    end
  end
  return points, msg
end

def check_repo_sanity(path, min, max)
  # Check that the repository looks sane. We expect:
  # - An Assets folder
  # - A .gitignore File
  # - At least min files
  # - No more than max files

  assets = Pathname.new("#{local_repo}/Assets")
  if (assets.dir?)
    points = 1
  else
    points = 0
    msg = "Your Assets folder appears to be missing. Did you create your Git " +
          "repository inside of your Unity project (do you see a Prototype-4 " +
          "folder inside of your Unity project)? If that is so, Git won't "    +
          "see your changes (there will be nothing to commit & push). If "     +
          "you've just started, the easiest thing to do is probably to "       +
          "delete the repository locally and on GitHub and start over. It is " +
          "also possible to move the Git repository 'up a level' to fix the "  +
          "problem. As long as you fix it promptly it's not a big deal "       +
          "either way."
  end

  gitignore = Pathname.new("#{local_repo}/.gitignore")
  if (gitignore.file? && gitignore.size > @opts[:gitignore_size])
    # Do nothing, we're either already good or going to fail due to the
    # Assets folder being missing.
  else
    points = 0
    msg = "Your .gitignore is either missing or smaller than expected for "    +
          "Unity - please double check that you have a good .gitignore."
  end

  items = Dir["#{local_repo}/**/*"].length
  if (items >= 20 && items <= 200)
    # Same logic here.
  elsif (items < 20)
    points = 0
    msg = "There don't seem to be enough files is your project - it's likely " +
          "that your Unity project and the Git repository aren't in the same " +
          "the same folder - please ask for help if you don't know how to fix" +
          "this problem."
  else # > 200
    points = 0
    msg = "There are way too many files in your Git repository. This usually " +
          "happens when either the .gitignore file is missing or the first "   +
          "commit was done before adding it. You may also be having trouble "  +
          "pushing to GitHub. If you have a good .gitignore this will be "     +
          "messy to fix - it's probably easiest to start over."
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

# Confirm that the repo looks sane.

points, comment = check_repo_sanity(local_repo, 20, 200)
@score += points
@comments.push(comment)
done(true) if (points == 0) # Clone failed, quit

# Confirm that the prototype scene file exists & the sample has been removed

prototype_scene = Pathname.new("#{local_repo}/Assets/Scenes/#{@opts[:scene]}")
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

done(@resubmit)
