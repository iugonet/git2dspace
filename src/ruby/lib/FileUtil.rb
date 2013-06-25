# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [FileUtil.rb]                                                      ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './lib/Log'
require './lib/LogStdOut'
require './conf/ResultCode'

class FileUtil


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
  end


  ## ---------------------------------------------------------------- ##
  ## [method] final                                                   ##
  ## ---------------------------------------------------------------- ##
  def final
  end


  ## ---------------------------------------------------------------- ##
  ## [method] conv1                                                   ##
  ## ---------------------------------------------------------------- ##
  def conv1(strInFile, strOutFile)

    #### Debug ####
    @log.debug("START: FileUtil.rb#conv1 --------")

    #### Check ####
    ## strInFile
    if strInFile == nil
      @stdout.error("FileUtil.rb#conv1: strInFile is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strInFile.strip == ""
      @stdout.error("FileUtil.rb#conv1: strInFile is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end
    ## strOutFile
    if strOutFile == nil
      @stdout.error("FileUtil.rb#conv1: strOutFile is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strOutFile.strip == ""
      @stdout.error("FileUtil.rb#conv1: strOutFile is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL
    aryElements = Array.new
    strPwd = Dir::pwd

    #### Exec ####
    begin

      ## Set Elements (Filenames) to Array
      @log.info("START: Set Elements (Filenames) to Array. <== Watch the Processing Time!!")
      open(strInFile, "r") do |inf|
        while line = inf.gets
          if line != nil
            line = line.chomp
            line = line.strip
            if line != ""
              aryElements << line.gsub(/^[.][\/]/, "")
            end
          end
        end
      end
      @log.info("END: Set Elements (Filenames) to Array. <== Watch the Processing Time!!")

      ## Check
      if aryElements == nil
        return ResultCode::FILEIOERROR
      end

      ## Sort Elements
      @log.info("START: aryElements.sort! <== Watch the Processing Time!!")
      aryElements.sort!
      @log.info("END: aryElements.sort! <== Watch the Processing Time!!")

      ## Write into OutFile
      @log.info("START: Set Elements (Filenames) to OutFile. <== Watch the Processing Time!!")
      open(strOutFile, "a") do |outf|
        for i in 0..aryElements.length-1
          outf.write strPwd
          outf.write ','
          outf.write aryElements[i].strip
          outf.puts
        end
      end
      @log.info("END: Set Elements (Filenames) to OutFile. <== Watch the Processing Time!!")

    ## on Error
    rescue => e
      strResultCode = ResultCode::FILENOTFOUND
      @stdout.error("FuleUtil.rb#conv1: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    ensure
      ## Clear
      aryElements.clear
    end

    #### Debug ####
    @log.debug("END: FileUtil.rb#conv1 --------")

    #### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] conv2                                                   ##
  ## ---------------------------------------------------------------- ##
  def conv2(strInFile, strOutFile)

    #### Debug ####
    @log.info("START: FileUtil.rb#conv2 --------")

    #### Check ####
    ## strInFile
    if strInFile == nil
      @stdout.error("FileUtil.rb#conv2: strInFile is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strInFile.strip == ""
      @stdout.error("FileUtil.rb#conv2: strInFile is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end
    ## strOutFile
    if strOutFile == nil
      @stdout.error("FileUtil.rb#conv2: strOutFile is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strOutFile.strip == ""
      @stdout.error("FileUtil.rb#conv2: strOutFile is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL
    aryElements = Array.new
    strPwd = Dir::pwd

    #### Exec ####
    begin

      ## Set Elements (Filenames) to Array
      @log.info("START: Set Elements (Filenames) to Array. <== Watch the Processing Time!!")
      open(strInFile, "r") do |inf|
        while line = inf.gets
          if line != nil
            line = line.chomp
            line = line.strip
            aryElement = line.split(" ")
            if aryElement.length == 2
              if aryElement[1] == nil
                ## Do Nothing
              elsif aryElement[1] == ""
                ## Do Nothing
              else
                aryElements << aryElement[1]
              end
            end
          end
        end
      end
      @log.info("END: Set Elements (Filenames) to Array. <== Watch the Processing Time!!")

      ## Check
      if aryElements == nil
        return ResultCode::FILEIOERROR
      end

      ## Elements to Uniq
      @log.info("START: aryElements.uniq! <== Watch the Processing Time!!")
      aryElements.uniq!
      @log.info("END: aryElements.uniq! <== Watch the Processing Time!!")

      ## Sort Elements
      @log.info("START: aryElements.sort! <== Watch the Processing Time!!")
      aryElements.sort!
      @log.info("END: aryElements.sort! <== Watch the Processing Time!!")

      ## Check Compatibility
      ## ADD AND MODIFY
      if strInFile == Configure::TMPFILE_AANDM
        @log.info("START: Check Compatibility (AANDM) <== Watch the Processing Time!!")
        for i in 0..aryElements.length-1
          if aryElements[i] == nil
            # Do Nothing
          elsif not File.exist?(aryElements[i].strip)
            aryElements[i] = nil
          end
        end
        @log.info("END: Check Compatibility (AANDM) <== Watch the Processing Time!!")
      ## DELETE
      elsif strInFile == Configure::TMPFILE_DELETE
        @log.info("START: Check Compatibility (DELETE) <== Watch the Processing Time!!")
        for i in 0..aryElements.length-1
          if aryElements[i] == nil
            ## Do Nothing
          elsif File.exist?(aryElements[i].strip)
            aryElements[i] = nil
          end
        end
        @log.info("END: Check Compatibility (DELETE) <== Watch the Processing Time!!")
      end

      ## Write into OutFile
      @log.info("START: Set Elements (Filenames) to OutFile. <== Watch the Processing Time!!")
      open(strOutFile, "a") do |outf|
        for i in 0..aryElements.length-1
          if aryElements[i] != nil
            outf.write strPwd
            outf.write ','
            outf.write aryElements[i].strip
            outf.puts
          end
        end
      end
      @log.info("END: Set Elements (Filenames) to OutFile. <== Watch the Processing Time!!")

    ## on Error
    rescue => e
      strResultCode = ResultCode::FILENOTFOUND
      @stdout.error("FileUtil.rb#conv2: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    ensure
      ## Clear
      aryElements.clear
    end

    #### Debug ####
    @log.debug("END: FileUtil.rb#conv2 --------")

    ##### Return ####
    return strResultCode
    
  end


  ## ---------------------------------------------------------------- ##
  ## [method] countRecordNumber                                       ##
  ## ---------------------------------------------------------------- ##
  def countRecordNumber(strFile)

    #### Debug ####
    @log.debug("START: FileUtil.rb#countRecordNumber")

    #### Define ####
    strResultCode = ResultCode::NORMAL
    intRecordNumber = 0

    #### Check ####
    ## strFile
    if strFile == nil
      @stdout.error("FileUtil.rb#countRecordNumber: strFile is NIL.")
      return ResultCode::PARAMETER_ERROR, intRecordNumber
    elsif strFile.strip == ""
      @stdout.error("FileUtil.rb#countRecordNumber: strFile is BLANK.")
      return ResultCode::PARAMETER_ERROR, intRecordNumber
    end

    #### Exec ####
    begin
      File.open(strFile) do |inf|
        nil while inf.gets
        intRecordNumber = inf.lineno
      end
    ## on Error
    rescue => e
      intRecordNumber = 0
      strResultCode = ResultCode::FILEIOERROR
      @stdout.error("FileUtil.rb#countRecordNumber: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
    @log.debug("END: FileUtil.rb#countRecordNumber")

    #### Return ####
    return strResultCode, intRecordNumber

  end


  ## ---------------------------------------------------------------- ##
  ## [method] writeListFileAdd                                        ##
  ## ---------------------------------------------------------------- ##
  def writeListFileAdd(strPath, strFileName)

    #### Debug ####
    @log.debug("START: FileUtil.rb#writeListFileAdd")

    #### Check ####
    ## strPath
    if strPath == nil
      @stdout.error("FileUtil.rb#writeListFileAdd: strPath is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strPath.strip == ""
      @stdout.error("FileUtil.rb#writeListFileAdd: strPath is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end
    ## strFileName
    if strFileName == nil
      @stdout.error("FileUtil.rb#writeListFileAdd: strFileName is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strFileName.strip == ""
      @stdout.error("FileUtil.rb#writeListFileAdd: strFileName is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      open(Configure::FILE2_ADD, "a") do |outf|
        outf.puts (strPath + "," + strFileName)
      end
    ## on Error
    rescue => e
      strResultCode = ResultCode::FILEIOERROR
      @stdout.error("FileUtil.rb#writeListFileAdd: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
    @log.debug("END: FileUtil.rb#writeListFileAdd")

    ##### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] writeListFileMod                                        ##
  ## ---------------------------------------------------------------- ##
  def writeListFileMod(strPath, strFileName)

    #### Debug ####
    @log.debug("START: FileUtil.rb#writeListFileMod")

    #### Check ####
    ## strPath
    if strPath == nil
      @stdout.error("FileUtil.rb#writeListFileMod: strPath is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strPath.strip == ""
      @stdout.error("FileUtil.rb#writeListFileMod: strPath is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end
    ## strFileName
    if strFileName == nil
      @stdout.error("FileUtil.rb#writeListFileMod: strFileName is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strFileName.strip == ""
      @stdout.error("FileUtil.rb#writeListFileMod: strFileName is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      open(Configure::FILE2_MODIFY, "a") do |outf|
        outf.puts (strPath + "," + strFileName)
      end
    ## on Error
    rescue => e
      strResultCode = ResultCode::FILEIOERROR
      @stdout.error("FileUtil.rb#writeListFileMod: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
    @log.debug("END: FileUtil.rb#writeListFileMod")

    ##### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] writeListFileDel                                        ##
  ## ---------------------------------------------------------------- ##
  def writeListFileDel(strPath, strFileName)

    #### Debug ####
    @log.debug("START: FileUtil.rb#writeListFileDel")

    #### Check ####
    ## strPath
    if strPath == nil
      @stdout.error("FileUtil.rb#writeListFileDel: strPath is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strPath.strip == ""
      @stdout.error("FileUtil.rb#writeListFileDel: strPath is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end
    ## strFileName
    if strFileName == nil
      @stdout.error("FileUtil.rb#writeListFileDel: strFileName is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strFileName.strip == ""
      @stdout.error("FileUtil.rb#writeListFileDel: strFileName is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      open(Configure::FILE2_DELETE, "a") do |outf|
        outf.puts (strPath + "," + strFileName)
      end
    ## on Error
    rescue => e
      strResultCode = ResultCode::FILEIOERROR
      @stdout.error("FileUtil.rb#writeListFileDel: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
    @log.debug("END: FileUtil.rb#writeListFileDel")

    ##### Return ####
    return strResultCode

  end


  ## ---------------------------------------------------------------- ##
  ## [method] writeListFileSkip                                       ##
  ## ---------------------------------------------------------------- ##
  def writeListFileSkip(strPath, strFileName)

    #### Debug ####
    @log.debug("START: FileUtil.rb#writeListFileSkip")

    #### Check ####
    ## strPath
    if strPath == nil
      @stdout.error("FileUtil.rb#writeListFileSkip: strPath is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strPath.strip == ""
      @stdout.error("FileUtil.rb#writeListFileSkip: strPath is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end
    ## strFileName
    if strFileName == nil
      @stdout.error("FileUtil.rb#writeListFileSkip: strFileName is NIL.")
      return ResultCode::PARAMETER_ERROR
    elsif strFileName.strip == ""
      @stdout.error("FileUtil.rb#writeListFileSkip: strFileName is BLANK.")
      return ResultCode::PARAMETER_ERROR
    end

    #### Define ####
    strResultCode = ResultCode::NORMAL

    #### Exec ####
    begin
      open(Configure::FILE2_SKIP, "a") do |outf|
        outf.puts (strPath + "," + strFileName)
      end
    ## on Error
    rescue => e
      strResultCode = ResultCode::FILEIOERROR
      @stdout.error("FileUtil.rb#writeListFileSkip: Rescued.")
      @stdout.error(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

    #### Debug ####
    @log.debug("END: FileUtil.rb#writeListFileSkip")

    ##### Return ####
    return strResultCode

  end


end
