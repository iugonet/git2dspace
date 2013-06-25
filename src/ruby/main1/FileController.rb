# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [FileController.rb]                                                ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './conf/Configure'
require './conf/ExecCode'
require './conf/ResultCode'
require './conf/Command'
require './lib/Log'
require './lib/LogStdOut'
require './lib/Date'
require './lib/FileUtil'
require './api/Repository'
require './api/RegistStatus'

class FileController


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##


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

    ## Variables (For Repository API)
    @intHitsCountRepo   = 0
    @aryRepositoryCode  = Array.new
    @aryRemoteHost      = Array.new
    @aryRemotePath      = Array.new
    @aryLocalDirectory  = Array.new
    @aryLocalDirectory2 = Array.new
    @aryLoginAccount    = Array.new
    @aryLoginPassword   = Array.new
    @aryProtocolCode    = Array.new
    @aryErrorFlag       = Array.new
    ## Variables (For API Functions)
    @intMDNumAddForced = 0
    @intMDNumAandM     = 0
    @intMDNumDeleteF1  = 0
    @intMDNumAdd       = 0
    @intMDNumModify    = 0
    @intMDNumDeleteF2  = 0
    @intMDNumSkip      = 0

  end


  ## ---------------------------------------------------------------- ##
  ## [method] clear                                                   ##
  ## ---------------------------------------------------------------- ##
  def clear

    #### Exec ####
    ## Clear Array
    @intHitsCountRepo = 0
    @aryRepositoryCode.clear
    @aryRemoteHost.clear
    @aryRemotePath.clear
    @aryLocalDirectory.clear
    @aryLocalDirectory2.clear
    @aryLoginAccount.clear
    @aryLoginPassword.clear
    @aryProtocolCode.clear
    @aryErrorFlag.clear

  end


  ## ---------------------------------------------------------------- ##
  ## [method] exec                                                    ##
  ## ---------------------------------------------------------------- ##
  def exec

    #### Debug ####
    @log.debug("START: FileController.rb#exec --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    ##### Exec ####
    ## Step.1: Get Repository List
    strResultCode = getRepositoryList
    if strResultCode != ResultCode::NORMAL
      return strResultCode
    end
    ## Step.2: Synchronize Metadata (Remote --> Local)
    strResultCode = syncRepository
    if strResultCode != ResultCode::NORMAL
      return strResultCode
    end
    ## Step.3: Set Metadata to Temporary Files
    strResultCode = setFileList
    if strResultCode != ResultCode::NORMAL
      return strResultCode
    end

    #### Debug ####
    @log.debug("END: FileController.rb#exec --------")

    ##### Return ####
    return ResultCode::NORMAL

  end


  ## ---------------------------------------------------------------- ##
  ## [method] getRepositoryList                                       ##
  ## ---------------------------------------------------------------- ##
  def getRepositoryList

    #### Debug ####
    @log.debug("START: FileController.rb#getRepositoryList --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Call Repository API
    repo = Repository.new

    ## Get Repository List
    strResultCode = repo.exec(ExecCode::REPOSITORY_GET_ACTIVE)
    if strResultCode != ResultCode::NORMAL
      return strResultCode
    end

    ## Set Results
    @intHitsCountRepo      = repo.getHitsCount
    @aryRepositoryCode     = repo.getRepositoryCode
    @aryRepositoryNickName = repo.getRepositoryNickName
    @aryRemoteHost         = repo.getRemoteHost
    @aryRemotePath         = repo.getRemotePath
    @aryLoginAccount       = repo.getLoginAccount
    @aryLoginPassword      = repo.getLoginPassword
    @aryProtocolCode       = repo.getProtocolCode
    @aryLocalDirectory     = repo.getLocalDirectory
    @aryLocalDirectory2    = repo.getLocalDirectory2

    ## Debug
    for i in 0..@intHitsCountRepo-1
      @stdout.info("---- The Target Repository to Register -----------------------")
      @stdout.info("RepositoryCode     = [" + @aryRepositoryCode[i]     + "]")
      @stdout.info("RepositoryNickName = [" + @aryRepositoryNickName[i] + "]")
      @stdout.info("RemoteHost         = [" + @aryRemoteHost[i]         + "]")
      @stdout.info("RemotePath         = [" + @aryRemotePath[i]         + "]")
      @stdout.info("--------------------------------------------------------------")
    end

    #### Debug ####
    @log.debug("END: FileController.rb#getRepositoryList --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] syncRepository                                          ##
  ## ---------------------------------------------------------------- ##
  def syncRepository

    #### Debug ####
    @log.debug("START: FileController.rb#syncRepository --------")

    #### Define ####
    ## Classes
    command = Command.new
    ## Variables
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## Synchronize Metadata
    for i in 0..@intHitsCountRepo-1

      ## Set Error Flag
      @aryErrorFlag[i] = false

      ## Set MDDir Name
      strMDDir = File.join(Configure::MDDIR1, @aryLocalDirectory[i])

      ## Check Directory is Already Exist
      blnMDDirExist = File.exist?(strMDDir)

      ## Create Directory
      if blnMDDirExist == false
        FileUtils.mkdir_p(strMDDir)
      end

      ## Replace MDDir Name for Git
      ## Note:
      ##  ProtocolCode == "1" shows Git. In that case, use variable 'LocalDirectory2'
      ##  because one more directory is created under the 'local_directory'.
      ##  e.g., STEL.git --> '/STEL' 
      if blnMDDirExist == true && @aryProtocolCode[i] == "1"
        ## Replace MDDir Name
        strMDDir2 = File.join(Configure::MDDIR1, @aryLocalDirectory2[i])
        ## MD Repository Already Exist --> Replace MDDir Name
        if File.exist?(strMDDir2)
          strMDDir = strMDDir2
        ## MD Repository Not Exist (Rool-Back blnMDDirExist to false)
        else
          blnMDDirExist = false
        end
      end

      ## Change to MD Directory
      Dir::chdir(strMDDir)
      @log.info("FileController.rb#syncRepository: Change Directory --> [" + strMDDir + "]")

      ## Create Command
      if blnMDDirExist == true
        strCommand = command.getGitCommandPull
      elsif blnMDDirExist == false
        strRepositoryURL = File.join(@aryRemoteHost[i], @aryRemotePath[i])
        strCommand = command.getGitCommandClone(@aryLoginAccount[i], strRepositoryURL)
      end

      ## Debug
      @stdout.info("---- Synchronizing Metadata ----------------------------------")
      @stdout.info("RemoteHost = [" + @aryRemoteHost[i] + "]")
      @stdout.info("RemotePath = [" + @aryRemotePath[i] + "]")
      @stdout.info("LocalDir   = [" + strMDDir          + "]")
      @stdout.info("Command    = [" + strCommand        + "]")

      ## Synchronize Metadata
      @stdout.info("Synchronizing Metadata... [PASSED] <== Watch the Processing Time!!")
#     @stdout.info("Synchronizing Metadata... [START] <== Watch the Processing Time!!")
#     system(strCommand)
#     if $?.exitstatus == 0
#       @stdout.info("Synchronizing Metadata... [DONE]  <== Watch the Processing Time!!")
#     else
#       @aryErrorFlag[i] = true
#       @stdout.error("Synchronizing Metadata... [ERROR] <== Watch the Processing Time!!")
#       @stdout.error("Error Occurred on Synchronizing Metadata. See Log File!")
#       @stdout.error($?.to_s)
#     end

      ## Debug
      @stdout.info("--------------------------------------------------------------")

      ## Back to RUBY Directory      
      Dir::chdir(Configure::RUBYDIR)
      @log.info("FileController.rb#syncRepository: Change Directory --> [" + Configure::RUBYDIR + "]")

    end

    #### Debug ####
    @log.debug("END: FileController.rb#syncRepository --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] setFileList                                             ##
  ## ---------------------------------------------------------------- ##
  def setFileList

    #### Debug ####
    @log.debug("START: FileController.rb#setFileList --------")

    #### Define ####
    ## Classes
    command  = Command.new
    date     = Date.new
    fileutil = FileUtil.new
    ## Variables

    #### Exec ####
    ## Create Directory
    FileUtils.mkdir_p(Configure::FILEDIR1) unless File.exist?(Configure::FILEDIR1)

    ## Call Class
    registStatus = RegistStatus.new

    ## Set Parameters
    for i in 0..@intHitsCountRepo-1

      ## Back to Ruby Directory
      Dir::chdir(Configure::RUBYDIR)
      @log.info("FileController.rb#setFileList: Dir::pwd = [" + Dir::pwd + "]")

      ## Debug
      @stdout.info("---- Searching the Metadata Files to Register ----------------")
      @stdout.info("RepositoryCode     = [" + @aryRepositoryCode[i]     + "]")
      @stdout.info("RepositoryNickName = [" + @aryRepositoryNickName[i] + "]")

      ## Error Trap
      if @aryErrorFlag[i] == true
        ## Debug
        @stdout.error("Pass This Repository. Go Next!")
        @stdout.info("--------------------------------------------------------------")
        ## Regist to Admin-DB (INSERT RECORD with REGIST_STATUS_CODE = '8')
        registStatus.setRepositoryCode(@aryRepositoryCode[i])
        registStatus.setStartDate("")
        registStatus.setStartTime("")
        registStatus.setEndDate("")
        registStatus.setEndTime("")
        strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_REGIST_S8)
        ## Go to Next
        next
      end

      ## Get Regist Status
      registStatus.setRepositoryCode(@aryRepositoryCode[i])
      strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_GET_RECENTONE)
      if strResultCode != ResultCode::NORMAL
        ## Debug
        @log.error("FileController.rb#setFileList: Error Occurred on Selecting Recent One from Admin-DB. See Log File. Go Next!")
        ## Go to Next
        next
      end

      ## Note:
      ## The Variable 'HitsCount' Shows the Number Whether the Repository
      ## Have been Registed Until Now or Not.
      ## - HitsCount = 0: Never Registerd  --> Add(Forced)
      ## - HitsCount = 1: Already Registed --> Add or Modify
      ## 

      ## Set New Time Range
      ## Note: 
      ## - Cannot Parse the Form "%H%M%S" in Ruby_1.9.x??
      ## - Therefore, Use (%H:%M:%S).gsub(/:/, "")
      if registStatus.getHitsCount == 0
        @stdout.info("This Repository have NEVER been registered until now.")
        strStartDate = "20000101"
        strStartTime = "000000"
        strEndDate   = date.getNow("%Y%m%d")
        strEndTime   = date.getNow("%H:%M:%S").gsub(/:/, "")
      else
        @stdout.info("This Repository have ever been registered until now.")
        strStartDate = (registStatus.getEndDate)[0]
        strStartTime = (registStatus.getEndTime)[0]
        strEndDate   = date.getNow("%Y%m%d")
        strEndTime   = date.getNow("%H:%M:%S").gsub(/:/, "")
      end

      ## Debug
      @log.debug("FileController.rb#setFileList: strStartDate = [" + strStartDate + "]")
      @log.debug("FileController.rb#setFileList: strStartTime = [" + strStartTime + "]")
      @log.debug("FileController.rb#setFileList: strEndDate   = [" + strEndDate   + "]")
      @log.debug("FileController.rb#setFileList: strEndTime   = [" + strEndTime   + "]")

      ## Regist to Admin-DB (INSERT RECORD with REGIST_STATUS_CODE = '1')
      registStatus.setRepositoryCode(@aryRepositoryCode[i])
      registStatus.setStartDate(strStartDate)
      registStatus.setStartTime(strStartTime)
      registStatus.setEndDate(strEndDate)
      registStatus.setEndTime(strEndTime)
      strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_REGIST_S1)

      ## Change to Local Directory (Local Repository)
      begin
        if @aryProtocolCode[i] == "1"
          Dir::chdir File.join(Configure::MDDIR1, @aryLocalDirectory2[i])
        else
          Dir::chdir File.join(Configure::MDDIR1, @aryLocalDirectory[i])
        end
        @log.info("FileController.rb#setFileList: Dir::pwd = [" + Dir::pwd + "]")
      ## on Error
      rescue => e
        ## Regist to Admin-DB (REGIST_STATUS_CODE ->9)
        registStatus.setRegistID(registStatus.getCurrRegistID)
        strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_REGIST_S9)
        ## Debug
        @stdout.error("FileController.rb#setFileList: Rescued.")
        @stdout.error(e.class.to_s + ":" + e.message.to_s)
        @stdout.error("Pass This Repository. Go Next!")
        @stdout.info("--------------------------------------------------------------")
        ## Go Next
        next
      ensure
      end

      ## Search Metadata Files to Register
      ## REGIST ALL
      if registStatus.getHitsCount == 0
        ## Debug
        @stdout.info("START: Executing the Command. <== Watch the Processing Time!!")
        ## Add (Forced)
        strCommand = command.getFindCommand(".")
        @stdout.info("Command = [" + strCommand + "]")
        system(strCommand)
        @stdout.info("END: Executing the Command. <== Watch the Processing Time!!")

        ## Re-Format and Check Compatibility
        @stdout.info("START: Re-Format and Check Compatibility.")
        @log.debug("FileController.rb#setFileList: Target File = [" + Configure::TMPFILE_ADD_FORCE + "]")
        strResultCode = fileutil.conv1(Configure::TMPFILE_ADD_FORCE, Configure::FILE1_ADD_FORCE)
        if strResultCode != ResultCode::NORMAL
          ## Regist to Admin-DB (REGIST_STATUS_CODE ->9)
          registStatus.setRegistID(registStatus.getCurrRegistID)
          strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_REGIST_S9)
          ## Debug
          @stdout.error("System Error on Creating List. strResultCode = [" + strResultCode + "]")
          ## Go Next
          next
        end
        @stdout.info("END: Re-Format and Check Compatibility.")

      ## REGIST SYNC
      else
        ## Re-Format DateTime to Use on Git Command
        ## ("YYYYmmddHHMMSS" --> "YYYY/mm/dd HH:MM:SS")
        strStartDateTime = date.conv(strStartDate + strStartTime, "%Y/%m/%d %H:%M:%S")
        strEndDateTime   = date.conv(strEndDate   + strEndTime,   "%Y/%m/%d %H:%M:%S")

        ## Debug
        @stdout.info("START: Executing the Command. <== Watch the Processing Time!!")
        ## Add
        strCommand = command.getGitCommandLog(strStartDateTime, strEndDateTime, "A")
        @stdout.info("Command = [" + strCommand + "]")
        system(strCommand)
        ## Modify
        strCommand = command.getGitCommandLog(strStartDateTime, strEndDateTime, "M")
        @stdout.info("Command = [" + strCommand + "]")
        system(strCommand)
        ## Delete
        strCommand = command.getGitCommandLog(strStartDateTime, strEndDateTime, "D")
        @stdout.info("Command = [" + strCommand + "]")
        system(strCommand)
        ## Debug
        @stdout.info("END: Executing the Command. <== Watch the Processing Time!!")

        ## Re-Format and Check Compatibility
        @stdout.info("START: Re-Format and Check Compatibility.")
        strResultCode = fileutil.conv2(Configure::TMPFILE_AANDM,  Configure::FILE1_AANDM)
        if strResultCode != ResultCode::NORMAL
          ## Debug
          @stdout.error("System Error on Creating List. strResultCode = [" + strResultCode + "]")
          ## Regist to Admin-DB (REGIST_STATUS_CODE ->9)
          registStatus.setRegistID(registStatus.getCurrRegistID)
          strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_REGIST_S9)
          ## Go Next
          next
        end
        strResultCode = fileutil.conv2(Configure::TMPFILE_DELETE, Configure::FILE1_DELETE)
        if strResultCode != ResultCode::NORMAL
          ## Debug
          @stdout.error("System Error on Creating List. strResultCode = [" + strResultCode + "]")
          ## Regist to Admin-DB (REGIST_STATUS_CODE ->9)
          registStatus.setRegistID(registStatus.getCurrRegistID)
          strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_REGIST_S9)
          ## Go Next
          next
        end
        @stdout.info("END: Re-Format and Check Compatibility.")

      end

      ## Regist to Admin-DB (REGIST_STATUS_CODE 1->0)
      registStatus.setRegistID(registStatus.getCurrRegistID)
      strResultCode = registStatus.exec(ExecCode::REGISTSTATUS_REGIST_S0)

      ## Back to Ruby Directory
      Dir::chdir(Configure::RUBYDIR)
      @log.info("FileController.rb#setFileList: Dir::pwd = [" + Dir::pwd + "]")

      ## Debug
      @stdout.info("--------------------------------------------------------------")

    end

    #### Debug ####
    @log.debug("END: FileController.rb#setFileList --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] countMDNumber                                           ##
  ## ---------------------------------------------------------------- ##
  def countMDNumber

    #### Debug ####
    @log.debug("START: FileController.rb#countMDNumber")

    #### Define ####
    ## Classes
    fileUtil = FileUtil.new
    ## Variables
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    ## FILE1_ADD_FORCE
    if File.exist?(Configure::FILE1_ADD_FORCE)
      strResultCode, @intMDNumAddForced = fileUtil.countRecordNumber(Configure::FILE1_ADD_FORCE)
    end
    ## FILE1_AANDM
    if File.exist?(Configure::FILE1_AANDM)
      strResultCode, @intMDNumAandM = fileUtil.countRecordNumber(Configure::FILE1_AANDM)
    end
    ## FILE1_DELETE
    if File.exist?(Configure::FILE1_DELETE)
      strResultCode, @intMDNumDeleteF1 = fileUtil.countRecordNumber(Configure::FILE1_DELETE)
    end

    ## FILE2_ADD
    if File.exist?(Configure::FILE2_ADD)
      strResultCode, @intMDNumAdd = fileUtil.countRecordNumber(Configure::FILE2_ADD)
    end
    ## FILE2_MODIFY
    if File.exist?(Configure::FILE2_MODIFY)
      strResultCode, @intMDNumModify = fileUtil.countRecordNumber(Configure::FILE2_MODIFY)
    end
    ## FILE2_DELETE
    if File.exist?(Configure::FILE2_DELETE)
      strResultCode, @intMDNumDeleteF2 = fileUtil.countRecordNumber(Configure::FILE2_DELETE)
    end
    ## FILE2_SKIP
    if File.exist?(Configure::FILE2_SKIP)
      strResultCode, @intMDNumSkip = fileUtil.countRecordNumber(Configure::FILE2_SKIP)
    end

    #### Debug ####
    @log.debug("END: FileController.rb#countMDNumber")

    #### Return ####
    return strResultCode

  end

  ## ---------------------------------------------------------------- ##
  ## [API-Method] getMDNumAddForced                                   ##
  ## ---------------------------------------------------------------- ##
  def getMDNumAddForced
    return @intMDNumAddForced
  end

  ## ---------------------------------------------------------------- ##
  ## [API-Method] getMDNumAandM                                       ##
  ## ---------------------------------------------------------------- ##
  def getMDNumAandM
    return @intMDNumAandM
  end

  ## ---------------------------------------------------------------- ##
  ## [API-Method] getMDNumDeleteF1                                    ##
  ## ---------------------------------------------------------------- ##
  def getMDNumDeleteF1
    return @intMDNumDeleteF1
  end

  ## ---------------------------------------------------------------- ##
  ## [API-Method] getMDNumAdd                                         ##
  ## ---------------------------------------------------------------- ##
  def getMDNumAdd
    return @intMDNumAdd
  end

  ## ---------------------------------------------------------------- ##
  ## [API-Method] getMDNumModify                                      ##
  ## ---------------------------------------------------------------- ##
  def getMDNumModify
    return @intMDNumModify
  end

  ## ---------------------------------------------------------------- ##
  ## [API-Method] getMDNumDeleteF2                                    ##
  ## ---------------------------------------------------------------- ##
  def getMDNumDeleteF2
    return @intMDNumDeleteF2
  end

  ## ---------------------------------------------------------------- ##
  ## [API-Method] getMDNumSkip                                        ##
  ## ---------------------------------------------------------------- ##
  def getMDNumSkip
    return @intMDNumSkip
  end


end
