#!/bin/bash
# ----------------------------------------------------------------------------------- #
#  setup.sh for IUGONET ver 0.10
#  Released on 2013.04.05, STEL, N.UMEMURA
# ----------------------------------------------------------------------------------- #
#  -- INTRODUCTION --
#  This Script Setup the G2D System.
#
#  -- HOW TO RUN --
#  Run this command by SuperUser. (With No Args)
#  # ./setup.sh
#
#  -- MORE DETAILS --
#  See Operation Manual or Development Manual.
#
# ----------------------------------------------------------------------------------- #
#

#### [START] Define ###################################################################

#### Invariable Parameters ####
## Env etc.
SRC_SHELL=${G2D_HOME}'/src/shell'
DIR_ARCHIVE_BASE=${G2D_HOME}'/archive'
DIR_ARCHIVE_DEFAULT=${DIR_ARCHIVE_BASE}'/default'
SETUP_LOG='/tmp/g2d-setup.log'
DIR_LOG=${G2D_HOME}'/log'
## Target
DIR_LUCENE='/opt/dspace/search'
DIR_ASSET='/opt/dspace/assetstore'
DB_DSPACE='dspace'
DB_G2D='g2d'
## Utils
CDS=${SRC_SHELL}'/lib/CreateDate.sh'

#### Function ####
_start() {
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  echo `${CDS}`' ##                    [setup.sh] Git2DSpace SETUP  START                      ##'
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  echo `${CDS}`' ## INTRODUCTION:                                                              ##'
  echo `${CDS}`' ##   This Script Setup the Git2DSpace System (G2D).                           ##'
  echo `${CDS}`' ##   When This Script Finished Completely, Git2DSpace System (G2D) is Build,  ##'
  echo `${CDS}`' ##   and You Could Manage the Metadata Database Using This System.            ##'
  echo `${CDS}`' ## VERSION INFORMATION:                                                       ##'
  echo `${CDS}`' ##   ver.0.10: Released on 2013.04.05, STEL, N.UMEMURA                        ##'
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  echo `${CDS}`
}
_error() {
  echo `${CDS}`' !!ERROR> Program Exit. See Operation Manual.'
}
_end() {
  echo `${CDS}`
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  echo `${CDS}`' ##                     [setup.sh] Git2DSpace SETUP  END                       ##'
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
}
_exit0() {
  exit 0
}
_exit1() {
  exit 1
}


#### [START] Exec #####################################################################

#### Debug ####
_start

#### [START] Initialize ###############################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                              Initializing...                               ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'


#### Create Log File ####
## Debug
echo -n `${CDS}`' ###INFO> Creating Log File ('${SETUP_LOG}')... '
## Remove (If Already Exist)
if [ -f ${SETUP_LOG} ]; then
  rm -f ${SETUP_LOG} >/dev/null 2>&1
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could Not Delete Log File!'
    _error
    _end
    _exit1
  fi
fi
## Create Newly
touch ${SETUP_LOG} >/dev/null 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Create Log File!'
  _error
  _end
  _exit1
fi
## Change Owner
chown dspace.dspace ${SETUP_LOG} >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Change Owner of Log File!'
  _error
  _end
  _exit1
fi
## Change Mode SETUP_LOG
chmod 666 ${SETUP_LOG} >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Change Mode!'
  _error
  _end
  _exit1
fi
## on Normal All --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Create Log Directory ####
## Debug
echo -n `${CDS}`' ###INFO> Creating Log Directory ('${DIR_LOG}')... '
## Make Directory
if [ ! -d ${DIR_LOG} ]; then
  mkdir -p ${DIR_LOG} >> ${SETUP_LOG} 2>&1
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could Not Create Log Directory!'
    _error
    _end
    _exit1
  fi
fi
## Change Owner
chown dspace.dspace ${DIR_LOG} >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Create Log Directory!'
  _error
  _end
  _exit1
fi
## Change Mode SETUP_LOG
chmod 775 ${DIR_LOG} >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Create Log Directory!'
  _error
  _end
  _exit1
fi
## on Normal All --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Check Current User ####
## Debug
echo -n `${CDS}`' ###INFO> Checking Current User... '
## Exec
WHOAMI=`whoami 2>${SETUP_LOG}`
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Check Current User!'
  _error
  _end
  _exit1
fi
## Not root --> exit 1
if [ "${WHOAMI}" != "root" ]; then
  echo ${WHOAMI}' [Failed]'
  echo `${CDS}`' !!ERROR> Only root Can Run This Script!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo ${WHOAMI}' [OK]'

#### Sleep ####
sleep 2


