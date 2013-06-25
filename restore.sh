#!/bin/bash
# ----------------------------------------------------------------------------------- #
#  restore.sh for IUGONET ver 0.10
#  Released on 2013.04.12, STEL, N.UMEMURA
# ----------------------------------------------------------------------------------- #
#  -- INTRODUCTION --
#  This Script Restores Database Using Archive Data.
#
#  -- HOW TO RUN --
#  Run this command by SuperUser.
#  # ./restore.sh [-d ARCHIVE_DIRECTORY] [-h] [--no-header]
#  Options:
#    -d [ARCHIVE_DIRECTORY] : Set Directory to Restore.
#    -h                     : Show Help.
#    --no-header            : Do NOT Set Header and Footer (For System).
#
#  -- MORE DETAILS --
#  See Operation Manual or Development Manual.
#
# ----------------------------------------------------------------------------------- #
#

#### [START] Define ###################################################################

#### Invariable Parameters ####
## Env
PIDFILE='g2d.pid'
DIR_ARCHIVE_BASE=${G2D_HOME}'/archive'
DIR_ARCHIVE_BACKUP=${DIR_ARCHIVE_BASE}'/backup'
DIR_ARCHIVE_DEFAULT=${DIR_ARCHIVE_BASE}'/default'
RESTORE_LOG='/tmp/g2d-restore.log'
## Variables
EXECCODE=0
HFLAG=0          ## Do or Not Add Headers
TDIR=""          ## Archive Directory to Restore (Set Later)
## Utils
CDS=${G2D_HOME}'/src/shell/lib/CreateDate.sh'

#### Function ####
_start() {
  if [ ${HFLAG} = 0 ]; then
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
    echo `${CDS}`' ##                   [restore.sh] Git2DSpace RESTORE  START                   ##'
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
    echo `${CDS}`' ## INTRODUCTION:                                                              ##'
    echo `${CDS}`' ##   This Script Restores Database Using Archive Data.                        ##'
    echo `${CDS}`' ## VERSION INFORMATION:                                                       ##'
    echo `${CDS}`' ##   ver.0.10: Released on 2013.04.12, STEL, N.UMEMURA                        ##'
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
    echo `${CDS}`
  fi
}
_help() {
  echo `${CDS}`' ###HELP> Usage:'
  echo `${CDS}`' ###HELP>   $ ./restore.sh [-d ARCHIVE_DIRECTORY] [-h]'
  echo `${CDS}`' ###HELP> Options:'
  echo `${CDS}`' ###HELP>   -d [ARCHIVE_DIRECTORY] : Set Archive Directory to Restore.'
  echo `${CDS}`' ###HELP>                          : (Archive Directory is in $G2D_HOME/archive/backup).'
  echo `${CDS}`' ###HELP>   -h                     : Show Help.'
  echo `${CDS}`' ###HELP> Example:'
  echo `${CDS}`' ###HELP>   $ ./restore.sh -d 20130411.151058'
  echo `${CDS}`' ###HELP> Others:'
  echo `${CDS}`' ###HELP>   See Operation Maunal for Details.'
  echo `${CDS}`
}
_error() {
  echo `${CDS}`' !!ERROR> Program Exit. See Operation Manual.'
}
_end() {
  if [ ${HFLAG} = 0 ]; then
    echo `${CDS}`
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
    echo `${CDS}`' ##                    [restore.sh] Git2DSpace RESTORE  END                    ##'
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  fi
}
_exit0() {
  exit 0
}
_exit1() {
  exit 1
}


#### [START] Get Args #################################################################

#### Get Args ####
ARGS=`getopt -o :hd: -l no-header -- "$@"`

#### Check Args ####
## Arg Error --> exit 1
if [ $? -ne 0 ]; then
  echo `${CDS}`' !!ERROR> Invalid Argument.'
  _help
  _exit1
fi

#### ReSet Args ####
eval set -- $ARGS

