require "readline"
require "rubygems"
require "net/ssh"
require "net/sftp"

%w(shell file).each do |file|
  require File.dirname(__FILE__) + "/netmate/#{file}"
end

module Netmate  
end