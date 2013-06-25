# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [RegistController.rb]                                              ##
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
require './lib/XMLUtil'
require './lib/FileUtil'
require './lib/ShellMaker'
require './api/Metadata'
require './api/Collection'
require './main1/StructureController'

class RegistController


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##
  #### ExecCode (Private Key)
  ADD_FORCED     = '1002101'
  ADD_AND_MODIFY = '1002102'
  DELETE         = '1002103'


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
    @log      = Log.new
    @stdout   = LogStdOut.new
    @fileutil = FileUtil.new
    ## Variables (For SQL Results)
    @aryHandleIDSuffix = Array.new
    ## Variables
    @strDirNameAdd = ""         ## Directory Name for Add
    @strDirNameMod = ""         ## Directory Name for Modify
    @strDirNameDel = ""         ## Directory Name for Delete
    @intDirNumberAdd = 0        ## Directory Number for Add
    @intDirNumberMod = 0        ## Directory Number for Modify
    @intDirNumberDel = 0        ## Directory Number for Delete

  end


  ## ---------------------------------------------------------------- ##
  ## [method] clear                                                   ##
  ## ---------------------------------------------------------------- ##
  def clear

    #### Exec ####
    ## Variables (For SQL Results)
    @aryHandleIDSuffix.clear
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
    @log.debug("START: RegistController.rb#exec")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Case.1: ADD (Forced)
    if strExecCode == ADD_FORCED
      strResultCode = add_forced
    ## Case.2: ADD_AND_MODIFY
    elsif strExecCode == ADD_AND_MODIFY
      strResultCode = add_and_modify
    ## Case.3: DELETE
    elsif strExecCode == DELETE
      strResultCode = delete
    ## Error
    else
      @log.error("RegistController.rb#exec: Undefined ExecCode was Given.")
      strResultCode = ResultCode::EXECCODE_ERROR
    end

    #### Debug ####
    @log.debug("END: RegistController.rb#exec")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] add_forced                                              ##
  ## ---------------------------------------------------------------- ##
  def add_forced

    #### Debug ####
    @stdout.info("---- Setting the Metadata Files to Add ----------------")
    @log.debug("START: RegistController.rb#add_forced")

    #### Define ####
    ## Classes
    date       = Date.new
    collection = Collection.new
    command    = Command.new
    shellMaker_add = ShellMaker.new
    structureController = StructureController.new
    ## Variables
    strResultCode = ResultCode::NORMAL
    intDirCounter = 0                ## To Use the Part of Directory Name
    strResourceID = ""               ## ResourceID of Metadata
    strCollectionFullPath     = ""   ## Collection Name of Metadata
    strCollectionFullPathPrev = ""   ## (To Lotate Directory)
    blnWriteToShell_Add = false      ## To Write into the Shell File

    #### Exec ####
    ## Check (Cannot Use 'begin' Function in the Out of Loop..)
    if not File.exist?(Configure::FILE1_ADD_FORCE)
      @stdout.fatal("RegistController.rb#add_forced: Cannot Open File [" + Configure::FILE1_ADD_FORCE + "]")
      return ResultCode::FILENOTFOUND
    end

    ## Create Shell Header
    strResultCode = shellMaker_add.openFile(Configure::BATCHFILE_ADD_FORCE)

    ## Open File
    open(Configure::FILE1_ADD_FORCE) do |inf|

      ## Seek Line
      while line = inf.gets

        ## Clear Variables
        clear

        ## Split
        aryElement = line.split(",")
        if aryElement.length != 2
          next
        end

        ## Set Path, Filename, ResourceID and CollectionName
        @strPath     = aryElement[0].to_s.strip
        @strFileName = aryElement[1].to_s.strip
        @strFileNameFullPath = File.join(@strPath, @strFileName)
        strResourceID = Configure::RESOURCEID_PREFIX + @strFileName.gsub(File.extname(@strFileName), "")
        strCollectionFullPath = Configure::COMMUNITY_ROOT + @strFileName.slice(0, @strFileName.rindex("/"))
        @log.info("RegistController.rb#add_forced: ######## strResourceID = [" + strResourceID + "] ########")

        ## Lotation
        if strCollectionFullPath != strCollectionFullPathPrev 

          ## Debug
          @log.info("RegistController.rb#add_forced: Collection = [" + strCollectionFullPath + "]")

          ## Search Collection's HandleID
          collection.setCollectionName(strCollectionFullPath)
          strResultCode = collection.exec(ExecCode::COLLECTION_GET_FROM_NAME)
          if strResultCode != ResultCode::NORMAL
            ## Write into List File
            strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
            ## Debug
            @stdout.error("RegistController.rb#add_forced: System Error on Searching Collection. ResourceID = [" + strResourceID + "]. Skipped!!")
            ## Go Next
            next
          end

          ## Get (or Regist) Collection's HandleID
          ## Note
          ##  intHitsCount == nil --> System Error (SQL Error etc.)
          ##  intHitsCount == 0   --> Collection has not been Registed in DSpace-DB yet. Create Collection.
          ##  intHitsCount == 1   --> Collection has Already been Registed in DSpace-DB. Use That.
          ##  intHitsCount > 1    --> System Error (Collection Duplicate.)
          ## Result: Error
          intHitsCount = collection.getHitsCount
          if intHitsCount == nil
            ## Write into List File
            strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
            ## Debug
            @stdout.error("RegistController.rb#add_forced: System Error on Searching Collection. HitsCount is NIL. ResourceID = [" + strResourceID + "]. Skipped!!")
            ## Go Next
            next
          ## Result: Collection Not Found --> Create Collection.
          elsif intHitsCount == 0
            ## Debug
            @log.info("RegistController.rb#add_forced: OK! Collection Not Found. --> Create Newly!")
            ## Create Collection
            structureController.setCollectionFullPath(strCollectionFullPath)
            strResultCode = structureController.exec
            strHandleIDSuffixCol = structureController.getHandleIDSuffixCol
            ## on Error
            if strResultCode != ResultCode::NORMAL
              ## Debug
              @stdout.error("RegistController.rb#add_forced: System Error on Creating Collection. ResourceID = [" + strResourceID + "], strResultCode = [" + strResultCode + "]. Skipped!!")
              ## Write into List File
              strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
              ## Go Next
              next
            elsif strHandleIDSuffixCol == nil
              ## Debug
              @stdout.error("RegistController.rb#add_forced: System Error on Creating Collection. strHandleIDSuffix is NIL. ResourceID = [" + strResourceID + "]. Skipped!!")
              ## Write into List File
              strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
              ## Go Next
              next
            elsif strHandleIDSuffixCol.strip == ""
              ## Debug
              @stdout.error("RegistController.rb#add_forced: System Error on Creating Collection. strHandleIDSuffix is BLANK. ResourceID = [" + strResourceID + "]. Skipped!!")
              ## Write into List File
              strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
              ## Go Next
              next
            end
          ## Result: Collection Found (HitsCount == 1) --> Use that Collection.
          elsif intHitsCount == 1
            ## Use that Collection
            strHandleIDSuffixCol = collection.getHandleIDSuffix[0]
            ## Debug
            @log.info("RegistController.rb#add_forced: OK! Collection Found. strHandleIDSuffixCol = [" + strHandleIDSuffixCol + "]. --> Use this Collection.")
          ## Result: Collection Found (HitsCount > 1)  --> Duplication Error.
          elsif intHitsCount > 1
            ## Debug
            @stdout.error("RegistController.rb#add_forced: System Error on Searching Collection. Collection Overlaps!! ResourceID = [" + strResourceID + "], strCollectionFullPath = [" + strCollectionFullPath + "]. Skipped!!")
            ## Write into List File
            strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
            ## Go Next
            next
          ## Other Errors
          else
            ## Debug
            @stdout.error("RegistController.rb#add_forced: System Error on Searching Collection. Other Error Occurred. ResourceID = [" + strResourceID + "], strCollectionFullPath = [" + strCollectionFullPath + "]. Skipped!!")
            ## Write into List File
            strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
            ## Go Next
            next
          end

          ## Lotate Directory
          intDirCounter = intDirCounter + 1
          @strDirNameAdd = File.join(Configure::MDDIR2, "ImportData0_"  + date.getNow("%Y%m%d") + "_" + sprintf("%08d", intDirCounter).to_s)
          @intDirNumberAdd = 0

          ## Debug
          @stdout.info("Setting the Metadata... [" + @strDirNameAdd + "]")

          ## Write-Flag to True
          blnWriteToShell_Add = true

        end

        ## Count Up
        @intDirNumberAdd = @intDirNumberAdd + 1

        ## Set CollectionName to Prev.
        strCollectionFullPathPrev = strCollectionFullPath

        ## Exec
        strResultCode = add
        if strResultCode != ResultCode::NORMAL
          @log.error("RegistController.rb#add_forced: Failed on Adding the Metadata into DSpace. ResourceID = [" + strResourceID + "]. Skipped!!")
          next
        end

        ## Write to Shell File
        if blnWriteToShell_Add == true
          ## Write
          strCommand = command.getDSpaceCommandAdd(strHandleIDSuffixCol, @strDirNameAdd)
          @log.debug("RegistController.rb#add_forced: strCommand = [" + strCommand + "]")
          strResultCode = shellMaker_add.setCommand(strCommand)
          ## Flag to false
          blnWriteToShell_Add = false
        end

      end  ## End of while

    end  ## End of open(File, ..)

    ## Commit Shell to Register
    strResultCode = shellMaker_add.closeFile(Configure::BATCHFILE_ADD_FORCE)

    #### Debug ####
    @stdout.info("---- Setting the Metadata Files to Add ----------------")
    @log.debug("END: RegistController.rb#add_forced")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] add_and_modify                                          ##
  ## ---------------------------------------------------------------- ##
  def add_and_modify

    #### Debug ####
    @stdout.info("---- Setting the Metadata Files to Add and Modify ----------------")
    @log.debug("START: RegistController.rb#add_and_modify")

    #### Define ####
    ## Classes
    metadata   = Metadata.new
    date       = Date.new
    collection = Collection.new
    command    = Command.new
    shellMaker_add = ShellMaker.new
    shellMaker_mod = ShellMaker.new
    structureController = StructureController.new
    ## Variables
    strResultCode = ResultCode::NORMAL
    intDirCounter = 0                ## To Use the Part of Directory Name
    strResourceID = ""               ## ResourceID of Metadata
    strCollectionFullPath     = ""   ## Collection Name of Metadata
    strCollectionFullPathPrev = ""   ## (To Lotate Directory)
    blnWriteToShell_Add = false      ## To Write into the Shell File for Add
    blnWriteToShell_Mod = false      ## To Write into the Shell File for Mod

    #### Exec ####
    ## Check (Cannot Use 'begin' Function in the Out of Loop..)
    if not File.exist?(Configure::FILE1_AANDM)
      @log.fatal("RegistController.rb#add_and_modify: Cannot Open File [" + Configure::FILE1_AANDM + "]")
      return ResultCode::FILENOTFOUND
    end

    ## Create Shell Header
    strResultCode = shellMaker_add.openFile(Configure::BATCHFILE_ADD)
    strResultCode = shellMaker_mod.openFile(Configure::BATCHFILE_MODIFY)

    ## Open File
    open(Configure::FILE1_AANDM) do |inf|

      ## Seek Line
      while line = inf.gets

        ## Clear Variables
        clear

        ## Split
        aryElement = line.split(",")
        if aryElement.length != 2
          next
        end

        ## Set Path, Filename and ResourceID
        @strPath     = aryElement[0].to_s.strip
        @strFileName = aryElement[1].to_s.strip
        @strFileNameFullPath = File.join(@strPath, @strFileName)
        strResourceID = Configure::RESOURCEID_PREFIX + @strFileName.gsub(File.extname(@strFileName), "")
        strCollectionFullPath = Configure::COMMUNITY_ROOT + @strFileName.slice(0, @strFileName.rindex("/"))
        @log.info("RegistController.rb#add_and_modify: ######## strResourceID = [" + strResourceID + "] ########")

        ## Lotation
        if strCollectionFullPath != strCollectionFullPathPrev 

          ## Debug
          @log.info("RegistController.rb#add_and_modify: Collection = [" + strCollectionFullPath + "]")

          ## Search Collection's HandleID
          collection.setCollectionName(strCollectionFullPath)
          strResultCode = collection.exec(ExecCode::COLLECTION_GET_FROM_NAME)
          if strResultCode != ResultCode::NORMAL
            ## Debug
            @stdout.error("RegistController.rb#add_and_modify: System Error on Searching Collection. ResourceID = [" + strResourceID + "]. Skipped!!")
            ## Write into List File
            strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
            ## Go Next
            next
          end

          ## Get (or Regist) Collection's HandleID
          ## Note
          ##  intHitsCount == nil --> System Error. (SQL Error etc.)
          ##  intHitsCount == 0   --> Collection has not been Registed in DSpace-DB yet. Create Collection.
          ##  intHitsCount == 1   --> Collection has Already been Registed in DSpace-DB. Use That.
          ##  intHitsCount > 1    --> System Error. (Duplication of Collection.)
          ## Result: Error
          intHitsCount = collection.getHitsCount
          if intHitsCount == nil
            ## Debug
            @stdout.error("RegistController.rb#add_and_modify: System Error on Searching Collection. HitsCount is NULL. strCollectionFullPath = [" + strCollectionFullPath + "]. Skipped!!")
            ## Write into List File
            strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
            ## Go Next
            next
          ## Result: Collection Not Found --> Create Collection.
          elsif intHitsCount == 0
            ## Debug
            @log.info("RegistController.rb#add_and_modify: OK! Collection Not Found. --> Create Newly!")
            ## Create Collection
            structureController.setCollectionFullPath(strCollectionFullPath)
            strResultCode = structureController.exec
            strHandleIDSuffixCol = structureController.getHandleIDSuffixCol
            ## on Error
            if strResultCode != ResultCode::NORMAL
              ## Debug
              @stdout.error("RegistController.rb#add_and_modify: System Error on Creating Collection. ResourceID = [" + strResourceID + "], strResultCode = [" + strResultCode + "]. Skipped!!")
              ## Write into List File
              strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
              ## Go Next
              next
            elsif strHandleIDSuffixCol == nil
              ## Debug
              @stdout.error("RegistController.rb#add_and_modify: System Error on Creating Collection. strHandleIDSuffix is NIL. ResourceID = [" + strResourceID + "]. Skipped!!")
              ## Write into List File
              strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
              ## Go Next
              next
            elsif strHandleIDSuffixCol.strip == ""
              ## Debug
              @stdout.error("RegistController.rb#add_and_modify: System Error on Creating Collection. strHandleIDSuffix is BLANK. ResourceID = [" + strResourceID + "]. Skipped!!")
              ## Write into List File
              strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
              ## Go Next
              next
            end
          ## Result: Collection Found (HitsCount == 1) --> Use that Collection.
          elsif intHitsCount == 1
            ## Use That Collection
            strHandleIDSuffixCol = collection.getHandleIDSuffix[0]
            ## Debug
            @log.info("RegistController.rb#add_and_modify: OK! Collection Found. strHandleIDSuffixCol = [" + strHandleIDSuffixCol + "]. --> Use this Collection.")
          ## Result: Collection Found (HitsCount > 1)  --> Duplication Error.
          elsif intHitsCount > 1
            ## Debug
            @stdout.error("RegistController.rb#add_and_modify: System Error on Searching Collection. Collection Overlaps!! strCollectionFullPath = [" + strCollectionFullPath + "]. Skipped!!")
            ## Write into List File
            strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
            ## Go Next
            next
          ## Other Errors
          else
            ## Debug
            @stdout.error("RegistController.rb#add_and_modify: System Error on Searching Collection. Other Error Occurred. strCollectionFullPath = [" + strCollectionFullPath + "]. Skipped!!")
            ## Write into List File
            strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
            ## Go Next
            next
          end

          ## Lotate Directory
          intDirCounter = intDirCounter + 1
          @strDirNameAdd = File.join(Configure::MDDIR2, "ImportData_"  + date.getNow("%Y%m%d") + "_" + sprintf("%08d", intDirCounter).to_s)
          @strDirNameMod = File.join(Configure::MDDIR2, "ReplaceData_" + date.getNow("%Y%m%d") + "_" + sprintf("%08d", intDirCounter).to_s)
          @intDirNumberAdd = 0
          @intDirNumberMod = 0

          ## Write-Flag to True
          blnWriteToShell_Add = true
          blnWriteToShell_Mod = true

        end

        ## Judge Add or Modify (Use Metadata API)
        metadata.setResourceID(strResourceID)
        strResultCode = metadata.exec(ExecCode::METADATA_GET_FROM_RESOURCEID)
        if strResultCode != ResultCode::NORMAL
          ## Debug
          @stdout.error("RegistController.rb#add_and_modify: System Error on Selecting Metadata. Skipped!!")
          ## Write into List File
          strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
          ## Go Next
          next
        end
        intHitsCount = metadata.getHitsCount   ## type: int
