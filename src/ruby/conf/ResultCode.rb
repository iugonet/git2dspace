# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [ResultCode.rb]                                                    ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

class ResultCode


  #### [COMMON] ########################################################

  #### NORMAL ####
  NORMAL           = "000"

  #### PARAMETERS ####
  PARAMETER_ERROR  = "011"
  ## NOTE ##
  # - PARAMETE_ERROR: INVALID PARAMETER

  #### EXECCODE ####
  EXECCODE_ERROR   = "016"
  ## NOTE ##
  # - EXECCODE_ERROR: UNDEFINED CODE

  #### DB ####
  DBOPEN_ERROR     = "021"
  DBCLOSE_ERROR    = "022"
  SQL_ERROR        = "026"
  ## NOTE ##
  # - DBOPEN_ERROR  : CANNOT CONNECT DATABASE
  # - DBCLOSE_ERROR : CANNOT CLOSE DATABASE
  # - SQL ERROR     : INVALID SQL QUERY

  #### FILE ####
  FILEIOERROR      = "031"
  FILENOTFOUND     = "032"
  ## NOTE ##
  # - FILEIOERROR  : FILE I/O ERROR
  # - FILENOTFOUND : FILE NOT FOUND

  #### XML ####
  CONVERT_ERROR    = "041"
  XML_CREATE_ERROR = "042"
  ## NOTE ##
  # - CONVERT_ERROR    : CANNOT CONVERT XML
  # - XML_CREATE_ERROR : CANNOT CREATE XML DOCUMENT


  #### [API: REPOSITORY] ###############################################
  REPOSITORY_NOTFOUND     = "050"
  REPOSITORY_SYSTEM_ERROR = "059"
  ## NOTE ##
  # - REPOSITORY_NOTFOUND     : NO REPOSITORY TO REGISTER
  # - REPOSITORY_SYSTEM_ERROR : OTHER ERROR


  #### [API: COMMUNITY] ################################################
  COMMUNITY_NOTFOUND             = "060"
  COMMUNITY_REGIST_ERROR_DSPACE  = "061"
  COMMUNITY_REGIST_ERROR_ADMINDB = "062"
  COMMUNITY_SYSTEM_ERROR         = "069"
  ## NOTE ##
  # - COMMUNITY_NOTFOUND            : NO COMMUNITY TO MATCH
  # - COMMUNITY_REGIST_ERROR_DSPACE : CANNOT REGIST COMMUNITY TO DSPACE
  # - COMMUNITY_REGIST_ERROR_DSPACE : CANNOT REGIST COMMUNITY TO ADMIN-DB
  # - COMMUNITY_SYSTEM_ERROR        : OTHER ERROR


  #### [API: COLLECTION] ###############################################
  COLLECTION_NOTFOUND             = "070"
  COLLECTION_REGIST_ERROR_DSPACE  = "071"
  COLLECTION_REGIST_ERROR_ADMINDB = "072"
  COLLECTION_SYSTEM_ERROR         = "079"
  ## NOTE ##
  # - COLLECTION_NOTFOUND     : NO COLLECTION TO MATCH
  # - COLLECTION_REGIST_ERROR_DSPACE : CANNOT REGIST COLLECTION TO DSPACE
  # - COLLECTION_REGIST_ERROR_DSPACE : CANNOT REGIST COLLECTION TO ADMIN-DB
  # - COLLECTION_SYSTEM_ERROR : OTHER ERROR


  #### [API: METADATA] #################################################
  METADATA_NOTFOUND       = "080"
  METADATA_SYSTEM_ERROR   = "089"
  ## NOTE ##
  # - METADATA_NOTFOUND     : NO METADATA ON DSPACE
  # - METADATA_SYSTEM_ERROR : OTHER ERROR


  #### [API: HANDLE] ###################################################
  HANDLE_NOTFOUND       = "090"
  HANDLE_SYSTEM_ERROR   = "099"
  ## NOTE ##
  # - HANDLE_NOTFOUND     : NO RECORD ON DSPACE
  # - HANDLE_SYSTEM_ERROR : OTHER ERROR


  ## ---------------------------------------------------------------- ##
  ## [initialize]                                                     ##
  ## ---------------------------------------------------------------- ##
  def initialize
  end


end