#### Check Env Variable ($G2D_HOME) ####
## Debug
echo -n `${CDS}`' ###INFO> Checking Env Variable $G2D_HOME... '
## Exec
ECOUNT=`env | grep G2D_HOME | wc -l 2>/dev/null`
## on Error --> exit 1
if [ ${ECOUNT} -eq 0 ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Env Variable $G2D_HOME Not Found.'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Check Setup History ####
## Debug
echo -n `${CDS}`' ###INFO> Checking Setup History... '
## Exec
## on Error --> Disp Warning and Exit
if [ -r ${DIR_ARCHIVE_DEFAULT} ]; then
  echo '[Warning]'
  echo `${CDS}`' !!!WARN> Found the History of Setup!'
  echo `${CDS}`' !!!WARN> If Continuing this Script, You Lose the Important Initial Data to Operate Metadata Database!!'
  echo `${CDS}`' !!!WARN> Directory Contains Initial Data --> ['${DIR_ARCHIVE_DEFAULT}']'
  echo `${CDS}`' !!!WARN> If You Want to Continue,'
  echo `${CDS}`' !!!WARN> - First, Move This Initial Directory to Another Directory on Manual.'
  echo `${CDS}`' !!!WARN> - Next, Delete This Initial Directory on Manual.'
  echo `${CDS}`' !!!WARN> - Finally, Run This Script Again.'
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Do You Continue? ####
## Debug
echo `${CDS}`' ###INFO>'
echo `${CDS}`' ###INFO> OK, Ready to Continue.'
echo `${CDS}`' ###INFO> When This Script Finished Completely, Git2DSpace System (G2D) is Build,'
echo `${CDS}`' ###INFO> and You Could Manage the Metadata Database Using This System.'
echo `${CDS}`' ###INFO> ATTENTION!!'
echo `${CDS}`' ###INFO>   - While This Script is Running,'
echo `${CDS}`' ###INFO>     Httpd, Tomcat and PostgreSQL Services Stops!'
echo `${CDS}`' ###INFO>   - This Setup Requires About 3-5 Minutes.'
echo `${CDS}`' ###INFO>'
echo -n `${CDS}`' ###INFO> Start Automatically in 180 Seconds. Do You Continue? (y/n)?: '
## Read Arg
read -t 180 CONTINUE
if [ "${CONTINUE}" = "" ]; then
  CONTINUE='y'
  echo 'y'
fi
## Judge Arg
while :
do
  if [ "${CONTINUE}" = "y" ]; then
    echo `${CDS}`' ###INFO> OK Continue!'
    break;
  elif [ "${CONTINUE}" = "n" ]; then
    echo `${CDS}`' ###INFO> Cancelled.'
    _end
    _exit0
  else
    echo -n `${CDS}`' !!!WARN> Type y or n. (y/n)?: '
    read CONTINUE
  fi
done

#### Debug ####
echo `${CDS}`

#### Sleep ####
sleep 2



#### [START] Step.1: Shutdown Services ################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                         [Step.1] Shutdown Services                         ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Shutdown Httpd ####
## Debug
echo -n `${CDS}`' ###INFO> Shutdown Httpd... '
## Exec Command
/etc/rc.d/init.d/httpd stop >> ${SETUP_LOG} 2>&1
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
sleep 5


#### Shutdown Tomcat ####
## Debug
echo -n `${CDS}`' ###INFO> Shutdown Tomcat... '
## Exec Command
/opt/tomcat/bin/shutdown.sh >> ${SETUP_LOG} 2>&1
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
sleep 5


#### Shutdown PostgreSQL ####
## Debug
echo -n `${CDS}`' ###INFO> Shutdown PostgreSQL... '
## Exec Command (Shutdown)
su pgsql -c "/usr/local/pgsql/bin/pg_ctl -m fast stop >> ${SETUP_LOG} 2>&1"
## on Error --> exit 1
## NOTE:
##   When PG is Down Already, Receive Exit Code '1'.
##   Therefore, Throw in This Case.
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
sleep 5



#### [START] Step.2: Install PG Library on Ruby #######################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                    [Step.2] Install PG Library on Ruby                     ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Install PG Library on Ruby ####
## Debug
echo -n `${CDS}`' ###INFO> Install PG Library on Ruby... '
## Exec (gem)
gem install pg >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Install PG Library on Ruby!'
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



#### [START] Step.3: Create ADMIN-DB for g2d ##########################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                     [Step.3] Create Admin-DB for G2D                       ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Start PostgreSQL ####
## Debug
echo -n `${CDS}`' ###INFO> Starting PostgreSQL... '
## Exec Command (Shutdown)
su pgsql -c "/usr/local/pgsql/bin/pg_ctl start >> ${SETUP_LOG} 2>&1"
## on Error --> exit 1
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


#### Create Database ####
## Debug
echo -n `${CDS}`' ###INFO> Creating Admin-DB... '
## DropDB
su dspace -c "dropdb ${DB_G2D} >> ${SETUP_LOG} 2>&1"
## CreateDB
su dspace -c "createdb ${DB_G2D} >> ${SETUP_LOG} 2>&1"
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Create Admin-DB!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Create Tables ####
## Debug
echo `${CDS}`' ###INFO> Creating Tables in the Admin-DB...'
## Create Tables
su dspace -c "${SRC_SHELL}/lib/CreateTables.sh 2>>${SETUP_LOG}"
## on Error --> exit 1
if [ $? != "0" ]; then
  echo `${CDS}`' !!ERROR> Could NOT Create Tables in the Admin-DB!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo `${CDS}`' ###INFO> Creating Tables in the Admin-DB... [OK]'

#### Debug ####
echo `${CDS}`

#### Sleep ####
sleep 2



#### [START] Step.4: Backup Initial Data in PostgreSQL and Lucene #####################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                        [Step.4] Backup Initial Data                        ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Make Directory ####
## Debug
echo -n `${CDS}`' ###INFO> Making Backup Directory... '
## Make Directory (Parent)
mkdir -p ${DIR_ARCHIVE_BASE} >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Create Backup Directory!'
  _error
  _end
  _exit1
fi
## Make Directory (Child)
mkdir -p ${DIR_ARCHIVE_DEFAULT} >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Create Backup Directory!'
  _error
  _end
  _exit1
fi
## Make Directory (for PostgreSQL)
mkdir -p ${DIR_ARCHIVE_DEFAULT}/postgresql >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Create Backup Directory!'
  _error
  _end
  _exit1
fi
## Make Directory (for Lucene)
mkdir -p ${DIR_ARCHIVE_DEFAULT}/lucene >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Create Backup Directory!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'
echo `${CDS}`' ###INFO> Backup Directory --> ['${DIR_ARCHIVE_DEFAULT}']'

#### Sleep ####
sleep 2


#### Change Owner ####
## Debug
echo -n `${CDS}`' ###INFO> Changing Owner of Backup Directory... '
## Exec
chown -R dspace.dspace ${DIR_ARCHIVE_BASE} >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Change Owner of Backup Directory!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Change Mode ####
## Debug
echo -n `${CDS}`' ###INFO> Changing Mode of Backup Directory... '
## Change Mode (Child)
chmod 775 ${DIR_ARCHIVE_BASE} >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Change Mode of Backup Directory!'
  _error
  _end
  _exit1
fi
## Change Mode (Child)
chmod 775 ${DIR_ARCHIVE_DEFAULT} >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Change Mode of Backup Directory!'
  _error
  _end
  _exit1
fi
## Change Mode (for PostgreSQL)
chmod 775 ${DIR_ARCHIVE_DEFAULT}/postgresql >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Change Mode of Backup Directory!'
  _error
  _end
  _exit1
fi
## Change Mode (for PostgreSQL)
chmod 775 ${DIR_ARCHIVE_DEFAULT}/lucene >> ${SETUP_LOG} 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Change Mode of Backup Directory!'
  _error
  _end
  _exit1
fi

## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Backup PostgreSQL (DSpace) ####
## Debug
echo -n `${CDS}`' ###INFO> Backup Initial Data of PostgreSQL (DSpace)... '
## Backup (PostgreSQL: DSpace)
su dspace -c "pg_dump ${DB_DSPACE} > ${DIR_ARCHIVE_DEFAULT}/postgresql/dspace.dump 2>>${SETUP_LOG}"
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Backup Initial Data of PostgreSQL (DSpace)!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Backup PostgreSQL (G2D) ####
## Debug
echo -n `${CDS}`' ###INFO> Backup Initial Data of PostgreSQL (G2D)... '
## Backup
su dspace -c "pg_dump ${DB_G2D} > ${DIR_ARCHIVE_DEFAULT}/postgresql/g2d.dump 2>>${SETUP_LOG}"
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Backup Initial Data of PostgreSQL (G2D)!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Backup Lucene ####
## Debug
echo -n `${CDS}`' ###INFO> Backup Initial Data of Lucene... '
## Dump Data
su dspace -c "cp -pr ${DIR_LUCENE} ${DIR_ARCHIVE_DEFAULT}/lucene/. >> ${SETUP_LOG} 2>&1"
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Backup Initial Data of Lucene!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'

#### Sleep ####
sleep 2


#### Backup AssetStore ####
## Debug
echo -n `${CDS}`' ###INFO> Backup Initial Data of AssetStore... '
## Dump Data
su dspace -c "cp -pr ${DIR_ASSET} ${DIR_ARCHIVE_DEFAULT}/. >> ${SETUP_LOG} 2>&1"
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could NOT Backup Initial Data of AssetStore!'
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



#### [START] Step.6: Start Services ###################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                          [Step.5] Start Services                           ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Start Tomcat ####
## Debug
echo -n `${CDS}`' ###INFO> Starting Tomcat... '
## Exec Command
/opt/tomcat/bin/startup.sh >> ${SETUP_LOG} 2>&1
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
echo -n `${CDS}`' ###INFO> Starting Httpd... '
## Exec Command
/etc/rc.d/init.d/httpd start >> ${SETUP_LOG} 2>&1
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
sleep 10


#### [START] Finalize #################################################################

#### Debug ####
echo `${CDS}`' ## ************************************************************************** ## '
echo `${CDS}`' ##                          * * * COMPLETED!! * * *                           ##'
echo `${CDS}`' ##               Please Check the Metadata Database is Running!               ##'
echo `${CDS}`' ## ************************************************************************** ## '
#### Exit ####
_end
_exit0

