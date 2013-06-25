# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [ShellMaker.rb]                                                    ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './lib/Log'
require './lib/LogStdOut'
require './conf/ResultCode'

class ShellMaker


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
    #### Define ####
    ## Classes
    @log    = Log.new
    @stdout = LogStdOut.new
  end


  ## ---------------------------------------------------------------- ##
  ## [method] openFile                                                ##
  ## ---------------------------------------------------------------- ##
  def openFile(strFileName)

    #### Debug ####
    @log.debug("START: ShellMaker.rb#openFile --------")

    #### Check ####
    ## strFileName
    if strFileName == nil
      @stdout.error("ShellMaker.rb#openFile: strFileName is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strFileName.strip == ""
      @stdout.error("ShellMaker.rb#openFile: strFileName is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      @log.debug("ShellMaker.rb#openFile: strFileName = [" + strFileName.to_s + "]")
      @fw = open(strFileName, "w")
      File.chmod(0755, strFileName)
      @fw.puts "#!/bin/bash"
      @fw.puts
      @fw.puts "echo 'START #{strFileName} ----------------'"
      @fw.puts
    ## on Error
    rescue => e
      strResultCode = ResultCode::FILEIOERROR
      @stdout.error("ShellMaker.rb#openFile: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    end

    #### Debug ####
    @log.debug("END: ShellMaker.rb#openFile --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] setCommand                                              ##
  ## ---------------------------------------------------------------- ##
  def setCommand(strCommand)

    #### Debug ####
    @log.debug("START: ShellMaker.rb#setCommand --------")

    #### Check ####
    ## strCommand
    if strCommand == nil
      @stdout.error("ShellMaker.rb#setCommand: strCommand is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strCommand.strip == ""
      @stdout.error("ShellMaker.rb#setCommand: strCommand is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      @fw.puts strCommand.to_s
      @log.debug("ShellMaker.rb#setCommand: strCommand = [" + strCommand.to_s + "]")
    ## on Error
    rescue => e
      strResultCode = ResultCode::FILEIOERROR
      @stdout.error("ShellMaker.rb#setCommand: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    end

    #### Debug ####
    @log.debug("END: ShellMaker.rb#setCommand --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] closeFile                                               ##
  ## ---------------------------------------------------------------- ##
  def closeFile(strFileName)

    #### Debug ####
    @log.debug("START: ShellMaker.rb#closeFile --------")

    #### Check ####
    ## strFileName
    if strFileName == nil
      @stdout.error("ShellMaker.rb#closeFile: strFileName is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strFileName.strip == ""
      @stdout.error("ShellMaker.rb#closeFile: strFileName is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      @log.debug("ShellMaker.rb#closeFile: strFileName = [" + strFileName.to_s + "]")
      @fw.puts
      @fw.puts "echo 'END #{strFileName} ----------------'"
      @fw.close
    ## on Error
    rescue => e
      strResultCode = ResultCode::FILEIOERROR
      @stdout.error("ShellMaker.rb#closeFile: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    end

    #### Debug ####
    @log.debug("END: ShellMaker.rb#closeFile --------")

    #### Return ####
    return strResultCode

  end

end
