# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [Configure.rb]                                                     ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

class Configure


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##

  #### [VARIABLE PARAMETERS] ###########################################

  #### COMMAND PATH ####  
  ## SET PATH ACCORDING TO YOUR ENVIRONMENT.
  COMMAND_GIT  = "git"
# COMMAND_GIT  = "/usr/bin/git"
  COMMAND_FIND = "find"
# COMMAND_FIND = "/usr/bin/find"
  DSPACE_IMPORT = "/opt/dspace/bin/import"
  DSPACE_STRUCTURE = "/opt/dspace/bin/structure-builder"

  #### LOG ####
  ## SET LOG PARAMETERS,
  ## NOTE:
  ##  - LOG_FLAG : true or false
  ##  - LOG_LEVEL: in (FATAL, ERROR, WARN, INFO, DEBUG)
  LOG_FLAG   = true
  LOG_LEVEL  = 'DEBUG'

  #### DATABASE #1 ####
  ## SET DATABASE CONFIGURE (DSPACE)
  DB1_NAME   = 'dspace'
  DB1_IP     = 'localhost'
  DB1_PORT   = '5432'
  DB1_USER   = 'dspace'
  DB1_PASSWD = 'dspace'

  #### DATABASE #2 ####
  ## SET DATABASE CONFIGURE (ADMIN-DB: G2D ORIGINAL)
  DB2_NAME   = 'g2d'
  DB2_IP     = 'localhost'
  DB2_PORT   = '5432'
  DB2_USER   = 'dspace'
  DB2_PASSWD = 'dspace'
  DB2_USER_ADMIN = 'pgsql'
  DB2_PASSWD_ADMIN = ''

  #### DATABASE ADMINISTRATOR (FOR DSPACE) ####
  ## SET ADMINISTRATOR'S E-MAIL ADDRESS
  DSPACE_DB_ADMIN = 'umemura@stelab.nagoya-u.ac.jp'



  #### [INVARIABLE PARAMETERS] #########################################

  #### ENV ####
  RUBYDIR    = Dir::pwd
  G2DDIR     = RUBYDIR.gsub("/src/ruby", "")
  LOGDIR     = File.join(G2DDIR, "log")
  CONFDIR    = File.join(G2DDIR, "conf")
  SHELLDIR   = File.join(G2DDIR, "src/shell")
  MDDIR1     = File.join(G2DDIR, "WorkDir/Metadata")
# MDDIR2     = File.join(G2DDIR, "WorkDir/Metadata2")
  FILEDIR1   = File.join(G2DDIR, "WorkDir/list")
# FILEDIR2   = File.join(G2DDIR, "WorkDir/list2")
  MDDIR2     = File.join(G2DDIR, "WorkDir/Regist")

  #### FILES ####
  ## XPATH LIST TO REGISTER
  FILE_ELEMENTLIST  = File.join(RUBYDIR, "conf/spase2dspace_2.txt")
  ## LIST FILES (TEMPORARY)
  TMPFILE_ADD_FORCE = File.join(FILEDIR1, "add_force.tmp")
  TMPFILE_AANDM     = File.join(FILEDIR1, "add_and_replace.tmp")
  TMPFILE_DELETE    = File.join(FILEDIR1, "delete.tmp")
  ## LIST FILES (FOR MERGE)
  FILE1_ADD_FORCE   = File.join(FILEDIR1, "add_force.txt")
  FILE1_AANDM       = File.join(FILEDIR1, "add_and_replace.txt")
  FILE1_DELETE      = File.join(FILEDIR1, "delete.txt")
  ## LIST FILES (FINAL RESULT)
  FILE2_ADD         = File.join(FILEDIR1, "add.out")
  FILE2_MODIFY      = File.join(FILEDIR1, "modify.out")
  FILE2_DELETE      = File.join(FILEDIR1, "delete.out")
  FILE2_SKIP        = File.join(FILEDIR1, "skip.out")
  ## BATCH FILES
  BATCHFILE_ADD_FORCE = File.join(SHELLDIR, "runImport0.sh")
  BATCHFILE_ADD       = File.join(SHELLDIR, "runImport.sh")
  BATCHFILE_MODIFY    = File.join(SHELLDIR, "runReplace.sh")
  BATCHFILE_DELETE    = File.join(SHELLDIR, "runDelete.sh")
  ## TABLES
  FILE_TBL_T_METADATA   = File.join(FILEDIR1, "tbl_t_medadata.txt")
  FILE_TBL_T_COLLECTION = File.join(FILEDIR1, "tbl_t_collection.txt")
  FILE_TBL_T_COMMUNITY  = File.join(FILEDIR1, "tbl_t_community.txt")
  ## LOGS
  LOG_TRANSFER = File.join(LOGDIR, "transfer.log")
  LOG_DSPACE   = File.join(LOGDIR, "dspace.log")

  #### HANDLE ####
  HANDLE_ID_PREFIX  = "123456789"
  RESOURCETYPEID_METADATA   = '2'
  RESOURCETYPEID_COLLECTION = '3'
  RESOURCETYPEID_COMMUNITY  = '4'

  #### ACTIVITY_CODE ####
  ACTIVITYCODE_ACTIVE = '1'
  ACTIVITYCODE_PAUSE  = '8'
  ACTIVITYCODE_STOP   = '9'

  #### CHARACTOR ####
  RESOURCEID_PREFIX = "spase://IUGONET/"
  COMMUNITY_ROOT    = "IUGONET/"


  ## ---------------------------------------------------------------- ##
  ## [initialize]                                                     ##
  ## ---------------------------------------------------------------- ##
  def initialize
  end


  ## ---------------------------------------------------------------- ##
  ## [init]                                                           ##
  ## ---------------------------------------------------------------- ##
  def init

    #### Database ####
    $db = DBAccess.new
    ## OpenDB1
    strResultCode = $db.openDB1
    if strResultCode != '000'
      return strResultCode
    end
    ## OpenDB2
    strResultCode = $db.openDB2
    if strResultCode != '000'
      return strResultCode
    end

    #### Return ####
    return strResultCode

  end

  ## ---------------------------------------------------------------- ##
  ## [final]                                                          ##
  ## ---------------------------------------------------------------- ##
  def final

    #### Database ####
    ## CloseDB1
    strResultCode = $db.closeDB1
    if strResultCode != '000'
      return strResultCode
    end
    ## CloseDB2
    strResultCode = $db.closeDB2
    if strResultCode != '000'
      return strResultCode
    end

    #### Return ####
    return strResultCode

  end

end
