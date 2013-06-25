# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [CharUtil.rb]                                                      ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './lib/Log'
require './lib/LogStdOut'
require './conf/ResultCode'

class CharUtil


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
    #### Define ####
    ## Classes
    @log    = Log.new
    @stdout = LogStdOut.new
  end


  ## ---------------------------------------------------------------- ##
  ## [method] final                                                   ##
  ## ---------------------------------------------------------------- ##
  def final
  end


  ## ---------------------------------------------------------------- ##
  ## [method] sqlEncode                                               ##
  ## ---------------------------------------------------------------- ##
  def sqlEncode(strChar)

    #### Debug ####
#   @log.debug("START: CharUtil.rb#sqlEncode")

    #### Check ####
    if strChar == nil
#     @log.error("CharUtil.rb#sqlEncode: Parameter Error! strChar is NIL.")
      return ""
    elsif strChar.strip == ""
#     @log.error("CharUtil.rb#sqlEncode: Parameter Error! strChar is BLANK.")
      return ""
    end

    #### Exec ####
    strChar = strChar.to_s
#   @log.debug("CharUtil.rb#sqlEncode: strChar = [" + strChar + "]")
    strChar.chomp!
    strChar.strip!
    strChar.gsub!(/[']/, '\'\'')
#   @log.debug("CharUtil.rb#sqlEncode: strChar = [" + strChar + "]")

    #### Debug ####
#   @log.debug("END: CharUtil.rb#sqlEncode")

    #### Return ####
    return strChar

  end


  ## ---------------------------------------------------------------- ##
  ## [method] xmlEncode                                               ##
  ## ---------------------------------------------------------------- ##
  def xmlEncode(strChar)

    #### Debug ####
#   @log.debug("START: CharUtil.rb#xmlEncode")

    #### Check ####
    if strChar == nil
      @log.error("CharUtil.rb#xmlEncode: Parameter Error! strChar is NIL.")
      return ""
    elsif strChar.strip == ""
      @log.error("CharUtil.rb#xmlEncode: Parameter Error! strChar is BLANK.")
      return ""
    end

    #### Exec ####
    strChar = strChar.to_s
#   @log.debug("CharUtil.rb#xmlEncode: strChar = [" + strChar + "]")
    strChar.gsub!(/[&]/, '&amp;')
    strChar.gsub!(/[<]/, '&lt;')
    strChar.gsub!(/[>]/, '&gt;')
    strChar.gsub!(/["]/, '&quot;')
    strChar.gsub!(/[']/, '&apos;')
#   @log.debug("CharUtil.rb#xmlEncode: strChar = [" + strChar + "]")

    #### Debug ####
#   @log.debug("END: CharUtil.rb#xmlEncode")

    #### Return ####
    return strChar

  end


  ## ---------------------------------------------------------------- ##
  ## [method] handleSplit                                             ##
  ## ---------------------------------------------------------------- ##
  def handleSplit(strChar)

    #### Debug ####
    @log.debug("START: CharUtil.rb#handleSplit")

    #### Define ####
    strHandleIDPrefix = ""
    strHandleIDSuffix = ""

    #### Check ####
    if strChar == nil
      @log.error("CharUtil.rb#handleSplit: Parameter Error! strChar is NIL.")
      return strHandleIDPrefix, strHandleIDSuffix
    elsif strChar.strip == ""
      @log.error("CharUtil.rb#handleSplit: Parameter Error! strChar is BLANK.")
      return strHandleIDPrefix, strHandleIDSuffix
    end

    #### Exec ####
    ## Split
    aryElement = strChar.split("/")
    if aryElement.length == 2
      ## Set
      strHandleIDPrefix = aryElement[0].strip
      strHandleIDSuffix = aryElement[1].strip
      ## Debug
      @log.debug("CharUtil.rb#handleSplit: strHandleIDPrefix = [" + strHandleIDPrefix + "]")
      @log.debug("CharUtil.rb#handleSplit: strHandleIDSuffix = [" + strHandleIDSuffix + "]")
      ## Clear Array
      aryElement.clear
    end

    #### Debug ####
    @log.debug("END: CharUtil.rb#handleSplit")

    #### Return ####
    return strHandleIDPrefix, strHandleIDSuffix
    
  end


end
