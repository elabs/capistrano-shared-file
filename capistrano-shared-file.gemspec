# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "capistrano-shared-file"
  gem.version       = "1.1.1"
  gem.authors       = ["Daniel Salmeron Amselem"]
  gem.email         = ["daniel.amselem@gmail.com"]
  gem.description   = %q{Capistrano recipe to upload, download and symlink shared files.}
  gem.summary       = %q{Capistrano recipe to upload, download and symlink shared files.}
  gem.homepage      = "http://github.com/damselem/capistrano-shared-file"
  gem.licenses      = ['MIT']

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'capistrano', '>= 2.0'
end


