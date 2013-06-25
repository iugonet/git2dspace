# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [Collection.rb]                                                    ##
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

class Collection


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##
  #### ExecCode (Private Key)
  ## Search
  GET_ALL        = '2003101'  ## Get All Records (Contains Deleted Records)
  GET_NOTDELETED = '2003102'  ## Expect Deleted Records
  GET_FROM_NAME  = '2003103'  ## Search From the Collection Name
  ## Regist
  REGIST_ALL     = '2003201'  ## Regist Collections to Admin-DB
  ## Others
  RESTORE        = '2003301'  ## Restore Collections from DSpace to Admin-DB


  ## ---------------------------------------------------------------- ##
  ## [initialize]                                                     ##
  ## ---------------------------------------------------------------- ##
  def initialize
    #### Exec ####
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
    @intHitsCount      = 0
    @aryCollectionID   = Array.new
    @aryHandleIDSuffix = Array.new
    @aryCollectionName = Array.new
    @aryCommunityID    = Array.new
    @aryCommunityName  = Array.new
    @aryDelFlag        = Array.new
    @aryRcdNewDate     = Array.new
    @aryRcdNewTime     = Array.new
    @aryRcdMdfDate     = Array.new
    @aryRcdMdfTime     = Array.new
    ## Variables (For API Functions)
    @strCollectionID   = ""
    @strHandleIDSuffix = ""
    @strCollectionName = ""
    @strCommunityID    = ""

  end


  ## ---------------------------------------------------------------- ##
  ## [method] clear                                                   ##
  ## ---------------------------------------------------------------- ##
  def clear

    #### Exec ####
    ## Variables (For SQL Results)
    @intHitsCount = 0
    @aryCollectionID.clear
    @aryHandleIDSuffix.clear
    @aryCollectionName.clear
    @aryCommunityID.clear
    @aryCommunityName.clear
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
    @log.debug("START: Community.rb#exec")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Search: GET_ALL
    if strExecCode == GET_ALL
      strResultCode = search(strExecCode)
    ## Search: GET_NOTDELETED
    elsif strExecCode == GET_NOTDELETED
      strResultCode = search(strExecCode)
    ## Search: GET_FROM_NAME
    elsif strExecCode == GET_FROM_NAME
      strResultCode = search(strExecCode)
    ## Regist: REGIST_ALL
    elsif strExecCode == REGIST_ALL
      strResultCode = regist(strExecCode)
    ## Others: RESTORE
    elsif strExecCode == RESTORE
      ## Step.1: Truncate Table
      strResultCode = truncateTable
      if strResultCode != ResultCode::NORMAL
        return strResultCode
      end
      ## Step.2: Restore Table
      strResultCode = restore
      if strResultCode != ResultCode::NORMAL
        return strResultCode
      end
    ## Error
    else
      @log.error("Collection.rb#exec: Undefined ExecCode was Given.")
      strResultCode = ResultCode::EXECCODE_ERROR
    end

    #### Debug ####
    @log.debug("END: Collection.rb#exec")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] truncateTable                                           ##
  ## ---------------------------------------------------------------- ##
  def truncateTable

    #### Debug ####
    @log.debug("START: Collection.rb#truncateTable")

    #### Define ####
    strResultCode = ResultCode::NORMAL
    aryTableList = Array.new
    
    #### Exec ####

    ## Set Table List
    aryTableList << 'TBL_T_COLLECTION'

    ## Loop and Exec
    for i in 0..aryTableList.size-1

      ## Create SQL
      strSQL = ''
      strSQL = strSQL + 'TRUNCATE TABLE '
      strSQL = strSQL +    @charutil.sqlEncode(aryTableList[i])

      ## Debug
      @log.debug("Collection.rb#truncateTable: strSQL = [" + strSQL + "]")

      ## Exec Transaction
      @stdout.info("START: Truncating Table [" + aryTableList[i] + "]. <== Watch the Processing Time!!")
      strResultCode, result = $db.exUpdateDB2(strSQL)
      @stdout.info("END: Truncating Table [" + aryTableList[i] + "]. <== Watch the Processing Time!!")

      ## Clear Result
      if result != nil
        result.clear
      end

      ## Error Trap
      if strResultCode != ResultCode::NORMAL
        @stdout.error("Collection.rb#truncateTable: SQL Error on Truncating Collection Table! strSQL = [" + strSQL.to_s + "]")
        return strResultCode
      end

    end

    ## Clear Array
    aryTableList.clear

    #### Debug ####
    @log.debug("END: Collection.rb#truncateTable")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] restore                                                 ##
  ## ---------------------------------------------------------------- ##
  def restore

    #### Debug ####
    @log.debug("START: Collection.rb#restore")

    #### Define ####
    ## Variables
    strResultCode = ResultCode::NORMAL

    #### Exec ####

    ## Debug
    @stdout.info("START: Restoring Collections to the Admin-DB. <== Watch the Processing Time!!")

    ## Create SQL
    strSQL = ''
    strSQL = strSQL + 'SELECT '
    strSQL = strSQL +   'H.HANDLE_ID     AS HANDLE_ID, '
    strSQL = strSQL +   'C.COLLECTION_ID AS COLLECTION_ID, '
    strSQL = strSQL +   'C.NAME          AS NAME, '
    strSQL = strSQL +   'C2C.COMMUNITY_ID AS COMMUNITY_ID '
    strSQL = strSQL + 'FROM '
    strSQL = strSQL +   'HANDLE AS H '
    strSQL = strSQL + 'LEFT OUTER JOIN '
    strSQL = strSQL +   'COLLECTION AS C '
    strSQL = strSQL + 'ON '
    strSQL = strSQL +   'H.RESOURCE_ID = C.COLLECTION_ID '
    strSQL = strSQL + 'LEFT OUTER JOIN '
    strSQL = strSQL +   'COMMUNITY2COLLECTION AS C2C '
    strSQL = strSQL + 'ON '
    strSQL = strSQL +   'H.RESOURCE_ID = C2C.COLLECTION_ID '
    strSQL = strSQL + 'WHERE '
    strSQL = strSQL +   'H.RESOURCE_TYPE_ID = \'' + @charutil.sqlEncode(Configure::RESOURCETYPEID_COLLECTION) + '\' '
    strSQL = strSQL + 'ORDER BY '
    strSQL = strSQL +   'H.HANDLE_ID ASC'

    ## Debug
    @log.debug("Collection.rb#restore: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    strResultCode, result = $db.exQueryDB1(strSQL)

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("Collection.rb#restore: SQL Error on Selecting Collection! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end
    if result == nil
      @stdout.error("Collection.rb#restore: SQL Error on Selecting Collection! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end

    ## Define (Temporary Variables)
    strResourceID = ""
    blnNext = true
    aryName = Array.new

    ## Analyze Result
    result.each do |res|

      ## Set Variables
      @strCollectionID   = res['collection_id'].to_s.strip
      @strHandleIDSuffix = res['handle_id'].to_s.strip
      @strCollectionName = res['name'].to_s.strip
      @strCommunityID    = res['community_id'].to_s.strip

      ## Debug
#     @log.debug("Collection.rb#restore: strCollectionID   = [" + @strCollectionID e + "]")
#     @log.debug("Collection.rb#restore: strHandleIDSuffix = [" + @strHandleIDSuffix + "]")
#     @log.debug("Collection.rb#restore: strCollectionName = [" + @strCollectionName + "]")
#     @log.debug("Collection.rb#restore: strCommunityID    = [" + @strCommunityID    + "]")

      ## Regist Collection to Admin-DB
      strResultCode = regist(ExecCode::COLLECTION_REGIST_ALL)
      if strResultCode != ResultCode::NORMAL
        @stdout.error("Collection.rb#restore: Error Occurred on Registing Collection to the Admin-DB")
      end

    end

    ## Clear Result
    result.clear

    #### Debug ####
    @stdout.info("END: Restoring Collections to the Admin-DB. <== Watch the Processing Time!!")
    @log.debug("END: Collection.rb#restore")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] regist                                                  ##
  ## ---------------------------------------------------------------- ##
  def regist(strExecCode)

    #### Debug ####
#   @log.debug("START: Collection.rb#regist")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####

    ## Create SQL
    strSQL = ''
    strSQL = strSQL + 'INSERT INTO '
    strSQL = strSQL +   'TBL_T_COLLECTION '
    strSQL = strSQL + 'VALUES('
    strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strCollectionID)   + '\','
    strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strHandleIDSuffix) + '\','
    strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strCollectionName) + '\','
    strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strCommunityID)    + '\','
    strSQL = strSQL +   '\'0\', '                        # DELFLAG
    strSQL = strSQL +   'TO_CHAR(NOW(), \'YYYYMMDD\'), ' # RCDNEWDATE
    strSQL = strSQL +   'TO_CHAR(NOW(), \'HH24MISS\'), ' # RCDNEWTIME
    strSQL = strSQL +   '\'\',                   '       # RCDMDFDATE
    strSQL = strSQL +   '\'\'                    '       # RCDMDFTIME
    strSQL = strSQL + ') '

    ## Debug
