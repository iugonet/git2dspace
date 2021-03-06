# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [Date.rb]                                                          ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require 'date'

class Date


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
  ## [init]                                                           ##
  ## ---------------------------------------------------------------- ##
  def init
  end


  ## ---------------------------------------------------------------- ##
  ## [method] getNow                                                  ##
  ## ---------------------------------------------------------------- ##
  def getNow(strDateFormat)

    #### Exec and Return ####
    dt = DateTime.now
    begin
      dts = dt.strftime strDateFormat
      DateTime.parse(dt.strftime strDateFormat)
      return dts
    rescue => e
      dts = dt.strftime "%Y/%m/%d %H:%M:%S"
      return dts
    ensure
    end

  end


  ## ---------------------------------------------------------------- ##
  ## [method] conv                                                    ##
  ## ---------------------------------------------------------------- ##
  def conv(strDateTime, strDateFormat)

    #### Exec and Return ####
    begin
      dt = DateTime.parse strDateTime
      return dt.strftime(strDateFormat)
    rescue => e
      return strDateTime
    ensure
    end

  end


end