#       @log.debug("RegistController.rb#add_and_modify: intHitsCount = [" + intHitsCount.to_s + "]")
        @aryHandleIDSuffix = metadata.getHandleIDSuffix

        ## Note
        ##  intHitsCount == nil --> System Error. (SQL Error etc.)
        ##  intHitsCount == 0   --> Add (Metadata has NOT been Registed in DSpace yet.)
        ##  intHitsCount == 1   --> Modify (Metadata has Already been Registed in DSpace.)
        ##  intHitsCount > 1    --> System Error. (Duplication of ResourceID.)
        ## Result: Error
        if intHitsCount == nil
          ## Debug
          @stdout.error("RegistController.rb#add_and_modify: System Error on Searching Metadata. HitsCount is NULL. strResourceID = [" + strResourceID + "]. Skipped!!")
          ## Write into List File
          strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
          ## Go Next
          next
        ## Result: Add
        elsif intHitsCount == 0
          ## Debug
          @log.info("RegistController.rb#add_and_modify: OK! Metadata Not Found. ResourceID = [" + strResourceID + "]. --> Add")
          ## Count Up
          @intDirNumberAdd = @intDirNumberAdd + 1
          ## Set CollectionName to Prev.
          strCollectionFullPathPrev = strCollectionFullPath
          ## Exec
          strResultCode = add
          if strResultCode != ResultCode::NORMAL
            ## Debug
            @log.error("RegistController.rb#add_and_modify: Failed on Adding the Metadata into DSpace. ResourceID = [" + strResourceID + "]. Skipped!!")
            ## Go Next
            next
          end
          ## Write to Shell File
          if blnWriteToShell_Add == true
            ## Debug
            @stdout.info("Setting the Metadata... [" + @strDirNameAdd + "]")
            ## Write
            strCommand = command.getDSpaceCommandAdd(strHandleIDSuffixCol, @strDirNameAdd)
            @log.debug("RegistController.rb#add_and_modify: strCommand = [" + strCommand + "]")
            strResultCode = shellMaker_add.setCommand(strCommand)
            ## Flag to false
            blnWriteToShell_Add = false
          end
        ## Result: Modify
        elsif intHitsCount == 1
          ## Debug
          @log.info("RegistController.rb#add_and_modify: OK! Metadata Found. ResourceID = [" + strResourceID + "], HandleIDSuffix = [" + @aryHandleIDSuffix[0] + "]. --> Modify")
          ## Count Up
          @intDirNumberMod = @intDirNumberMod + 1
          ## Set CollectionName to Prev.
          strCollectionFullPathPrev = strCollectionFullPath
          ## Exec
          strResultCode = modify
          if strResultCode != ResultCode::NORMAL
            ## Debug
            @log.error("RegistController.rb#add_and_modify: Failed on Modifying the Metadata into DSpace. ResourceID = [" + strResourceID + "]. Skipped!!")
            ## Go Next
            next
          end
          ## Write to Shell File
          if blnWriteToShell_Mod == true
            ## Debug
            @stdout.info("Setting the Metadata... [" + @strDirNameMod + "]")
            ## Write
            strCommand = command.getDSpaceCommandReplace(strHandleIDSuffixCol, @strDirNameMod)
            @log.debug("RegistController.rb#add_and_modify: strCommand = [" + strCommand + "]")
            strResultCode = shellMaker_mod.setCommand(strCommand)
            ## Flag to false
            blnWriteToShell_Mod = false
          end
        ## Result: Error
        elsif intHitsCount > 1
          ## Debug
          @stdout.error("RegistController.rb#add_and_modify: System Error on Searching Metadata. HitsCount > 1. ResourceID = [" + strResourceID + "]. Skipped!!")
          ## Write into List File
          strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
          ## Go Next
          next
        ## Result: Error
        else
          ## Debug
          @stdout.error("RegistController.rb#add_and_modify: System Error on Searching Metadata. Other Error Occurred. ResourceID = [" + strResourceID + "]. Skipped!!")
          ## Write into List File
          strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
          ## Go Next
          next
        end

      end  ## End of while

    end  ## End of open(File, ..)

    ## Commit Shell to Register
    strResultCode = shellMaker_add.closeFile(Configure::BATCHFILE_ADD)
    strResultCode = shellMaker_mod.closeFile(Configure::BATCHFILE_MODIFY)


    #### Debug ####
    @stdout.info("---- Setting the Metadata Files to Add and Modify ----------------")
    @log.debug("END: RegistController.rb#add_and_modify")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] add                                                     ##
  ## ---------------------------------------------------------------- ##
  def add

    #### Debug ####
    @log.debug("START: RegistController.rb#add")

    #### Define ####
    ## Classes
    xmlutil = XMLUtil.new
    ## Variables
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin

      ## Make Temporary Directory to Store Metadata etc.
      strDirName = File.join(@strDirNameAdd, @intDirNumberAdd.to_s)
      FileUtils.mkdir_p(strDirName) unless File.exist?(strDirName)

      ## Copy Original Metadata File from Local Repository to Temporary Directory
      FileUtils.cp @strFileNameFullPath, strDirName

      ## Convert Metadata Format from SPASE to Dublin-Core(DC)
      xmlDocDC = xmlutil.convSPASEtoDC(@strFileNameFullPath)
      if xmlDocDC == nil
        ## Write into List File
        strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
        ## Return
        return ResultCode::CONVERT_ERROR
      end
      strDCFile = File.join(strDirName, "dublin_core.xml")
      open(strDCFile, "w") do |outf|
        xmlDocDC.write(outf)
      end

      ## Write Origina Metadata File Name to the file 'contents'
      strContentsFile = File.join(strDirName, "contents")
      open(strContentsFile, "w") do |outf|
        outf.puts File.basename(@strFileNameFullPath)
      end

      ## Write into List File
      strResultCode = @fileutil.writeListFileAdd(@strPath, @strFileName)
      if strResultCode != ResultCode::NORMAL
        ## Write into List File
        strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
        ## Debug
        @stdout.error("RegistController.rb#add: System Error on Adding to Add List. Skipped!!")
      end

    ## on Error
    rescue => e
      ## Write into List File
      strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
      ## Set Error Code
      strResultCode = ResultCode::CONVERT_ERROR
      ## Debug
      @stdout.error("RegistController.rb#add: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
      @stdout.error("RegistController.rb#add: @strFileNameFullPath = [" + @strFileNameFullPath + "]")

    ensure
    end

    #### Debug ####
    @log.debug("END: RegistController.rb#add")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] modify                                                  ##
  ## ---------------------------------------------------------------- ##
  def modify

    #### Debug ####
    @log.debug("START: RegistController.rb#modify")

    #### Define ####
    ## Classes
    xmlutil = XMLUtil.new
    ## Variables
    strResultCode = ResultCode::NORMAL

    #### Exec ####

    ## Exec
    begin

      ## Make Temporary Directory to Store Metadata etc.
      strDirName = File.join(@strDirNameMod, @intDirNumberMod.to_s)
      FileUtils.mkdir_p(strDirName) unless File.exist?(strDirName)

      ## Copy Original Metadata File from Local Repository to Temporary Directory
      FileUtils.cp @strFileNameFullPath, strDirName

      ## Convert Metadata Format from SPASE to Dublin-Core(DC)
      xmlDocDC = xmlutil.convSPASEtoDC(@strFileNameFullPath)
      if xmlDocDC == nil
        ## Write into List File
        strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
        ## Return
        return ResultCode::CONVERT_ERROR
      end
      strDCFile = File.join(strDirName, "dublin_core.xml")
      open(strDCFile, "w") do |outf|
        xmlDocDC.write(outf)
      end

      ## Write Origina Metadata File Name to the file 'contents'
      strContentsFile = File.join(strDirName, "contents")
      open(strContentsFile, "w") do |outf|
        outf.puts File.basename(@strFileNameFullPath)
      end

      ## Write Current HandleID to the file 'mapfile'
      strMapFile = File.join(@strDirNameMod, "mapfile")
      open(strMapFile, "a") do |outf|
        outf.printf("%d %s\n", @intDirNumberMod.to_s, Configure::HANDLE_ID_PREFIX + "/" + @aryHandleIDSuffix[0])
      end

      ## Write into List File
      strResultCode = @fileutil.writeListFileMod(@strPath, @strFileName)
      if strResultCode != ResultCode::NORMAL
        ## Debug
        @stdout.error("RegistController.rb#modify: System Error on Adding to Modify List. Skipped!!")
        ## Write into List File
        strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
      end

    ## on Error
    rescue => e
      ## Write into List File
      strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
      ## Set Error Code
      strResultCode = ResultCode::CONVERT_ERROR
      ## Debug
      @stdout.error("RegistController.rb#modify: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
      @stdout.error("RegistController.rb#modify: @strFileNameFullPath = [" + @strFileNameFullPath + "]")

    ensure
    end

    #### Debug ####
    @log.debug("END: RegistController.rb#modify")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] delete                                                  ##
  ## ---------------------------------------------------------------- ##
  def delete

    #### Debug ####
    @stdout.info("---- Setting the Metadata Files to Delete ----------------")
    @log.debug("START: RegistController.rb#delete")

    #### Define ####
    ## Classes
    metadata = Metadata.new
    date     = Date.new
    command  = Command.new
    shellMaker_del = ShellMaker.new
    ## Variables
    strResultCode = ResultCode::NORMAL
    strDirNameDel = ""  ## Directory Name for Del
    intFileCounter = 0  ## The Number to Write into the File 'mapfile'

    #### Exec ####

    ## Check (Cannot Use 'begin' Function in the Out of Loop..)
    if not File.exist?(Configure::FILE1_DELETE)
      @log.fatal("RegistController.rb#delete: Cannot Open File [" + Configure::FILE1_DELETE + "]")
      return ResultCode::FILENOTFOUND
    end

    ## Create Shell Header
    strResultCode = shellMaker_del.openFile(Configure::BATCHFILE_DELETE)

    ## Make Temporary Directory to Store Metadata etc.
    strDirNameDel = File.join(Configure::MDDIR2, "DeleteData_"  + date.getNow("%Y%m%d") + "_" + sprintf("%08d", "1").to_s)
    FileUtils.mkdir_p(strDirNameDel) unless File.exist?(strDirNameDel)

    ## Debug
    @stdout.info("Setting the Metadata... [" + strDirNameDel + "]")

    ## Open File
    open(Configure::FILE1_DELETE) do |inf|

      ## Seek Line
      while line = inf.gets

        ## Clear Variables
        clear

        ## Split
        aryElement = line.split(",")
        if aryElement.length != 2
          next
        end

        ## Set Path, Filename and ResourceID
        @strPath     = aryElement[0].to_s.strip
        @strFileName = aryElement[1].to_s.strip
        @strFileNameFullPath = File.join(@strPath, @strFileName)
        strResourceID = Configure::RESOURCEID_PREFIX + @strFileName.gsub(File.extname(@strFileName), "")
        @log.info("RegistController.rb#delete: ######## strResourceID = [" + strResourceID + "] ########")

        ## Get Metadata's HandleID
        metadata.setResourceID(strResourceID)
        strResultCode = metadata.exec(ExecCode::METADATA_GET_FROM_RESOURCEID)
        if strResultCode != ResultCode::NORMAL
          ## Debug
          @stdout.error("System Error on Searching Metadata. ResourceID = [" + strResourceID + "]. Skipped!!")
          ## Write into List File
          strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
          ## Go Next
          next
        end
        intHitsCount = metadata.getHitsCount   ## type: int
        @aryHandleIDSuffix = metadata.getHandleIDSuffix
