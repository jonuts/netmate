module Netmate
  class File
    def initialize(path, filename, key)
      @filetype = filename.slice(/\..+$/)
      @full_file_name = filename
      filename  = filename.split('/').last
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
        begin
          sftp.download!(@path + @full_file_name, "/tmp/#{@key + @filename}") if method == :download
        rescue
          FileUtils.touch("/tmp/#{@key + @filetype}")
        end
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