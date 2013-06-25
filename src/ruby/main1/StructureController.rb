# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [StructureController.rb]                                           ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './conf/ResultCode'
require './conf/ExecCode'
require './conf/Command'
require './lib/Log'
require './lib/LogStdOut'
require './lib/CharUtil'
require './lib/XMLUtil'
require './api/Community'
require './api/Collection'
require './api/Handle'

class StructureController


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##
  #### Variables 

  #### Private Key


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

    #### Define #####
    ## Classes
    @log    = Log.new
    @stdout = LogStdOut.new
    ## Variables
    @strHandleIDSuffixCom = ""
    @strHandleIDSuffixCol = ""
    @strCommunityID        = ""
    @strCommunityFullPath  = ""
    @strCollectionFullPath = ""

  end


  ## ---------------------------------------------------------------- ##
  ## [method] clear                                                   ##
  ## ---------------------------------------------------------------- ##
  def clear
    #### Exec ####
    ## Variables (For SQL Results)
  end


  ## ---------------------------------------------------------------- ##
  ## [method] final                                                   ##
  ## ---------------------------------------------------------------- ##
  def final
  end


  ## ---------------------------------------------------------------- ##
  ## [method] exec                                                    ##
  ## ---------------------------------------------------------------- ##
  def exec

    #### Debug ####
    @log.debug("START: StructureContoller.rb#exec")

    #### Define ####
    ## Variables
    strResultCode = ResultCode::NORMAL

    #### Check ####
    ## strCollectionFullPath
    if @strCollectionFullPath == nil
      return ResultCode::PARAMETER_ERROR
    elsif @strCollectionFullPath.strip == ""
      return ResultCode::PARAMETER_ERROR
    end

    #### Exec ####
    ## Create CommunityFullPath
    @strCommunityFullPath = @strCollectionFullPath.slice(0, @strCollectionFullPath.rindex("/"))
    @log.debug("StructureContoller.rb#exec: strCollectionFullPath = [" + @strCollectionFullPath + "]")
    @log.debug("StructureContoller.rb#exec: strCommunityFullPath  = [" + @strCommunityFullPath  + "]")

    ## Step.1: Search Community
    strResultCode = searchCommunity
    if strResultCode != ResultCode::NORMAL
      return strResultCode
    end
    ## Step.2: Search Collection
    strResultCode = searchCollection
    if strResultCode != ResultCode::NORMAL
      return strResultCode
    end

    #### Debug ####
    @log.debug("END: StructureContoller.rb#exec")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] searchCommunity                                         ##
  ## ---------------------------------------------------------------- ##
  def searchCommunity

    #### Debug ####
    @log.debug("START: StructureController.rb#searchCommunity")

    #### Define ####
    ## Classes
    community = Community.new
    ## Variables
    strResultCode  = ResultCode::NORMAL
    aryElement     = Array.new

    #### Exec ####

    ## Get Element and Total Index
    aryElement = @strCommunityFullPath.split("/")
    intTotalIndex = aryElement.size

    ## Set Community Full Path to Tmp Variable
    strCommunityTmpPath = @strCommunityFullPath

    ## Loop
    while true
      ## Check Community Exist or Not (Use Community API)
      community.setCommunityName(strCommunityTmpPath)
      strResultCode = community.exec(ExecCode::COMMUNITY_GET_FROM_NAME)
      ## Judge
      ## System Error --> return
      if strResultCode != ResultCode::NORMAL
        @log.error("StructureController#rb:searchCommunity: System Error on Searching Community. strResultCode = [" + strResultCode + "]")
        return strResultCode
      ## Community Found --> Use This HandleID and Break
      elsif community.getHitsCount == 1
        @strCommunityID       = (community.getCommunityID)[0]
        @strHandleIDSuffixCom = (community.getHandleIDSuffix)[0]
        @log.info("StructureController#rb:searchCommunity: strCommunityID = [" + @strCommunityID + "], strHandleIDSuffixCom = [" + @strHandleIDSuffixCom + "] Found. --> Use This Community")
        break;
      end
      ## Community Not Found --> Go To Next Loop
      if strCommunityTmpPath.include?("/")
        strCommunityTmpPath = strCommunityTmpPath.slice(0, strCommunityTmpPath.rindex("/"))
      else
        strCommunityTmpPath = ""
        break;
      end
    end

    ## Get Current Index
    intCurrentIndex = strCommunityTmpPath.split("/").size

    ## Create Community
    for i in intCurrentIndex..intTotalIndex-1
      ## Case: Top Hierarchy (ex. 'IUGONET')
      if i == 0
        ## Add Nothing (Use 'strCommunityTmpPath' as it is.) 
        strCommunityTmpPath = aryElement[i]
      ## Case: Child Hierarchy (ex. 'IUGONET/NumericalData')
      else
        ## Add Child Hierarchy
        strCommunityTmpPath = strCommunityTmpPath + "/" + aryElement[i]
      end
      strResultCode = createCommunityToDSpace(strCommunityTmpPath)
      if strResultCode != ResultCode::NORMAL
        @log.error("StructureController#rb:searchCommunity: System Error on Registing Community to Admin-DB. strResultCode = [" + strResultCode + "]")
        break;
      end
    end

    ## Clear
    aryElement.clear

    #### Debug ####
    @log.debug("END: StructureController.rb#searchCommunity")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] searchCollection                                        ##
  ## ---------------------------------------------------------------- ##
  def searchCollection

    #### Debug ####
    @log.debug("START: StructureController.rb#searchCollection")

    #### Define ####
    ## Classes
    collection = Collection.new
    ## Variables
    strResultCode  = ResultCode::NORMAL

    #### Exec ####

    ## Check Collection Exist or Not (Use Collection API)
    collection.setCollectionName(@strCollectionFullPath)
    strResultCode = collection.exec(ExecCode::COLLECTION_GET_FROM_NAME)

    ## Judge
    ## System Error --> Do Nothing
    if strResultCode != ResultCode::NORMAL
      @log.error("StructureController#rb:searchCollection: System Error on Searching Collection. strResultCode = [" + strResultCode + "]")
    ## Collection Not Fount --> Create Collection Newly.
    elsif collection.getHitsCount == 0
      @log.info("StructureController#rb:searchCollection: strHandleIDSuffixCol Not Found. --> Create Newly")
      strResultCode = createCollectionToDSpace
      if strResultCode != ResultCode::NORMAL
        @log.error("StructureController#rb:searchCollection: System Error on Creating Collection. strResultCode = [" + strResultCode + "]")
      else
        @log.info("StructureController#rb:searchCollection: strHandleIDSuffixCol = [" + @strHandleIDSuffixCol + "] Created. --> Use This Collection.")
      end
    ## Collection Found --> Use This HandleID
    elsif collection.getHitsCount == 1
      @strCommunityID       = (collection.getCommunityID)[0]
      @strHandleIDSuffixCol = (collection.getHandleIDSuffix)[0]
      @log.info("StructureController#rb:searchCollection: strHandleIDSuffixCol = [" + @strHandleIDSuffixCol + "] Found. --> Use This Collection")
    ## Collection Duplicate --> Set Error Code
    elsif collection.getHitsCount > 1
      strResultCode = ResultCode::COLLECTION_SYSTEM_ERROR
      @log.error("StrucrureController.rb#searchCollection: System Error on Searching Collection.")
      @log.error("StrucrureController.rb#searchCollection: Collection Duplicated!! HitsCount = [" + (collection.getHitsCount).to_s + "]")
    ## Other Errors --> Set Error Code
    else
      strResultCode = ResultCode::COLLECTION_SYSTEM_ERROR
      @log.error("StrucrureController.rb#searchCollection: System Error on Searching Collection.")
    end

    #### Debug ####
    @log.debug("END: StructureController.rb#searchCollection")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] createCommunityToDSpace                                 ##
  ## ---------------------------------------------------------------- ##
  def createCommunityToDSpace(strCommunityName)

    #### Debug ####
    @log.debug("START: StructureController.rb#createCommunityToDSpace")

    #### Define ###
    ## Classes
    command  = Command.new
    charutil = CharUtil.new
    xmlutil  = XMLUtil.new
    community = Community.new
    ## Variables
    strResultCode = ResultCode::NORMAL
    strInFile  = File.join(Configure::MDDIR2, "ist_com_" + @strHandleIDSuffixCom + ".xml")
    strOutFile = File.join(Configure::MDDIR2, "ost_com_" + @strHandleIDSuffixCom + ".xml")
    strCommunityElement = ""
    strHandleID       = ""
    strHandleIDPrefix = ""
    strHandleIDSuffix = ""
    intHitsCount = 0
    aryResourceID = Array.new

    #### Exec ####
    begin

      ## Create Temporal Directory
      FileUtils.mkdir_p(Configure::MDDIR2) unless File.exist?(Configure::MDDIR2)

      ## Get Community Element
      ## Case: Top Hierarchy (ex. 'IUGONET') --> Use 'strCommunityName' as it is.) 
      if not strCommunityName.include?("/")
        strCommunityElement = strCommunityName
      ## Case: Child Hierarchy (ex. 'IUGONET/NumericalData') --> Get Element(Child) Name
      else
        strCommunityElement = strCommunityName.slice(strCommunityName.rindex("/") + 1, strCommunityName.length)
      end
        
      ## Create ImportStructure XML (Use XMLUtil)
      xmlDocIS = xmlutil.createImportStructureXMLCommunity(strCommunityElement)
      if xmlDocIS == nil
        return ResultCode::XML_CREATE_ERROR
      end

      ## Write XMLDoc into File
      open(strInFile, "w") do |inf|
        xmlDocIS.write(inf)
      end

      ## Regist to DSpace
      ## Case: Top Hierarchy (ex. 'IUGONET') --> Add No Handle
      if not strCommunityName.include?("/")
        strCommand = command.getCommandCreateCommunity(strInFile, strOutFile, "")
      ## Case: Child Hierarchy (ex. 'IUGONET/NumericalData') --> Add Parent Community's Handle
      else
        strCommand = command.getCommandCreateCommunity(strInFile, strOutFile, Configure::HANDLE_ID_PREFIX + "/" + @strHandleIDSuffixCom)
      end
      @log.info("StructureController.rb#createCommunityToDSpace: strCommand = [" + strCommand + "]")
      system(strCommand)

      ## Get New HandleID
      open(strOutFile, "r") do |outf|
        xmldoc = REXML::Document.new outf
        strHandleID = xmldoc.elements["//imported_structure/community/@identifier"].to_s
      end

      ## Set HandleID (Overwrite @strHandleIDCom)
      strHandleIDPrefix, strHandleIDSuffix = charutil.handleSplit(strHandleID)
      @strHandleIDSuffixCom = strHandleIDSuffix

      ## Resolve CommunityID from HandleID
      handle = Handle.new
      handle.setHandleIDSuffix(@strHandleIDSuffixCom)
      handle.setResourceTypeID(Configure::RESOURCETYPEID_COMMUNITY)
      strResultCode = handle.exec(ExecCode::GET_FROM_HANDLEID_AND_RESOURCETYPEID)
      intHitsCount = handle.getHitsCount
      aryResourceID = handle.getResourceID  ## Note: RESOURCD_ID@HANDLE == COLLECTION_ID@COLLECTION
      ## Check
      if intHitsCount == nil
        @log.error("StructureController.rb#createCommunityToDspace: System Error on Resolving CommunityID. intHitsCount NIL.")
        return ResultCode::HANDLE_SYSTEM_ERROR
      elsif intHitsCount == 0
        @log.error("StructureController.rb#createCommunityToDspace: System Error on Resolving CommunityID. Not Found on DSpace.")
        return ResultCode::HANDLE_NOTFOUND
      elsif intHitsCount == 1
        @strCommunityID = aryResourceID[0].to_s
        @log.debug("StructureController.rb#createCommunityToDspace: CommunityID = [" + @strCommunityID + "] Found on DSpace. --> Regist to Admin-DB.")
      elsif intHitsCount > 1
        @log.error("StructureController.rb#createCommunityToDspace: System Error on Resolving CommunityID. intHitsCount > 1.")
        return ResultCode::HANDLE_SYSTEM_ERROR
      elsif strResultCode != ResultCode::NORMAL
        @log.error("StructureController.rb#createCommunityToDspace: System Error on Resolving CommunityID.")
        return ResultCode::HANDLE_SYSTEM_ERROR
      else
        @log.error("StructureController.rb#createCommunityToDspace: System Error on Resolving CommunityID.")
        return ResultCode::HANDLE_SYSTEM_ERROR
      end

      ## Regist New Community to Admin-DB
      community = Community.new
      community.setCommunityID(@strCommunityID)
      community.setHandleIDSuffix(@strHandleIDSuffixCom)
      community.setCommunityName(strCommunityName)
      strResultCode = community.exec(ExecCode::COMMUNITY_REGIST_ALL)
      if strResultCode != ResultCode::NORMAL
        @log.error("StructureController.rb#createCommunityToDspace: System Error on Registing Community To Admin-DB.")
        return ResultCode::COMMUNITY_REGIST_ERROR_ADMINDB
      end

    ## on Error
    rescue => e
      strResultCode = ResultCode::COMMUNITY_REGIST_ERROR_DSPACE
      @log.error("StructureController.rb#createCommunityToDspace: Rescued.")
      @log.error(e.class.to_s + ":" + e.message.to_s)
    ensure
      ## Clear Array
      aryResourceID.clear
    end

    #### Debug ####
    @log.debug("END: StructureController.rb#createCommunityToDSpace")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] createCollectionToDSpace                                ##
  ## ---------------------------------------------------------------- ##
  def createCollectionToDSpace

    #### Debug ####
    @log.debug("START: StructureController.rb#createCollectionToDSpace")

    #### Define ###
    ## Classes
    command  = Command.new
    charutil = CharUtil.new
    xmlutil  = XMLUtil.new
    ## Variables
    strResultCode = ResultCode::NORMAL
    strInFile  = File.join(Configure::MDDIR2, "ist_col_" + @strHandleIDSuffixCom + ".xml")
    strOutFile = File.join(Configure::MDDIR2, "ost_col_" + @strHandleIDSuffixCom + ".xml")
    strHandleID       = ""
    strHandleIDPrefix = ""
    strHandleIDSuffix = ""
    aryElement = Array.new
    intHitsCount = 0
    aryResourceID = Array.new

    #### Exec ####
    begin

      ## Create Temporal Directory
      FileUtils.mkdir_p(Configure::MDDIR2) unless File.exist?(Configure::MDDIR2)

      ## Get Collection Name from strCollectionName(FullPath)
      aryElement = @strCollectionFullPath.split("/")
      strCollectionName = aryElement[aryElement.size-1]

      ## Create ImportStructure XML (Use XMLUtil)
      xmlDocIS = xmlutil.createImportStructureXMLCollection(strCollectionName)
      if xmlDocIS == nil
        return ResultCode::XML_CREATE_ERROR
      end

      ## Write XMLDoc into File
      open(strInFile, "w") do |inf|
        xmlDocIS.write(inf)
      end

      ## Regist to DSpace
      strCommand = command.getCommandCreateCollection(strInFile, strOutFile, Configure::HANDLE_ID_PREFIX + "/" + @strHandleIDSuffixCom)
      @log.info("StructureController.rb#createCollectionToDSpace: strCommand = [" + strCommand + "]")
      system(strCommand)

      ## Get New HandleID
      open(strOutFile, "r") do |outf|
        xmldoc = REXML::Document.new outf
        strHandleID = xmldoc.elements["//imported_structure/collection/@identifier"].to_s
      end

      ## Set HandleID (Overwrite)
      strHandleIDPrefix, strHandleIDSuffix = charutil.handleSplit(strHandleID)
      @strHandleIDSuffixCol = strHandleIDSuffix

      ## Resolve CollectionID from HandleID
      handle = Handle.new
      handle.setHandleIDSuffix(@strHandleIDSuffixCol)
      handle.setResourceTypeID(Configure::RESOURCETYPEID_COLLECTION)
      strResultCode = handle.exec(ExecCode::GET_FROM_HANDLEID_AND_RESOURCETYPEID)
      intHitsCount = handle.getHitsCount
      aryResourceID = handle.getResourceID  ## Note: RESOURCD_ID@HANDLE == COLLECTION_ID@COLLECTION
      ## Check
      if intHitsCount == nil
        @log.error("StructureController.rb#createCollectionToDspace: System Error on Resolving CollectionID. intHitsCount NIL.")
        return ResultCode::HANDLE_SYSTEM_ERROR
      elsif intHitsCount == 0
        @log.error("StructureController.rb#createCollectionToDspace: System Error on Resolving CollectionID. Not Found on DSpace.")
        return ResultCode::HANDLE_NOTFOUND
      elsif intHitsCount == 1
        @log.debug("StructureController.rb#createCollectionToDspace: CollectionID = [" + aryResourceID[0].to_s + "] Found on DSpace. --> Regist to Admin-DB.")
      elsif intHitsCount > 1
        @log.error("StructureController.rb#createCollectionToDspace: System Error on Resolving CollectionID. intHitsCount > 1.")
        return ResultCode::HANDLE_SYSTEM_ERROR
      elsif strResultCode != ResultCode::NORMAL
        @log.error("StructureController.rb#createCollectionToDspace: System Error on Resolving CollectionID.")
        return ResultCode::HANDLE_SYSTEM_ERROR
      else
        @log.error("StructureController.rb#createCollectionToDspace: System Error on Resolving CollectionID.")
        return ResultCode::HANDLE_SYSTEM_ERROR
      end

      ## Regist New Collection to Admin-DB
      collection = Collection.new
      collection.setCollectionID(aryResourceID[0])
      collection.setHandleIDSuffix(@strHandleIDSuffixCol)
      collection.setCollectionName(strCollectionName)
      collection.setCommunityID(@strCommunityID)
      strResultCode = collection.exec(ExecCode::COLLECTION_REGIST_ALL)
      if strResultCode != ResultCode::NORMAL
        @log.error("StructureController.rb#createCollectionToDspace: System Error on Registing Collection To Admin-DB.")
        return ResultCode::COLLECTION_REGIST_ERROR_ADMINDB
      end

    ## on Error
    rescue => e
      strResultCode = ResultCode::COLLECTION_REGIST_ERROR_DSPACE
      @log.error("StructureController.rb#createCollectionToDSpace: Rescued.")
      @log.error(e.class.to_s + ":" + e.message.to_s)
    ensure
      ## Clear
      aryElement.clear
      aryResourceID.clear
    end

    #### Debug ####
    @log.debug("START: StructureController.rb#createCollectionToDSpace")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [API-method] setCollectionFullPath                               ##
  ## ---------------------------------------------------------------- ##
  def setCollectionFullPath(strCollectionFullPath)
    @strCollectionFullPath = strCollectionFullPath
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getHandleIDSuffixCom                                ##
  ## ---------------------------------------------------------------- ##
  def getHandleIDSuffixCom
    return @strHandleIDSuffixCom
  end

  ## ---------------------------------------------------------------- ##
  ## [API-method] getHandleIDSuffixCol                                ##
  ## ---------------------------------------------------------------- ##
  def getHandleIDSuffixCol
    return @strHandleIDSuffixCol
  end


end