#   @log.debug("Collection.rb#regist: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    strResultCode, result = $db.exUpdateDB2(strSQL)

    ## Clear Result
    if result != nil
      result.clear
    end

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("Collection.rb#regist: SQL Error on Registing Collections to the Admin-DB! strSQL = [" + strSQL.to_s + "]")
    end

    #### Debug ####
#   @log.debug("END: Collection.rb#regist")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] search                                                  ##
  ## ---------------------------------------------------------------- ##
  def search(strExecCode)

    #### Debug ####
    @log.debug("START: Collection.rb#search")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Check ####
    ## Search: GET_ALL
    if strExecCode == GET_ALL
      ## Do Nothing
    ## Search: GET_NOTDELETED
    elsif strExecCode == GET_NOTDELETED
      ## Do Nothing
    ## Search: GET_FROM_NAME
    elsif strExecCode == GET_FROM_NAME
      ## strCollectionName
      if @strCollectionName == nil
        @log.error("Collection.rb#search: Parameter Error. strCollectionName is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strCollectionName.strip == ""
        @log.error("Collection.rb#search: Parameter Error. strCollectionName is BLANK.")
        return ResultCode::PARAMETER_ERROR
      end
    end

    #### Exec ####
    ## Clear Array
    clear

    ## Create SQL
    strSQL = ''
    strSQL = strSQL + 'SELECT '
    strSQL = strSQL +   'COL.COLLECTION_ID   AS COLLECTION_ID, '
    strSQL = strSQL +   'COL.HANDLE_ID       AS HANDLE_ID, '
    strSQL = strSQL +   'COL.COLLECTION_NAME AS COLLECTION_NAME, '
    strSQL = strSQL +   'COL.COMMUNITY_ID    AS COMMUNITY_ID, '
    strSQL = strSQL +   'COM.COMMUNITY_NAME  AS COMMUNITY_NAME, '
    strSQL = strSQL +   'COL.DEL_FLAG   AS DEL_FLAG, '
    strSQL = strSQL +   'COL.RCDNEWDATE AS RCDNEWDATE, '
    strSQL = strSQL +   'COL.RCDNEWTIME AS RCDNEWTIME, '
    strSQL = strSQL +   'COL.RCDMDFDATE AS RCDMDFDATE, '
    strSQL = strSQL +   'COL.RCDMDFTIME AS RCDMDFTIME  '
    strSQL = strSQL + 'FROM '
    strSQL = strSQL +   'TBL_T_COLLECTION AS COL, '
    strSQL = strSQL +   'TBL_T_COMMUNITY AS COM '
    ## Where
    if strExecCode == GET_ALL
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'COL.COMMUNITY_ID = COM.COMMUNITY_ID '
    elsif strExecCode == GET_NOTDELETED
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'COL.COMMUNITY_ID = COM.COMMUNITY_ID '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'COL.DEL_FLAG = \'0\' '
    elsif strExecCode == GET_FROM_NAME
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'COL.COMMUNITY_ID = COM.COMMUNITY_ID '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'COM.COMMUNITY_NAME || \'/\' || COL.COLLECTION_NAME = \'' + @charutil.sqlEncode(@strCollectionName) + '\' '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'COL.DEL_FLAG = \'0\' '
    end
    ## Order by
    strSQL = strSQL + 'ORDER BY '
    strSQL = strSQL +   'COL.COLLECTION_ID ASC '

    ## Debug
    @log.debug("Collection.rb#search: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    @log.debug("START: Searching Collections from the Admin-DB. <== Watch the Processing Time!!")
    strResultCode, result = $db.exQueryDB2(strSQL)
    @log.debug("END: Searching Collections from the Admin-DB. <== Watch the Processing Time!!")

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("Collection.rb#search: SQL Error on Selecting Collection! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end
    if result == nil
      @stdout.error("Collection.rb#search: SQL Error on Selecting Collection! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end

    ## Analyze Result
    result.each do |res|
      ## Set Result
      @aryCollectionID   << res['collection_id'].to_s.strip
      @aryHandleIDSuffix << res['handle_id'].to_s.strip
      @aryCollectionName << res['collection_name'].to_s.strip
      @aryCommunityID    << res['community_id'].to_s.strip
      @aryCommunityName  << res['community_name'].to_s.strip
      @aryDelFlag        << res['del_flag'].to_s.strip
      @aryRcdNewDate     << res['rcdnewdate'].to_s.strip
      @aryRcdNewTime     << res['rcdnewtime'].to_s.strip
      @aryRcdMdfDate     << res['rcdmdfdate'].to_s.strip
      @aryRcdMdfTime     << res['rcdmdftime'].to_s.strip
    end

    ## Set Hits Count
    @intHitsCount = @aryCollectionID.size

    ## Clear
    result.clear

    #### Debug ####
    @log.debug("END: Collection.rb#search")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [API-method] setCollectionID                                     ##
  ## ---------------------------------------------------------------- ##
  def setCollectionID(strCollectionID)
    @strCollectionID = strCollectionID
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setHandleIDSuffix                                   ##
  ## ---------------------------------------------------------------- ##
  def setHandleIDSuffix(strHandleIDSuffix)
    @strHandleIDSuffix = strHandleIDSuffix
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setCollectionName                                   ##
  ## ---------------------------------------------------------------- ##
  def setCollectionName(strCollectionName)
    @strCollectionName = strCollectionName
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setCommunityID                                      ##
  ## ---------------------------------------------------------------- ##
  def setCommunityID(strCommunityID)
    @strCommunityID = strCommunityID
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getHitsCount                                        ##
  ## ---------------------------------------------------------------- ##
  def getHitsCount
    return @intHitsCount
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getCollecionID                                      ##
  ## ---------------------------------------------------------------- ##
  def getCollectionID
    return @aryCollectionID
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getHandleIDSuffix                                   ##
  ## ---------------------------------------------------------------- ##
  def getHandleIDSuffix
    return @aryHandleIDSuffix
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getCollectionName                                   ##
  ## ---------------------------------------------------------------- ##
  def getCollectionName
    return @aryCollectionName
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getCommunityID                                      ##
  ## ---------------------------------------------------------------- ##
  def getCommunityID
    return @aryCommunityID
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getCommunityName                                    ##
  ## ---------------------------------------------------------------- ##
  def getCommunityName
    return @aryCommunityName
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
