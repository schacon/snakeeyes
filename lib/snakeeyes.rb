require 'rubygems'
require "json"
require "uri"
require 'popen4'
require "net/http"
require 'pp'

class SnakeEyes

  attr_accessor :path, :sleep, :debug_level, :run_count, :master, :omaster, :config

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
        pass, output = run_tests
        report_tests(pass, output)
        @run_count += 1
      end

      sleepy_time
    end
  end

  def first_run
    @run_count == 0
  end

  # if something is new, reset to it
  def reset_to_newest_commit
    debug "reset to newest commit (#{@omaster})"
    git("reset --hard #{@omaster}")
  end

  def run_tests
    debug "run tests"
    command = git("config cijoe.runner")
    debug "running '#{command}'...", 1
    output = ''
    status = POpen4::popen4(command) do |stdout, stderr, stdin, pid|
      out = stdout.read
      err = stderr.read
      output = out + err
    end
    debug "test exitstatus : #{ status.exitstatus }", 2
    [(status.exitstatus == 0), output]
  end

  # report the output to general hawk
  def report_tests(pass, output)
    status = pass ? 'good' : 'bad'
    debug "reporting test results [#{status}] {#{@master}}"
    data = git('log -1 --format="%s:;:%an" ' + @master)
    message, author = data.split(":;:")
    post_results(status, output, message, author, @master)
  end

  def has_new_commits
    debug "check for new commits"

    # look at origin/master branch
    current_master = git("rev-parse origin/master")
    debug "current o/master : #{current_master}", 1

    debug "fetching commits", 1
    git('fetch')

    # look at origin/master branch again
    new_master = git("rev-parse origin/master")
    debug "new o/master     : #{new_master}", 1

    # set master branch SHA internally
    @omaster = new_master

    @master = git("rev-parse refs/heads/master")
    debug "master           : #{@master}", 1

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
    status = POpen4::popen4("git #{command}") do |stdout, stderr, stdin, pid|
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

  ## General Hawk Stuff ##
  
  def post_results(status, output, message, author, sha)
    config = hawk_config
    data = {
        "agent"       => config[:agent],
        "description" => config[:description],
        "branch"      => "master",
        "author"      => author,
        "sha"         => sha,
        "status"      => status,
        "url"         => config[:url],
        "message"     => message,
        "output"      => output
      }
    post_update(data.to_json) # POST JSON TO URL
  end

  def hawk_config
    return @config if @config
    c = {}
    config = git('config --list')
    config.split("\n").each do |line| 
      k, v = line.split('=')
      c[k] = v
    end
    url = ''
    u = c['remote.origin.url']
    if m = /github\.com.(.*?)\/(.*?)\.git/.match(u)
      user = m[1]
      proj = m[2]
      url = "https://github.com/#{user}/#{proj}"
    end

    @config = {
      :server    => c['hawk.server'],
      :token     => c['hawk.token'],
      :agent     => c['hawk.agent'],
      :description => c['hawk.description'],
      :url => url
    }
  end

  def post_update(data)
    config = hawk_config
    ws = "#{config[:server]}/update/#{config[:token]}"
    x = Net::HTTP.post_form(URI.parse(ws), {'data' => data})
    pp x
  end
end
