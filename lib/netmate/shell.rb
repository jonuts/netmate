module Netmate
  # To shell or not to shell.. when it can upload upon saving, we can get rid of this maybe
  class Shell
    def initialize
      @open = []
    end

    def run
      ssh = Net::SSH.start($config[:host], $config[:user], :password => $config[:pass])
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
            if a.empty?
              # save all
              @open.each do |key|
                (file = File.find_by(:key => key)).save
                @open.delete file.key
              end
            else
              (file = File.find_by(:filename => a)).save
              @open.delete file.key
            end
          elsif c == 'show'
            if @open.empty?
              puts "nothing to see here people."
            else
              @open.each do |file|
                print File.find_by(:key => file).filename, file == @open.last ? "\n" : ', '
              end
            end
          else
            channel = ssh.exec("#{c} #{a}")
            ssh.loop(0.1) do
              begin
                buf = $stdin.read_nonblock(1000)
                channel.send_data buf
              rescue Errno::EAGAIN
                nil
              rescue EOFError
                channel.close
              rescue => e
                puts "#{e.class}: #{e.message}"
              end
              ssh.busy?
            end
          end
        rescue => e
          puts "#{e.class}: #{e.message}"
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
  
end