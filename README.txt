SnakeEyes Unit Testing
=========================

So here's the story.  I started out with trying to use CIJoe for all my awesome
testing needs.  It turns out that it calls `sh` on post hooks for reporting,
which doesn't work very well on Windows systems.  Really what I need is a simple
system that will just run the test and then report to General Hawk for me. So,
this is the simplest possible solution.

  $ gem install snakeeyes

  $ git clone [project-url]
  $ cd [project]
  $ git config hawk.server [server]
  $ git config hawk.token  [token]
  $ git config hawk.agent  [agent-string]
  $ git config hawk.description  [agent-desc]
  $ git config cijoe.runner [rake test]

  $ cd ..
  $ snakeeyes [project] &

There are a few other differences, besides working on all platforms.

1) No web interface
2) Polls Git repo until it sees new commits, rinse repeat
3) Auto-reports to GeneralHawk, no hook install needed