#### Catch Args ####
until [ $1 = "--" ];
do
  case $1 in
  ## Case: Set Directory to Restore
  -d)
    EXECCODE=1
    TDIR=$2
    ;;
  ## Case: Help
  -h)
    _help
    _exit0
    ;;
  ## Case: Do NOT Add Header
  --no-header)
    EXECCODE=1
    HFLAG=1
    ;;
  esac
  shift
done
shift

#### Check ExecCode ####
if [ "${EXECCODE}" = "0" ]; then
  echo `${CDS}`' !!ERROR> No Argument.'
  _help
  _exit1
fi



#### [START] Exec #####################################################################

#### Debug ####
_start



#### [START] Step.1: Check User #######################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                        [Step.1] Check Current User                         ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Debug ####
echo -n `${CDS}`' ###INFO> Checking Current User... '

#### Exec ####
WHOAMI=`whoami 2>/dev/null`
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Check Current User!'
  _error
  _end
  _exit1
fi
## Not root --> exit 1
if [ ${WHOAMI} != 'root' ]; then
  echo '[FAILED]'
  echo `${CDS}`' !!ERROR> Only root can Run This Script.'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo ${WHOAMI}' [OK]'

#### Debug ####
echo `${CDS}`


#### Sleep ####
sleep 2



#### [START] Step.2: Check Process ####################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                         [Step.2] Check G2D Process                         ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Change Directory ####
cd ${G2D_HOME}

#### Debug ####
echo -n `${CDS}`' ###INFO> Checking G2D Process... '

