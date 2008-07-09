require "readline"
require "rubygems"
require "net/sftp"

module Netmate
  
  # To shell or not to shell.. when it can upload upon saving, we can get rid of this
  class Shell
    def initialize(args)
      @user = args[:user]
      @pass = args[:pass]
      @host = args[:host]
      @path = args[:path]
      # @file = args[:file]
      # @type = @file.split(".").pop
      # @key  = generate_key
    end
  
    def run
      loop do
        cmd = Readline.readline("> ").downcase.split
        Readline::HISTORY.push cmd.join(" ")
        c,a = cmd.shift, cmd.join(" ") 
      
        exit if c == "exit"
        Netmate::File.new(a) if c == 'mate'
      end
    end
  
    # def edit(file)
    #   download file
    #   %x(mate /tmp/feh.html)
    # end
    #   
    # def download(file)
    #   Net::SFTP.start(@host, @user, :password => @pass) do |sftp|
    #     sftp.download!(file, "/tmp/feh.html")
    #   end
    # end
  
  end
  
  class File
    def initialize(filename)
      @filetype, @filename = (file = filename.slice(/\..+/)), file
      @key = generate_key
    end
    
  protected
    def generate_key
      10.times { (@a ||= []) << num; @a << letter }
      @a.sort_by { rand }
    end
  end
end