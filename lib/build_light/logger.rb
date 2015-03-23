module Logger

  include Logging.globally

  # here we setup a color scheme called 'bright'
  Logging.color_scheme( 'bright',
    :levels => {
      :info  => :green,
      :warn  => :yellow,
      :error => :red,
      :fatal => [:white, :on_red]
    },
    :date => :blue,
    :logger => :cyan,
    :message => :magenta
  )

  Logging.appenders.stdout(
    'stdout',
    :layout => Logging.layouts.pattern(
      :pattern => '[%d] %-5l %c: %m\n',
      :color_scheme => 'bright'
    )
  )

  Logging.logger.root.level = :debug
  Logging.logger.root.appenders = Logging.appenders.stdout
  Logging.consolidate 'BuildStatus', 'NilLight'

end