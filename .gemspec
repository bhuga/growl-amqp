GEMSPEC = Gem::Specification.new do |gem|
  gem.name = 'growl-amqp'
  gem.version = '0.1.0'
  gem.date = '2009-12-20'
  gem.license = 'Public Domain' if gem.respond_to?(:license=)
  gem.summary = 'Report AMQP messages via Growl.  Grr, grr!'
  gem.description = gem.summary
 
  gem.authors = ['Ben Lavender']
  gem.email = 'blavender@gmail.com'
 
  gem.platform = Gem::Platform::RUBY
  gem.files = %w(README.md LICENSE UNLICENSE bin/growlamqp lib/growl-amqp.rb examples/bert-decode examples/options resources/amqp.jpg)
  gem.bindir = %q(bin)
  gem.executables = %w(growlamqp)
  gem.default_executable = gem.executables.first
  gem.require_paths = %w(lib)
  gem.extensions = %w()
  gem.test_files = %w()
  gem.has_rdoc = false
 
  gem.required_ruby_version = '>= 1.8.2'
  gem.requirements = ['daemons','amqp','mq','growl']
  gem.add_runtime_dependency 'amqp', '>= 0.6.5'
  gem.add_runtime_dependency 'daemons', '>= 1.0.10'
  gem.add_runtime_dependency 'growl', '>= 1.0.3'
  gem.post_install_message = nil
end

