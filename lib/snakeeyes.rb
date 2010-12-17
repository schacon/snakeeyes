require 'open3'
require 'pp'

class SnakeEyes

  attr_accessor :path, :sleep, :debug_level, :run_count, :master, :omaster

  def initialize(path)
    @path = path
    @sleep = 5 * 60 # 5 minutes
    @debug_level = 99
    @run_count = 0
  end

  def start
    Dir.chdir(@path) do
      debug "Starting loop"
      main_loop
    end
  end

  def main_loop
    while true
      debug "Start #{@path}"

      if has_new_commits || first_run
        reset_to_newest_commit
        run_tests
        report_tests
      end

      sleepy_time
      @run_count += 1
    end
  end

  def first_run
    @run_count == 0
  end

  # if something is new, reset to it
  def reset_to_newest_commit
    debug "reset to newest commit"
  end

  def run_tests
    debug "run tests"
  end

  # report the output to general hawk
  def report_tests
    debug "report tests"
  end

  def has_new_commits
    debug "check for new commits"

    # look at origin/master branch
    current_master = git("rev-parse origin/master")
    debug "current o/master #{current_master}", 1

    debug "fetching commits"
    git('fetch')

    # look at origin/master branch again
    new_master = git("rev-parse origin/master")
    debug "new o/master #{new_master}", 1

    # set master branch SHA internally
    @omaster = new_master

    @master = git("rev-parse refs/heads/master")
    debug "master #{@master}", 1

    # return true if they differ
    new_master != current_master
  end

  def sleepy_time
    debug
    debug "OK, sleeping for a while (#{@sleep})..."
    debug
    Kernel.sleep @sleep
  end

  def git(command)
    out = ''
    Open3.popen3("git #{command}") do |stdin, stdout, stderr|
      out = stdout.read
    end
    out.chomp
  end

  def debug(message = "", level = 0)
    if level <= @debug_level
      tabs = "\t" * level
      puts tabs + message 
    end
  end
end