#### Check Process ####
if [ -f ${PIDFILE} ]; then
  PROCESSNUM=`ps -p \`cat ${PIDFILE}\` | wc -l 2>/dev/null`
  ## on Error: Already Running --> exit 1
  if [ $PROCESSNUM -gt 1 ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> G2D is Running Now! Cannot Run This Script When G2D is Running.'
    _error
    _end
    _exit1
  fi
fi
## on Normal --> Go Next
echo ' G2D is NOT Running [OK]'

#### Debug ####
echo `${CDS}`


#### Sleep ####
sleep 2



#### [START] Step.3: Check Archive Data to Restore ####################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                   [Step.3] Check Archive Data to Restore                   ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Debug ####
echo -n `${CDS}`' ###INFO> Checking Archive Data to Restore... '

#### Change Directory ####
cd ${G2D_HOME}

#### Check ARCHIVE_DIR_BASE ####
## on Error (Not Exist) --> exit 1
if [ ! -d ${ARCHIVE_DIR_BASE} ]; then
   echo '[Failed]'
   echo `${CDS}`' !!ERROR> Archive Data Not Found!'
   echo `${CDS}`' !!ERROR> Directory --> ['${ARCHIVE_DIR_BASE}']'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next


#### Archive Directory Exists?  ####
case ${TDIR} in
  ## Case: default
  default)
    ## on Error --> exit 1
    if [ ! -d ${DIR_ARCHIVE_DEFAULT} ]; then
      echo '[Failed]'
      echo `${CDS}`' !!ERROR> Archive Data Not Found!'
      echo `${CDS}`' !!ERROR> Directory --> ['${ARCHIVE_DIR_BASE}']'
      _error
      _end
      _exit1
    fi
    ## on Normal --> Go Next
    echo '[OK]'
    ## Set Target Directory (Overwrite $TDIR)
    TDIR=${DIR_ARCHIVE_DEFAULT}
    ## Debug
    echo `${CDS}`' ###INFO> Archive Data to Restore --> ['${TDIR}']'
    ;;
  ## Case: HEAD
  HEAD*)
    ## Count Number of '^'
    CNUM=`echo ${TDIR} | tr -dc '^' 2>/dev/null`
    CNUM=${#CNUM}
    ## Change Directory
    cd ${DIR_ARCHIVE_BACKUP} 2>/dev/null
    ## on Error --> exit 1
    if [ $? != "0" ]; then
      echo '[Failed]'
      echo `${CDS}`' !!ERROR> Archive Data Not Found!'
      echo `${CDS}`' !!ERROR> Directory --> ['${ARCHIVE_DIR_BACKUP}']'
      _error
      _end
      _exit1
    fi
    ## Set Directory List
    ARCHIVELIST=(`ls -r 2>/dev/null`)
    ## on Error --> exit 1
    if [ $? != "0" ]; then
      echo '[Failed]'
      echo `${CDS}`' !!ERROR> Could Not Set List of Archive Data!'
      echo `${CDS}`' !!ERROR> Directory --> ['${ARCHIVE_DIR_BACKUP}']'
      _error
      _end
      _exit1
    fi
    ## Count Number of Archive Directories
    ARCHIVELISTNUM=${#ARCHIVELIST[*]}
    ## on Error --> exit 1
    if [ $? != "0" ]; then
      echo '[Failed]'
      echo `${CDS}`' !!ERROR> Could Not Set List of Archive Data!'
      echo `${CDS}`' !!ERROR> Directory --> ['${ARCHIVE_DIR_BACKUP}']'
      _error
      _end
      _exit1
    fi
    ## Check Target Directory Exists?  on Error --> Exit 1
    if [ ${CNUM} -ge ${ARCHIVELISTNUM} ]; then
      echo '[Failed]'
      echo `${CDS}`' !!ERROR> Could Not Find Archive Data to Restore!'
      echo `${CDS}`' !!ERROR> Your Input --> ['${TDIR}']'
      _error
      _end
      _exit1
    fi
    ## on Normal --> Go Next
    echo '[OK]'
    ## on Normal --> Set Target Directory (Overwrite $TDIR)
    TDIR=${ARCHIVELIST[$CNUM]}
    ## Judge Directory or File?
    case $TDIR in
      ## Case: .tar.gz File
      *.tar.gz)
        ## Change Directory
	cd ${DIR_ARCHIVE_BACKUP} 2>/dev/null
        ## on Error --> exit 1
	if [ $? != "0" ]; then
          echo `${CDS}`' !!ERROR> Could NOT Change Directory!'
          echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE_BACKUP}']'
          _error
          _end
          _exit1
        fi
        ## Debug
        echo -n `${CDS}`' ###INFO> Decompressing '${TDIR}'... '
        ## Decompress
        tar -xzf ${TDIR} 2>/dev/null
        ## on Error --> exit 1
	if [ $? != "0" ]; then
          echo '[Failed]'
          echo `${CDS}`' !!ERROR> Could NOT Decompressing '${TDIR}
          echo `${CDS}`' !!ERROR> File --> ['${TDIR}']'
          _error
          _end
          _exit1
        fi
        ## Change Mode
        chmod 775 ${TDIR/.tar.gz/} 2>/dev/null
        ## on Error --> exit 1
	if [ $? != "0" ]; then
          echo '[Failed]'
          echo `${CDS}`' !!ERROR> Could NOT Change Mode!'
          echo `${CDS}`' !!ERROR> Directory --> ['${TDIR/.tar.gz/}']'
          _error
          _end
          _exit1
        fi
        ## Debug
        echo '[OK]'
        ## Delete .tar.gz File
        rm -f ${TDIR} > /dev/null 2>&1
        ## Set Target Directory (Overwrite $TDIR)
        TDIR=${DIR_ARCHIVE_BACKUP}'/'${TDIR/.tar.gz/}
        ## Debug
        echo `${CDS}`' ###INFO> Archive Data to Restore --> ['${TDIR}']'
	;;
      ## Case: Directory
      *)
        ;;
    esac
    ;;
  ## Case: Directory Name or *.tar.gz File
  *)
    ## Get Directory or File Name (Delete Path).
    TDIR=${TDIR##*/}
    ## Judge Directory or File?
    case $TDIR in
      ## Case: .tar.gz File
      *.tar.gz)
        ## Check Exist or Not?  on Error --> exit 1
        if [ ! -r ${DIR_ARCHIVE_BACKUP}'/'${TDIR} ]; then
          echo '[Failed]'
          echo `${CDS}`' !!ERROR> Archive Data Not Found!'
          echo `${CDS}`' !!ERROR> Your Input --> ['${DIR_ARCHIVE_BACKUP}'/'${TDIR}']'
          _error
          _end
          _exit1
        fi
        ## on Normal
        echo '[OK]'
        echo `${CDS}`' ###INFO> Your Input --> ['${DIR_ARCHIVE_BACKUP}'/'${TDIR}']'
        ## Change Directory
	cd ${DIR_ARCHIVE_BACKUP} 2>/dev/null
        ## on Error --> exit 1
	if [ $? != "0" ]; then
          echo '[Failed]'
          echo `${CDS}`' !!ERROR> Could NOT Change Directory!'
          echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE_BACKUP}']'
          _error
          _end
          _exit1
        fi
        ## Debug
        echo -n `${CDS}`' ###INFO> Decompressing '${TDIR}'... '
        ## Decompress
        tar -xzf ${TDIR} 2>/dev/null
        ## on Error --> exit 1
	if [ $? != "0" ]; then
          echo '[Failed]'
          echo `${CDS}`' !!ERROR> Could NOT Decompressing '${TDIR}
          echo `${CDS}`' !!ERROR> File --> ['${TDIR}']'
          _error
          _end
          _exit1
        fi
        ## Change Mode
        chmod 775 ${TDIR/.tar.gz/} 2>/dev/null
        ## on Error --> exit 1
	if [ $? != "0" ]; then
          echo '[Failed]'
          echo `${CDS}`' !!ERROR> Could NOT Change Mode!'
          echo `${CDS}`' !!ERROR> Directory --> ['${TDIR/.tar.gz/}']'
          _error
          _end
          _exit1
        fi
        ## Debug
        echo '[OK]'
        ## Delete .tar.gz File
        rm -f ${TDIR} > /dev/null 2>&1
        ## Set Target Directory (Overwrite $TDIR)
        TDIR=${DIR_ARCHIVE_BACKUP}'/'${TDIR/.tar.gz/}
        ## Debug
        echo `${CDS}`' ###INFO> Archive Data to Restore --> ['${TDIR}']'
	;;
      ## Case: Directory
      *)
        ## Check Exist or Not?  on Error --> exit 1
        if [ ! -d ${DIR_ARCHIVE_BACKUP}'/'${TDIR} ]; then
          echo '[Failed]'
          echo `${CDS}`' !!ERROR> Archive Data Not Found!'
          echo `${CDS}`' !!ERROR> Your Input --> ['${DIR_ARCHIVE_BACKUP}'/'${TDIR}']'
          _error
          _end
          _exit1
        fi
        ## on Normal
        echo '[OK]'
        ## Set Target Directory (Overwrite $TDIR)
        TDIR=${DIR_ARCHIVE_BACKUP}'/'${TDIR}
        ## Debug
        echo `${CDS}`' ###INFO> Archive Data to Restore --> ['${TDIR}']'
	;;
    esac
    ;;
