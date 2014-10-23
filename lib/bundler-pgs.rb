require 'bundler/version'

if Bundler::VERSION > "1.7.4"
  puts "\nWarning: You are using bundler #{Bundler::VERSION} and bundler-pgs patch might not work for this version."
  puts "Make sure your Gemfile.lock does not contain your credentials after running bundle-pgs!"
  puts ""
end

require "bundler-pgs/version"
require "bundler-pgs/credential_file"
require "bundler-pgs/bundler_patch"
require "bundler-pgs/bundler_dsl_extension"

