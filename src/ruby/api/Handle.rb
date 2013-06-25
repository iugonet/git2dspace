# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [Handle.rb]                                                        ##
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

class Handle


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##
  #### ExecCode (Private Key)
  ## Search
  GET_FROM_HANDLEID  = '2006101'
  GET_FROM_HANDLEID_AND_RESOURCETYPEID = '2006102'

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
    @aryHandleID       = Array.new
    @aryHandleIDSuffix = Array.new
    @aryResourceTypeID = Array.new
    @aryResourceID     = Array.new
    ## Variables (For API Functions)
    @strHandleIDSuffix = ""
    @strResourceTypeID = ""

  end


  ## ---------------------------------------------------------------- ##
  ## [method] clear                                                   ##
  ## ---------------------------------------------------------------- ##
  def clear

    #### Exec ####
    ## Variables (For SQL Results)
    @intHitsCount = 0
    @aryHandleID.clear
    @aryHandleIDSuffix.clear
    @aryResourceTypeID.clear
    @aryResourceID.clear

  end


  ## ---------------------------------------------------------------- ##
  ## [method] exec                                                    ##
  ## ---------------------------------------------------------------- ##
  def exec(strExecCode)

    #### Debug ####
    @log.debug("START: Handle.rb#exec")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Search: GET_FROM_HANDLEID
    if strExecCode == GET_FROM_HANDLEID
      strResultCode = search(strExecCode)
    ## Search: GET_FROM_HANDLEID_AND_RESOURCETYPEID
    elsif strExecCode == GET_FROM_HANDLEID_AND_RESOURCETYPEID
      strResultCode = search(strExecCode)
    ## Error
    else
      @log.error("Handle.rb#exec: Undefined ExecCode was Given.")
      strResultCode = ResultCode::EXECCODE_ERROR
    end

    #### Debug ####
    @log.debug("END: Handle.rb#exec")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] search                                                  ##
  ## ---------------------------------------------------------------- ##
  def search(strExecCode)

    #### Debug ####
    @log.debug("START: Handle.rb#search")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Check ####
    ## SEARCH: GET_FROM_HANDLEID
    if strExecCode == GET_FROM_HANDLEID
      ## @strHandleIDSuffix
      if @strHandleIDSuffix == nil
        @log.error("Handle.rb#search: Parameter Error. strHandleIDSuffix is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strHandleIDSuffix.strip == ""
        @log.error("Handle.rb#search: Parameter Error. strHandleIDSuffix is BLANK.")
        return ResultCode::PARAMETER_ERROR
      elsif not @strHandleIDSuffix.strip =~ /^[0-9]+$/
        @log.error("Handle.rb#search: Parameter Error. strHandleIDSuffix is Not Numeric.")
        return ResultCode::PARAMETER_ERROR
      end
    ## SEARCH: GET_FROM_HANDLEID_AND_RESOURCETYPEID
    elsif strExecCode == GET_FROM_HANDLEID_AND_RESOURCETYPEID
      ## @strHandleIDSuffix
      if @strHandleIDSuffix == nil
        @log.error("Handle.rb#search: Parameter Error. strHandleIDSuffix is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strHandleIDSuffix.strip == ""
        @log.error("Handle.rb#search: Parameter Error. strHandleIDSuffix is BLANK.")
        return ResultCode::PARAMETER_ERROR
      elsif not @strHandleIDSuffix.strip =~ /^[0-9]+$/
        @log.error("Handle.rb#search: Parameter Error. strHandleIDSuffix is Not Numeric.")
        return ResultCode::PARAMETER_ERROR
      end
      ## @strResourceTypeID
      if @strResourceTypeID == nil
        @log.error("Handle.rb#search: Parameter Error. strResourceTypeID is NIL.")
        return ResultCode::PARAMETER_ERROR
      elsif @strResourceTypeID.strip == ""
        @log.error("Handle.rb#search: Parameter Error. strResourceTypeID is BLANK.")
        return ResultCode::PARAMETER_ERROR
      elsif not @strResourceTypeID.strip =~ /^[0-9]+$/
        @log.error("Handle.rb#search: Parameter Error. strResourceTypeID is Not Numeric.")
        return ResultCode::PARAMETER_ERROR
      end
    end

    #### Exec ####

    ## Clear Array
    clear

    ## Create SQL
    strSQL = ''
    strSQL = strSQL + 'SELECT '
    strSQL = strSQL +   'HANDLE_ID AS HANDLE_ID, '
    strSQL = strSQL +   'HANDLE    AS HANDLE, '
    strSQL = strSQL +   'RESOURCE_TYPE_ID AS RESOURCE_TYPE_ID, '
    strSQL = strSQL +   'RESOURCE_ID      AS RESOURCE_ID '
    strSQL = strSQL + 'FROM '
    strSQL = strSQL +   'HANDLE '
    ## Where
    if strExecCode == GET_FROM_HANDLEID
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'HANDLE_ID = \'' + @charutil.sqlEncode(@strHandleIDSuffix) + '\' '
    elsif strExecCode == GET_FROM_HANDLEID_AND_RESOURCETYPEID
      strSQL = strSQL + 'WHERE '
      strSQL = strSQL +   'HANDLE_ID = \'' + @charutil.sqlEncode(@strHandleIDSuffix) + '\' '
      strSQL = strSQL + 'AND '
      strSQL = strSQL +   'RESOURCE_TYPE_ID = \'' + @charutil.sqlEncode(@strResourceTypeID) + '\' '
    end
    ## Order by
    strSQL = strSQL + 'ORDER BY '
    strSQL = strSQL +   'HANDLE_ID ASC '

    ## Debug
    @log.debug("Handle.rb#search: strSQL = [" + strSQL + "]")

    ## Exec Transaction
#   @log.debug("START: Searching Handles from the DSpace-DB. <== Watch the Processing Time!!")
    strResultCode, result = $db.exQueryDB1(strSQL)
#   @log.debug("END: Searching Handles from the DSpace-DB. <== Watch the Processing Time!!")

    ## Error Trap
    if strResultCode != ResultCode::NORMAL
      @stdout.error("Handle.rb#search: SQL Error on Selecting Collection! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end
    if result == nil
      @stdout.error("Handle.rb#search: SQL Error on Selecting Collection! strSQL = [" + strSQL.to_s + "]")
      return ResultCode::SQL_ERROR
    end

    ## Analyze Result
    result.each do |res|
      ## Set Result
      @aryHandleID       << res['handle_id'].to_s.strip
      @aryHandleIDSuffix << res['handle'].to_s.strip
      @aryResourceTypeID << res['resource_type_id'].to_s.strip
      @aryResourceID     << res['resource_id'].to_s.strip
    end

    ## Set Hits Count
    @intHitsCount = @aryHandleID.size

    ## Clear
    result.clear

    #### Debug ####
    @log.debug("END: Handle.rb#search")

    #### Return ####
    return strResultCode

  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setHandleIDSuffix                                   ##
  ## ---------------------------------------------------------------- ##
  def setHandleIDSuffix(strHandleIDSuffix)
    @strHandleIDSuffix = strHandleIDSuffix
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] setResourceTypeID                                   ##
  ## ---------------------------------------------------------------- ##
  def setResourceTypeID(strResourceTypeID)
    @strResourceTypeID = strResourceTypeID
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getHitsCount                                        ##
  ## ---------------------------------------------------------------- ##
  def getHitsCount
    return @intHitsCount
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getHandleID                                         ##
  ## ---------------------------------------------------------------- ##
  def getHandleID
    return @aryHandleID
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getHandleIDSuffix                                   ##
  ## ---------------------------------------------------------------- ##
  def getHandleIDSuffix
    return @aryHandleIDSuffix
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getResourceTypeID                                   ##
  ## ---------------------------------------------------------------- ##
  def getResourceTypeID
    return @aryResourceTypeID
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getResourceID                                       ##
  ## ---------------------------------------------------------------- ##
  def getResourceID
    return @aryResourceID
  end


end
