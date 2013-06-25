# -*- coding : utf-8 -*-

## ------------------------------------------------------------------ ##
## [Command.rb]                                                       ##
## ------------------------------------------------------------------ ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
##                                                                    ##
## ------------------------------------------------------------------ ##

require './conf/Configure'

class Command


  ## ---------------------------------------------------------------- ##
  ## [define]                                                         ##
  ## ---------------------------------------------------------------- ##


  ## ---------------------------------------------------------------- ##
  ## [initialize]                                                     ##
  ## ---------------------------------------------------------------- ##
  def initialize
  end

  ## ---------------------------------------------------------------- ##
  ## [method] init                                                    ##
  ## ---------------------------------------------------------------- ##
  def init
  end

  ## ---------------------------------------------------------------- ##
  ## [method] final                                                   ##
  ## ---------------------------------------------------------------- ##
  def final
  end


  ## ---------------------------------------------------------------- ##
  ## [method] getGitCommandClone                                      ##
  ## ---------------------------------------------------------------- ##
  def getGitCommandClone(strURL, strAccount)
    return sprintf("%s clone ssh://%s@%s >> %s 2>&1", 
      Configure::COMMAND_GIT, strURL, strAccount, Configure::LOG_TRANSFER)
  end


  ## ---------------------------------------------------------------- ##
  ## [method] getGitCommandPull                                       ##
  ## ---------------------------------------------------------------- ##
  def getGitCommandPull
    return sprintf("%s pull >> %s 2>&1",
      Configure::COMMAND_GIT, Configure::LOG_TRANSFER)
  end


  ## ---------------------------------------------------------------- ##
  ## [method] getFindCommand                                          ##
  ## ---------------------------------------------------------------- ##
  def getFindCommand(strDirName)
    return sprintf("%s %s -type f | egrep \'.xml|.XML\' > %s",
      Configure::COMMAND_FIND, strDirName, Configure::TMPFILE_ADD_FORCE)
  end


  ## ---------------------------------------------------------------- ##
  ## [method] getGitCommandLog                                        ##
  ## ---------------------------------------------------------------- ##
  def getGitCommandLog(strSince, strUntil, strGrepMode)
    ## Judge Grep Mode
    if strGrepMode == nil
    elsif strGrepMode == "A"
      strGrepCommand = "grep ^A | grep -v ^Author"
      strOutFile = Configure::TMPFILE_AANDM
    elsif strGrepMode == "M"
      strGrepCommand = "grep ^M"
      strOutFile = Configure::TMPFILE_AANDM
    elsif strGrepMode == "D"
      strGrepCommand = "grep ^D | grep -v ^Date"
      strOutFile = Configure::TMPFILE_DELETE
    else
    end
    ## Return
    if strGrepMode == "M"
      return sprintf("%s log --since=\"%s\" --until=\"%s\" --name-status | %s | egrep \'.xml|.XML\' >> %s", 
          Configure::COMMAND_GIT, strSince, strUntil, strGrepCommand, strOutFile)
    else 
      return sprintf("%s log --since=\"%s\" --until=\"%s\" --name-status | %s | egrep \'.xml|.XML\' > %s", 
          Configure::COMMAND_GIT, strSince, strUntil, strGrepCommand, strOutFile)
    end
  end


  ## ---------------------------------------------------------------- ##
  ## [method] getDSpaceCommandAdd                                     ##
  ## ---------------------------------------------------------------- ##
  def getDSpaceCommandAdd(strHandleID, strDirName)
    return sprintf("%s -a -e %s -c %s -s %s -m %s", 
      Configure::DSPACE_IMPORT, Configure::DSPACE_DB_ADMIN, 
      Configure::HANDLE_ID_PREFIX + "/" + strHandleID, strDirName, 
      File.join(strDirName, "mapfile"))
  end


  ## ---------------------------------------------------------------- ##
  ## [method] getDSpaceCommandReplace                                 ##
  ## ---------------------------------------------------------------- ##
  def getDSpaceCommandReplace(strHandleID, strDirName)
    return sprintf("%s -r -e %s -c %s -s %s -m %s", 
      Configure::DSPACE_IMPORT, Configure::DSPACE_DB_ADMIN, 
      Configure::HANDLE_ID_PREFIX + "/" + strHandleID, strDirName, 
      File.join(strDirName, "mapfile"))
  end


  ## ---------------------------------------------------------------- ##
  ## [method] getDSpaceCommandDelete                                  ##
  ## ---------------------------------------------------------------- ##
  def getDSpaceCommandDelete(strDirName)
    return sprintf("%s -d -e %s -m %s", 
      Configure::DSPACE_IMPORT, Configure::DSPACE_DB_ADMIN,
      File.join(strDirName, "mapfile"))
  end


  ## ---------------------------------------------------------------- ##
  ## [method] getCommandCreateCommunity                               ##
  ## ---------------------------------------------------------------- ##
  def getCommandCreateCommunity(strInFile, strOutFile, strParentHandleID)
    ## Case: Top Hierarchy (ex. 'IUGONET') --> Add No Handle
    if strParentHandleID == nil || strParentHandleID == ""
      return sprintf("%s -e %s -f %s -o %s -t %s >> %s 2>&1",
        Configure::DSPACE_STRUCTURE, Configure::DSPACE_DB_ADMIN,
        strInFile, strOutFile, "community", Configure::LOG_DSPACE)
    ## Case: Child Hierarchy (ex. 'IUGONET/NumericalData') --> Add Parent Community's Handle
    else
      return sprintf("%s -e %s -f %s -o %s -h %s -t %s >> %s 2>&1",
        Configure::DSPACE_STRUCTURE, Configure::DSPACE_DB_ADMIN,
        strInFile, strOutFile, strParentHandleID, "community", Configure::LOG_DSPACE)
    end
  end

  ## ---------------------------------------------------------------- ##
  ## [method] getCommandCreateCollection                              ##
  ## ---------------------------------------------------------------- ##
  def getCommandCreateCollection(strInFile, strOutFile, strParentHandleID)
    return sprintf("%s -e %s -f %s -o %s -h %s -t %s >> %s 2>&1",
      Configure::DSPACE_STRUCTURE, Configure::DSPACE_DB_ADMIN,
      strInFile, strOutFile, strParentHandleID, "collection", Configure::LOG_DSPACE)
  end


end
