# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [RegistHistory.rb]                                                 ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './conf/ResultCode'
require './conf/DisplayLabel'
require './lib/Log'
require './lib/LogStdOut'
require './lib/Date'
require './api/RegistStatus'

class RegistHistoryController


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##
  #### ExecCode (Private Key)
  ## Search
  GET_ALL        = "5002101"  ## Get All Records (Contains Deleted Records)
  GET_NOTDELETED = "5002102"  ## Expect Deleted Records
  GET_RECENTONE  = "5002103"  ## Get Most Recent One
  GET_FROM_REPOSITORYCODE = "5002104"  ## Search From Repository Code
  ## Regist
  ## Delete
  DELETE         = "5002301"  ## Delete the Regist History (DelFlag --> 9)
  ENABLE         = "5002302"  ## Enable the Regist History (DelFlag --> 0)


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
    ## Variables (For API Function)
    @strRegistID       = ""
    @strRepositoryCode = ""
    @strOffset         = "0"   ## Default Value
    @strLimit          = "10"  ## Default Value
    ## Variables (For API Integration)
    @intHitsCount          = 0
    @aryRegistID           = Array.new
    @aryRepositoryCode     = Array.new
    @aryRepositoryNickName = Array.new
    @aryStartDate          = Array.new
    @aryStartTime          = Array.new
    @aryEndDate            = Array.new
    @aryEndTime            = Array.new
    @aryRegistStatusCode   = Array.new
    @aryDelFlag            = Array.new
    @aryRcdNewDate         = Array.new
    @aryRcdNewTime         = Array.new
    @aryRcdMdfDate         = Array.new
    @aryRcdMdfTime         = Array.new
    @aryRepositoryRF       = Array.new
    @aryStartDateTimeRF    = Array.new
    @aryEndDateTimeRF      = Array.new
    @aryRcdNewDateTimeRF   = Array.new
    @aryRcdMdfDateTimeRF   = Array.new
  end


  ## ---------------------------------------------------------------- ##
  ## [method] clear                                                   ##
  ## ---------------------------------------------------------------- ##
  def clear
    #### Exec ####
    ## Variables (For API Integration)
    @intHitsCount = 0
    @aryRegistID.clear
    @aryRepositoryCode.clear
    @aryRepositoryNickName.clear
    @aryStartDate.clear
    @aryStartTime.clear
    @aryEndDate.clear
    @aryEndTime.clear
    @aryRegistStatusCode.clear
    @aryDelFlag.clear
    @aryRcdNewDate.clear
    @aryRcdNewTime.clear
    @aryRcdMdfDate.clear
    @aryRcdMdfTime.clear
    @aryRepositoryRF.clear
    @aryStartDateTimeRF.clear
    @aryEndDateTimeRF.clear
    @aryRcdNewDateTimeRF.clear
    @aryRcdMdfDateTimeRF.clear
  end


  ## ---------------------------------------------------------------- ##
  ## [method] final                                                   ##
  ## ---------------------------------------------------------------- ##
  def final
  end


  ## ---------------------------------------------------------------- ##
  ## [method] exec                                                    ##
  ## ---------------------------------------------------------------- ##
  def exec(strExecCode)

    #### Debug ####
    @log.info("START: RegistHistoryController.rb#exec --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Search: GET_ALL
    if strExecCode == GET_ALL
      strResultCode = search(strExecCode)
      strResultCode = disp(strExecCode)
    ## Search: GET_NOTDELETED
    elsif strExecCode == GET_NOTDELETED
      strResultCode = search(strExecCode)
      strResultCode = disp(strExecCode)
    ## Search: GET_RECENTONE
    elsif strExecCode == GET_RECENTONE
      strResultCode = search(strExecCode)
      strResultCode = disp(strExecCode)
    ## Search: GET_FROM_REPOSITORYCODE
    elsif strExecCode == GET_FROM_REPOSITORYCODE
      strResultCode = search(strExecCode)
      strResultCode = disp(strExecCode)
    ## Delete: DELETE (DEL_FLAG --> 9)
    elsif strExecCode == DELETE
      strResultCode = regist(strExecCode)
      strResultCode = search(strExecCode)
      strResultCode = disp(strExecCode)
    ## Delete: ENABLE (DEL_FLAG --> 0)
    elsif strExecCode == ENABLE
      strResultCode = regist(strExecCode)
      strResultCode = search(strExecCode)
      strResultCode = disp(strExecCode)
    ## Error
    else
      @stdout.error("RegistHistoryController.rb#exec: Undefined ExecCode was Given.")
      strResultCode = ResultCode::EXECCODE_ERROR
    end

    #### Clear ####
    clear

    #### Debug ####
    @log.info("END: RegistHistoryController.rb#exec --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] search                                                  ##
  ## ---------------------------------------------------------------- ##
  def search(strExecCode)

    #### Debug ####
    @log.debug("START: RegistHistoryController.rb#search")

    #### Define ####
    ## Classes
    registStatus = RegistStatus.new
    ## Variables
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Exec API
    ## Case: GET_ALL
    if strExecCode == GET_ALL
      registStatus.setOffset(@strOffset)
      registStatus.setLimit(@strLimit)
      strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_GET_ALL)
    ## Case: GET_NOTDELETED
    elsif strExecCode == GET_NOTDELETED
      registStatus.setOffset(@strOffset)
      registStatus.setLimit(@strLimit)
      strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_GET_NOTDELETED)
    ## Case: GET_RECENTONE
    elsif strExecCode == GET_RECENTONE
      registStatus.setOffset(@strOffset)
      registStatus.setLimit(@strLimit)
      repository.setRepositoryCode(@strRepositoryCode)
      strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_GET_RECENTONE)
    ## Case: GET_FROM_REPOSITORYCODE
    elsif strExecCode == GET_FROM_REPOSITORYCODE
      registStatus.setOffset(@strOffset)
      registStatus.setLimit(@strLimit)
      registStatus.setRepositoryCode(@strRepositoryCode)
      strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_GET_FROM_REPOSITORYCODE)
    ## Case: DELETE
    elsif strExecCode == DELETE
      registStatus.setRegistID(@strRegistID)
      strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_GET_FROM_REGISTID)
    ## Case: ENABLE
    elsif strExecCode == ENABLE
      registStatus.setRegistID(@strRegistID)
      strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_GET_FROM_REGISTID)
    end

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      return strResultCode
    end

    ## Get Result
    @intHitsCount          = registStatus.getHitsCount
    @aryRegistID           = registStatus.getRegistID
    @aryRepositoryCode     = registStatus.getRepositoryCode
    @aryRepositoryNickName = registStatus.getRepositoryNickName
    @aryStartDate          = registStatus.getStartDate
    @aryStartTime          = registStatus.getStartTime
    @aryEndDate            = registStatus.getEndDate
    @aryEndTime            = registStatus.getEndTime
    @aryRegistStatusCode   = registStatus.getRegistStatusCode
    @aryDelFlag            = registStatus.getDelFlag
    @aryRcdNewDate         = registStatus.getRcdNewDate
    @aryRcdNewTime         = registStatus.getRcdNewTime
    @aryRcdMdfDate         = registStatus.getRcdMdfDate
    @aryRcdMdfTime         = registStatus.getRcdMdfTime

    #### Debug ####
    @log.debug("END: RegistHistoryController.rb#search")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] regist                                                  ##
  ## ---------------------------------------------------------------- ##
  def regist(strExecCode)

    #### Debug ####
    @log.debug("START: RegistHistoryController.rb#regist")

    #### Define ####
    ## Classes
    registStatus = RegistStatus.new
    date       = Date.new
    ## Variables
    strResultCode = ResultCode::NORMAL

    #### Check ####
    ## Delete: DELETE (DEL_FLAG --> 9)
    if strExecCode == DELETE
      ## strRegistID
      if @strRegistID == nil
        return ResultCode::PARAMETER_ERROR
      elsif @strRegistID.strip == ""
        return ResultCode::PARAMETER_ERROR
      elsif not @strRegistID.strip =~ /^[0-9]+$/
        return ResultCode::PARAMETER_ERROR
      end
    ## Delete: ENABLE (DEL_FLAG --> 0)
    elsif strExecCode == ENABLE
      ## strRegistID
      if @strRegistID == nil
        return ResultCode::PARAMETER_ERROR
      elsif @strRegistID.strip == ""
        return ResultCode::PARAMETER_ERROR
      elsif not @strRegistID.strip =~ /^[0-9]+$/
        return ResultCode::PARAMETER_ERROR
      end
    end

    #### Exec ####
    ## Delete: DELETE (DEL_FLAG --> 9)
    if strExecCode == DELETE
      registStatus.setRegistID(@strRegistID)
      strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_DELETE)
    ## Delete: ENABLE (DEL_FLAG --> 0)
    elsif strExecCode == ENABLE
      registStatus.setRegistID(@strRegistID)
      strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_ENABLE)
    end

    #### Debug ####
    @log.debug("END: RegistHistoryController.rb#regist")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] disp                                                    ##
  ## ---------------------------------------------------------------- ##
  def disp(strExecCode)

    #### Debug ####
    @log.debug("START: RegistHistoryController.rb#disp")

    #### Define ####
    ## Classes
    date = Date.new
    ## Variables
    intMaxLenRegistID           = 0
    intMaxLenRepositoryCode     = 0 
    intMaxLenRepositoryNickName = 0 
    intMaxLenRepository         = 0 
    intMaxLenStartDateTime      = 0
    intMaxLenEndDateTime        = 0
    intMaxLenStartEndDateTime   = 0
    intMaxLenRegistStatusCode   = 0
    intMaxLenDelFlag            = 0
    intMaxLenRcdNewDateTime     = 0
    intMaxLenRcdMdfDateTime     = 0
    intMaxLenRcdDateTime        = 0
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Get Max Length of Charactor on Array
    ## RegistID
    for i in 0..@intHitsCount-1
      if intMaxLenRegistID < @aryRegistID[i].to_s.length
        intMaxLenRegistID = @aryRegistID[i].to_s.length
      end
    end
    if intMaxLenRegistID < DisplayLabel::LABEL_REGHITORY_REGISTID.length
      intMaxLenRegistID = DisplayLabel::LABEL_REGHITORY_REGISTID.length
    end
    ## RepositoryCode
    for i in 0..@intHitsCount-1
      if intMaxLenRepositoryCode < @aryRepositoryCode[i].to_s.length
        intMaxLenRepositoryCode = @aryRepositoryCode[i].to_s.length
      end
    end
    ## RepositoryNickName
    for i in 0..@intHitsCount-1
      if intMaxLenRepositoryNickName < @aryRepositoryNickName[i].to_s.length
        intMaxLenRepositoryNickName = @aryRepositoryNickName[i].to_s.length
      end
    end
    ## RepositoryCode, RepositoryNickName
    intMaxLenRepository = intMaxLenRepositoryCode + 2 + intMaxLenRepositoryNickName
    if intMaxLenRepository < DisplayLabel::LABEL_REGHITORY_REPOSITORY.length
      intMaxLenRepository = DisplayLabel::LABEL_REGHITORY_REPOSITORY.length
    end
    ## StartDateTimeRF, EndDateTimeRF
    for i in 0..@intHitsCount-1
      @aryStartDateTimeRF[i] = date.conv(@aryStartDate[i].to_s + @aryStartTime[i].to_s, "%Y/%m/%d %H:%M:%S")
      if intMaxLenStartDateTime < @aryStartDateTimeRF[i].to_s.length
        intMaxLenStartDateTime = @aryStartDateTimeRF[i].to_s.length
      end
    end
    if intMaxLenStartDateTime < DisplayLabel::LABEL_REGHITORY_STARTDATETIME.length
      intMaxLenStartDateTime = DisplayLabel::LABEL_REGHITORY_STARTDATETIME.length
    end
    for i in 0..@intHitsCount-1
      @aryEndDateTimeRF[i] = date.conv(@aryEndDate[i].to_s + @aryEndTime[i].to_s, "%Y/%m/%d %H:%M:%S")
      if intMaxLenEndDateTime < @aryEndDateTimeRF[i].to_s.length
        intMaxLenEndDateTime = @aryEndDateTimeRF[i].to_s.length
      end
    end
    if intMaxLenEndDateTime < DisplayLabel::LABEL_REGHITORY_ENDDATETIME.length
      intMaxLenEndDateTime = DisplayLabel::LABEL_REGHITORY_ENDDATETIME.length
    end
    if intMaxLenStartDateTime > intMaxLenEndDateTime
      intMaxLenStartEndDateTime = intMaxLenStartDateTime
    elsif intMaxLenStartDateTime < intMaxLenEndDateTime
      intMaxLenStartEndDateTime = intMaxLenEndDateTime
    else
      intMaxLenStartEndDateTime = intMaxLenEndDateTime
    end
    ## RegistStatusCode
    for i in 0..@intHitsCount-1
      if intMaxLenRegistStatusCode < @aryRegistStatusCode[i].to_s.length
        intMaxLenRegistStatusCode = @aryRegistStatusCode[i].to_s.length
      end
    end
    if intMaxLenRegistStatusCode < DisplayLabel::LABEL_REGHITORY_STAUSCODE.length
      intMaxLenRegistStatusCode = DisplayLabel::LABEL_REGHITORY_STAUSCODE.length
    end
    ## DelFlag
    for i in 0..@intHitsCount-1
      if intMaxLenDelFlag < @aryDelFlag[i].to_s.length
        intMaxLenDelFlag = @aryDelFlag[i].to_s.length
      end
    end
    if intMaxLenDelFlag < DisplayLabel::LABEL_COMMON_DEL_FLAG.length
      intMaxLenDelFlag = DisplayLabel::LABEL_COMMON_DEL_FLAG.length
    end
    ## RcdNewDateTime, RcdMdfDateTime
    for i in 0..@intHitsCount-1
      @aryRcdNewDateTimeRF[i] = date.conv(@aryRcdNewDate[i].to_s + @aryRcdNewTime[i].to_s, "%Y/%m/%d %H:%M:%S")
      if intMaxLenRcdNewDateTime < @aryRcdNewDateTimeRF[i].to_s.length
        intMaxLenRcdNewDateTime = @aryRcdNewDateTimeRF[i].to_s.length
      end
    end
    if intMaxLenRcdNewDateTime < DisplayLabel::LABEL_COMMON_RCDNEWDATETIME.length
      intMaxLenRcdNewDateTime = DisplayLabel::LABEL_COMMON_RCDNEWDATETIME.length
    end
    for i in 0..@intHitsCount-1
      @aryRcdMdfDateTimeRF[i] = date.conv(@aryRcdMdfDate[i].to_s + @aryRcdMdfTime[i].to_s, "%Y/%m/%d %H:%M:%S")
      if intMaxLenRcdMdfDateTime < @aryRcdMdfDateTimeRF[i].to_s.length
        intMaxLenRcdMdfDateTime = @aryRcdMdfDateTimeRF[i].to_s.length
      end
    end
    if intMaxLenRcdMdfDateTime < DisplayLabel::LABEL_COMMON_RCDMDFDATETIME.length
      intMaxLenRcdMdfDateTime = DisplayLabel::LABEL_COMMON_RCDMDFDATETIME.length
    end
    if intMaxLenRcdNewDateTime > intMaxLenRcdMdfDateTime
      intMaxLenRcdDateTime = intMaxLenRcdNewDateTime
    elsif intMaxLenRcdNewDateTime < intMaxLenRcdMdfDateTime
      intMaxLenRcdDateTime = intMaxLenRcdMdfDateTime
    else
      intMaxLenRcdDateTime = intMaxLenRcdMdfDateTime
    end


    #### Standard Out ####
    ## Blank
