task :default => :spec

desc "run the specs"
task :spec do
  sh "./node_modules/.bin/vows " + Dir.glob("spec/**/*_spec.js").join(" ")
end
