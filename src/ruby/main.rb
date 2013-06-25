# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [main.rb]                                                          ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './lib/Log'
require './lib/LogStdOut'
require './conf/ExecCode'
require './conf/ResultCode'
require './conf/Configure'
require './main1/FileController'
require './main1/AdminDBController'
require './main1/RegistController'


## ------------------------------------------------------------------ ##
## [Define]                                                           ##
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
MESSAGE_START  = "START: main.rb"
MESSAGE_END    = "END: main.rb"
MESSAGE_ERROR1 = "System Error Occurred!"
MESSAGE_ERROR2 = "Please See the Operation Manual."

#### Debug ####
stdout.info(MESSAGE_START)

#### Initialize ####
strResultCode = conf.init
## on Error --> exit(1)
if strResultCode != ResultCode::NORMAL
  stdout.error(MESSAGE_ERROR1 + " ERRORCODE = [" + strResultCode + "]")
  stdout.error(MESSAGE_ERROR2)
  stdout.info(MESSAGE_END)
  exit(1)
end


## ------------------------------------------------------------------ ##
## [step.1] Set Metadata Files to Register                            ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

#### Debug ####
stdout.info("######## START: Step.1, Set Metadata Files to Register ########")

#### Exec ####

## Call Class
fileController = FileController.new

## Set Metadata Files
strResultCode = fileController.exec
## on Error --> exit(1)
if strResultCode != ResultCode::NORMAL
  ## Debug
  stdout.error(MESSAGE_ERROR1 + " ERRORCODE = [" + strResultCode + "]")
  stdout.error(MESSAGE_ERROR2)
  stdout.info(MESSAGE_END)
  ## Finalize
  strResultCode = conf.final
  ## Exit
  exit(1)
end

## Count
strResultCode = fileController.countMDNumber
intMDNumAddForced = fileController.getMDNumAddForced
intMDNumAandM     = fileController.getMDNumAandM
intMDNumDelete    = fileController.getMDNumDeleteF1

#### Debug ####
stdout.info("---- RESULT: The Number of Metadata to Register --------------")
stdout.info("ADD(Forced) --> [" + intMDNumAddForced.to_s + "]")
stdout.info("ADD/MODIFY  --> [" + intMDNumAandM.to_s     + "]")
stdout.info("DELETE      --> [" + intMDNumDelete.to_s    + "]")
stdout.info("--------------------------------------------------------------")

#### Debug ####
stdout.info("######## END: Step.1, Set Metadata Files to Register ########")

#### Break --> exit(0) ####
if intMDNumAddForced == 0 && intMDNumAandM == 0 && intMDNumDelete == 0
  ## Debug
  stdout.info("No Metadata to Register.")
  stdout.info(MESSAGE_END)
  ## Finalize
  strResultCode = conf.final
  ## Exit
  exit(8)
end


## ------------------------------------------------------------------ ##
## [step.2] Restore Community, Collection and Metadata to Admin-DB    ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

#### Debug ####
stdout.info("######## START: Step.2, Restore Community, Collection and ResourceID to Admin-DB ########")

#### Exec ####

## Call Class
adminDBController = AdminDBController.new

## Restore Community
strResultCode = adminDBController.exec(ExecCode::ADMINDB_RESTORE_COMMUNITY)
## on Error --> exit(1)
if strResultCode != ResultCode::NORMAL
  ## Debug
  stdout.error(MESSAGE_ERROR1 + " ERRORCODE = [" + strResultCode + "]")
  stdout.error(MESSAGE_ERROR2)
  stdout.info(MESSAGE_END)
  ## Finalize
  strResultCode = conf.final
  ## Exit
  exit(1)
end

## Restore Collection
strResultCode = adminDBController.exec(ExecCode::ADMINDB_RESTORE_COLLECTION)
## on Error --> exit(1)
if strResultCode != ResultCode::NORMAL
  ## Debug
  stdout.error(MESSAGE_ERROR1 + " ERRORCODE = [" + strResultCode + "]")
  stdout.error(MESSAGE_ERROR2)
  stdout.info(MESSAGE_END)
  ## Finalize
  strResultCode = conf.final
  ## Exit
  exit(1)
