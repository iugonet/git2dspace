# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [Repository.rb]                                                    ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './conf/ResultCode'
require './lib/DBAccess'
require './lib/Log'
require './lib/LogStdOut'
require './lib/CharUtil'

class Repository


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##

  #### ExecCode (Private Key)
  ## Search
  GET_ALL        = '2001101'  ## Get All Records (Contains Deleted Records)
  GET_NOTDELETED = '2001102'  ## Expect Deleted Records
  GET_ACTIVE     = '2001103'  ## Only the Records Given Active Code
  GET_SUSPEND    = '2001104'  ## Only the Records Given Suspend Code
  GET_AANDS      = '2001105'  ## Only the Records Given Active or Suspend Code
  GET_FROM_REPOSITORYCODE = '2001106'  ## Search From the Repository Code
  ## Regist
  REGIST_INTO_ACTIVE = '2001201'  ## Change the Repository Activity
  REGIST_INTO_PAUSE  = '2001202'  ## Change the Repository into Pause
  REGIST_INTO_STOP   = '2001203'  ## Change the Repository into Stop
  ## Delete
  DELETE         = '2001301'  ## Delete thr Repository


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
    @log      = Log.new
    @stdout   = LogStdOut.new
    @charutil = CharUtil.new

    ## Variables (For SQL Results)
    @intHitsCount              = 0
    @aryRepositoryCode         = Array.new
    @aryRepositoryNickName     = Array.new
    @aryRepositoryActivityCode = Array.new
    @aryRepositoryActivityName = Array.new
    @aryRemoteHost             = Array.new
    @aryRemotePath             = Array.new
    @aryLoginAccount           = Array.new
    @aryLoginPassword          = Array.new
    @aryProtocolCode           = Array.new
    @aryLocalDirectory         = Array.new
    @aryLocalDirectory2        = Array.new
    @aryDelFlag    = Array.new
    @aryRcdNewDate = Array.new
    @aryRcdNewTime = Array.new
    @aryRcdMdfDate = Array.new
    @aryRcdMdfTime = Array.new

  end


  ## ---------------------------------------------------------------- ##
  ## [method] clear                                                   ##
  ## ---------------------------------------------------------------- ##
  def clear

    #### Exec ####
    ## Variables (For SQL Results)
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

  end


  ## ---------------------------------------------------------------- ##
  ## [method] exec                                                    ##
  ## ---------------------------------------------------------------- ##
  def exec(strExecCode)

    #### Debug ####
    @log.debug("START Repository.rb#exec ----------------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Search: GET_ACTIVE
    if strExecCode == GET_ALL
      strResultCode = search(strExecCode)
    ## Search: GET_NOTDELETED
    elsif strExecCode == GET_NOTDELETED
      strResultCode = search(strExecCode)
    ## Search: GET_ACTIVE
    elsif strExecCode == GET_ACTIVE
      strResultCode = search(strExecCode)
    ## Search: GET_SUSPEND
    elsif strExecCode == GET_SUSPEND
      strResultCode = search(strExecCode)
    ## Search: GET_AANDS (Active and Suspend)
    elsif strExecCode == GET_AANDS
      strResultCode = search(strExecCode)
    ## Search: GET_FROM_REPOSITORYCODE
    elsif strExecCode == GET_FROM_REPOSITORYCODE
      strResultCode = search(strExecCode)
    ## Regist: REGIST_INTO_ACTIVE
    elsif strExecCode == REGIST_INTO_ACTIVE
      strResultCode = regist(strExecCode)
    ## Regist: Change the Repository into Pause
    elsif strExecCode == REGIST_INTO_PAUSE
      strResultCode = regist(strExecCode)
    ## Regist: Change the Repository into Stop
    elsif strExecCode == REGIST_INTO_STOP
      strResultCode = regist(strExecCode)
    ## Undefined Code (Error)
    else
      @log.error("Repository.rb#exec: Undefined ExecCode was Given.")
      strResultCode = ResultCode::EXECCODE_ERROR
    end

    #### Debug ####
    @log.debug("END Repository.rb#exec ----------------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] search                                                  ##
  ## ---------------------------------------------------------------- ##
  def search(strExecCode)

    #### Debug ####
    @log.debug("START: Repository.rb#search")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Check ####
    ## Search: GET_FROM_REPOSITORYCODE
    if strExecCode == GET_FROM_REPOSITORYCODE
      ## @strRepositoryCode
      if @strRepositoryCode == nil
        @log.error("Repository.rb#search: Parameter Error. strRepositoryCode is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strRepositoryCode.strip == ""
        @log.error("Repository.rb#search: Parameter Error. strRepositoryCode is BLANK.")
        return ResultCode::PARAMETER_ERROR
      elsif not @strRepositoryCode.strip =~ /^[0-9]+$/
        return ResultCode::PARAMETER_ERROR
      end
    end

    #### Exec ####
    ## Clear Array
    clear

    ## Create SQL
    strSQL = ''
    strSQL = strSQL + 'SELECT '
    strSQL = strSQL +   'R.REPOSITORY_CODE           AS REPOSITORY_CODE,          '
    strSQL = strSQL +   'R.REPOSITORY_NICKNAME       AS REPOSITORY_NICKNAME,      '
    strSQL = strSQL +   'R.REPOSITORY_ACTIVITY_CODE  AS REPOSITORY_ACTIVITY_CODE, '
    strSQL = strSQL +   'RA.REPOSITORY_ACTIVITY_NAME AS REPOSITORY_ACTIVITY_NAME, '
    strSQL = strSQL +   'R.REMOTE_HOST               AS REMOTE_HOST,              '
    strSQL = strSQL +   'R.REMOTE_PATH               AS REMOTE_PATH,              '
    strSQL = strSQL +   'R.LOGIN_ACCOUNT             AS LOGIN_ACCOUNT,            '
    strSQL = strSQL +   'R.LOGIN_PASSWORD            AS LOGIN_PASSWORD,           '
    strSQL = strSQL +   'R.PROTOCOL_CODE             AS PROTOCOL_CODE,            '
    strSQL = strSQL +   'R.LOCAL_DIRECTORY           AS LOCAL_DIRECTORY,          '
    strSQL = strSQL +   'R.DEL_FLAG   AS DEL_FLAG,   '
    strSQL = strSQL +   'R.RCDNEWDATE AS RCDNEWDATE, '
    strSQL = strSQL +   'R.RCDNEWTIME AS RCDNEWTIME, '
    strSQL = strSQL +   'R.RCDMDFDATE AS RCDMDFDATE, '
    strSQL = strSQL +   'R.RCDMDFTIME AS RCDMDFTIME  '
    strSQL = strSQL + 'FROM '
    strSQL = strSQL +   'TBL_M_REPOSITORY AS R '
    strSQL = strSQL + 'LEFT OUTER JOIN '
    strSQL = strSQL +   'TBL_M_REPOSITORY_ACTIVITYNAME AS RA '
    strSQL = strSQL + 'ON '
    strSQL = strSQL +   'R.REPOSITORY_ACTIVITY_CODE = RA.REPOSITORY_ACTIVITY_CODE '
    ## WHERE
    if strExecCode == GET_ALL
      ## Add Nothing
    elsif strExecCode == GET_NOTDELETED
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'R.DEL_FLAG = \'0\' '
    elsif strExecCode == GET_ACTIVE
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'R.REPOSITORY_ACTIVITY_CODE = \'1\' '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'R.DEL_FLAG = \'0\' '
    elsif strExecCode == GET_SUSPEND
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'R.REPOSITORY_ACTIVITY_CODE = \'8\' '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'R.DEL_FLAG = \'0\' '
    elsif strExecCode == GET_AANDS
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'R.REPOSITORY_ACTIVITY_CODE IN (\'1\', \'8\') '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'R.DEL_FLAG = \'0\' '
    elsif strExecCode == GET_FROM_REPOSITORYCODE
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'R.REPOSITORY_CODE = \'' + @charutil.sqlEncode(@strRepositoryCode) + '\' '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'R.DEL_FLAG = \'0\' '
    end
    ## ORDER BY
    strSQL = strSQL + 'ORDER BY '
    strSQL = strSQL +   'TO_NUMBER(R.REPOSITORY_CODE, \'0000\') ASC'

    ## Debug
    @log.info("Repository.rb#search: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    strResultCode, result = $db.exQueryDB2(strSQL)

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("Repository.rb#search: Error Occurred in the SQL Transaction. strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end
    if result == nil
      @stdout.error("Repository.rb#search: Error Occurred in the SQL Transaction. strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end

    ## Analyze Result
    result.each do |res|
      ## Set Result
      @aryRepositoryCode         << res['repository_code'].to_s.strip
      @aryRepositoryNickName     << res['repository_nickname'].to_s.strip
      @aryRepositoryActivityCode << res['repository_activity_code'].to_s.strip
      @aryRepositoryActivityName << res['repository_activity_name'].to_s.strip
      @aryRemoteHost             << res['remote_host'].to_s.strip
      @aryRemotePath             << res['remote_path'].to_s.strip
      @aryLoginAccount           << res['login_account'].to_s.strip
      @aryLoginPassword          << res['login_password'].to_s.strip
      @aryProtocolCode           << res['protocol_code'].to_s.strip
      @aryLocalDirectory         << res['local_directory'].to_s.strip
      @aryDelFlag    << res['del_flag'].to_s.strip
      @aryRcdNewDate << res['rcdnewdate'].to_s.strip
      @aryRcdNewTime << res['rcdnewtime'].to_s.strip
      @aryRcdMdfDate << res['rcdmdfdate'].to_s.strip
      @aryRcdMdfTime << res['rcdmdftime'].to_s.strip
    end

    ## Set Hits Count
    @intHitsCount = @aryRepositoryCode.size
    if @intHitsCount == 0
      @stdout.info("Repository.rb#search: No Repository to Register.")
      return ResultCode::REPOSITORY_NOTFOUND
    end

    ## Option: Create LocalDirectory2 (For Git)
    for i in 0..@intHitsCount-1
      @aryLocalDirectory2 << File.join(@aryLocalDirectory[i], File.basename(@aryRemotePath[i]).gsub(/.git/, ""))
    end

    ## Clear Result
    result.clear

    #### Debug ####
    @log.debug("END: Repository.rb#search")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] regist                                                  ##
  ## ---------------------------------------------------------------- ##
  def regist(strExecCode)

    #### Debug ####
    @log.debug("START: Repository.rb#regist")

    #### Define ####
    strResultCode = ResultCode::NORMAL
    strSQL = ""

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
    ## Create SQL
    strSQL = ""
    strSQL = strSQL + "UPDATE "
    strSQL = strSQL +   "TBL_M_REPOSITORY "
    strSQL = strSQL + "SET "
    ## Search: REGIST_INTO_ACTIVE
    if strExecCode == REGIST_INTO_ACTIVE
      strSQL = strSQL + "REPOSITORY_ACTIVITY_CODE = '" + @charutil.sqlEncode(Configure::ACTIVITYCODE_ACTIVE) + "', "
    ## Search: REGIST_INTO_PAUSE
    elsif strExecCode == REGIST_INTO_PAUSE
      strSQL = strSQL + "REPOSITORY_ACTIVITY_CODE = '" + @charutil.sqlEncode(Configure::ACTIVITYCODE_PAUSE)  + "', "
    ## Search: REGIST_INTO_STOP
    elsif strExecCode == REGIST_INTO_STOP
      strSQL = strSQL + "REPOSITORY_ACTIVITY_CODE = '" + @charutil.sqlEncode(Configure::ACTIVITYCODE_STOP)   + "', "
    end
    strSQL = strSQL +   "RCDMDFDATE = TO_CHAR(NOW(), 'YYYYMMDD'), "
    strSQL = strSQL +   "RCDMDFTIME = TO_CHAR(NOW(), 'HH24MISS')  "
    strSQL = strSQL + "WHERE "
    strSQL = strSQL +   "REPOSITORY_CODE = '" + @charutil.sqlEncode(@strRepositoryCode) + "' "

    ## Debug
    @log.debug("Repository.rb#regist: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    strResultCode, result = $db.exUpdateDB2(strSQL)

    ## Clear Result
    if result != nil
      result.clear
    end

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("Repository.rb#regist: SQL Error on Registing Collections to the Admin-DB! strSQL = [" + strSQL.to_s + "]")
    end

    #### Debug ####
    @log.debug("END: Repository.rb#regist")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [API-method] setRepositoryCode                                   ##
  ## ---------------------------------------------------------------- ##
  def setRepositoryCode(strRepositoryCode)
    @strRepositoryCode = strRepositoryCode
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getHitsCount                                        ##
  ## ---------------------------------------------------------------- ##
  def getHitsCount
    return @intHitsCount
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getRepositoryCode                                   ##
  ## ---------------------------------------------------------------- ##
  def getRepositoryCode
    return @aryRepositoryCode
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getRepositoryNickName                               ##
  ## ---------------------------------------------------------------- ##
  def getRepositoryNickName
    return @aryRepositoryNickName
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getRepositoryActivityCode                           ##
  ## ---------------------------------------------------------------- ##
  def getRepositoryActivityCode
    return @aryRepositoryActivityCode
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getRepositoryActivityName                           ##
  ## ---------------------------------------------------------------- ##
  def getRepositoryActivityName
    return @aryRepositoryActivityName
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getRemoteHost                                       ##
  ## ---------------------------------------------------------------- ##
  def getRemoteHost
    return @aryRemoteHost
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getRemotePath                                       ##
  ## ---------------------------------------------------------------- ##
  def getRemotePath
    return @aryRemotePath
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getLoginAccount                                     ##
  ## ---------------------------------------------------------------- ##
  def getLoginAccount
    return @aryLoginAccount
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getLoginPassword                                    ##
  ## ---------------------------------------------------------------- ##
  def getLoginPassword
    return @aryLoginPassword
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getProtocolCode                                     ##
  ## ---------------------------------------------------------------- ##
  def getProtocolCode
    return @aryProtocolCode
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getLocalDirectory                                   ##
  ## ---------------------------------------------------------------- ##
  def getLocalDirectory
    return @aryLocalDirectory
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getLocalDirectory2                                  ##
  ## ---------------------------------------------------------------- ##
  def getLocalDirectory2
    return @aryLocalDirectory2
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getDelFlag                                          ##
  ## ---------------------------------------------------------------- ##
  def getDelFlag
    return @aryDelFlag
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getRcdNewDate                                       ##
  ## ---------------------------------------------------------------- ##
  def getRcdNewDate
    return @aryRcdNewDate
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getRcdNewTime                                       ##
  ## ---------------------------------------------------------------- ##
  def getRcdNewTime
    return @aryRcdNewTime
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getRcdMdfDate                                       ##
  ## ---------------------------------------------------------------- ##
  def getRcdMdfDate
    return @aryRcdMdfDate
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getRcdMdfTime                                       ##
  ## ---------------------------------------------------------------- ##
  def getRcdMdfTime
    return @aryRcdMdfTime
  end

end
