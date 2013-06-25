# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [LogStdOut.rb]                                                     ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './lib/Date'
require './lib/Log'

class LogStdOut


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##


  ## ---------------------------------------------------------------- ##
  ## [initialize]                                                     ##
  ## ---------------------------------------------------------------- ##
  def initialize
    init
  end


  ## ---------------------------------------------------------------- ##
  ## [method] init                                                    ##
  ## ---------------------------------------------------------------- ##
  def init
    ## Classes
    @date = Date.new
    @log  = Log.new
    ## Variables
    @strDateFormat = "%Y/%m/%d %H:%M:%S.%6N"
  end


  ## ---------------------------------------------------------------- ##
  ## [method] getDateTime                                             ##
  ## ---------------------------------------------------------------- ##
  def getDateTime
    return @date.getNow(@strDateFormat)
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] debug                                               ##
  ## ---------------------------------------------------------------- ##
  def debug(strMessage)
    if strMessage != nil
      puts (getDateTime + " ##DEBUG> " + strMessage)
      @log.debug(strMessage)
    end
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] info                                                ##
  ## ---------------------------------------------------------------- ##
  def info(strMessage)
    if strMessage != nil
      puts (getDateTime + " ###INFO> " + strMessage)
      @log.info(strMessage)
    end
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] warn                                                ##
  ## ---------------------------------------------------------------- ##
  def warn(strMessage)
    if strMessage != nil
      puts (getDateTime + " !!!WARN> " + strMessage)
      @log.warn(strMessage)
    end
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] error                                               ##
  ## ---------------------------------------------------------------- ##
  def error(strMessage)
    if strMessage != nil
      puts (getDateTime + " !!ERROR> " + strMessage)
      @log.error(strMessage)
    end
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] fatal                                               ##
  ## ---------------------------------------------------------------- ##
  def fatal(strMessage)
    if strMessage != nil
      puts (getDateTime + " !!FATAL> " + strMessage)
      @log.fatal(strMessage)
    end
  end

end

