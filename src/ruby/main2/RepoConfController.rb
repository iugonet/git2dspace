# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [RepoConfController.rb]                                            ##
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
require './api/Repository'

class RepoConfController


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##
  #### ExecCode (Private Key)
  ## Search
  GET_ALL            = '5001101'   ## Get All Records (Contains Deleted Records)
  GET_NOTDELETED     = '5001102'   ## Expect Deleted Records
  ## Regist
  REGIST_INTO_ACTIVE = '5001201'   ## Change the Repository Actively
  REGIST_INTO_PAUSE  = '5001202'   ## Change the Repository into Pause
  REGIST_INTO_STOP   = '5001203'   ## Change the Repository into Stop
  ## Delete
  DELETE             = '5001301'   ## Delete the Repository

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
    @strRepositoryCode = ""
    ## Variables (For API Integration)
    @intHitsCount        = 0
    @aryRepositoryCode         = Array.new
    @aryRepositoryNickName     = Array.new
    @aryRepositoryActivityCode = Array.new
    @aryRepositoryActivityName = Array.new
    @aryRemoteHost       = Array.new
    @aryRemotePath       = Array.new
    @aryLoginAccount     = Array.new
    @aryLoginPassword    = Array.new
    @aryProtocolCode     = Array.new
    @aryLocalDirectory   = Array.new
    @aryLocalDirectory2  = Array.new
    @aryDelFlag          = Array.new
    @aryRcdNewDate       = Array.new
    @aryRcdNewTime       = Array.new
    @aryRcdMdfDate       = Array.new
    @aryRcdMdfTime       = Array.new
    @aryRcdNewDateTimeRF = Array.new
    @aryRcdMdfDateTimeRF = Array.new
  end


  ## ---------------------------------------------------------------- ##
  ## [method] clear                                                   ##
  ## ---------------------------------------------------------------- ##
  def clear
    #### Exec ####
    ## Variables (For API Integration)
    @intHitsCount = 0
    @aryRepositoryCode.clear
    @aryRepositoryNickName.clear
    @aryRepositoryActivityCode.clear
    @aryRepositoryActivityName.clear
    @aryRemoteHost.clear
    @aryRemotePath.clear
    @aryLoginAccount.clear
    @aryLoginPassword.clear
    @aryProtocolCode.clear
    @aryLocalDirectory.clear
    @aryLocalDirectory2.clear
    @aryDelFlag.clear
    @aryRcdNewDate.clear
    @aryRcdNewTime.clear
    @aryRcdMdfDate.clear
    @aryRcdMdfTime.clear
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
    @log.info("START: RepoConfController.rb#exec --------")

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
    ## Regist: REGIST_INTO_ACTIVE
    elsif strExecCode == REGIST_INTO_ACTIVE
      strResultCode = regist(strExecCode)
      strResultCode = search(strExecCode)
      strResultCode = disp(strExecCode)
    ## Regist: REGIST_INTO_PAUSE
    elsif strExecCode == REGIST_INTO_PAUSE
      strResultCode = regist(strExecCode)
      strResultCode = search(strExecCode)
      strResultCode = disp(strExecCode)
    ## Regist: REGIST_INTO_STOP
    elsif strExecCode == REGIST_INTO_STOP
      strResultCode = regist(strExecCode)
      strResultCode = search(strExecCode)
      strResultCode = disp(strExecCode)
    ## Error
    else
      @stdout.error("RepoConfController.rb#exec: Undefined ExecCode was Given.")
      strResultCode = ResultCode::EXECCODE_ERROR
    end

    #### Clear ####
    clear

    #### Debug ####
    @log.info("END: RepoConfController.rb#exec --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] search                                                  ##
  ## ---------------------------------------------------------------- ##
  def search(strExecCode)

    #### Debug ####
    @log.debug("START: RepoConfController.rb#search")

    #### Define ####
    ## Classes
    repository = Repository.new
    ## Variables
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Exec API
    ## Case: GET_ALL
    if strExecCode == GET_ALL
      strResultCode = repository.exec(ExecCode::REPOSITORY_GET_ALL)
    ## Case: GET_NOTDELETED
    elsif strExecCode == GET_NOTDELETED
      strResultCode = repository.exec(ExecCode::REPOSITORY_GET_NOTDELETED)
    ## Case: REGIST_INTO_ACTIVE
    elsif strExecCode == REGIST_INTO_ACTIVE
      repository.setRepositoryCode(@strRepositoryCode)
      strResultCode = repository.exec(ExecCode::REPOSITORY_GET_FROM_REPOSITORYCODE)
    ## Case: REGIST_INTO_PAUSE
    elsif strExecCode == REGIST_INTO_PAUSE
      repository.setRepositoryCode(@strRepositoryCode)
      strResultCode = repository.exec(ExecCode::REPOSITORY_GET_FROM_REPOSITORYCODE)
    ## Case: REGIST_INTO_STOP
    elsif strExecCode == REGIST_INTO_STOP
      repository.setRepositoryCode(@strRepositoryCode)
      strResultCode = repository.exec(ExecCode::REPOSITORY_GET_FROM_REPOSITORYCODE)
    end

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      return strResultCode
    end

    ## Get Result
    @intHitsCount              = repository.getHitsCount
    @aryRepositoryCode         = repository.getRepositoryCode
    @aryRepositoryNickName     = repository.getRepositoryNickName
    @aryRepositoryActivityCode = repository.getRepositoryActivityCode
    @aryRepositoryActivityName = repository.getRepositoryActivityName
    @aryRemoteHost             = repository.getRemoteHost
    @aryRemotePath             = repository.getRemotePath
    @aryLoginAccount           = repository.getLoginAccount
    @aryLoginPassword          = repository.getLoginPassword
    @aryProtocolCode           = repository.getProtocolCode
    @aryLocalDirectory         = repository.getLocalDirectory
    @aryLocalDirectory2        = repository.getLocalDirectory2
    @aryDelFlag                = repository.getDelFlag
    @aryRcdNewDate             = repository.getRcdNewDate
    @aryRcdNewTime             = repository.getRcdNewTime
    @aryRcdMdfDate             = repository.getRcdMdfDate
    @aryRcdMdfTime             = repository.getRcdMdfTime

    #### Debug ####
    @log.debug("END: RepoConfController.rb#search")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] regist                                                  ##
  ## ---------------------------------------------------------------- ##
  def regist(strExecCode)

    #### Debug ####
    @log.debug("START: RepoConfController.rb#regist")

    #### Define ####
    ## Classes
    repository = Repository.new
    date       = Date.new
    ## Variables
    strResultCode = ResultCode::NORMAL

    #### Check ####
    ## Search: REGIST_INTO_ACTIVE
    if strExecCode == REGIST_INTO_ACTIVE
      ## strRepositoryCode
      if @strRepositoryCode == nil
        return ResultCode::PARAMETER_ERROR
      elsif @strRepositoryCode.strip == ""
        return ResultCode::PARAMETER_ERROR
      elsif not @strRepositoryCode.strip =~ /^[0-9]+$/
        return ResultCode::PARAMETER_ERROR
      end
    ## Search: REGIST_INTO_PAUSE
    elsif strExecCode == REGIST_INTO_PAUSE
      ## strRepositoryCode
      if @strRepositoryCode == nil
        return ResultCode::PARAMETER_ERROR
      elsif @strRepositoryCode.strip == ""
        return ResultCode::PARAMETER_ERROR
      elsif not @strRepositoryCode.strip =~ /^[0-9]+$/
        return ResultCode::PARAMETER_ERROR
      end
    ## Search: REGIST_INTO_STOP
    elsif strExecCode == REGIST_INTO_STOP
      ## strRepositoryCode
      if @strRepositoryCode == nil
        return ResultCode::PARAMETER_ERROR
      elsif @strRepositoryCode.strip == ""
        return ResultCode::PARAMETER_ERROR
      elsif not @strRepositoryCode.strip =~ /^[0-9]+$/
        return ResultCode::PARAMETER_ERROR
      end
    end

    #### Exec ####
    ## Regist: REGIST_INTO_ACTIVE
    if strExecCode == REGIST_INTO_ACTIVE
      repository.setRepositoryCode(@strRepositoryCode)
      strResultCode = repository.exec(ExecCode::REPOSITORY_REGIST_INTO_ACTIVE)
    ## Regist: REGIST_INTO_PAUSE
    elsif strExecCode == REGIST_INTO_PAUSE
      repository.setRepositoryCode(@strRepositoryCode)
      strResultCode = repository.exec(ExecCode::REPOSITORY_REGIST_INTO_PAUSE)
    ## Regist: REGIST_INTO_STOP
    elsif strExecCode == REGIST_INTO_STOP
      repository.setRepositoryCode(@strRepositoryCode)
      strResultCode = repository.exec(ExecCode::REPOSITORY_REGIST_INTO_STOP)
    end

    #### Debug ####
    @log.debug("END: RepoConfController.rb#regist")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] disp                                                    ##
  ## ---------------------------------------------------------------- ##
  def disp(strExecCode)

    #### Debug ####
    @log.debug("START: RepoConfController.rb#disp")

    #### Define ####
    ## Classes
    date = Date.new
    ## Variables
    intMaxLenRepositoryCode         = 0
    intMaxLenRepositoryNickName     = 0
    intMaxLenRepository             = 0
    intMaxLenRepositoryActivityCode = 0
    intMaxLenRepositoryActivityName = 0
    intMaxLenRepositoryActivity     = 0
    intMaxLenRemoteHost             = 0
    intMaxLenRemotePath             = 0
    intMaxLenLoginAccount           = 0
    intMaxLenLoginPassword          = 0
    intMaxLenProtocol               = 0
    intMaxLenLocalDirectory         = 0
    intMaxLenDelFlag                = 0
    intMaxLenRcdNewDateTime         = 0
    intMaxLenRcdMdfDateTime         = 0
    intMaxLenRcdDateTime            = 0
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Get Max Length of Charactor on Array
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
    if intMaxLenRepository < DisplayLabel::LABEL_REPOSITORY.length
      intMaxLenRepository = DisplayLabel::LABEL_REPOSITORY.length
    end
    ## ActivityCode
    for i in 0..@intHitsCount-1
      if intMaxLenRepositoryActivityCode < @aryRepositoryActivityCode[i].to_s.length
        intMaxLenRepositoryActivityCode = @aryRepositoryActivityCode[i].to_s.length
      end
    end
    ## ActivityName
    for i in 0..@intHitsCount-1
      if intMaxLenRepositoryActivityName < @aryRepositoryActivityName[i].to_s.length
        intMaxLenRepositoryActivityName = @aryRepositoryActivityName[i].to_s.length
      end
    end
    ## Activity
    intMaxLenRepositoryActivity = intMaxLenRepositoryActivityCode + 2 + intMaxLenRepositoryActivityName
    if intMaxLenRepositoryActivity < DisplayLabel::LABEL_REPOSITORY_ACTIVITY.length
      intMaxLenRepositoryActivity = DisplayLabel::LABEL_REPOSITORY_ACTIVITY.length
    end
    ## RemoteHost
    for i in 0..@intHitsCount-1
      if intMaxLenRemoteHost < @aryRemoteHost[i].to_s.length
        intMaxLenRemoteHost = @aryRemoteHost[i].to_s.length
      end
    end
    if intMaxLenRemoteHost < DisplayLabel::LABEL_REPOSITORY_REMOTE_HOST.length
      intMaxLenRemoteHost = DisplayLabel::LABEL_REPOSITORY_REMOTE_HOST.length
    end
    ## RemotePath
    for i in 0..@intHitsCount-1
      if intMaxLenRemotePath < @aryRemotePath[i].to_s.length
        intMaxLenRemotePath = @aryRemotePath[i].to_s.length
      end
    end
    if intMaxLenRemotePath < DisplayLabel::LABEL_REPOSITORY_REMOTE_PATH.length
      intMaxLenRemotePath = DisplayLabel::LABEL_REPOSITORY_REMOTE_PATH.length
    end
    ## LoginAccount
    for i in 0..@intHitsCount-1
      if intMaxLenLoginAccount < @aryLoginAccount[i].to_s.length
        intMaxLenLoginAccount = @aryLoginAccount[i].to_s.length
      end
    end
    if intMaxLenLoginAccount < DisplayLabel::LABEL_REPOSITORY_LOGIN_ACCOUNT.length
      intMaxLenLoginAccount = DisplayLabel::LABEL_REPOSITORY_LOGIN_ACCOUNT.length
    end
    ## LoginPassword
    for i in 0..@intHitsCount-1
      if intMaxLenLoginPassword < @aryLoginPassword[i].to_s.length
        intMaxLenLoginPassword = @aryLoginPassword[i].to_s.length
      end
    end
    if intMaxLenLoginPassword < DisplayLabel::LABEL_REPOSITORY_LOGIN_PASSWD.length
      intMaxLenLoginPassword = DisplayLabel::LABEL_REPOSITORY_LOGIN_PASSWD.length
    end
    ## Protocol
    for i in 0..@intHitsCount-1
      if intMaxLenProtocol < @aryProtocolCode[i].to_s.length
        intMaxLenProtocol = @aryProtocolCode[i].to_s.length
      end
    end
    if intMaxLenProtocol < DisplayLabel::LABEL_REPOSITORY_PROTOCOL.length
      intMaxLenProtocol = DisplayLabel::LABEL_REPOSITORY_PROTOCOL.length
    end
    ## LocalDirectory
    for i in 0..@intHitsCount-1
      if intMaxLenLocalDirectory < @aryLocalDirectory[i].to_s.length
        intMaxLenLocalDirectory = @aryLocalDirectory[i].to_s.length
      end
    end
    if intMaxLenLocalDirectory < DisplayLabel::LABEL_REPOSITORY_LOCAL_DIRECTORY.length
      intMaxLenLocalDirectory = DisplayLabel::LABEL_REPOSITORY_LOCAL_DIRECTORY.length
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
    printf "| %*s ", intMaxLenRepository,         DisplayLabel::LABEL_REPOSITORY.center(intMaxLenRepository, " ")
    printf "| %*s ", intMaxLenRepositoryActivity, DisplayLabel::LABEL_REPOSITORY_ACTIVITY.center(intMaxLenRepositoryActivity, " ")
    printf "| %*s ", intMaxLenRemoteHost,         DisplayLabel::LABEL_REPOSITORY_REMOTE_HOST.center(intMaxLenRemoteHost, " ")
    printf "| %*s ", intMaxLenRemotePath,         DisplayLabel::LABEL_REPOSITORY_REMOTE_PATH.center(intMaxLenRemotePath, " ")
    if strExecCode == GET_ALL
      printf "| %*s ", intMaxLenLoginAccount,       DisplayLabel::LABEL_REPOSITORY_LOGIN_ACCOUNT.center(intMaxLenLoginAccount, " ")
      printf "| %*s ", intMaxLenLoginPassword,      DisplayLabel::LABEL_REPOSITORY_LOGIN_PASSWD.center(intMaxLenLoginPassword, " ")
      printf "| %*s ", intMaxLenProtocol,           DisplayLabel::LABEL_REPOSITORY_PROTOCOL.center(intMaxLenProtocol, " ")
      printf "| %*s ", intMaxLenLocalDirectory,     DisplayLabel::LABEL_REPOSITORY_LOCAL_DIRECTORY.center(intMaxLenLocalDirectory, " ")
      printf "| %*s ", intMaxLenDelFlag,            DisplayLabel::LABEL_COMMON_DEL_FLAG.center(intMaxLenDelFlag, " ")
    end
    printf "| %*s ", intMaxLenRcdDateTime,        DisplayLabel::LABEL_COMMON_RCDNEWDATETIME.center(intMaxLenRcdDateTime, " ")
    printf "| %*s ", intMaxLenRcdDateTime,        DisplayLabel::LABEL_COMMON_RCDMDFDATETIME.center(intMaxLenRcdDateTime, " ")
    puts   "|"

    ## Line
    printf "+-%*s-", intMaxLenRepository,         "-".ljust(intMaxLenRepository,         "-")
    printf "+-%*s-", intMaxLenRepositoryActivity, "-".ljust(intMaxLenRepositoryActivity, "-")
    printf "+-%*s-", intMaxLenRemoteHost,         "-".ljust(intMaxLenRemoteHost,         "-")
    printf "+-%*s-", intMaxLenRemotePath,         "-".ljust(intMaxLenRemotePath,         "-")
    if strExecCode == GET_ALL
      printf "+-%*s-", intMaxLenLoginAccount,       "-".ljust(intMaxLenLoginAccount,       "-")
      printf "+-%*s-", intMaxLenLoginPassword,      "-".ljust(intMaxLenLoginPassword,      "-")
      printf "+-%*s-", intMaxLenProtocol,           "-".ljust(intMaxLenProtocol,           "-")
      printf "+-%*s-", intMaxLenLocalDirectory,     "-".ljust(intMaxLenLocalDirectory,     "-")
      printf "+-%*s-", intMaxLenDelFlag,            "-".ljust(intMaxLenDelFlag,            "-")
    end
    printf "+-%*s-", intMaxLenRcdDateTime,        "-".ljust(intMaxLenRcdDateTime,     "-")
    printf "+-%*s-", intMaxLenRcdDateTime,        "-".ljust(intMaxLenRcdDateTime,     "-")
    puts   "+"

    ## Value
    for i in 0..@intHitsCount - 1
      printf "| %*s: %-*s ", intMaxLenRepositoryCode, @aryRepositoryCode[i].strip,
        intMaxLenRepository - intMaxLenRepositoryCode - 2, @aryRepositoryNickName[i].strip
      printf "| %*s: %-*s ", intMaxLenRepositoryActivityCode, @aryRepositoryActivityCode[i].strip,
        intMaxLenRepositoryActivity - intMaxLenRepositoryActivityCode - 2, @aryRepositoryActivityName[i].strip
      printf "| %-*s ", intMaxLenRemoteHost,         @aryRemoteHost[i].strip
      printf "| %-*s ", intMaxLenRemotePath,         @aryRemotePath[i].strip
      if strExecCode == GET_ALL
        printf "| %-*s ", intMaxLenLoginAccount,       @aryLoginAccount[i].strip
        printf "| %-*s ", intMaxLenLoginPassword,      @aryLoginPassword[i].strip
        printf "| %-*s ", intMaxLenProtocol,           @aryProtocolCode[i].strip + ": "
        printf "| %-*s ", intMaxLenLocalDirectory,     @aryLocalDirectory[i].strip
        printf "| %-*s ", intMaxLenDelFlag,            @aryDelFlag[i].strip
      end
      printf "| %-*s ", intMaxLenRcdDateTime,        @aryRcdNewDateTimeRF[i].strip
      printf "| %-*s ", intMaxLenRcdDateTime,        @aryRcdMdfDateTimeRF[i].strip
      puts   "|"
    end

    ## Blank
    puts

    #### Debug ####
    @log.debug("END: RepoConfController.rb#disp")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [API-method] setRepositoryCode                                   ##
  ## ---------------------------------------------------------------- ##
  def setRepositoryCode(strRepositoryCode)
    @strRepositoryCode = strRepositoryCode
  end


end