esac


#### Debug ####
echo `${CDS}`

#### Sleep ####
sleep 2



#### [START] Step.4: Agreement ########################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                             [Step.4] Agreement                             ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Debug ####
echo `${CDS}`' ###INFO> When Continuing, There are Some Risks.'
echo `${CDS}`' ###INFO> - You Lost the Current Data on This Database System.'
echo `${CDS}`' ###INFO> - While this Script is Running, Database System Stops (Include Httpd).'
echo `${CDS}`' ###INFO> - This Restoration Requires Max 1 Day.'
echo `${CDS}`' ###INFO> - If Archive Data to Restore Have Some Problems,'
echo `${CDS}`' ###INFO>     - Database System May Not Start or Run.'
echo `${CDS}`' ###INFO>     - Database System May Have Data Inconsistent.'
echo `${CDS}`' ###INFO>'
echo -n `${CDS}`' ###INFO> Start Automatically in 180 Seconds. Do You Sure Continue? (y/n)?: '
read -t 180 CONTINUE
if [ "$CONTINUE" == "" ]; then
  CONTINUE='y'
  echo 'y'
fi

#### Get Arg ####
while :
do
  if [ "$CONTINUE" == "y" ]; then
    echo `${CDS}`' ###INFO> OK Continue!'
    break;
  elif [ "$CONTINUE" == "n" ]; then
    echo `${CDS}`' ###INFO> Cancelled.'
    _end
    _exit1
  else
    echo -n `${CDS}`' !!!WARN> Type y or n. (y/n)?: '
    read CONTINUE
  fi
