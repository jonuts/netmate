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
            File.new($config[:path], a, key).open
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
      Time.now.strftime("%Y%m%d%H%M%S_")
    end
  
    def help
      "Help me plox"
    end
    
  end
  
  class File
    def initialize(path, filename, key)
      @filetype = filename.slice(/\..+$/)
      @full_file_name = filename
      filename = filename.split('/').last
      @filename = get_filename(filename)
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
      %x(mate /tmp/#{@key + @filename})
    end
    
    def save
      open_connection :upload
    end
    
  protected
    def open_connection(method)
      Net::SFTP.start($config[:host], $config[:user], :password => $config[:pass]) do |sftp|
        sftp.download!(@path + @full_file_name, "/tmp/#{@key + @filename}") if method == :download
        sftp.upload!("/tmp/#{@key + @filename}", @path + @full_file_name) if method == :upload
      end
    end
    
    # make sure there isn't an open file with the filename
    def get_filename(filename,n=1)
      if File.find_by :filename => filename
        name = filename.split('.').first.sub(/--\d--/,'') + '--' + n.to_s + '--' + @filetype
        get_filename(name, n+=1)
      else
        filename
      end
    end
    
  end
  
end