#       @log.debug("RegistController.rb#delete: intHitsCount = [" + intHitsCount.to_s + "]")

        ## Note
        ##  intHitsCount == nil --> System Error. (SQL Error etc.)
        ##  intHitsCount == 0   --> System Error. (Metadata Not Found)
        ##  intHitsCount == 1   --> Delete (Metadata Found.)
        ##  intHitsCount > 1    --> System Error. (Duplication of ResourceID.)
        ## Result: Error
        if intHitsCount == nil
          ## Debug
          @stdout.error("RegistController.rb#delete: System Error on Searching Metadata. HitsCount is NULL. ResourceID = [" + strResourceID + "]. Skipped!!")
          ## Write into List File
          strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
          ## Go Next
          next
        ## Result: Error (Metadata Not Found)
        elsif intHitsCount == 0
          ## Debug
          @stdout.error("RegistController.rb#delete: System Error on Searching Metadata. Metadata Not Found. ResourceID = [" + strResourceID + "]. Skipped!!")
          ## Write into List File
          strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
          ## Go Next
          next
        ## Result: Normal (Metadata Found)
        elsif intHitsCount == 1
          begin
            ## Count Up
            intFileCounter = intFileCounter + 1
            ## Debug
            @log.info("RegistController.rb#delete: OK! Metadata Found. HandleIDSuffix = [" + @aryHandleIDSuffix[0] + "] --> Delete")
            ## Write Filename into 'logfile'
            strLogFile = File.join(strDirNameDel, "logfile")
            open(strLogFile, "a") do |outf|
              outf.printf("%s\n", File.basename(@strFileName))
            end
            ## Write HandleID into 'mapfile'
            strMapFile = File.join(strDirNameDel, "mapfile")
            open(strMapFile, "a") do |outf|
              outf.printf("%s %s\n", intFileCounter.to_s, Configure::HANDLE_ID_PREFIX + "/" + @aryHandleIDSuffix[0])
            end
            ## Write into List File
            strResultCode = @fileutil.writeListFileDel(@strPath, @strFileName)
            if strResultCode != ResultCode::NORMAL
              ## Debug
              @stdout.error("RegistController.rb#delete: System Error on Adding to Delete List. ResourceID = [" + strResourceID + "]. Skipped!!")
              ## Write into List File
              strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
            end
          ## on Error
          rescue => e
            ## Debug
            @stdout.error("RegistController.rb#delete: System Error on Setting logfile and mapfile. ResourceID = [" + strResourceID + "]. Skipped!!")
            ## Write into List File
            strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
            ## Go Next
            next
          end
        ## Result: Error
        elsif intHitsCount > 1
          ## Debug
          @stdout.error("RegistController.rb#delete: System Error on Searching Metadata. HitsCount > 1. ResourceID = [" + strResourceID + "]. Skipped!!")
          ## Write into List File
          strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
          ## Go Next
          next
        ## Result: Error
        else
          ## Debug
          @stdout.error("RegistController.rb#delete: System Error on Searching Metadata. Other Error Occurred. ResourceID = [" + strResourceID + "]. Skipped!!")
          ## Write into List File
          strResultCode = @fileutil.writeListFileSkip(@strPath, @strFileName)
          ## Go Next
          next
        end

      end  ## End of while

    end  ## End of open(File, ..)

    ## Write to Shell File
    strCommand = command.getDSpaceCommandDelete(strDirNameDel)
    @log.debug("RegistController.rb#delete: strCommand = [" + strCommand + "]")
    strResultCode = shellMaker_del.setCommand(strCommand)
    strResultCode = shellMaker_del.closeFile(Configure::BATCHFILE_DELETE)

    #### Debug ####
    @stdout.info("---- Setting the Metadata Files to Delete ----------------")
    @log.debug("END: RegistController.rb#delete")

    #### Return ####
    return strResultCode

  end


end
