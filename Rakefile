require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :example_app do
  Spec::Rake::SpecTask.new(:spec) do |spec|
    desc "Specs for Example app"
    spec.libs << 'lib' << 'spec'
    spec.spec_files = FileList['examples/rails_root/spec/**/*_spec.rb']
  end
end

task :default => [ :spec, 'example_app:spec' ]
