# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [DBAccess.rb]                                                      ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './conf/Configure'
require './conf/ResultCode'
require './lib/Log'
require './lib/LogStdOut'
require 'pg'

class DBAccess


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##


  ## ---------------------------------------------------------------- ##
  ## [method] initialize                                              ##
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
  end


  ## ---------------------------------------------------------------- ##
  ## [method] openDB1                                                 ##
  ## ---------------------------------------------------------------- ##
  def openDB1

    #### Debug ####
    @log.debug("START: DBAccess.rb#openDB1 --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      @connection1 = PGconn.connect(Configure::DB1_IP, Configure::DB1_PORT, "", "",
         Configure::DB1_NAME, Configure::DB1_USER, Configure::DB1_PASSWD)
      @log.info("DBAccess.rb#openDB1: Open Database [" + Configure::DB1_NAME + "]")
    ## on Error
    rescue => e
      strResultCode = ResultCode::DBOPEN_ERROR
      @stdout.fatal("DBAccess.rb#openDB1: Cannot Open Database [" + Configure::DB1_NAME + "]")
      @stdout.fatal(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
    @log.debug("END: DBAccess.rb#openDB1 --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] openDB2                                                 ##
  ## ---------------------------------------------------------------- ##
  def openDB2

    #### Debug ####
    @log.debug("START: DBAccess.rb#openDB2 --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      @connection2 = PGconn.connect(Configure::DB2_IP, Configure::DB2_PORT, "", "",
         Configure::DB2_NAME, Configure::DB2_USER, Configure::DB2_PASSWD)
      @log.info("DBAccess.rb#openDB2: Open Database [" + Configure::DB2_NAME + "]")
    ## on Error
    rescue => e
      strResultCode = ResultCode::DBOPEN_ERROR
      @stdout.fatal("DBAccess.rb#openDB2: Cannot Open Database [" + Configure::DB2_NAME + "]")
      @stdout.fatal(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
    @log.debug("END: DBAccess.rb#openDB2 --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] openDB2Admin                                            ##
  ## ---------------------------------------------------------------- ##
  def openDB2Admin

    #### Debug ####
    @log.debug("START: DBAccess.rb#openDB2Admin --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      @connection2admin = PGconn.connect(Configure::DB2_IP, Configure::DB2_PORT, "", "",
         Configure::DB2_NAME, Configure::DB2_USER_ADMIN, Configure::DB2_PASSWD_ADMIN)
      @log.info("DBAccess.rb#openDB2Admin: Open Database [" + Configure::DB2_NAME + "(Admin)]")
    ## on Error
    rescue => e
      strResultCode = ResultCode::DBOPEN_ERROR
      @stdout.fatal("DBAccess.rb#openDB2Admin: Cannot Open Database Using Admin-User [" + Configure::DB2_NAME + "(Admin)]")
      @stdout.fatal(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
    @log.debug("END: DBAccess.rb#openDB2Admin --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] closeDB1                                                ##
  ## ---------------------------------------------------------------- ##
  def closeDB1

    #### Debug ####
    @log.debug("START: DBAccess.rb#closeDB1 --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      @connection1.close
      @log.info("DBAccess.rb#closeDB1: Close Database [" + Configure::DB1_NAME + "]")
    ## on Error
    rescue => e
      strResultCode = ResultCode::DBCLOSE_ERROR
      @stdout.fatal("DBAccess.rb#closeDB1: Cannot Close Database [" + Configure::DB1_NAME + "]")
      @stdout.fatal(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
    @log.debug("END: DBAccess.rb#closeDB1 --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] closeDB2                                                ##
  ## ---------------------------------------------------------------- ##
  def closeDB2

    #### Debug ####
    @log.debug("START: DBAccess.rb#closeDB2 --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      @connection2.close
      @log.info("DBAccess.rb#closeDB2: Close Database [" + Configure::DB2_NAME + "]")
    ## on Error
    rescue => e
      strResultCode = ResultCode::DBCLOSE_ERROR
      @stdout.fatal("DBAccess.rb#closeDB2: Cannot Close Database [" + Configure::DB2_NAME + "]")
      @stdout.fatal(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
    @log.debug("END: DBAccess.rb#closeDB2 --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] closeDB2Admin                                           ##
  ## ---------------------------------------------------------------- ##
  def closeDB2Admin

    #### Debug ####
    @log.debug("START: DBAccess.rb#closeDB2Admin --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      @connection2admin.close
      @log.info("DBAccess.rb#closeDB2Admin: Close Database [" + Configure::DB2_NAME + "(Admin)]")
    ## on Error
    rescue => e
      strResultCode = ResultCode::DBCLOSE_ERROR
      @stdout.fatal("DBAccess.rb#closeDB2Admin: Cannot Close Database [" + Configure::DB2_NAME + "(Admin)]")
      @stdout.fatal(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
    @log.debug("END: DBAccess.rb#closeDB2Admin --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] exQueryDB1                                              ##
  ## ---------------------------------------------------------------- ##
  def exQueryDB1(strSQL)

    #### Debug ####
#   @log.debug("START: DBAccess.rb#exQueryDB1 --------")

    #### Check ####
    ## strSQL
    if strSQL == nil
      @stdout.error("DBAccess.rb#exQueryDB1: DBAccess.rb#exQueryDB1: strSQL is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strSQL.strip == ""
      @stdout.error("DBAccess.rb#exQueryDB1: strSQL is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL
    result = nil

    #### Exec ####
    begin
#     @log.debug("DBAccess.rb#exQueryDB1: strSQL = [" + strSQL.to_s + "]")
      result = @connection1.exec strSQL.to_s
    ## on Error
    rescue => e
      strResultCode = ResultCode::SQL_ERROR
      @stdout.error("DBAccess.rb#exQueryDB1: Invalid SQL! strSQL = [" + strSQL.to_s + "]")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
#   @log.debug("END: DBAccess.rb#exQueryDB1 --------")

    #### Return ####
    return strResultCode, result

  end


  ## ---------------------------------------------------------------- ##
  ## [method] exQueryDB2                                              ##
  ## ---------------------------------------------------------------- ##
  def exQueryDB2(strSQL)

    #### Debug ####
#   @log.debug("START: DBAccess.rb#exQueryDB2 --------")

    #### Check ####
    ## strSQL
    if strSQL == nil
      @stdout.error("DBAccess.rb#exQueryDB2: strSQL is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strSQL.strip == ""
      @stdout.error("DBAccess.rb#exQueryDB2: strSQL is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL
    result = nil

    #### Exec ####
    begin
#     @log.debug("DBAccess.rb#exQueryDB2: strSQL = [" + strSQL.to_s + "]")
      result = @connection2.exec strSQL
    ## on Error
    rescue => e
      strResultCode = ResultCode::SQL_ERROR
      @stdout.error("DBAccess.rb#exQueryDB2: Invalid SQL! strSQL = [" + strSQL.to_s + "]")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
#   @log.debug("END: DBAccess.rb#exQueryDB2 --------")

    #### Return ####
    return strResultCode, result

  end


  ## ---------------------------------------------------------------- ##
  ## [method] exUpdateDB2                                             ##
  ## ---------------------------------------------------------------- ##
  def exUpdateDB2(strSQL)

    #### Debug ####
#   @log.debug("START: DBAccess.rb#exUpdateDB2 --------")

    #### Check ####
    ## strSQL
    if strSQL == nil
      @stdout.error("DBAccess.rb#exUpdateDB2: strSQL is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strSQL.strip == ""
      @stdout.error("DBAccess.rb#exUpdateDB2: strSQL is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL
    result = nil

    #### Exec ####
    begin
#     @log.debug("DBAccess.rb#exUpdateDB2: strSQL = [" + strSQL.to_s + "]")
      result = @connection2.exec strSQL
    ## on Error
    rescue => e
      strResultCode = ResultCode::SQL_ERROR
      @stdout.error("DBAccess.rb#exUpdateDB2: Invalid SQL! strSQL = [" + strSQL.to_s + "]")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
#   @log.debug("END: DBAccess.rb#exUpdateDB2 --------")

    #### Return ####
    return strResultCode, result

  end


  ## ---------------------------------------------------------------- ##
  ## [method] exUpdateDB2Admin                                        ##
  ## ---------------------------------------------------------------- ##
  def exUpdateDB2Admin(strSQL)

    #### Debug ####
#   @log.debug("START: DBAccess.rb#exUpdateDB2Admin --------")

    #### Check ####
    ## strSQL
    if strSQL == nil
      @stdout.error("DBAccess.rb#exUpdateDB2Admin: strSQL is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strSQL.strip == ""
      @stdout.error("DBAccess.rb#exUpdateDB2Admin: strSQL is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL
    result = nil

    #### Exec ####
    begin
#     @log.debug("DBAccess.rb#exUpdateDB2Admin: strSQL = [" + strSQL.to_s + "]")
      result = @connection2admin.exec strSQL
    ## on Error
    rescue => e
      strResultCode = ResultCode::SQL_ERROR
      @stdout.error("DBAccess.rb#exUpdateDB2Admin: Invalid SQL! strSQL = [" + strSQL.to_s + "]")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
#   @log.debug("END: DBAccess.rb#exUpdateDB2Admin --------")

    #### Return ####
    return strResultCode, result

  end


end
