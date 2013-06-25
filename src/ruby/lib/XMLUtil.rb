# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [XMLUtil.rb]                                                       ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './lib/Log'
require './lib/LogStdOut'
require './lib/CharUtil'
require './conf/ResultCode'
require 'rexml/document'

class XMLUtil


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
    @charutil = CharUtil.new
    #### Exec ####
    setList
  end


  ## ---------------------------------------------------------------- ##
  ## [method] final                                                   ##
  ## ---------------------------------------------------------------- ##
  def final
  end


  ## ---------------------------------------------------------------- ##
  ## [method] setList                                                 ##
  ## ---------------------------------------------------------------- ##
  def setList

    #### Debug ####
    @log.debug("START: XMLUtil.rb#setList --------")

    #### Define ####
    @aryXPathList        = Array.new
    @aryResourceTypeList = Array.new

    #### Exec ####
    begin

      ## Seek File
      open(Configure::FILE_ELEMENTLIST, "r") do |inf|

        ## Loop
        while strLine = inf.gets

          ## Error Check
          if strLine == nil
            next
          end
          ## Re-Format
          strLine.strip!
          strLine.chomp!
          ## Error Check
          if strLine == ""
            next
          end

          ## Set XPath List
          @aryXPathList << strLine

          ## Set ResourceType List
          aryElement = strLine.split("/")
          if aryElement.size > 2
            if aryElement[2] != nil
              @aryResourceTypeList << aryElement[2].strip
            end
          end

          ## Clear Array
          if aryElement != nil
            aryElement.clear
          end

          ## ResourceType to Unique
          @aryResourceTypeList.uniq!

        end  ## End of while

      end  ## End of open(File, ..)

      ## on Error
    rescue => e
      @log.error("XMLUtil.rb#setList: Rescued.")
      @log.error(e.class.to_s + ":" + e.message.to_s)
    ensure
    end
    
    #### Debug ####
    @log.debug("END: XMLUtil.rb#setList --------")

  end


  ## ---------------------------------------------------------------- ##
  ## [method] convSPASEtoDC                                           ##
  ## ---------------------------------------------------------------- ##
  def convSPASEtoDC(strInFile)

    #### Debug ####
#   @log.debug("START: XMLUtil.rb#convSPASEtoDC --------")

    #### Define ####
    strResultCode = ResultCode::NORMAL
    @strResourceType = ""

    #### Exec ####
    begin

      ## Parse Base XML (File)
      xmldoc_in = REXML::Document.new File.new(strInFile)

      ## Define New XML
      xmldoc_out = REXML::Document.new()

      ## Judge ResourceType
      for i in 0..@aryResourceTypeList.size-1
        if xmldoc_in.elements[sprintf("//%s/%s", xmldoc_in.root.name, @aryResourceTypeList[i])] != nil
          @strResourceType = @aryResourceTypeList[i]
          break
        end
      end

      ## Create XML Header
      xmldoc_out.add(REXML::XMLDecl.new(version="1.0", encoding="UTF-8"))

      ## Create Root Element                                                                     
      @elmRoot = REXML::Element.new("dublin_core")
      @elmRoot.add_attribute("schema", "iugonet")
      xmldoc_out.add_element(@elmRoot)

      ## Create Element (@element='Filename')
      setElement("Filename", "none", File.basename(strInFile))

      ## Create Element (@element='ResourceID')
      ## Note:
      ##  In This Function, 'sprintf' is More Faster Than '+'.
      ##  Then, Use 'sprintf'. Ruby Problem??
      ##  ex: 'sprintf': 0.002891 [sec], '+': 0.004161 [sec]
