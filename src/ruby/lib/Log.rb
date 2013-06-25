# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [Log.rb]                                                           ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require 'logger'
require 'fileutils'
require './conf/Configure'
require './lib/Date'

class Log


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##


  ## ---------------------------------------------------------------- ##
  ## [initialize]                                                     ##
  ## ---------------------------------------------------------------- ##
  def initialize
  end


  ## ---------------------------------------------------------------- ##
  ## [method] setLogger                                               ##
  ## ---------------------------------------------------------------- ##
  def setLogger
    #### Define ####
    ## Call Class
    date = Date.new
    ## Set Log File
    strLogFile = File.join(Configure::LOGDIR, date.getNow("%Y%m%d_%H") + ".log")
    ## Set Logger
    @log = Logger.new strLogFile
    ## Set Log Level
    if Configure::LOG_LEVEL == "DEBUG" || Configure::LOG_LEVEL == "debug"
      @log.level = Logger::DEBUG
    elsif Configure::LOG_LEVEL == "INFO" || Configure::LOG_LEVEL == "info"
      @log.level = Logger::INFO
    elsif Configure::LOG_LEVEL == "WARN" || Configure::LOG_LEVEL == "warn"
      @log.level = Logger::WARN
    elsif Configure::LOG_LEVEL == "ERROR" || Configure::LOG_LEVEL == "error"
      @log.level = Logger::ERROR
    elsif Configure::LOG_LEVEL == "FATAL" || Configure::LOG_LEVEL == "fatal"
      @log.level = Logger::FATAL
    end
  end


  ## ---------------------------------------------------------------- ##
  ## [API-method] debug                                               ##
  ## ---------------------------------------------------------------- ##
  def debug(strMessage)
    if Configure::LOG_FLAG == true
      if strMessage != nil
        setLogger
        @log.debug strMessage
      end
    end
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] info                                                ##
  ## ---------------------------------------------------------------- ##
  def info(strMessage)
    if Configure::LOG_FLAG == true
      if strMessage != nil
        setLogger
        @log.info strMessage
      end
    end
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] warn                                                ##
  ## ---------------------------------------------------------------- ##
  def warn(strMessage)
    if Configure::LOG_FLAG == true
      if strMessage != nil
        setLogger
        @log.warn strMessage
      end
    end
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] error                                               ##
  ## ---------------------------------------------------------------- ##
  def error(strMessage)
    if Configure::LOG_FLAG == true
      if strMessage != nil
        setLogger
        @log.error strMessage

      end
    end
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] fatal                                               ##
  ## ---------------------------------------------------------------- ##
  def fatal(strMessage)
    if Configure::LOG_FLAG == true
      if strMessage != nil
        setLogger
        @log.fatal strMessage
      end
    end
  end


end