end

## Restore ResourceID
if intMDNumAandM > 0 || intMDNumDelete > 0
  strResultCode = adminDBController.exec(ExecCode::ADMINDB_RESTORE_METADATA)
  ## on Error --> exit(1)
  if strResultCode != ResultCode::NORMAL
    ## Debug
    stdout.error(MESSAGE_ERROR1 + " ERRORCODE = [" + strResultCode + "]")
    stdout.error(MESSAGE_ERROR2)
    stdout.info(MESSAGE_END)
    ## Finalize
    strResultCode = conf.final
    ## Exit
    exit(1)
  end
end

#### Debug ####
stdout.info("######## END: Step.2, Restore Community, Collection and ResourceID to Admin-DB ########")

## ------------------------------------------------------------------ ##
## [step.3] Create Regist Command                                     ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

#### Debug ####
stdout.info("######## START: Step.3, Create Regist Command ########")

#### Exec ####

## Call Controller
registController = RegistController.new

## Add (Forced)
if intMDNumAddForced > 0
  strResultCode = registController.exec(ExecCode::REGIST_ADD_FORCED)
  ## on Error --> exit(1)
  if strResultCode != ResultCode::NORMAL
    ## Debug
    stdout.error(MESSAGE_ERROR1 + " ERRORCODE = [" + strResultCode + "]")
    stdout.error(MESSAGE_ERROR2)
    stdout.info(MESSAGE_END)
    ## Finalize
    strResultCode = conf.final
    ## Exit
    exit(1)
  end
end

## Add and Modify
if intMDNumAandM > 0
  strResultCode = registController.exec(ExecCode::REGIST_ADD_AND_MODIFY)
  ## on Error --> exit(1)
  if strResultCode != ResultCode::NORMAL
    ## Debug
    stdout.error(MESSAGE_ERROR1 + " ERRORCODE = [" + strResultCode + "]")
    stdout.error(MESSAGE_ERROR2)
    stdout.info(MESSAGE_END)
    ## Finalize
    strResultCode = conf.final
    ## Exit
    exit(1)
  end
end

## Delete
if intMDNumDelete > 0
  strResultCode = registController.exec(ExecCode::REGIST_DELETE)
  ## on Error --> exit(1)
  if strResultCode != ResultCode::NORMAL
    ## Debug
    stdout.error(MESSAGE_ERROR1 + " ERRORCODE = [" + strResultCode + "]")
    stdout.error(MESSAGE_ERROR2)
    stdout.info(MESSAGE_END)
    ## Finalize
    strResultCode = conf.final
    ## Exit
    exit(1)
  end
end

## Count 
strResultCode = fileController.countMDNumber
intMDNumAdd    = fileController.getMDNumAdd
intMDNumModify = fileController.getMDNumModify
intMDNumDelete = fileController.getMDNumDeleteF2
intMDNumSkip   = fileController.getMDNumSkip

#### Debug ####
stdout.info("---- COMMIT: The Number of Metadata to Register --------------")
stdout.info("ADD    --> [" + intMDNumAdd.to_s    + "]")
stdout.info("MODIFY --> [" + intMDNumModify.to_s + "]")
stdout.info("DELETE --> [" + intMDNumDelete.to_s + "]")
stdout.info("SKIP   --> [" + intMDNumSkip.to_s   + "]")
if intMDNumSkip > 0
  stdout.warn("!!!!!!!! See \"skip.out\" !!!!!!!!")
end
stdout.info("--------------------------------------------------------------")

#### Debug ####
stdout.info("######## END: Step.3, Create Regist Command ########")


## ------------------------------------------------------------------ ##
## [step.4] Finalize                                                  ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

#### Finalize ####
strResultCode = conf.final

#### Debug ####
stdout.info(MESSAGE_END)
