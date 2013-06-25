# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [AdminDBController.rb]                                             ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './conf/ResultCode'
require './lib/Log'
require './lib/LogStdOut'
require './api/Community'
require './api/Collection'
require './api/Metadata'

class AdminDBController


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##
  #### ExecCode (Pricate Key)
  ## Restore
  RESTORE_COMMUNITY  = '1001101'  ## Restore Communities
  RESTORE_COLLECTION = '1001102'  ## Restore Collections
  RESTORE_METADATA   = '1001103'  ## Restore Metadata (ResourceID)


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
    ## Variables

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
    @log.info("START: AdminDBController.rb#exec --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Restore: RESTORE_COMMUNITY
    if strExecCode == RESTORE_COMMUNITY
      strResultCode = restoreCommunity
    ## Restore: RESTORE_COLLECTION
    elsif strExecCode == RESTORE_COLLECTION
      strResultCode = restoreCollection
    ## Restore: RESTORE_METADATA
    elsif strExecCode == RESTORE_METADATA
      strResultCode = restoreMetadata
    ## Error
    else
      @log.error("AdminDBController.rb#exec: Undefined ExecCode was Given.")
      strResultCode = ResultCode::EXECCODE_ERROR
    end

    #### Debug ####
    @log.info("END: AdminDBController.rb#exec --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] restoreCommunity                                        ##
  ## ---------------------------------------------------------------- ##
  def restoreCommunity

    #### Debug ####
    @log.info("START: AdminDBController.rb#restoreCommunity --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Restore Community
    community = Community.new
    strResultCode = community.exec(ExecCode::COMMUNITY_RESTORE)

    #### Debug ####
    @log.info("END: AdminDBController.rb#restoreCommunity --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] restoreCollection                                       ##
  ## ---------------------------------------------------------------- ##
  def restoreCollection

    #### Debug ####
    @log.info("START: AdminDBController.rb#restoreCollection --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Restore Collection
    collection = Collection.new
    strResultCode = collection.exec(ExecCode::COLLECTION_RESTORE)

    #### Debug ####
    @log.info("END: AdminDBController.rb#restoreCollection --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] restoreMetadata                                         ##
  ## ---------------------------------------------------------------- ##
  def restoreMetadata

    #### Debug ####
    @log.info("START: AdminDBController.rb#restoreMetadata --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Restore Metadata
    metadata = Metadata.new
    strResultCode = metadata.exec(ExecCode::METADATA_RESTORE)

    #### Debug ####
    @log.info("END: AdminDBController.rb#restoreMetadata --------")

    #### Return ####
    return strResultCode

  end


end
