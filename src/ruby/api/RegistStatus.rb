# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [RegistStatus.rb]                                                  ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './conf/ResultCode'
require './lib/Log'
require './lib/LogStdOut'
require './lib/DBAccess'
require './lib/CharUtil'

class RegistStatus


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##

  #### ExecCode (Private Key)
  ## Search
  GET_ALL        = "2005101"  ## Get All Records (Contains Deleted Records)
  GET_NOTDELETED = "2005102"  ## Expect Deleted Records
  GET_RECENTONE  = "2005103"  ## Get Most Recent One
  GET_FROM_REPOSITORYCODE = "2005104"  ## Search From Repository Code
  GET_FROM_REGISTID       = "2005105"  ## Search From Regist ID
  ## Regist
  REGIST_S0      = "2005201"  ## REGIST_STATUS_CODE --> 0
  REGIST_S1      = "2005202"  ## REGIST_STATUS_CODE --> 1
  REGIST_S2      = "2005203"  ## REGIST_STATUS_CODE --> 2
  REGIST_S8      = "2005208"  ## REGIST_STATUS_CODE --> 8
  REGIST_S9      = "2005209"  ## REGIST_STATUS_CODE --> 9
  ## Delete
  DELETE         = "2005301"  ## DEL_FLAG --> 9
  ENABLE         = "2005302"  ## DEL_FLAG --> 9


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

    #### Classes
    @log      = Log.new
    @stdout   = LogStdOut.new
    @charutil = CharUtil.new

    #### Variables (For API Functions)
    @strRepositoryCode     = ""
    @strStartDate          = ""
    @strStartTime          = ""
    @strEndDate            = ""
    @strEndTime            = ""
    @strRegistStatusCode   = ""
    @strOffset             = "0"
    @strLimit              = "5"
    #### Variables (For SQL Results)
    @intHitsCount          = 0
    @aryRegistID           = Array.new
    @aryRepositoryCode     = Array.new
    @aryRepositoryNickName = Array.new
    @aryStartDate          = Array.new
    @aryStartTime          = Array.new
    @aryEndDate            = Array.new
    @aryEndTime            = Array.new
    @aryRegistStatusCode   = Array.new
    @aryDelFlag    = Array.new
    @aryRcdNewDate = Array.new
    @aryRcdNewTime = Array.new
    @aryRcdMdfDate = Array.new
    @aryRcdMdfTime = Array.new
    @strCurrRegistID = ""

  end


  ## ---------------------------------------------------------------- ##
  ## [method] clear                                                   ##
  ## ---------------------------------------------------------------- ##
  def clear

    #### Exec ####
    ## Variables (For SQL Results)
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

  end


  ## ---------------------------------------------------------------- ##
  ## [method] exec                                                    ##
  ## ---------------------------------------------------------------- ##
  def exec(strExecCode)

    #### Debug ####
    @log.debug("START RegistStatus.rb#exec ----------------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Search: GET_ALL
    if strExecCode == GET_ALL
      strResultCode = search(strExecCode)
    ## Search: GET_NOTDELETED
    elsif strExecCode == GET_NOTDELETED
      strResultCode = search(strExecCode)
    ## Search: GET_RECENTONE
    elsif strExecCode == GET_RECENTONE
      strResultCode = search(strExecCode)
    ## Search: GET_FROM_REPOSITORYCODE
    elsif strExecCode == GET_FROM_REPOSITORYCODE
      strResultCode = search(strExecCode)
    ## Search: GET_FROM_REGISTID
    elsif strExecCode == GET_FROM_REGISTID
      strResultCode = search(strExecCode)
    ## Regist: REGIST_S0
    elsif strExecCode == REGIST_S0
      strResultCode = regist(strExecCode)
    ## Regist: REGIST_S1
    elsif strExecCode == REGIST_S1
      strResultCode = regist(strExecCode)
    ## Regist: REGIST_S2
    elsif strExecCode == REGIST_S2
      strResultCode = regist(strExecCode)
    ## Regist: REGIST_S8
    elsif strExecCode == REGIST_S8
      strResultCode = regist(strExecCode)
    ## Regist: REGIST_S9
    elsif strExecCode == REGIST_S9
      strResultCode = regist(strExecCode)
    ## Delete: DELETE (DEL_FLAG --> 9)
    elsif strExecCode == DELETE
      strResultCode = regist(strExecCode)
    ## Delete: ENABLE (DEL_FLAG --> 0)
    elsif strExecCode == ENABLE
      strResultCode = regist(strExecCode)
    ## Error
    else
      @log.error("RegistStatus.rb#exec: Undefined ExecCode was Given.")
      strResultCode = ResultCode::EXECCODE_ERROR
    end

    #### Debug ####
    @log.debug("START RegistStatus.rb#exec ----------------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] search                                                  ##
  ## ---------------------------------------------------------------- ##
  def search(strExecCode)

    #### Debug ####
    @log.debug("START: RegistStatus.rb#search")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Check ####
    ## strOffset
    if @strOffset == nil
      return ResultCode::PARAMETER_ERROR
    elsif @strOffset.strip == ""
      ## Do Nothing (on Normal)
    elsif not @strOffset.strip =~ /^[0-9]+$/
      return ResultCode::PARAMETER_ERROR
    end
    ## strLimit
    if @strLimit == nil
      return ResultCode::PARAMETER_ERROR
    elsif @strLimit.strip == ""
      ## Do Nothing (on Normal)
    elsif @strLimit.strip == "all" || @strLimit.strip == "ALL"
      ## Do Nothing (on Normal)
    elsif not @strLimit.strip =~ /^[0-9]+$/
      return ResultCode::PARAMETER_ERROR
    end


    #### Exec ####
    ## Clear Array
    clear

    ## Create SQL
    strSQL = ''
    strSQL = strSQL + 'SELECT '
    strSQL = strSQL +   'M.REGIST_ID           AS REGIST_ID,           '
    strSQL = strSQL +   'M.REPOSITORY_CODE     AS REPOSITORY_CODE,     '
    strSQL = strSQL +   'R.REPOSITORY_NICKNAME AS REPOSITORY_NICKNAME, '
    strSQL = strSQL +   'M.STARTDATE           AS STARTDATE,           '
    strSQL = strSQL +   'M.STARTTIME           AS STARTTIME,           '
    strSQL = strSQL +   'M.ENDDATE             AS ENDDATE,             '
    strSQL = strSQL +   'M.ENDTIME             AS ENDTIME,             '
    strSQL = strSQL +   'M.REGIST_STATUS_CODE  AS REGIST_STATUS_CODE,  '
    strSQL = strSQL +   'M.DEL_FLAG   AS DEL_FLAG,   '
    strSQL = strSQL +   'M.RCDNEWDATE AS RCDNEWDATE, '
    strSQL = strSQL +   'M.RCDNEWTIME AS RCDNEWTIME, '
    strSQL = strSQL +   'M.RCDMDFDATE AS RCDMDFDATE, '
    strSQL = strSQL +   'M.RCDMDFTIME AS RCDMDFTIME  '
    strSQL = strSQL + 'FROM '
    strSQL = strSQL +   'TBL_T_METADATA_REGISTSTATUS AS M '
    strSQL = strSQL + 'LEFT OUTER JOIN '
    strSQL = strSQL +   'TBL_M_REPOSITORY AS R '
    strSQL = strSQL + 'ON '
    strSQL = strSQL +   'M.REPOSITORY_CODE = R.REPOSITORY_CODE '
    ## WHERE
    if strExecCode == GET_ALL
      ## Add Nothing
    elsif strExecCode == GET_NOTDELETED
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'M.DEL_FLAG = \'0\' '
    elsif strExecCode == GET_FROM_REPOSITORYCODE
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'M.REPOSITORY_CODE = \'' + @charutil.sqlEncode(@strRepositoryCode) + '\' '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'M.DEL_FLAG = \'0\' '
    elsif strExecCode == GET_FROM_REGISTID
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'M.REGIST_ID = \'' + @charutil.sqlEncode(@strRegistID) + '\' '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'M.DEL_FLAG = \'0\' '
    elsif strExecCode == GET_RECENTONE
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'M.REPOSITORY_CODE = \'' + @charutil.sqlEncode(@strRepositoryCode) + '\' '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'M.REGIST_STATUS_CODE = \'0\' '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'M.DEL_FLAG = \'0\' '
    end
    ## ORDER BY
    if strExecCode == GET_RECENTONE
      strSQL = strSQL + 'ORDER BY '
      strSQL = strSQL +   'TO_NUMBER(M.REGIST_ID, \'00000000\') DESC '
    else
      strSQL = strSQL + 'ORDER BY '
#     strSQL = strSQL +   'TO_NUMBER(M.REGIST_ID, \'00000000\') ASC '
      strSQL = strSQL +   'TO_NUMBER(M.REGIST_ID, \'00000000\') DESC '
    end
    ## OFFSET and LIMIT
    if strExecCode == GET_RECENTONE
      strSQL = strSQL + 'OFFSET '
      strSQL = strSQL +   '0 '
      strSQL = strSQL + 'LIMIT '
      strSQL = strSQL +   '1 '
    elsif @strOffset != "" and @strLimit != ""
      strSQL = strSQL + 'OFFSET '
      strSQL = strSQL +   @charutil.sqlEncode(@strOffset.to_s) + ' '
      strSQL = strSQL + 'LIMIT '
      strSQL = strSQL +   @charutil.sqlEncode(@strLimit.to_s) + ' '
    end

    ## Debug
    @log.debug("RegistStatus.rb#search: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    strResultCode, result = $db.exQueryDB2(strSQL)

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("RegistStatus.rb#search: SQL Error on Selecting Collection! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end
    if result == nil
      @stdout.error("RegistStatus.rb#search: SQL Error on Selecting Collection! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end

    ## Analyze Result
    result.each do |res|
      ## Set Results
      @aryRegistID            << res['regist_id'].to_s.strip
      @aryRepositoryCode      << res['repository_code'].to_s.strip
      @aryRepositoryNickName  << res['repository_nickname'].to_s.strip
      @aryStartDate           << res['startdate'].to_s.strip
      @aryStartTime           << res['starttime'].to_s.strip
      @aryEndDate             << res['enddate'].to_s.strip
      @aryEndTime             << res['endtime'].to_s.strip
      @aryRegistStatusCode    << res['regist_status_code'].to_s.strip
      @aryDelFlag             << res['del_flag'].to_s.strip
      @aryRcdNewDate          << res['rcdnewdate'].to_s.strip
      @aryRcdNewTime          << res['rcdnewtime'].to_s.strip
      @aryRcdMdfDate          << res['rcdmdfdate'].to_s.strip
      @aryRcdMdfTime          << res['rcdmdftime'].to_s.strip
    end

    ## Set Hits Count
    @intHitsCount = @aryRegistID.size

    ## Clear Result
    result.clear

    #### Debug ####
    @log.debug("END: RegistStatus.rb#search")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] regist                                                  ##
  ## ---------------------------------------------------------------- ##
  def regist(strExecCode)

    #### Debug ####
    @log.debug("START: RegistStatus.rb#regist")

    #### Check ####
    ## REGIST_S0
    if strExecCode == REGIST_S0
      ## strRegistID
      if @strRegistID == nil
        @stdout.error("RegistStatus.rb#regist: strRegistID is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strRegistID.strip == ""
        @stdout.error("RegistStatus.rb#regist: strRegistID is BLANK.")
        return ResultCode::PARAMETER_ERROR
      end
    ## REGIST_S1
    elsif strExecCode == REGIST_S1
      ## strRegistID
      if @strRepositoryCode == nil
        @stdout.error("RegistStatus.rb#regist: strRepositoryCode is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strRepositoryCode.strip == ""
        @stdout.error("RegistStatus.rb#regist: strRepositoryCode is BLANK.")
        return ResultCode::PARAMETER_ERROR
      end
    ## REGIST_S2
    elsif strExecCode == REGIST_S2
      ## strRegistID
      if @strRegistID == nil
        @stdout.error("RegistStatus.rb#regist: strRegistID is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strRegistID.strip == ""
        @stdout.error("RegistStatus.rb#regist: strRegistID is BLANK.")
        return ResultCode::PARAMETER_ERROR
      end
    ## REGIST_S8
    elsif strExecCode == REGIST_S8
      ## strRepositoryCode
      if @strRepositoryCode == nil
        @stdout.error("RegistStatus.rb#regist: strRepositoryCode is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strRepositoryCode.strip == ""
        @stdout.error("RegistStatus.rb#regist: strRepositoryCode is BLANK.")
        return ResultCode::PARAMETER_ERROR
      end
    ## REGIST_S9
    elsif strExecCode == REGIST_S9
      ## strRegistID
      if @strRegistID == nil
        @stdout.error("RegistStatus.rb#regist: strRegistID is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strRegistID.strip == ""
        @stdout.error("RegistStatus.rb#regist: strRegistID is BLANK.")
        return ResultCode::PARAMETER_ERROR
      end
    ## DELETE (DEL_FLAG --> 9)
    elsif strExecCode == DELETE
      ## strRegistID
      if @strRegistID == nil
        @stdout.error("RegistStatus.rb#regist: strRegistID is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strRegistID.strip == ""
        @stdout.error("RegistStatus.rb#regist: strRegistID is BLANK.")
        return ResultCode::PARAMETER_ERROR
      end
    ## ENABLE (DEL_FLAG --> 0)
    elsif strExecCode == ENABLE
      ## strRegistID
      if @strRegistID == nil
        @stdout.error("RegistStatus.rb#regist: strRegistID is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strRegistID.strip == ""
        @stdout.error("RegistStatus.rb#regist: strRegistID is BLANK.")
        return ResultCode::PARAMETER_ERROR
      end
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####

    ## Create SQL
    ## Case. REGIST_S0
    if strExecCode == REGIST_S0
      strSQL = ''
      strSQL = strSQL + 'UPDATE '
      strSQL = strSQL +   'TBL_T_METADATA_REGISTSTATUS '
      strSQL = strSQL + 'SET '
      strSQL = strSQL +   'REGIST_STATUS_CODE = \'0\', '
      strSQL = strSQL +   'RCDMDFDATE = TO_CHAR(NOW(), \'YYYYMMDD\'), '
      strSQL = strSQL +   'RCDMDFTIME = TO_CHAR(NOW(), \'HH24MISS\') '
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'REGIST_ID = \'' + @charutil.sqlEncode(@strRegistID) + '\' '
    ## Case. REGIST_S1
    elsif strExecCode == REGIST_S1
      strSQL = ''
      strSQL = strSQL + 'INSERT INTO '
      strSQL = strSQL +   'TBL_T_METADATA_REGISTSTATUS '
      strSQL = strSQL + 'VALUES( '
      strSQL = strSQL +   'NEXTVAL(\'SEQ_REGIST_ID\'), '
      strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strRepositoryCode) + '\', '
      strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strStartDate)      + '\', '
      strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strStartTime)      + '\', '
      strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strEndDate)        + '\', '
      strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strEndTime)        + '\', '
      strSQL = strSQL +   '\'1\', '                        # REGIST_STATUS_CODE
      strSQL = strSQL +   '\'0\', '                        # DELFLAG
      strSQL = strSQL +   'TO_CHAR(NOW(), \'YYYYMMDD\'), ' # RCDNEWDATE
      strSQL = strSQL +   'TO_CHAR(NOW(), \'HH24MISS\'), ' # RCDNEWTIME
      strSQL = strSQL +   '\'\',                   '       # RCDMDFDATE
      strSQL = strSQL +   '\'\'                    '       # RCDMDFTIME
      strSQL = strSQL + ') '
    ## Case. REGIST_S2
    elsif strExecCode == REGIST_S2
      strSQL = ''
      strSQL = strSQL + 'UPDATE '
      strSQL = strSQL +   'TBL_T_METADATA_REGISTSTATUS '
      strSQL = strSQL + 'SET '
      strSQL = strSQL +   'REGIST_STATUS_CODE = \'2\', '
      strSQL = strSQL +   'RCDMDFDATE = TO_CHAR(NOW(), \'YYYYMMDD\'), '
      strSQL = strSQL +   'RCDMDFTIME = TO_CHAR(NOW(), \'HH24MISS\') '
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'REGIST_ID = \'' + @charutil.sqlEncode(@strRegistID) + '\' '
    ## Case. REGIST_S8
    elsif strExecCode == REGIST_S8
      strSQL = ''
      strSQL = strSQL + 'INSERT INTO '
      strSQL = strSQL +   'TBL_T_METADATA_REGISTSTATUS '
      strSQL = strSQL + 'VALUES( '
      strSQL = strSQL +   'NEXTVAL(\'SEQ_REGIST_ID\'), '
      strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strRepositoryCode) + '\', '
      strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strStartDate)      + '\', '
      strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strStartTime)      + '\', '
      strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strEndDate)        + '\', '
      strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strEndTime)        + '\', '
      strSQL = strSQL +   '\'8\', '                        # REGIST_STATUS_CODE
      strSQL = strSQL +   '\'0\', '                        # DELFLAG
      strSQL = strSQL +   'TO_CHAR(NOW(), \'YYYYMMDD\'), ' # RCDNEWDATE
      strSQL = strSQL +   'TO_CHAR(NOW(), \'HH24MISS\'), ' # RCDNEWTIME
      strSQL = strSQL +   '\'\',                   '       # RCDMDFDATE
      strSQL = strSQL +   '\'\'                    '       # RCDMDFTIME
      strSQL = strSQL + ') '
    ## Case. REGIST_S9
    elsif strExecCode == REGIST_S9
      strSQL = ''
      strSQL = strSQL + 'UPDATE '
      strSQL = strSQL +   'TBL_T_METADATA_REGISTSTATUS '
      strSQL = strSQL + 'SET '
      strSQL = strSQL +   'REGIST_STATUS_CODE = \'9\', '
      strSQL = strSQL +   'RCDMDFDATE = TO_CHAR(NOW(), \'YYYYMMDD\'), '
      strSQL = strSQL +   'RCDMDFTIME = TO_CHAR(NOW(), \'HH24MISS\') '
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'REGIST_ID = \'' + @charutil.sqlEncode(@strRegistID) + '\' '
    ## Case. DELETE (DEL_FLAG --> 9)
    elsif strExecCode == DELETE
      strSQL = ''
      strSQL = strSQL + 'UPDATE '
      strSQL = strSQL +   'TBL_T_METADATA_REGISTSTATUS '
      strSQL = strSQL + 'SET '
      strSQL = strSQL +   'DEL_FLAG = \'9\', '
      strSQL = strSQL +   'RCDMDFDATE = TO_CHAR(NOW(), \'YYYYMMDD\'), '
      strSQL = strSQL +   'RCDMDFTIME = TO_CHAR(NOW(), \'HH24MISS\') '
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'REGIST_ID = \'' + @charutil.sqlEncode(@strRegistID) + '\' '
    ## Case. ENABLE (DEL_FLAG --> 0)
    elsif strExecCode == ENABLE
      strSQL = ''
      strSQL = strSQL + 'UPDATE '
      strSQL = strSQL +   'TBL_T_METADATA_REGISTSTATUS '
      strSQL = strSQL + 'SET '
      strSQL = strSQL +   'DEL_FLAG = \'0\', '
      strSQL = strSQL +   'RCDMDFDATE = TO_CHAR(NOW(), \'YYYYMMDD\'), '
      strSQL = strSQL +   'RCDMDFTIME = TO_CHAR(NOW(), \'HH24MISS\') '
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'REGIST_ID = \'' + @charutil.sqlEncode(@strRegistID) + '\' '
    end

    ## Debug
    @log.debug("RegistStatus.rb#regist: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    strResultCode, result = $db.exUpdateDB2(strSQL)

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("SQL Error on Registing Metadata Status! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end
    if result == nil
      @stdout.error("SQL Error on Registing Metadata Status! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end

    ## Get currval('SEQ_REGIST_ID')
    if strExecCode == REGIST_S1
      ## Create SQL
      strSQL = ''
      strSQL = strSQL + 'SELECT '
      strSQL = strSQL +   'CURRVAL(\'SEQ_REGIST_ID\') AS REGIST_ID '
      ## Exec Transaction
      strResultCode, result = $db.exQueryDB2(strSQL)
      ## Set Result
      if strResultCode == ResultCode::NORMAL
        result.each do |res|
          @strCurrRegistID = res['regist_id'].to_s.strip
        end
      end
    end

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("SQL Error on Selecting Currval(SEQ_REGIST_ID)! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end
    if result == nil
      @stdout.error("SQL Error on Selecting Currval(SEQ_REGIST_ID)! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end

    ## Clear Result
    if result != nil
      result.clear
    end

    #### Debug ####
    @log.debug("END: RegistStatus.rb#regist")

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
  ## [API-method] setStartDate                                        ##
  ## ---------------------------------------------------------------- ##
  def setStartDate(strStartDate)
    @strStartDate = strStartDate
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setStartTime                                        ##
  ## ---------------------------------------------------------------- ##
  def setStartTime(strStartTime)
    @strStartTime = strStartTime
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setEndDate                                          ##
  ## ---------------------------------------------------------------- ##
  def setEndDate(strEndDate)
    @strEndDate = strEndDate
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setEndTime                                          ##
  ## ---------------------------------------------------------------- ##
  def setEndTime(strEndTime)
    @strEndTime = strEndTime
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setRegistStatusCode                                 ##
  ## ---------------------------------------------------------------- ##
  def setRegistStatusCode(strRegistStatusCode)
    @strRegistStatusCode = strRegistStatusCode
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

  ## ---------------------------------------------------------------- ##
  ## [API-method] getHitsCount                                        ##
  ## ---------------------------------------------------------------- ##
  def getHitsCount
    return @intHitsCount
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getRegistID                                         ##
  ## ---------------------------------------------------------------- ##
  def getRegistID
    return @aryRegistID
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
  ## [API-method] getStartDate                                        ##
  ## ---------------------------------------------------------------- ##
  def getStartDate
    return @aryStartDate
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getStartTime                                        ##
  ## ---------------------------------------------------------------- ##
  def getStartTime
    return @aryStartTime
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getEndDate                                          ##
  ## ---------------------------------------------------------------- ##
  def getEndDate
    return @aryEndDate
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getEndTime                                          ##
  ## ---------------------------------------------------------------- ##
  def getEndTime
    return @aryEndTime
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getRegistStatusCode                                 ##
  ## ---------------------------------------------------------------- ##
  def getRegistStatusCode
    return @aryRegistStatusCode
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

  ## ---------------------------------------------------------------- ##
  ## [API-method] getCurrRegistID                                     ##
  ## ---------------------------------------------------------------- ##
  def getCurrRegistID
    return @strCurrRegistID
  end


end
