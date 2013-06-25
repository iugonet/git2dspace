# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [Community.rb]                                                     ##
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

class Community


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##
  #### ExecCode (Private Key)
  ## Search
  GET_ALL        = '2002101'  ## Get All Records (Contains Deleted Records)
  GET_NOTDELETED = '2002102'  ## Expect Deleted Records
  GET_FROM_NAME  = '2002103'  ## Search From the Community Name
  ## Regist
  REGIST_ALL     = '2002201'  ## Regist Communities to Admin-DB
  ## Others
  RESTORE        = '2002301'  ## Restore Communities From DSpace to Admin-DB


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
    @aryCommunityID    = Array.new
    @aryHandleIDSuffix = Array.new
    @aryCommunityName  = Array.new
    @aryDelFlag        = Array.new
    @aryRcdNewDate     = Array.new
    @aryRcdNewTime     = Array.new
    @aryRcdMdfDate     = Array.new
    @aryRcdMdfTime     = Array.new
    ## Variables (For API Functions)
    @strCommunityID    = ""
    @strHandleIDSuffix = ""
    @strCommunityName  = ""

  end


  ## ---------------------------------------------------------------- ##
  ## [method] clear                                                   ##
  ## ---------------------------------------------------------------- ##
  def clear

    #### Exec ####
    ## Variables (For SQL Results)
    @intHitsCount = 0
    @aryCommunityID.clear
    @aryHandleIDSuffix.clear
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
    ## Search: GET_NOT_DELETED
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
      @log.error("Community.rb#exec: Undefined ExecCode was Given.")
      strResultCode = ResultCode::EXECCODE_ERROR
    end

    #### Debug ####
    @log.debug("END: Community.rb#exec")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] truncateTable                                           ##
  ## ---------------------------------------------------------------- ##
  def truncateTable

    #### Debug ####
    @log.debug("START: Community.rb#truncateTable")

    #### Define ####
    strResultCode = ResultCode::NORMAL
    aryTableList = Array.new
    
    #### Exec ####

    ## Set Table List
    aryTableList << 'TBL_T_COMMUNITY'

    ## Loop and Exec
    for i in 0..aryTableList.size-1

      ## Create SQL
      strSQL = ''
      strSQL = strSQL + 'TRUNCATE TABLE '
      strSQL = strSQL +    @charutil.sqlEncode(aryTableList[i])

      ## Debug
      @log.debug("Community.rb#truncateTable: strSQL = [" + strSQL + "]")

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
        @stdout.error("Community.rb#truncateTable: SQL Error on Truncating Community Table! strSQL = [" + strSQL.to_s + "]")
        return strResultCode
      end

    end

    ## Clear Array
    aryTableList.clear

    #### Debug ####
    @log.debug("END: Community.rb#truncateTable")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] restore                                                 ##
  ## ---------------------------------------------------------------- ##
  def restore

    #### Debug ####
    @log.debug("START: Community.rb#restore")

    #### Define ####
    ## Variables
    strResultCode = ResultCode::NORMAL

    #### Exec ####

    ## Debug
    @stdout.info("START: Restoring Communities to the Admin-DB. <== Watch the Processing Time!!")

    ## Create SQL
    strSQL = ''
    strSQL = strSQL + 'SELECT '
    strSQL = strSQL +   'H.HANDLE_ID    AS HANDLE_ID, '
    strSQL = strSQL +   'H.RESOURCE_ID  AS RESOURCE_ID, '
    strSQL = strSQL +   'C.NAME         AS NAME '
    strSQL = strSQL + 'FROM '
    strSQL = strSQL +   'HANDLE AS H '
    strSQL = strSQL + 'LEFT OUTER JOIN '
    strSQL = strSQL +   'COMMUNITY AS C '
    strSQL = strSQL + 'ON '
    strSQL = strSQL +   'H.RESOURCE_ID = C.COMMUNITY_ID '
    strSQL = strSQL + 'WHERE '
    strSQL = strSQL +   'H.RESOURCE_TYPE_ID = \'' + @charutil.sqlEncode(Configure::RESOURCETYPEID_COMMUNITY) + '\' '
    strSQL = strSQL + 'ORDER BY '
    strSQL = strSQL +   'H.HANDLE_ID ASC'

    ## Debug
    @log.debug("Community.rb#restore: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    @log.debug("START: Selecting the Community from the DSpace-DB (#1). <== Watch the Processing Time!!")
    strResultCode, result = $db.exQueryDB1(strSQL)
    @log.debug("END: Selecting the Community from the DSpace-DB (#1). <== Watch the Processing Time!!")

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("Community.rb#restore: SQL Error on Selecting Community! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end
    if result == nil
      @stdout.error("Community.rb#restore: SQL Error on Selecting Community! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end

    ## Define (Temporary Variables)
    strResourceID = ""
    blnNext = true
    aryCommunityName = Array.new

    ## Analyze Result
    result.each do |res|

      ## Initialize
      blnNext = true
      strResourceID = res['resource_id'].to_s.strip

      ## Initialize
      while blnNext

        ## Replace Flag (Temporary)
        blnNext = false

        ## Create SQL
        strSQL = ''
        strSQL = strSQL + 'SELECT '
        strSQL = strSQL +   'C2C.PARENT_COMM_ID AS PARENT_COMM_ID, '
        strSQL = strSQL +   'C.NAME AS NAME '
        strSQL = strSQL + 'FROM '
        strSQL = strSQL +   'COMMUNITY2COMMUNITY AS C2C '
        strSQL = strSQL + 'LEFT OUTER JOIN '
        strSQL = strSQL +   'COMMUNITY AS C '
        strSQL = strSQL + 'ON '
        strSQL = strSQL +   'C2C.PARENT_COMM_ID = C.COMMUNITY_ID '
        strSQL = strSQL + 'WHERE '
        strSQL = strSQL +   'C2C.CHILD_COMM_ID = \'' + @charutil.sqlEncode(strResourceID) + '\' '

        ## Debug
#       @log.debug("Community.rb#restore: strSQL = [" + strSQL + "]")

        ## Exec Transaction
#       @log.debug("START: Selecting the Community from the DSpace-DB (#2). <== Watch the Processing Time!!")
        strResultCode, result2 = $db.exQueryDB1(strSQL)
#       @log.debug("END: Selecting the Community from the DSpace-DB (#2). <== Watch the Processing Time!!")

        ## Error Trap
        if strResultCode != ResultCode::NORMAL
          @stdout.error("Community.rb#restore: SQL Error on Selecting Parent Community! strSQL = [" + strSQL.to_s + "]")
          return ResultCode::SQL_ERROR
        end
        if result2 == nil
          @stdout.error("Community.rb#restore: SQL Error on Selecting Parent Community! strSQL = [" + strSQL.to_s + "]")
          return ResultCode::SQL_ERROR
        end

        ## Analyze Result
        result2.each do |res2|
          aryCommunityName << res2['name'].to_s.strip
          strResourceID = res2['parent_comm_id'].to_s.strip
          blnNext = true  # Has More Parent --> Go to Next Loop
        end

        ## Has No More Parent --> Regist Community to Admin-DB
        if blnNext == false

          ## Clear Variables
          @strCommunityID    = ""
          @strCommunityName  = ""
          @strHandleIDSuffix = ""

          ## Set Variables
          @strCommunityID = res['resource_id'].to_s.strip
          aryCommunityName.reverse_each do |strCommunityName|
            @strCommunityName = @strCommunityName + strCommunityName + "/"
          end
          @strCommunityName  = @strCommunityName + res['name'].to_s.strip
          @strHandleIDSuffix = res['handle_id'].to_s.strip

          ## Clear
          aryCommunityName.clear
          result2.clear

          ## Debug
#         @log.debug("Community.rb#restore: strCommunityID    = [" + @strCommunityID    + "]")
#         @log.debug("Community.rb#restore: strHandleIDSuffix = [" + @strHandleIDSuffix + "]")
#         @log.debug("Community.rb#restore: strCommunityName  = [" + @strCommunityName  + "]")

          ## Regist Collection to Admin-DB
          strResultCode = regist(ExecCode::COMMUNITY_REGIST_ALL)
          if strResultCode != ResultCode::NORMAL
            @stdout.error("Community.rb#restore: Error Occurred on Registing Community to the Admin-DB")
          end

        end  ## End of if

      end  ## End of while

    end  ## end of do

    ## Clear
    result.clear

    #### Debug ####
    @stdout.info("END: Restoring Communities to the Admin-DB. <== Watch the Processing Time!!")
    @log.debug("END: Community.rb#restore")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] regist                                                  ##
  ## ---------------------------------------------------------------- ##
  def regist(strExecCode)

    #### Debug ####
#   @log.debug("START: Community.rb#regist")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####

    ## Create SQL
    strSQL = ''
    strSQL = strSQL + 'INSERT INTO '
    strSQL = strSQL +   'TBL_T_COMMUNITY '
    strSQL = strSQL + 'VALUES('
    strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strCommunityID)    + '\','
    strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strHandleIDSuffix) + '\','
    strSQL = strSQL +   '\'' + @charutil.sqlEncode(@strCommunityName)  + '\','
    strSQL = strSQL +   '\'0\', '                        # DELFLAG
    strSQL = strSQL +   'TO_CHAR(NOW(), \'YYYYMMDD\'), ' # RCDNEWDATE
    strSQL = strSQL +   'TO_CHAR(NOW(), \'HH24MISS\'), ' # RCDNEWTIME
    strSQL = strSQL +   '\'\',                   '       # RCDMDFDATE
    strSQL = strSQL +   '\'\'                    '       # RCDMDFTIME
    strSQL = strSQL + ') '

    ## Debug
#   @log.debug("Community.rb#regist: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    strResultCode, result = $db.exUpdateDB2(strSQL)

    ## Clear Result
    if result != nil
      result.clear
    end

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("Community.rb#regist: SQL Error on Registing Communities to the Admin-DB! strSQL = [" + strSQL.to_s + "]")
    end

    #### Debug ####
#   @log.debug("END: Community.rb#regist")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] search                                                  ##
  ## ---------------------------------------------------------------- ##
  def search(strExecCode)

    #### Debug ####
    @log.debug("START: Community.rb#search")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Check ####
    ## Search: GET_ALL
    if strExecCode == GET_ALL
      ## Do Nothing
    ## Search: GET_NOT_DELETED
    elsif strExecCode == GET_NOTDELETED
      ## Do Nothing
    ## Search: GET_FROM_NAME
    elsif strExecCode == GET_FROM_NAME
      ## strCommunityName
      if @strCommunityName == nil
        @log.error("Community.rb#search: Parameter Error. strCommunityName is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strCommunityName.strip == ""
        @log.error("Community.rb#search: Parameter Error. strCommunityName is BLANK.")
        return ResultCode::PARAMETER_ERROR
      end
    end

    #### Exec ####
    ## Clear Array
    clear

    ## Create SQL
    strSQL = ''
    strSQL = strSQL + 'SELECT '
    strSQL = strSQL +   'COMMUNITY_ID   AS COMMUNITY_ID, '
    strSQL = strSQL +   'HANDLE_ID      AS HANDLE_ID, '
    strSQL = strSQL +   'COMMUNITY_NAME AS COMMUNITY_NAME, '
    strSQL = strSQL +   'DEL_FLAG   AS DEL_FLAG, '
    strSQL = strSQL +   'RCDNEWDATE AS RCDNEWDATE, '
    strSQL = strSQL +   'RCDNEWTIME AS RCDNEWTIME, '
    strSQL = strSQL +   'RCDMDFDATE AS RCDMDFDATE, '
    strSQL = strSQL +   'RCDMDFTIME AS RCDMDFTIME  '
    strSQL = strSQL + 'FROM '
    strSQL = strSQL +   'TBL_T_COMMUNITY '
    ## Where
    if strExecCode == GET_ALL
      ## Add Nothing
    elsif strExecCode == GET_NOTDELETED
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'DEL_FLAG = \'0\' '
    elsif strExecCode == GET_FROM_NAME
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'COMMUNITY_NAME = \'' + @charutil.sqlEncode(@strCommunityName) + '\' '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'DEL_FLAG = \'0\' '
    end
    ## Order By
    strSQL = strSQL + 'ORDER BY '
    strSQL = strSQL +   'COMMUNITY_ID ASC '

    ## Debug
    @log.debug("Community.rb#search: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    @log.debug("START: Searching Communities from the Admin-DB. <== Watch the Processing Time!!")
    strResultCode, result = $db.exQueryDB2(strSQL)
    @log.debug("END: Searching Communities from the Admin-DB. <== Watch the Processing Time!!")

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("Community.rb#search: SQL Error on Selecting Collection! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end
    if result == nil
      @stdout.error("Community.rb#search: SQL Error on Selecting Collection! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end

    ## Analyze Result
    result.each do |res|
      ## Set Variables
      @aryCommunityID    << res['community_id'].to_s.strip
      @aryHandleIDSuffix << res['handle_id'].to_s.strip
      @aryCommunityName  << res['community_name'].to_s.strip
      @aryDelFlag        << res['del_flag'].to_s.strip
      @aryRcdNewDate     << res['rcdnewdate'].to_s.strip
      @aryRcdNewTime     << res['rcdnewtime'].to_s.strip
      @aryRcdMdfDate     << res['rcdmdfdate'].to_s.strip
      @aryRcdMdfTime     << res['rcdmdftime'].to_s.strip
    end

    ## Set Hits Count
    @intHitsCount = @aryCommunityID.size

    ## Clear
    result.clear

    #### Debug ####
    @log.debug("END: Community.rb#search")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [API-method] setCommunityID                                      ##
  ## ---------------------------------------------------------------- ##
  def setCommunityID(strCommunityID)
    @strCommunityID = strCommunityID
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setHandleIDSuffix                                   ##
  ## ---------------------------------------------------------------- ##
  def setHandleIDSuffix(strHandleIDSuffix)
    @strHandleIDSuffix = strHandleIDSuffix
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setCommunityName                                    ##
  ## ---------------------------------------------------------------- ##
  def setCommunityName(strCommunityName)
    @strCommunityName = strCommunityName
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getHitsCount                                        ##
  ## ---------------------------------------------------------------- ##
  def getHitsCount
    return @intHitsCount
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getCommunityID                                      ##
  ## ---------------------------------------------------------------- ##
  def getCommunityID
    return @aryCommunityID
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getHandleIDSuffix                                   ##
  ## ---------------------------------------------------------------- ##
  def getHandleIDSuffix
    return @aryHandleIDSuffix
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