done

#### Debug ####
echo `${CDS}`

#### Sleep ####
sleep 2



#### [START] Step.5: Shutdown Services ################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                         [Step.5] Shutdown Services                         ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Create File of RESTORE_LOG ####
if [ -f ${RESTORE_LOG} ]; then
  rm -f ${RESTORE_LOG} 2>/dev/null
fi
touch ${RESTORE_LOG} 2>/dev/null
chmod 666 ${RESTORE_LOG} 2>/dev/null


#### Shutdown Httpd ####
## Debug
echo -n `${CDS}`' ###INFO> Shutdown Httpd... '
## Exec
/etc/rc.d/init.d/httpd stop >> ${RESTORE_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Shutdown Httpd!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 10


#### Shutdown Tomcat ####
## Debug
echo -n `${CDS}`' ###INFO> Shutdown Tomcat... '
## Exec
/opt/tomcat/bin/shutdown.sh >> ${RESTORE_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Shutdown Tomcat!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 10


#### Shutdown PostgreSQL ####
## Debug
echo -n `${CDS}`' ###INFO> Shutdown PostgreSQL... '
## Exec
su pgsql -c "/usr/local/pgsql/bin/pg_ctl -m fast stop >> ${RESTORE_LOG} 2>&1"
## on Error --> exit 1
## NOTE:
##   When PosgreSQL Down Already, Receive Exit Code '1'.
##   Therefore, Pass Such Case.
#if [ $? != "0" ]; then
#  echo '[Failed]'
#  echo `${CDS}`' !!ERROR> Could NOT Shutdown PostgreSQL!'
#  _error
#  _end
#  _exit1
#fi
## on Normal --> Go Next
echo '[OK]'


#### Debug ####
echo `${CDS}`

#### Sleep ####
sleep 10



#### [START] Step.6: Restore PostgreSQL ###############################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                        [Step.6] Restore PostgreSQL                         ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Start PostgreSQL ####
## Debug
echo -n `${CDS}`' ###INFO> Starting PostgreSQL... '
## Exec
su pgsql -c "/usr/local/pgsql/bin/pg_ctl start >> ${RESTORE_LOG} 2>&1"
# on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Start PostgreSQL!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 10


#### Drop DB (dspace) ####
## Debug
echo -n `${CDS}`' ###INFO> Dropping Database (dspace)... '
## Exec
su dspace -c "dropdb dspace >> ${RESTORE_LOG} 2>&1"
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Drop Database (dspace)!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Drop DB (G2D) ####
## Debug
echo -n `${CDS}`' ###INFO> Dropping Database (G2D)... '
## Exec
su dspace -c "dropdb g2d >> ${RESTORE_LOG} 2>&1"
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Drop Database (G2D)!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Create DB (dspace) ####
## Debug
echo -n `${CDS}`' ###INFO> Creating Database (dspace)... '
## Exec
su dspace -c "createdb dspace >> ${RESTORE_LOG} 2>&1"
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Create Database (dspace)!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Create DB (G2D) ####
## Debug
echo -n `${CDS}`' ###INFO> Creating Database (G2D)... '
## Exec
su dspace -c "createdb g2d >> ${RESTORE_LOG} 2>&1"
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Create Database (G2D)!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Restore DB (dspace) ####
## Debug
echo -n `${CDS}`' ###INFO> Importing Database (dspace)... '
## Exec
su dspace -c "psql dspace < ${TDIR}/postgresql/dspace.dump" >> ${RESTORE_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Import Database (dspace)!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Restore DB (G2D) ####
## Debug
echo -n `${CDS}`' ###INFO> Importing Database (G2D)... '
## Exec
su dspace -c "psql g2d < ${TDIR}/postgresql/g2d.dump" >> ${RESTORE_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Import Database (G2D)!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Debug ####
echo `${CDS}`

#### Sleep ####
sleep 2



#### [START] Step.7: Restore Lucene Index #############################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                       [Step.7] Restore Lucene Index                        ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Delete Index ####
## Debug
echo -n `${CDS}`' ###INFO> Dropping Lucene Index... '
## Exec
su dspace -c "rm -rf /opt/dspace/search >> ${RESTORE_LOG} 2>&1"
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Drop Lucene Index!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Restore Index ####
## Debug
echo -n `${CDS}`' ###INFO> Rebuilding Lucene Index... '
## Exec
su dspace -c "cp -pr ${TDIR}/lucene/search /opt/dspace/. >> ${RESTORE_LOG} 2>&1"
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Rebuild Lucene Index!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Debug ####
echo `${CDS}`

#### Sleep ####
sleep 2



#### [START] Step.8: Restore AssetStore ###############################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                        [Step.8] Restore AssetStore                         ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Check AssetStore Exist in Archive Directory ####
## Debug
echo -n `${CDS}`' ###INFO> Checking AssetStore in Archive Directory... '
## Exec
if [ -d ${TDIR}/assetstore ]; then
  echo 'Found [OK]'
else
  echo 'Not Found [OK]'
fi


#### Delete AssetStore ####
## Debug
echo -n `${CDS}`' ###INFO> Dropping AssetStore... '
## Exec: Found --> Remove
if [ -d ${TDIR}/assetstore ]; then
  su dspace -c "rm -rf /opt/dspace/assetstore >> ${RESTORE_LOG} 2>&1"
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could NOT Drop AssetStore!'
    _error
    _end
    _exit1
  fi
  ## on Normal --> Go Next
  echo '[OK]'
## : Not Found --> Do Nothing
else
  echo '[Passed]'
fi


#### Restore AssetStore ####
## Debug
echo -n `${CDS}`' ###INFO> Rebuilding Lucene Index... '
## Exec: Found --> Restore
if [ -d ${TDIR}/assetstore ]; then
  su dspace -c "cp -pr ${TDIR}/assetstore /opt/dspace/. >> ${RESTORE_LOG} 2>&1"
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could NOT Drop AssetStore!'
    _error
    _end
    _exit1
  fi
  ## on Normal --> Go Next
  echo '[OK]'
## : Not Found --> Do Nothing
else
  echo '[Passed]'
fi

#### Debug ####
echo `${CDS}`

#### Sleep ####
sleep 2



#### [START] Step.9: Start Services ###################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                          [Step.9] Start Services                           ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Start Tomcat ####
## Debug
echo -n `${CDS}`' ###INFO> Starting Tomcat... '
## Exec
/opt/tomcat/bin/startup.sh >> ${RESTORE_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Start Tomcat!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 10


#### Start Httpd ####
## Debug
echo -n `${CDS}`' ###INFO> Start Httpd... '
## Exec Command
/etc/rc.d/init.d/httpd start >> ${RESTORE_LOG} 2>&1
## on Error --> exit(1)
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Start Httpd!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Debug ####
echo `${CDS}`

#### Sleep ####
sleep 2



#### [START] Finalize #################################################################

#### Debug ####
echo `${CDS}`' ## ************************************************************************** ## '
echo `${CDS}`' ##                          * * * COMPLETED!! * * *                           ##'
echo `${CDS}`' ##           Please Check the Database System is Running Correctly!           ##'
echo `${CDS}`' ## ************************************************************************** ## '

#### Debug ####
_end

#### Exit ####
_exit0

