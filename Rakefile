if File.exists?(".env")
  require 'dotenv'
  Dotenv.load
end

Dir[File.join(File.dirname(__FILE__),'lib','tasks','*.rake')].each {|f| load f}

task :default => :test

task :environment do
  require_relative 'app'
end

require 'rake/testtask'
Rake::TestTask.new do |test|
  test.libs = ["test","lib"]
  test.test_files = FileList['test/**/*_test.rb']
  test.verbose = true
end
