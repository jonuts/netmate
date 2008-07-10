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
      
        begin
          if c == 'exit'
            puts 'Goodbye.'
            exit
          elsif c == 'mate'
            @open << (key = generate_key)
            file = File.new($config[:path], a, key)
            file.open
          elsif c == 'save'
            (file = File.find_by(:filename => a)).save
            @open.delete file.key
          elsif c == 'show'
            if @open.empty?
              puts "nothing to see here people."
            else
              @open.each do |file|
                print File.find_by(:key => file).filename, file == @open.last ? "\n" : ', '
              end
            end
          else
            puts help
          end
        rescue => e
          puts "#{e.class}: #{e.message}"
          next
        end
      end
    end
    
  protected
    # Generate a random key so we can find the file later
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
    
  end
  
  class File
    def initialize(path, filename, key)
      @filetype = filename.slice(/\..+$/)
      @filename = filename
      @path     = path
      @key      = key
      $cache << self
    end
    
    attr_reader :filename, :key
    
    def self.find_by(type = {})
      typek = type.keys.first
      $cache.find { |e| eval("e.#{typek}") == type[typek] }
    end
    
    def open
      open_connection :download
      %x(mate /tmp/#{@key + @filetype})
    end
    
    def save
      open_connection :upload
    end
    
  protected
    def open_connection(method)
      Net::SFTP.start($config[:host], $config[:user], :password => $config[:pass]) do |sftp|
        sftp.download!(@path + @filename, "/tmp/#{@key + @filetype}") if method == :download
        sftp.upload!("/tmp/#{@key + @filetype}", @path + @filename) if method == :upload
      end
    end
    
  end
  
end