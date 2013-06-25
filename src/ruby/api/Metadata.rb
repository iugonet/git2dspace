# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [Metadata.rb]                                                      ##
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
require './lib/Date'

class Metadata


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##
  #### ExecCode (Private Key)
  ## Search
# GET_ALL             = '2004101'  ## Get All Records (Contains Deleted Records)
# GET_NOTDELETED      = '2004101'  ## Expect Deleted Records
  GET_FROM_RESOURCEID = '2004103'  ## Search From the ResourceID
  ## Regist
  ## Others
  RESTORE             = '2004301'  ## Restore Metadata's ResourceID From DSpace to Admin-DB

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

    #### Variables (For SQL Results)
    @intHitsCount        = 0
    @aryHandleIDSuffix   = Array.new
    @aryResourceID       = Array.new
    @aryOwningCollection = Array.new
    @aryItemID           = Array.new
    @aryDelFlag          = Array.new
    @aryRcdNewDate       = Array.new
    @aryRcdNewTime       = Array.new
    @aryRcdMdfDate       = Array.new
    @aryRcdMdfTime       = Array.new
    #### Variables (For API Functions)
    @strHandleIDSuffix     = ""
    @strResourceID         = ""
    @strOwningCollectionID = ""
    @strItemID             = ""

  end


  ## ---------------------------------------------------------------- ##
  ## [method] clear                                                   ##
  ## ---------------------------------------------------------------- ##
  def clear

    #### Exec ####
    ## Variables (For SQL Results)
    @intHitsCount = 0
    @aryHandleIDSuffix.clear
    @aryResourceID.clear
    @aryOwningCollection.clear
    @aryItemID.clear
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
    @log.debug("START: Metadata.rb#exec")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Search: GET_FROM_RESOURCEID
    if strExecCode == GET_FROM_RESOURCEID
      strResultCode = search(strExecCode)
    ## Others: RESTORE
    elsif strExecCode == RESTORE
      ## Step.1: Truncate Table
      strResultCode = truncateTable
      if strResultCode != ResultCode::NORMAL
        return strResultCode
      end
      ## Step.2: Drop Keys
      strResultCode = dropKeys
      if strResultCode != ResultCode::NORMAL
        return strResultCode
      end
      ## Step.3: Restore Table
      strResultCode = restore
      if strResultCode != ResultCode::NORMAL
        return strResultCode
      end
      ## Step.4: Regist to Admin-DB (Using Temporary File)
      strResultCode = regist(strExecCode)
      if strResultCode != ResultCode::NORMAL
        return strResultCode
      end
      ## Step.5: Create Keys (Primary-Key, Index-Key)
      strResultCode = createKeys
      if strResultCode != ResultCode::NORMAL
        return strResultCode
      end
    ## Error
    else
      @log.error("Metadata.rb#exec: Undefined ExecCode was Given.")
      strResultCode = ResultCode::EXECCODE_ERROR
    end

    #### Debug ####
    @log.debug("END: Metadata.rb#exec")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] truncateTable                                           ##
  ## ---------------------------------------------------------------- ##
  def truncateTable

    #### Debug ####
    @log.debug("START: Metadata.rb#truncateTable")

    #### Define ####
    strResultCode = ResultCode::NORMAL
    aryTableList = Array.new
    
    #### Exec ####

    ## Set Table List
    aryTableList << 'TBL_T_METADATA'

    ## Loop and Exec
    for i in 0..aryTableList.size-1

      ## Create SQL
      strSQL = ''
      strSQL = strSQL + 'TRUNCATE TABLE '
      strSQL = strSQL +    @charutil.sqlEncode(aryTableList[i])

      ## Debug
      @log.debug("Metadata.rb#truncateTable: strSQL = [" + strSQL + "]")

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
        @stdout.error("Metadata.rb#truncateTable: SQL Error on Truncating Metadata Table! strSQL = [" + strSQL.to_s + "]")
        return strResultCode
      end

    end

    ## Clear Array
    aryTableList.clear

    #### Debug ####
    @log.debug("END: Metadata.rb#truncateTable")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] dropKeys                                                ##
  ## ---------------------------------------------------------------- ##
  def dropKeys

    #### Debug ####
    @log.debug("START: Metadata.rb#dropKeys")

    #### Define ####
    strResultCode = ResultCode::NORMAL
    aryPrimaryKeyList = Array.new
    aryIndexKeyList   = Array.new
    
    #### Exec ####

    ## Set Key List
    aryPrimaryKeyList << 'TBL_T_METADATA_PKEY'
    aryIndexKeyList   << 'IDX_RESOURCE_ID_ON_TBL_T_METADATA'

    ## Drop Primary Key(s)
    for i in 0..aryPrimaryKeyList.size-1

      ## Create SQL
      strSQL = ''
      strSQL = strSQL + 'ALTER TABLE '
      strSQL = strSQL +   'TBL_T_METADATA '
      strSQL = strSQL + 'DROP CONSTRAINT '
      strSQL = strSQL +   @charutil.sqlEncode(aryPrimaryKeyList[i])

      ## Debug
      @log.debug("Metadata.rb#dropKeys: strSQL = [" + strSQL + "]")

      ## Exec Transaction
      @stdout.info("START: Dropping Primary Key [" + aryPrimaryKeyList[i] + "] on [TBL_T_METADATA] <== Watch the Processing Time!!")
      strResultCode, result = $db.exUpdateDB2(strSQL)
      @stdout.info("END: Dropping Primary Key [" + aryPrimaryKeyList[i] + "] on [TBL_T_METADATA] <== Watch the Processing Time!!")

      ## Clear Result
      if result != nil
        result.clear
      end

      ## Error Trap
      if strResultCode != ResultCode::NORMAL
        @stdout.error("Metadata.rb#dropKeys: SQL Error on Dropping Primary-Keys on Metadata Table! strSQL = [" + strSQL.to_s + "]")
        return strResultCode
      end

    end

    ## Drop Index Key(s)
    for i in 0..aryIndexKeyList.size-1

      ## Create SQL
      strSQL = ''
      strSQL = strSQL + 'DROP INDEX '
      strSQL = strSQL +   @charutil.sqlEncode(aryIndexKeyList[i])

      ## Debug
      @log.debug("Metadata.rb#dropKeys: strSQL = [" + strSQL + "]")

      ## Exec Transaction
      @stdout.info("START: Dropping Index Key [" + aryIndexKeyList[i] + "] on [TBL_T_METADATA] <== Watch the Processing Time!!")
      strResultCode, result = $db.exUpdateDB2(strSQL)
      @stdout.info("END: Dropping Index Key [" + aryIndexKeyList[i] + "] on [TBL_T_METADATA] <== Watch the Processing Time!!")

      ## Clear Result
      if result != nil
        result.clear
      end

      ## Error Trap
      if strResultCode != ResultCode::NORMAL
        @stdout.error("Metadata.rb#dropKeys: SQL Error on Dropping Index-Keys on Metadata Table! strSQL = [" + strSQL.to_s + "]")
        return strResultCode
      end

    end

    ## Clear Array
    aryPrimaryKeyList.clear
    aryIndexKeyList.clear

    #### Debug ####
    @log.debug("END: Metadata.rb#dropKeys")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] restore                                                 ##
  ## ---------------------------------------------------------------- ##
  def restore

    #### Debug ####
    @log.debug("START: Metadata.rb#restore")

    #### Define ####
    ## Classes
    date = Date.new
    ## Variables
    strResultCode = ResultCode::NORMAL
    strResourceTypeIDMetadata = "2"

    #### Exec ####

    ## Debug
    @stdout.info("START: Selecting Metadata from the DSpace-DB. <== Watch the Processing Time!!")

    ## Create SQL
    strSQL = ''
    strSQL = strSQL + 'SELECT '
    strSQL = strSQL +   'H.HANDLE_ID     AS HANDLE_ID, '
    strSQL = strSQL +   'MDV.TEXT_VALUE  AS RESOURCE_ID, '
    strSQL = strSQL +   'I.OWNING_COLLECTION AS OWNING_COLLECTION, '
    strSQL = strSQL +   'MDV.ITEM_ID     AS ITEM_ID '
    strSQL = strSQL + 'FROM '
    strSQL = strSQL +   'METADATAVALUE AS MDV, '
    strSQL = strSQL +   'HANDLE AS H, '
    strSQL = strSQL +   'ITEM AS I '
    strSQL = strSQL + 'WHERE '
    strSQL = strSQL +   'MDV.ITEM_ID = H.RESOURCE_ID '
    strSQL = strSQL + 'AND '
    strSQL = strSQL +   'MDV.ITEM_ID = I.ITEM_ID '
    strSQL = strSQL + 'AND '
    strSQL = strSQL +   'MDV.METADATA_FIELD_ID '
    strSQL = strSQL +     'IN( '
    strSQL = strSQL +       'SELECT '
    strSQL = strSQL +         'MDR.METADATA_FIELD_ID '
    strSQL = strSQL +       'FROM '
    strSQL = strSQL +         'METADATAFIELDREGISTRY AS MDR '
    strSQL = strSQL +       'WHERE '
    strSQL = strSQL +         'MDR.QUALIFIER = \'ResourceID\' '
    strSQL = strSQL +     ') '
    strSQL = strSQL + 'AND '
    strSQL = strSQL +   'H.RESOURCE_TYPE_ID = \'' + @charutil.sqlEncode(strResourceTypeIDMetadata) + '\' '

    ## Debug
    @log.debug("Metadata.rb#restore: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    strResultCode, result = $db.exQueryDB1(strSQL)

    ## Debug
    @stdout.info("END: Selecting Metadata from the DSpace-DB. <== Watch the Processing Time!!")

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("Metadata.rb#restore: SQL Error on Selecting Collection! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end
    if result == nil
      @stdout.error("Metadata.rb#restore: SQL Error on Selecting Collection! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end

    ## Write to Temporary File
    ## NOTE:
    ##  Too Late When Add 'date.getNow', 'gsub' and '@charutil.sqlEndode'
    ##  in this Loop, So Do Not Add That.
    ## ex. (per 1,000,000 Metadatas on Dev_Machine):
    ##  - Add Nothing                  :   4.287 [sec]
    ##  - Add '@charutil.sqlencode'    :  22.667 [sec]
    ##  - Add 'date.getNow' and 'gsub' :  78.669 [sec]
    ##  - Add All                      : 106.399 [sec]
    ## Create Directory
    FileUtils.mkdir_p(Configure::FILEDIR1) unless File.exist?(Configure::FILEDIR1)
    ## Create TmpDate
    strNowDateTmp = date.getNow("%Y%m%d")
    strNowTimeTmp = date.getNow("%H:%M:%S").gsub(/:/, "")
    begin
      ## Debug
      @stdout.info("START: Writing the Metadata to Temporary File. <== Watch the Processing Time!!")
      ## Write
      open(Configure::FILE_TBL_T_METADATA, "w") do |outf|
        ## Analyze Result
        result.each do |res|
          ## Set to File
          outf.print res['handle_id'], ","
          outf.print res['resource_id'], ","
          outf.print res['owning_collection'], ","
          outf.print res['item_id'], ","
          outf.print "0", ","
          outf.print strNowDateTmp, ","
          outf.print strNowTimeTmp, ","
          outf.print "", ","
          outf.print ""
          outf.puts
        end
      end
=begin
      open(Configure::FILE_TBL_T_METADATA, "w") do |outf|
        ## Analyze Result
        result.each do |res|
          ## Set to File
          outf.print @charutil.sqlEncode(res['handle_id']), ","
          outf.print @charutil.sqlEncode(res['resource_id']), ","
          outf.print @charutil.sqlEncode(res['owning_collection']), ","
          outf.print @charutil.sqlEncode(res['item_id']), ","
          outf.print @charutil.sqlEncode("0"), ","
          outf.print @charutil.sqlEncode(date.getNow("%Y%m%d")), ","
          outf.print @charutil.sqlEncode(date.getNow("%H:%M:%S").gsub(/:/, "")), ","
          outf.print @charutil.sqlEncode(""), ","
          outf.print @charutil.sqlEncode("")
          outf.puts
        end
      end
=end
      ## Debug
      @stdout.info("END: Writing the Metadata to Temporary File. <== Watch the Processing Time!!")
    ## on Error
    rescue => e
      strResultCode = ResultCode::FILEIOERROR
      @stdout.error("Metadata.rb#restore: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    ## Clear Result
    result.clear

    #### Debug ####
    @log.debug("END: Metadata.rb#restore")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] regist                                                  ##
  ## ---------------------------------------------------------------- ##
  def regist(strExecCode)

    #### Debug ####
    @log.debug("START: Metadata.rb#regist")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####

    ## Connect DB (Using Admin User)
    strResultCode = $db.openDB2Admin
    if strResultCode != ResultCode::NORMAL
      return ResultCode::DBOPEN_ERROR
    end

    ## Create SQL
    strSQL = ''
    strSQL = strSQL + 'COPY '
    strSQL = strSQL +   'TBL_T_METADATA '
    strSQL = strSQL + 'FROM '
    strSQL = strSQL +   '\'' + @charutil.sqlEncode(Configure::FILE_TBL_T_METADATA) + '\' '
    strSQL = strSQL + 'WITH '
    strSQL = strSQL +   'DELIMITER \',\' '
    strSQL = strSQL +   'NULL \'#\' '

    ## Debug
    @log.debug("Metadata.rb#regist: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    @stdout.info("START: Restoring the Metadata to Admin-DB. <== Watch the Processing Time!!")
    strResultCode, result = $db.exUpdateDB2Admin(strSQL)
    @stdout.info("END: Restoring the Metadata to Admin-DB. <== Watch the Processing Time!!")

    ## Clear Result
    if result != nil
      result.clear
    end

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("Metadata.rb#regist: SQL Error on Registing Metadata to Admin-DB! strSQL = [" + strSQL.to_s + "]")
    end

    ## Close DB (Using Admin User)
    strResultCode = $db.closeDB2Admin

    #### Debug ####
    @log.debug("END: Metadata.rb#regist")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] createKeys                                              ##
  ## ---------------------------------------------------------------- ##
  def createKeys

    #### Debug ####
    @log.debug("START: Metadata.rb#createKeys")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    aryPrimaryKeyList = Array.new
    aryIndexKeyList   = Array.new

    ## Set Key List (Column Name)
    aryPrimaryKeyList << 'HANDLE_ID'
    aryIndexKeyList   << 'IDX_RESOURCE_ID_ON_TBL_T_METADATA'

    ## Create Primary Key(s)
    for i in 0..aryPrimaryKeyList.size-1

      ## Create SQL
      strSQL = ''
      strSQL = strSQL + 'ALTER TABLE '
      strSQL = strSQL +   'TBL_T_METADATA '
      strSQL = strSQL + 'ADD PRIMARY KEY('
      strSQL = strSQL +   @charutil.sqlEncode(aryPrimaryKeyList[i])
      strSQL = strSQL + ') '

      ## Debug
      @log.debug("Metadata.rb#createKeys: strSQL = [" + strSQL + "]")

      ## Exec Transaction
      @stdout.info("START: Creating Primary Key [" + aryPrimaryKeyList[i] + "] on [TBL_T_METADATA] <== Watch the Processing Time!!")
      strResultCode, result = $db.exUpdateDB2(strSQL)
      @stdout.info("END: Creating Primary Key [" + aryPrimaryKeyList[i] + "] on [TBL_T_METADATA] <== Watch the Processing Time!!")

      ## Clear Result
      if result != nil
        result.clear
      end

      ## Error Trap
      if strResultCode != ResultCode::NORMAL
        @stdout.error("Metadata.rb#createKeys: SQL Error on Creating Primary Keys to Admin-DB! strSQL = [" + strSQL.to_s + "]")
        return strResultCode
      end

    end

    ## Create Index Key(s)
    for i in 0..aryIndexKeyList.size-1

      ## Create SQL
      strSQL = ''
      strSQL = strSQL + 'CREATE INDEX '
      strSQL = strSQL +   @charutil.sqlEncode(aryIndexKeyList[i]) + ' '
      strSQL = strSQL + 'ON '
      strSQL = strSQL +   'TBL_T_METADATA(RESOURCE_ID) '

      ## Debug
      @log.debug("Metadata.rb#createKeys: strSQL = [" + strSQL + "]")

      ## Exec Transaction
      @stdout.info("START: Creating Index Key [" + aryIndexKeyList[i] + "] on [TBL_T_METADATA] <== Watch the Processing Time!!")
      strResultCode, result = $db.exUpdateDB2(strSQL)
      @stdout.info("END: Creating Index Key [" + aryIndexKeyList[i] + "] on [TBL_T_METADATA] <== Watch the Processing Time!!")

      ## Clear Result
      if result != nil
        result.clear
      end

      ## Error Trap
      if strResultCode != ResultCode::NORMAL
        @stdout.error("Metadata.rb#createKeys: SQL Error on Creating Index Keys to Admin-DB! strSQL = [" + strSQL.to_s + "]")
        return strResultCode
      end

    end

    ## Clear Array
    aryPrimaryKeyList.clear
    aryIndexKeyList.clear

    #### Debug ####
    @log.debug("END: Metadata.rb#createKeys")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] search                                                  ##
  ## ---------------------------------------------------------------- ##
  def search(strExecCode)

    #### Debug ####
#   @log.debug("START: Metadata.rb#search")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Check ####
    ## Search: GET_FROM_RESOURCEID
    if strExecCode == GET_FROM_RESOURCEID
      ## strResourceID
      if @strResourceID == nil
        @log.error("Metadata.rb#search: Parameter Error. strResourceID is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strResourceID.strip == ""
        @log.error("Metadata.rb#search: Parameter Error. strResourceID is BLANK.")
        return ResultCode::PARAMETER_ERROR
      end
    end

    #### Exec ####
    ## Clear Array
    clear

    ## Create SQL
    strSQL = ''
    strSQL = strSQL + 'SELECT '
    strSQL = strSQL +   'M.HANDLE_ID         AS HANDLE_ID, '
    strSQL = strSQL +   'M.RESOURCE_ID       AS RESOURCE_ID, '
    strSQL = strSQL +   'M.OWNING_COLLECTION AS OWNING_COLLECTION, '
    strSQL = strSQL +   'M.ITEM_ID           AS ITEM_ID, '
    strSQL = strSQL +   'M.DEL_FLAG   AS DEL_FLAG, '
    strSQL = strSQL +   'M.RCDNEWDATE AS RCDNEWDATE, '
    strSQL = strSQL +   'M.RCDNEWTIME AS RCDNEWTIME, '
    strSQL = strSQL +   'M.RCDMDFDATE AS RCDMDFDATE, '
    strSQL = strSQL +   'M.RCDMDFTIME AS RCDMDFTIME '
    strSQL = strSQL + 'FROM '
    strSQL = strSQL +   'TBL_T_METADATA AS M '
    ## Where
    if strExecCode == GET_FROM_RESOURCEID
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'M.RESOURCE_ID = \'' + @charutil.sqlEncode(@strResourceID) + '\' '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'M.DEL_FLAG = \'0\' '
    end
    ## Order By
    strSQL = strSQL + 'ORDER BY '
    strSQL = strSQL +   'M.HANDLE_ID ASC '

    ## Debug
    @log.debug("Metadata.rb#search: strSQL = [" + strSQL + "]")

    ## Exec Transaction
    strResultCode, result = $db.exQueryDB2(strSQL)

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("Metadata.rb#search: SQL Error on Selecting Metadata! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end
    if result == nil
      @stdout.error("Metadata.rb#search: SQL Error on Selecting Metadata! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end

    ## Analyze Result
    result.each do |res|
      ## Set Results
      @aryHandleIDSuffix   << res['handle_id'].to_s.strip
      @aryResourceID       << res['resource_id'].to_s.strip
      @aryOwningCollection << res['owning_collection'].to_s.strip
      @aryItemID           << res['item_id'].to_s.strip
      @aryDelFlag          << res['del_flag'].to_s.strip
      @aryRcdNewDate       << res['rcdnewdate'].to_s.strip
      @aryRcdNewTime       << res['rcdnewtime'].to_s.strip
      @aryRcdMdfDate       << res['rcdmdfdate'].to_s.strip
      @aryRcdMdfTime       << res['rcdmdftime'].to_s.strip
    end

    ## Set Hits Count
    @intHitsCount = @aryHandleIDSuffix.size

    ## Clear Result
    result.clear

    #### Debug ####
#   @log.debug("END: Metadata.rb#search")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [API-method] setResourceID                                       ##
  ## ---------------------------------------------------------------- ##
  def setResourceID(strResourceID)
    @strResourceID = strResourceID
  end


  ## ---------------------------------------------------------------- ##
  ## [API-method] getHitsCount                                        ##
  ## ---------------------------------------------------------------- ##
  def getHitsCount
    return @intHitsCount
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getHandleIDSuffix                                   ##
  ## ---------------------------------------------------------------- ##
  def getHandleIDSuffix
    return @aryHandleIDSuffix
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getResourceID                                       ##
  ## ---------------------------------------------------------------- ##
  def getResourceID
    return @aryResourceID
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getOwningCollection                                 ##
  ## ---------------------------------------------------------------- ##
  def getOwningCollection
    return @aryOwningCollection
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getItemID                                           ##
  ## ---------------------------------------------------------------- ##
  def getItemID
    return @aryItemID
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
