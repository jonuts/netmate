require "readline"
require "rubygems"
require "net/sftp"

module Netmate
  
  # To shell or not to shell.. when it can upload upon saving, we can get rid of this maybe
  class Shell
    def initialize
      @open = []
    end
  
    def run
      loop do
        cmd = Readline.readline("> ").downcase.split
        Readline::HISTORY.push cmd.join(" ")
        c,a = cmd.shift, cmd.join(" ") 
      
        if c == 'exit'
          puts 'Goodbye.'
          exit
        elsif c == 'mate'
          @open << (key = generate_key)
          file = File.new(a,key)
          file.open
        elsif c == 'save'
          (file = File.find_by(:filename => a)).save
          @open.delete file.key
        elsif c == 'show'
          @open.each do |file|
            print File.find_by(:filename => file).filename, file == @open.last ? '.' : ', '
          end
        else
          puts help
        end
      end
    end

    def generate_key
      10.times { (@a ||= []) << num; @a << letter }
      @a.sort_by { rand }.join
    end
    
    def num
      rand 10
    end
    
    def letter
      ('a'..'z').to_a[rand(26)]
    end
  
    def help
      "Help me plox"
    end
    
    # def edit(file)
    #   download file
    #   %x(mate /tmp/feh.html)
    # end
      
    # def download(file)
    #   Net::SFTP.start(@host, @user, :password => @pass) do |sftp|
    #     sftp.download!(file, "/tmp/feh.html")
    #   end
    # end
  
  end
  
  class File
    def initialize(filename, key)
      @filetype, @filename = filename.slice(/\..+$/), filename
      @key = key
    end
    
    def open
      download @filename
      %x(mate /tmp/#{@key + @filetype})
    end
    
  protected
    def download(file)
      Net::SFTP.start($config[:host], $config[:user], :password => $config[:pass]) do |sftp|
        sftp.download!($config[:path]+@filename, "/tmp/#{@key + @filetype}")
      end
    end
  end
  
end