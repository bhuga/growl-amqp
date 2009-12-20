# GrowlAMQP

Display AMQP messages in growl.

The built in binary, 'growlamqp', will run out-of-the-box to report
messages with non-binary data.  It looks like this:

### growlamqp example
    $ growlamqp -e amq.direct -k my.key.name
    $

If your data requires post-processing, or you only want to see some data,
write a wrapper script.  Return whatever you want and growl will print it.
Return nil and it won't print it.

### queuemon

    # queuemon
    #!/usr/bin/env ruby
    require 'growlamqp'
    require 'bert'

    GrowlAMQP.monitor! do | msg |
      BERT.decode(msg)
    end

The file 'queuemon' is now a workable executable,
complete with config files, command line options,
and more.  Enjoy.
