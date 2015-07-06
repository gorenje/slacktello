Dir[File.join(File.dirname(__FILE__),'lib','tasks','*.rake')].each {|f| load f}

task :default => :test
task :environment do
  require_relative 'app.rb'
end
