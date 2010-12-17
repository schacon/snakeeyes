$LOAD_PATH.unshift 'lib'

Gem::Specification.new do |s|
  s.name              = "snakeeyes"
  s.version           = "0.0.1"
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "snakeeyes reports to general hawk. hes the coolest cijoe"
  s.homepage          = "http://github.com/schacon/snakeeyes"
  s.email             = "schacon@gmail.com"
  s.authors           = [ "Scott Chacon" ]
  s.has_rdoc          = false

  s.files             = %w( LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")

  s.executables       = %w( snakeeyes )

   s.description       = <<desc
  snakeeyes is a polling, command line based cijoe replacement that will
  report to generalhawk.
desc
end