#     setElement("ResourceID", "none", xmldoc_in.elements["//" + xmldoc_in.root.name + "/" + @strResourceType + "/ResourceID"].text)
      setElement("ResourceID", "none", xmldoc_in.elements[sprintf("//%s/%s/ResourceID", xmldoc_in.root.name, @strResourceType)].text)

      ## Create Element (@element='ResourceType')
      setElement("ResourceType", "none", @strResourceType)

      ## Read and Set Child Element
      readxml(xmldoc_in.root)

      #### Return ####
      return xmldoc_out

    ## on Error
    rescue => e
      @log.error("XMLUtil.rb#convSPASEtoDC: Rescued.")
      @log.error(e.class.to_s + ":" + e.message.to_s)
      return nil
    ensure
    end

  end


  ## ---------------------------------------------------------------- ##
  ## [method] readxml                                                 ##
  ## ---------------------------------------------------------------- ##
  def readxml(element)

    ##### Debug ####
#   @log.debug("START: XMLUtil.rb#readxml")

    ##### Exec ####

    ## Get Text (Element Value)
    strText = element.text

    ## Get XML Parameters
    if strText != nil && strText.strip != ""

      ## Get XPath (Cut Element Number)
      strXPath = (element.xpath).gsub(/\[[0-9]*\]/, "")

      ## Get Qualifier (for DSpace)
      strQualifier = strXPath.gsub(/\[[0-9]*\]/, "")
      strQualifier = strQualifier.gsub(/^\/[a-z]*/i, "")  # Delete Root Element ("/Spase")
      strQualifier = strQualifier.gsub(/^\/[a-z]*/i, "")  # Detele 2nd Element (ex. "/NumericalData")
      strQualifier = strQualifier.gsub(/\//, "")          # Delete Separator '/'

      ## Set into XML Document
      if strQualifier != nil && strQualifier != ""

        ## Matching
        if @aryXPathList.include?(strXPath) == true

          ## Write
          setElement(@strResourceType, strQualifier, @charutil.xmlEncode(strText))

          ## Add Time Range (Existing Logic)
          if strQualifier.include?("StartDate") || strQualifier.include?("StopDate")
            setDateTime(@strResourceType, strQualifier, @charutil.xmlEncode(strText))
          ## Add Location Range (Existing Logic)
          elsif strQualifier.include?("LocationLatitude")
            setLocationLatitude(@strResourceType, strQualifier, @charutil.xmlEncode(strText))
          elsif strQualifier.include?("LocationLongitude")
            setLocationLongitude(@strResourceType, strQualifier, @charutil.xmlEncode(strText))
          elsif strQualifier.include?("NorthernmostLatitude")
            setSpatialCoverageLatitude(@strResourceType, strQualifier, @charutil.xmlEncode(strText))
          elsif strQualifier.include?("SouthernmostLatitude")
            setSpatialCoverageLatitude(@strResourceType, strQualifier, @charutil.xmlEncode(strText))
          elsif strQualifier.include?("WesternmostLongitude") || strQualifier.include?("EasternmostLongitude")
            if strQualifier.include?("WesternmostLongitude")
              setSpatialCoverageWesternmostLongitude(@strResourceType, strQualifier, @charutil.xmlEncode(strText))
            elsif strQualifier.include?("EasternmostLongitude")
              setSpatialCoverageEasternmostLongitude(@strResourceType, strQualifier, @charutil.xmlEncode(strText))
            end
            if @wl && @el
              setSpatialCoverageLongitude
            end
          end

        end
      end
    end

    ## If element has child...
    if element.has_elements? then
      element.each_element do |elemchild|
        readxml(elemchild)
      end
    end

    ##### Debug ####
#   @log.debug("END: XMLUtil.rb#readxml")

  end


  ## ---------------------------------------------------------------- ##
  ## [method] setElement                                              ##
  ## ---------------------------------------------------------------- ##
  def setElement(strElement, strQualifier, strText)

    #### Exec ####
    begin
      ## Create Element
      elmChild = REXML::Element.new("dcvalue")
      elmChild.add_attribute("element",   @charutil.xmlEncode(strElement))
      elmChild.add_attribute("qualifier", @charutil.xmlEncode(strQualifier))
      elmChild.add_text(@charutil.xmlEncode(strText))
      @elmRoot.add_element(elmChild)
    ## on Error
    rescue => e
      @log.error("XMLUtil.rb#setElement: Rescued.")
      @log.error(e.class.to_s + ":" + e.message.to_s)
    ensure
    end

  end


  ## ---------------------------------------------------------------- ##
  ## [method] setDateTime                                             ##
  ## ---------------------------------------------------------------- ##
  def setDateTime(strElement, strQualifier, strText)

    #### Define ####
    strRangeExtension = "RangeSearch"

    #### Exec ####
    if strQualifier != nil
      strQualifier = strQualifier + strRangeExtension
    end
    begin
      t = DateTime.parse(strText)
      st = t.strftime(DateFormat)
      setElement(strElement, strQualifier, st)
    rescue => e
    end
  end


  ## ---------------------------------------------------------------- ##
  ## [method] setLocationLatitude                                     ##
  ## ---------------------------------------------------------------- ##
  def setLocationLatitude(strElement, strQualifier, strText)

    #### Define ####
    strRangeExtension = "RangeSearch"
    intShiftSpatialCoverage = 100000.0
    strSpatialCoverageFormat = "%08d"

    #### Exec ####
    if strQualifier != nil
      strQualifier = strQualifier + strRangeExtension
    end
    tf = strText.to_f
    if -90.0 < tf && tf < 90.0
      ti = ((tf + 90.0) * intShiftSpatialCoverage).to_i
      ts = sprintf(strSpatialCoverageFormat, ti)
      setElement(strElement, strQualifier, ts)
    else
    end

  end

  ## ---------------------------------------------------------------- ##
  ## [method] setLocationLongigude                                    ##
  ## ---------------------------------------------------------------- ##
  def setLocationLongitude(strElement, strQualifier, strText)

    #### Define ####
    strRangeExtension = "RangeSearch"
    intShiftSpatialCoverage = 100000.0
    strSpatialCoverageFormat = "%08d"

    #### Exec ####
    tf = strText.to_f
    if tf >= 0.0
    else
      tf = tf + 360.0
    end
    ti = (tf * intShiftSpatialCoverage).to_i
    ts = sprintf(strSpatialCoverageFormat, ti );
    strQualifier1 = strQualifier + strRangeExtension + "1"
    strQualifier2 = strQualifier + strRangeExtension + "2"
    setElement(strElement, strQualifier1, ts)
    setElement(strElement, strQualifier2, ts)

  end

  ## ---------------------------------------------------------------- ##
  ## [method] setSpatialCoverageLatitude                              ##
  ## ---------------------------------------------------------------- ##
  def setSpatialCoverageLatitude(strElement, strQualifier, strText)

    #### Define ####
    strRangeExtension = "RangeSearch"
    intShiftSpatialCoverage = 100000.0
    strSpatialCoverageFormat = "%08d"

    #### Exec ####
    if strQualifier != nil
      strQualifier = strQualifier + strRangeExtension
    end
    tf = strText.to_f
    if -90.0 < tf && tf < 90.0
      ti = ((tf + 90.0) * intShiftSpatialCoverage).to_i
      st = sprintf(strSpatialCoverageFormat, ti)
      setElement(strElement, strQualifier, st)
    else
    end

  end


  ## ---------------------------------------------------------------- ##
  ## [method] setSpatialCoverageLongitude                             ##
  ## ---------------------------------------------------------------- ##
  def setSpatialCoverageLongitude(strElement, strQualifier, strText)

    #### Define ####
    strRangeExtension = "RangeSearch"
    intShiftSpatialCoverage = 100000.0
    strSpatialCoverageFormat = "%08d"

    #### Exec ####
    if strQualifier != nil
      strQualifier = strQualifier + strRangeExtension
    end
    tf = strText.to_f
    if -360.0 < tf && tf < 360.0
      ti = ((tf + 360.0) * intShiftSpatialCoverage).to_i
      st = sprintf(strSpatialCoverageFormat, ti )
      setElement(strElement, strQualifier, st)
      tfb = tf - 360.0
      if -360.0 < tfb && tfb < 360.0
        ti = ((tfb + 360.0) * intShiftSpatialCoverage).to_i
        st = sprintf(strSpatialCoverageFormat, ti)
        setElement(strElement, strQualifier, st)
      end
      tff = tf + 360.0
      if -360.0 < tff && tff < 360.0
        ti = ((tff + 360.0) * intShiftSpatialCoverage).to_i
        st = sprintf(strSpatialCoverageFormat, ti)
        setElement(strElement, strQualifier, st)
      end
    else
    end

  end

  ## ---------------------------------------------------------------- ##
  ## [method] setSpatialCoverageLongitude                             ##
  ## ---------------------------------------------------------------- ##
  def setSpatialCoverageLongitude

    #### Define ####
    strRangeExtension = "RangeSearch"
    intShiftSpatialCoverage = 100000.0
    strSpatialCoverageFormat = "%08d"

    #### Exec ####
    wl = @wl_text.to_f
    el = @el_text.to_f

    if wl > el
      @log.error("XMLUtil.rb#setSpatialCoverageLongitude: Error: Westernmost Longitude > Easternmost Longitude")
      @log.error("XMLUtil.rb#setSpatialCoverageLongitude: Westernmost: " + wl)
      @log.error("XMLUtil.rb#setSpatialCoverageLongitude: Easternmost: " + el)
      exit
    end

    if wl >= -360.0 && wl <= 360.0
    else
      @log.error("XMLUtil.rb#setSpatialCoverageLongitude: Error: wl = "  + wl)
    end
    if el >= -360.0 && el <= 360.0
    else
      @log.error("XMLUtil.rb#setSpatialCoverageLongitude: Error: el = " + el)
    end

    if wl >= 0.0 && el >= 0.0
    else
      wl = wl + 360.0
      el = el + 360.0
    end

    if wl >= 0.0 && wl <= 360.0 && el >= 0.0 && el <= 360.0
      strQualifier = @wl_qualifier + strRangeExtension + "1"
      wi = (wl * intShiftSpatialCoverage).to_i
      ws = sprintf(strSpatialCoverageFormat, wi)
      setElement(@wl_element, strQualifier, ws)
      strQualifier = @el_qualifier + strRangeExtension + "1"
      ei = (el * intShiftSpatialCoverage).to_i
      es = sprintf(strSpatialCoverageFormat, ei)
      setElement(@el_element, strQualifier, es)
    end

    if wl >= 0.0 && wl <= 360.0 && el >= 360.0 && el <= 720.0
      strQualifier = @wl_qualifier + strRangeExtension + "1"
      wi = (wl * intShiftSpatialCoverage).to_i
      ws = sprintf(strSpatialCoverageFormat, wi)
      setElement(@wl_element, strQualifier, ws)

      strQualifier = @el_qualifier + strRangeExtension + "1"
      ei = (360.0 * intShiftSpatialCoverage).to_i
      es = sprintf(strSpatialCoverageFormat, ei)
      setElement(@el_element, strQualifier, es)

      strQualifier = @wl_qualifier + strRangeExtension + "2"
      wi = (0.0 * intShiftSpatialCoverage).to_i
      ws = sprintf(strSpatialCoverageFormat, wi)
      setElement(@wl_element, strQualifier, ws)

      strQualifier = @el_qualifier + strRangeExtension + "2"
      ei = ((el-360.0) * intShiftSpatialCoverage).to_i
      es = sprintf(strSpatialCoverageFormat, ei)
      setElement(@el_element, strQualifier, es)

    end
    ## Flag to false
    @wl = false
    @el = false

  end


  ## ---------------------------------------------------------------- ##
  ## [method] setSpatialCoverageWesternmostLongitude                  ##
  ## ---------------------------------------------------------------- ##
  def setSpatialCoverageWesternmostLongitude(strElement, strQualifier, strText)
    #### Exec ####
    @wl_element   = strElement
    @wl_qualifier = strQualifier
    @wl_text      = strText
    @wl           = true
  end

  ## ---------------------------------------------------------------- ##
  ## [method] setSpatialCoverageEasternmostLongitude                  ##
  ## ---------------------------------------------------------------- ##
  def setSpatialCoverageEasternmostLongitude(strElement, strQualifier, strText)
    #### Exec ####
    @el_element   = strElement
    @el_qualifier = strQualifier
    @el_text      = strText
    @el           = true
  end


  ## ---------------------------------------------------------------- ##
  ## [method] createImportStructureXMLCommunity                       ##
  ## ---------------------------------------------------------------- ##
  def createImportStructureXMLCommunity(strCommunityName)

    #### Debug ####
    @log.debug("START: XMLUtil.rb#createImportStructureXMLCommunity")

    #### Define ####

    #### Exec ####
    begin

      ## Define XML Document
      xmldoc_out = REXML::Document.new()

      ## Create XML Header
      xmldoc_out.add(REXML::XMLDecl.new(version="1.0", encoding="UTF-8"))

      ## Create Root Element: //import_structure
      elmImportStructure = REXML::Element.new("import_structure")
      xmldoc_out.add_element(elmImportStructure)

      ## Create Element: //import_structure/community
      elmCommunity = REXML::Element.new("community")
      elmImportStructure.add_element(elmCommunity)

      ## Create Element: //import_structure/community/name
      elmName = REXML::Element.new("name")
      elmName.add_text(@charutil.xmlEncode(strCommunityName))
      elmCommunity.add_element(elmName)

      ## Create Element: //import_structure/community/description
      elmDescription = REXML::Element.new("description")
      elmDescription.add_text(@charutil.xmlEncode(strCommunityName))
      elmCommunity.add_element(elmDescription)

      ## Debug
      @log.debug("XMLUtil.rb#createImportStructureXMLCommunity: xmldoc_out = [" + xmldoc_out.to_s + "]")

      ## Return
      return xmldoc_out

    ## on Error
    rescue => e
      ## Debug
      @log.error("XMLUtil.rb#createImportStructureXMLCommunity: Error Occurred on Creating ImportStructure of Community.")
      @log.error(e.class.to_s + ":" + e.message.to_s)
      ## Return
      return nil
    ensure
      #### Debug ####
      @log.debug("END: XMLUtil.rb#createImportStructureXMLCommunity")
    end

  end


  ## ---------------------------------------------------------------- ##
  ## [method] createImportStructureXMLCollection                      ##
  ## ---------------------------------------------------------------- ##
  def createImportStructureXMLCollection(strCollectionName)

    #### Debug ####
    @log.debug("START: XMLUtil.rb#createImportStructureXMLCollection")

    #### Define ####


    #### Exec ####
    begin

      ## Define XML Document
      xmldoc_out = REXML::Document.new()

      ## Create XML Header
      xmldoc_out.add(REXML::XMLDecl.new(version="1.0", encoding="UTF-8"))

      ## Create Root Element: //import_structure
      elmImportStructure = REXML::Element.new("import_structure")
      xmldoc_out.add_element(elmImportStructure)

      ## Create Element: //import_structure/collection
      elmCollection = REXML::Element.new("collection")
      elmImportStructure.add_element(elmCollection)

      ## Create Element: //import_structure/collection/name
      elmName = REXML::Element.new("name")
      elmName.add_text(@charutil.xmlEncode(strCollectionName))
      elmCollection.add_element(elmName)

      ## Create Element: //import_structure/collection/description
      elmDescription = REXML::Element.new("description")
      elmDescription.add_text(@charutil.xmlEncode(strCollectionName))
      elmCollection.add_element(elmDescription)

      ## Debug
      @log.debug("XMLUtil.rb#createImportStructureXMLCollection: xmldoc_out = [" + xmldoc_out.to_s + "]")

      ## Return
      return xmldoc_out

    ## on Error
    rescue => e
      ## Debug
      @log.error("XMLUtil.rb#createImportStructureXMLCollection: Error Occurred on Creating ImportStructure of Collection.")
      @log.error(e.class.to_s + ":" + e.message.to_s)
      ## Return
      return nil
    ensure
      #### Debug ####
      @log.debug("END: XMLUtil.rb#createImportStructureXMLCollection")
    end

  end


end
