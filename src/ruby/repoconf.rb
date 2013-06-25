# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [repoconf.rb]                                                      ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './conf/ExecCode'
require './conf/ResultCode'
require './api/Repository'
require './lib/Log'
require './lib/LogStdOut'
require './main2/RepoConfController'


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

  ## Search: REPOCONF_GET_ALL
  if strExecCode == ExecCode::REPOCONF_GET_ALL
    ## on Error --> exit(1)
    if ARGV.size != 1
      stdout.error("repoconf.rb#exec: Parameter Error.")
      strResultCode = ResultCode::PARAMETER_ERROR
      exit(1)
    end
  ## Search: REPOCONF_GET_NOTDELETED
  elsif strExecCode == ExecCode::REPOCONF_GET_NOTDELETED
    ## on Error --> exit(1)
    if ARGV.size != 1
      stdout.error("repoconf.rb#exec: Parameter Error.")
      strResultCode = ResultCode::PARAMETER_ERROR
      exit(1)
    end

  ## Regist: REPOCONF_INTO_ACTIVE
  elsif strExecCode == ExecCode::REPOCONF_REGIST_INTO_ACTIVE
    ## on Error --> exit(1)
    if ARGV.size != 2
      stdout.error("repoconf.rb#exec: Parameter Error.")
      strResultCode = ResultCode::PARAMETER_ERROR
      exit(1)
    end
    ## on Normal --> Set OptValue
    strOptValue = ARGV[1].to_s.strip

  ## Regist: REPOCONF_INTO_PAUSE
  elsif strExecCode == ExecCode::REPOCONF_REGIST_INTO_PAUSE
    ## on Error --> exit(1)
    if ARGV.size != 2
      stdout.error("repoconf.rb#exec: Parameter Error.")
      strResultCode = ResultCode::PARAMETER_ERROR
      exit(1)
    end
    ## on Normal --> Set OptValue
    strOptValue = ARGV[1].to_s.strip

  ## Regist: REPOCONF_INTO_STOP
  elsif strExecCode == ExecCode::REPOCONF_REGIST_INTO_STOP
    ## on Error --> exit(1)
    if ARGV.size != 2
      stdout.error("repoconf.rb#exec: Parameter Error.")
      strResultCode = ResultCode::PARAMETER_ERROR
      exit(1)
    end
    ## on Normal --> Set OptValue
    strOptValue = ARGV[1].to_s.strip

  ## Undefined ExecCode --> exit(1)
  else
    stdout.error("repoconf.rb#exec: Undefined ExecCode was Given.")
    strResultCode = ResultCode::EXECCODE_ERROR
    exit(1)
  end

## on Error
else
  stdout.error("repoconf.rb#exec: No Parameter.")
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
  stdout.error("repoconf.rb: System Error Occurred! ERRORCODE = [" + strResultCode + "]")
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
repoConfController = RepoConfController.new
## Exec
## Case: GET_ALL
if strExecCode == ExecCode::REPOCONF_GET_ALL
  strResultCode = repoConfController.exec(ExecCode::REPOCONF_GET_ALL)
## Case: GET_NOTDELETED
elsif strExecCode == ExecCode::REPOCONF_GET_NOTDELETED
  strResultCode = repoConfController.exec(ExecCode::REPOCONF_GET_NOTDELETED)
## Case: REGIST_INTO_ACTIVE
elsif strExecCode == ExecCode::REPOCONF_REGIST_INTO_ACTIVE
  repoConfController.setRepositoryCode(strOptValue)
  strResultCode = repoConfController.exec(ExecCode::REPOCONF_REGIST_INTO_ACTIVE)
## Case: REGIST_INTO_PAUSE
elsif strExecCode == ExecCode::REPOCONF_REGIST_INTO_PAUSE
  repoConfController.setRepositoryCode(strOptValue)
  strResultCode = repoConfController.exec(ExecCode::REPOCONF_REGIST_INTO_PAUSE)
## Case: REGIST_INTO_STOP
elsif strExecCode == ExecCode::REPOCONF_REGIST_INTO_STOP
  repoConfController.setRepositoryCode(strOptValue)
  strResultCode = repoConfController.exec(ExecCode::REPOCONF_REGIST_INTO_STOP)
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
  stdout.error("repoconf.rb: System Error Occurred! ERRORCODE = [" + strResultCode + "]")
  exit(1)
end

