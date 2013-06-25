# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [reghistory.rb]                                                    ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './conf/ExecCode'
require './conf/ResultCode'
require './api/RegistStatus'
require './lib/Log'
require './lib/LogStdOut'
require './main2/RegistHistoryController'


## ------------------------------------------------------------------ ##
## [step.1] Define                                                    ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##
#### Define ####
## Classes
log    = Log.new
stdout = LogStdOut.new
conf   = Configure.new
## Variables
strResultCode = ResultCode::NORMAL
strOptValue   = ""


## ------------------------------------------------------------------ ##
## [step.2] Get and Check Args                                        ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##
#### Get and Check Args ####
if ARGV.size > 0

  ## Set ExecCode
  strExecCode = ARGV[0]

  ## Search: REGHISTORY_GET_ALL
  if strExecCode == ExecCode::REGHISTORY_GET_ALL
    ## on Error --> exit(1)
    if ARGV.size != 3
      stdout.error("reghistory.rb#exec: Parameter Error.")
      strResultCode = ResultCode::PARAMETER_ERROR
      exit(1)
    end
    ## on Normal --> Set strOffset, strLimit
    strOffset = ARGV[1].dup
    strLimit  = ARGV[2].dup
  ## Search: REGHISTORY_GET_NOTDELETED
  elsif strExecCode == ExecCode::REGHISTORY_GET_NOTDELETED
    ## on Error --> exit(1)
    if ARGV.size != 3
      stdout.error("reghistory.rb#exec: Parameter Error.")
      strResultCode = ResultCode::PARAMETER_ERROR
      exit(1)
    end
    ## on Normal --> Set strOffset, strLimit
    strOffset = ARGV[1].dup
    strLimit  = ARGV[2].dup
  ## Search: REGHISTORY_GET_RECENTONE
  elsif strExecCode == ExecCode::REGHISTORY_GET_RECENTONE
    ## on Error --> exit(1)
    if ARGV.size != 3
      stdout.error("reghistory.rb#exec: Parameter Error.")
      strResultCode = ResultCode::PARAMETER_ERROR
      exit(1)
    end
    ## on Normal --> Set strOffset, strLimit
    strOffset = ARGV[1].dup
    strLimit  = ARGV[2].dup
  ## Search: REGHISTORY_GET_FROM_REPOSITORYCODE
  elsif strExecCode == ExecCode::REGHISTORY_GET_FROM_REPOSITORYCODE
    ## on Error --> exit(1)
    if ARGV.size != 4
      stdout.error("reghistory.rb#exec: Parameter Error.")
      strResultCode = ResultCode::PARAMETER_ERROR
      exit(1)
    end
    ## on Normal --> Set OptValue, strOffset, strLimit
    strOptValue = ARGV[1].dup.to_s.strip
    strOffset   = ARGV[2].dup.to_s.strip
    strLimit    = ARGV[3].dup.to_s.strip
  ## Delete: DELETE (DEL_FLAG --> 9)
  elsif strExecCode == ExecCode::REGHISTORY_DELETE
    ## on Error --> exit(1)
    if ARGV.size != 2
      stdout.error("reghistory.rb#exec: Parameter Error.")
      strResultCode = ResultCode::PARAMETER_ERROR
      exit(1)
    end
    ## on Normal --> Set OptValue, strOffset, strLimit
    strOptValue = ARGV[1].dup.to_s.strip
  ## Delete: ENABLE (DEL_FLAG --> 0)
  elsif strExecCode == ExecCode::REGHISTORY_ENABLE
    ## on Error --> exit(1)
    if ARGV.size != 2
      stdout.error("reghistory.rb#exec: Parameter Error.")
      strResultCode = ResultCode::PARAMETER_ERROR
      exit(1)
    end
    ## on Normal --> Set OptValue, strOffset, strLimit
    strOptValue = ARGV[1].dup.to_s.strip
  ## Undefined ExecCode --> exit(1)
  else
    stdout.error("reghistory.rb#exec: Undefined ExecCode was Given.")
    strResultCode = ResultCode::EXECCODE_ERROR
    exit(1)
  end

## on Error
else
  stdout.error("reghistory.rb#exec: No Parameter.")
  strResultCode = ResultCode::PARAMETER_ERROR
  exit(1)
end


## ------------------------------------------------------------------ ##
## [step.3] Initialize                                                ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##
#### Initialize ####
## Connect DB
strResultCode = conf.init
## on Error --> exit(1)
if strResultCode != ResultCode::NORMAL
  stdout.error("reghistory.rb: System Error Occurred! ERRORCODE = [" + strResultCode + "]")
  exit(1)
end


## ------------------------------------------------------------------ ##
## [step.4] Exec                                                      ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##
#### Exec ####
## Call Controller
registHistoryController = RegistHistoryController.new
## Exec
## Case: REGHISTORY_GET_ALL
if strExecCode == ExecCode::REGHISTORY_GET_ALL
  registHistoryController.setOffset(strOffset)
  registHistoryController.setLimit(strLimit)
  strResultCode = registHistoryController.exec(ExecCode::REGHISTORY_GET_ALL)
## Case: REGHISTORY_GET_NOTDELETED
elsif strExecCode == ExecCode::REGHISTORY_GET_NOTDELETED
  registHistoryController.setOffset(strOffset)
  registHistoryController.setLimit(strLimit)
  strResultCode = registHistoryController.exec(ExecCode::REGHISTORY_GET_NOTDELETED)
## Case: REGHISTORY_GET_RECENTONE
elsif strExecCode == ExecCode::REGHISTORY_GET_RECENTONE
  strResultCode = registHistoryController.exec(ExecCode::REGHISTORY_GET_RECENTONE)
## Case: REGHISTORY_GET_FROM_REPOSITORYCODE
elsif strExecCode == ExecCode::REGHISTORY_GET_FROM_REPOSITORYCODE
  registHistoryController.setRepositoryCode(strOptValue)
  registHistoryController.setOffset(strOffset)
  registHistoryController.setLimit(strLimit)
  strResultCode = registHistoryController.exec(ExecCode::REGHISTORY_GET_FROM_REPOSITORYCODE)
## Case: DELETE (DEL_FLAG --> 9)
elsif strExecCode == ExecCode::REGHISTORY_DELETE
  registHistoryController.setRegistID(strOptValue)
  strResultCode = registHistoryController.exec(ExecCode::REGHISTORY_DELETE)
## Case: ENABLE (DEL_FLAG --> 0)
elsif strExecCode == ExecCode::REGHISTORY_ENABLE
  registHistoryController.setRegistID(strOptValue)
  strResultCode = registHistoryController.exec(ExecCode::REGHISTORY_ENABLE)
end


## ------------------------------------------------------------------ ##
## [step.5] Finalize                                                  ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##
#### Finalize ####
## Close DB
conf.final


## ------------------------------------------------------------------ ##
## [step.6] Exit                                                      ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##
#### Return Exit Code ####
## on Normal --> exit(0)
if strResultCode == ResultCode::NORMAL
  exit(0)
## on Error --> exit(1)
else
  stdout.error("reghistory.rb: System Error Occurred! ERRORCODE = [" + strResultCode + "]")
  exit(1)
end