#   puts

    ## Header
    printf "| %*s ", intMaxLenRegistID,           DisplayLabel::LABEL_REGHITORY_REGISTID.center(intMaxLenRegistID, " ")
    printf "| %*s ", intMaxLenRepository,         DisplayLabel::LABEL_REGHITORY_REPOSITORY.center(intMaxLenRepository, " ")
    printf "| %*s ", intMaxLenStartEndDateTime,   DisplayLabel::LABEL_REGHITORY_STARTDATETIME.center(intMaxLenStartEndDateTime, " ")
    printf "| %*s ", intMaxLenStartEndDateTime,   DisplayLabel::LABEL_REGHITORY_ENDDATETIME.center(intMaxLenStartEndDateTime, " ")
    printf "| %*s ", intMaxLenRegistStatusCode,   DisplayLabel::LABEL_REGHITORY_STAUSCODE.center(intMaxLenRegistStatusCode, " ")
    if strExecCode == GET_ALL
      printf "| %*s ", intMaxLenDelFlag,            DisplayLabel::LABEL_COMMON_DEL_FLAG.center(intMaxLenDelFlag, " ")
    end
    printf "| %*s ", intMaxLenRcdDateTime,        DisplayLabel::LABEL_COMMON_RCDNEWDATETIME.center(intMaxLenRcdDateTime, " ")
    printf "| %*s ", intMaxLenRcdDateTime,        DisplayLabel::LABEL_COMMON_RCDMDFDATETIME.center(intMaxLenRcdDateTime, " ")
    puts   "|"

    ## Line
    printf "+-%*s-", intMaxLenRegistID,           "-".ljust(intMaxLenRegistID,           "-")
    printf "+-%*s-", intMaxLenRepository,         "-".ljust(intMaxLenRepository,         "-")
    printf "+-%*s-", intMaxLenStartEndDateTime,   "-".ljust(intMaxLenStartEndDateTime,   "-")
    printf "+-%*s-", intMaxLenStartEndDateTime,   "-".ljust(intMaxLenStartEndDateTime,   "-")
    printf "+-%*s-", intMaxLenRegistStatusCode,   "-".ljust(intMaxLenRegistStatusCode,   "-")
    if strExecCode == GET_ALL
      printf "+-%*s-", intMaxLenDelFlag,            "-".ljust(intMaxLenDelFlag,            "-")
    end
    printf "+-%*s-", intMaxLenRcdDateTime,        "-".ljust(intMaxLenRcdDateTime,     "-")
    printf "+-%*s-", intMaxLenRcdDateTime,        "-".ljust(intMaxLenRcdDateTime,     "-")
    puts   "+"

    ## Value
    for i in 0..@intHitsCount - 1
      printf "| %*s ",  intMaxLenRegistID,         @aryRegistID[i].strip
      printf "| %*s: %-*s ", intMaxLenRepositoryCode, @aryRepositoryCode[i].strip,
        intMaxLenRepository - intMaxLenRepositoryCode - 2, @aryRepositoryNickName[i].strip
      printf "| %-*s ", intMaxLenStartEndDateTime, @aryStartDateTimeRF[i].strip
      printf "| %-*s ", intMaxLenStartEndDateTime, @aryEndDateTimeRF[i].strip
      printf "| %-*s ", intMaxLenRegistStatusCode,   @aryRegistStatusCode[i].strip
      if strExecCode == GET_ALL
        printf "| %-*s ", intMaxLenDelFlag,            @aryDelFlag[i].strip
      end
      printf "| %-*s ", intMaxLenRcdDateTime,        @aryRcdNewDateTimeRF[i].strip
      printf "| %-*s ", intMaxLenRcdDateTime,        @aryRcdMdfDateTimeRF[i].strip
      puts   "|"
    end

    ## Blank
    puts

    #### Debug ####
    @log.debug("END: RegHistory.rb#disp")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [API-method] setRegistID                                         ##
  ## ---------------------------------------------------------------- ##
  def setRegistID(strRegistID)
    @strRegistID = strRegistID
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setRepositoryCode                                   ##
  ## ---------------------------------------------------------------- ##
  def setRepositoryCode(strRepositoryCode)
    @strRepositoryCode = strRepositoryCode
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setOffset                                           ##
  ## ---------------------------------------------------------------- ##
  def setOffset(strOffset)
    @strOffset = strOffset
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setLimit                                            ##
  ## ---------------------------------------------------------------- ##
  def setLimit(strLimit)
    @strLimit = strLimit
  end


end
