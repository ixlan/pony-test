# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pony-test}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [",,,"]
  s.date = %q{2009-12-20}
  s.email = %q{youremail@example.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["Rakefile", "README.rdoc", "spec/helpers_spec.rb", "spec/spec_helper.rb", "lib/email_steps.rb", "lib/pony_test.rb"]
  s.homepage = %q{http://yoursite.example.com}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{pony-test}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{What this thing does}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
