
require 'amqp'
require 'mq'
require 'growl'
require 'daemons'


module GrowlAMQP

  # monitor a given AMQP stream
  # the given_opts may contain options for AMQP.start!
  # and also :queue, :exchange, :vhost, :user, :pass,
  # :routing_key, :file, and :ontop.
  def monitor!(given_opts = nil, &block)

    # default options
    opts = {}
    unless given_opts
      opts[:exchange] = 'amq.fanout'
      opts[:queue] = 'amqpgrowl'
    end
    
    parser = OptionParser.new do | o | 
      o.banner = "Usage: #{File.basename($0)} [OPTIONS] <start|stop>"  
      o.banner = "Relay AMQP messages via growl.  Handy for debugging AMQP applications."  
    
      o.on('-q','--queue <queue>','The name of the AMQP queue to subscribe to') do | queue |
        opts[:queue] = queue 
      end
      
      o.on('-e','--exchange <exchange>','The name of the AMQP exchange to bind to.  Can be specified multiple times') do | exch |
        opts[:exchange] = exch
      end
    
      o.on('-k','--key <routing key>','The routing key to bind to (on diret and topic exchanges)') do | key |
        opts[:key] = key
      end
    
      o.on('-v','--vhost <vhost>','The name of the AMQP vhost to connect to') do | vhost |
        opts[:vhost] = vhost
      end
      
      o.on('-r','--remote <host>','The AMQP broker hostname') do | host |
        opts[:host] = host
      end
    
      o.on('-u','--user <user>','AMQP username') do | user |
        opts[:user] = user
      end
    
      o.on('-p','--pass <pass>','AMQP password') do | pass |
        opts[:pass] = pass 
      end
    
      o.on('-c','--file <filename>',"Use the given configuration file for options") do | file |
        opts[:file] = file 
      end
    
      o.on('-t','--ontop','Stay on top (does not daemonize)') do
        opts[:ontop] = true
      end
    
      o.on('-s','--stop','Stop daemon') do
        opts[:command] = "stop"
      end
    
      o.on('-h','--help','This help screen') do | nix |
        puts o
        abort ""
      end
    
    end
    
    parser.parse!

    # overwrite file options with CLI options
    if opts[:file]
      opts = YAML.load_file(opts[:file]).merge(opts)
    end

    # overwrite given options with CLI options
    opts = given_opts.merge(opts) if given_opts

    opts[:proc] = block || nil
    opts[:command] ||= "start"
    daemons_argv = [opts[:command]]
    
    unless opts[:command] == "stop"
      puts "Want to save these options?  Use this as a configuration file, and use -f to find it next time."
      puts YAML.dump(opts.reject { |k, v| [:proc,:command].include? k})
    end

    opts[:icon] = File.expand_path(File.join(File.dirname(__FILE__), '..', 'resources','amqp.jpg'))
    
    Daemons.run_proc("growlamqp", { :multiple => true,
                                    :ARGV => daemons_argv,
                                    :ontop => opts[:ontop]
                                    } ) do 
      trap(:INT) do AMQP.stop { EM.stop_event_loop }; abort "" end
      AMQP.start(opts) do
    
        queue = MQ::Queue.new(MQ.new,opts[:queue], :autodelete => true) 
        queue.bind(opts[:exchange], :routing_key => opts[:key])
        
        queue.subscribe do | header, body |
          
          message = opts[:proc] ? opts[:proc].call(body) : body
          if ! message.nil? 
            Growl.notify do | m |
              m.image = opts[:icon]
              m.message = message
            end
          end
    
        end
      end
    
    end
  end
  module_function :monitor!

end
