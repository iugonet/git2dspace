#!/bin/bash
# ----------------------------------------------------------------------------------- #
#  backup.sh for IUGONET ver 0.10
#  Released on 2013.04.10, STEL, N.UMEMURA
# ----------------------------------------------------------------------------------- #
#  -- INTRODUCTION --
#  This Script Backup the Database, Lucene Index and G2D Files,
#  and Saves to the Archive Directory.
#
#  -- HOW TO RUN --
#  Run this command.
#  $ ./backup.sh [-h]
#  Options:
#    -h  :Do NOT Set Start Header and End Footer
#
#  -- MORE DETAILS --
#  See Operation Manual or Development Manual.
#
# ----------------------------------------------------------------------------------- #
#

#### [START] Define ###################################################################

#### Variable Parameters ####
## Archive Flag
ARCHIVEFLAG=0         ## 0: Yes, 1: No
## Archive Mode
ARCHIVEMODE=0         ## 0: raw, 1: compress(tar.gz)
## Number to Archive
ARCHIVEMAX=20         ## ARCHIVEMAX > 0

#### Invariable Parameters ####
## Variables
CURRENTDATE=`date '+%Y%m%d.%H%M%S'`
HFLAG=0                      ## Do or Not Add Headers
## Env etc.
SRC_SHELL=${G2D_HOME}'/src/shell'
LIST_DIR=${G2D_HOME}'/WorkDir/list'
DIR_ARCHIVE_BASE=${G2D_HOME}'/archive/backup'
DIR_ARCHIVE=${DIR_ARCHIVE_BASE}'/'${CURRENTDATE}
## Target to Backup
FLIST=()                     ## Set Later
DIR_SRC_SHELL=()             ## Set Later ##
DIR_LIST=()                  ## Set Later ##
DIR_LOG=${G2D_HOME}'/log'
DIR_LUCENE='/opt/dspace/search'
DB_DSPACE='dspace'
DB_G2D='g2d'
## Utils
CDS=${G2D_HOME}'/src/shell/lib/CreateDate.sh'

#### Function ####
_start() {
  if [ ${HFLAG} = 0 ]; then
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
    echo `${CDS}`' ##                    [backup.sh] Git2DSpace BACKUP  START                    ##'
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
    echo `${CDS}`' ## INTRODUCTION:                                                              ##'
    echo `${CDS}`' ##   This Script Backup the Database, Lucene Index and G2D Files,             ##'
    echo `${CDS}`' ##   and Saves to the Archive Directory.                                      ##'
    echo `${CDS}`' ## VERSION INFORMATION:                                                       ##'
    echo `${CDS}`' ##   ver.0.10: Released on 2013.04.10, STEL, N.UMEMURA                        ##'
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  else
    echo `${CDS}`' ###INFO> START: backup.sh'
  fi
}
_pass() {
  echo `${CDS}`' ###INFO> Passed. ARCHIVEFLAG = ['${ARCHIVEFLAG}']'
}
_error() {
  echo `${CDS}`' !!ERROR> Program Exit. See Operation Manual.'
}
_end() {
  if [ ${HFLAG} = 0 ]; then
    echo `${CDS}`
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
    echo `${CDS}`' ##                     [backup.sh] Git2DSpace BACKUP  END                     ##'
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  else
    echo `${CDS}`' ###INFO> END: backup.sh'
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
ARGS=`getopt -o :h -l no-header -- "$@"`

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
  ## Case: Show All the Registration Histories (For Operators)
  -h|--no-header)
    HFLAG=1    ## Not Add Header and Footer
    ;;
  esac
  shift
done
shift


#### [START] Exec #####################################################################

#### Debug ####
_start

#### Judge Archive Mode ####
if [ ${ARCHIVEFLAG} != 0 ]; then
  _pass
  _end
  _exit0
fi

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


#### Change Directory ####
cd ${G2D_HOME}


#### [START] Step.0: Make Directory ###################################################

#### Make Directory ####
## Debug
echo -n `${CDS}`' ###INFO> Making Archive Directory... '
## Exec
mkdir -p ${DIR_ARCHIVE} 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Make Directory!'
  echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE}']'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'
echo `${CDS}`' ###INFO> Directory --> ['${DIR_ARCHIVE}']'

#### Sleep ####
#sleep 2


#### [START] Step.1: Backup G2D #######################################################

#### Debug ####
echo -n `${CDS}`' ###INFO> Step.1: Backup G2D Files... '


#### [START] Step.1-1: Backup G2D (List Files) ########################################

#### Make Directory ####
## Exec
mkdir -p ${DIR_ARCHIVE}/WorkDir/list 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Make Directory!'
  echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE}'/WorkDir/list]'
  _error
  _end
  _exit1
fi

#### Change Mode ####
## Exec
chmod 755 ${DIR_ARCHIVE}/WorkDir/list 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Change Mode!'
  echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE}'/WorkDir/list]'
  _error
  _end
  _exit1
fi

#### Change Directory ####
## Exec
if [ -d ${LIST_DIR} ]; then
  cd ${LIST_DIR} 2>/dev/null
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could Not Change Directory!'
    echo `${CDS}`' !!ERROR> Directory --> ['${LIST_DIR}']'
    _error
    _end
    _exit1
  fi
  #### Get File List ####
  FLIST=(`ls *.out 2>/dev/null`)
  ## on Error --> exit 1
  ## NOTE:
  ##   If Files Not Exit, Receive Exit Code '1'.
  ##   Therefore, Pass Such Case.
# if [ $? != "0" ]; then
#   echo '[Failed]'
#   echo `${CDS}`' !!ERROR> Could Not Get Files!'
#   echo `${CDS}`' !!ERROR> Directory --> ['${LIST_DIR}']'
#   _error
#   _end
#   _exit1
# fi
  #### Backup ####
  for file in ${FLIST[@]}; do
    cp -p ${file} ${DIR_ARCHIVE}/WorkDir/list/. 2>/dev/null
    ## on Error --> exit 1
    if [ $? != "0" ]; then
      echo '[Failed]'
      echo `${CDS}`' !!ERROR> Could Not Backup List Files!'
      echo `${CDS}`' !!ERROR> Directory --> ['${LIST_DIR}']'
      echo `${CDS}`' !!ERROR> File --> ['${file}']'
      _error
      _end
      _exit1
    fi
  done
fi


#### [START] Step.1-2: Backup G2D (Shell Files) #######################################

#### Make Directory ####
## Exec
mkdir -p ${DIR_ARCHIVE}/src/shell 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Make Directory!'
  echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE}'/src/shell]'
  _error
  _end
  _exit1
fi

#### Change Mode ####
## Exec
chmod 755 ${DIR_ARCHIVE}/src/shell 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Change Mode!'
  echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE}'/src/shell]'
  _error
  _end
  _exit1
fi

#### Change Directory ####
## Exec
if [ -d ${SRC_SHELL} ]; then
  cd ${SRC_SHELL} 2> /dev/null
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could Not Change Directory!'
    echo `${CDS}`' !!ERROR> Directory --> ['${SRC_SHELL}']'
    _error
    _end
    _exit1
  fi
  #### Get File List ####
  FLIST=(`ls *.sh 2>/dev/null`)
  ## on Error --> exit 1
  ## NOTE:
  ##   If Files Not Exit, Receive Exit Code '1'.
  ##   Therefore, Pass Such Case.
# if [ $? != "0" ]; then
#  echo '[Failed]'
#  echo `${CDS}`' !!ERROR> Could Not Get Shell Files!'
#  echo `${CDS}`' !!ERROR> Directory --> ['${SRC_SHELL}']'
#  _error
#  _end
#  _exit1
# fi
  #### Backup ####
  for file in ${FLIST[@]}; do
    cp -p ${file} ${DIR_ARCHIVE}/src/shell/. 2>/dev/null
    ## on Error --> exit 1
    if [ $? != "0" ]; then
      echo '[Failed]'
      echo `${CDS}`' !!ERROR> Could Not Backup Shell Files!'
      echo `${CDS}`' !!ERROR> Directory --> ['${SRC_SHELL}']'
      echo `${CDS}`' !!ERROR> File --> ['${file}']'
      _error
      _end
      _exit1
    fi
  done
fi


#### [START] Step.1-2: Backup G2D (Log Files) #########################################

#### Backup ####
## Exec
if [ -d ${DIR_LOG} ]; then
  cp -pr ${DIR_LOG} ${DIR_ARCHIVE}/. 2>/dev/null
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could Not Backup Log Files!'
    echo `${CDS}`' !!ERROR> Directory --> ['${DIR_LOG}']'
    _error
    _end
    _exit1
  fi
fi

#### Debug ####
echo '[OK]'

#### Sleep ####
#sleep 2



#### [START] Step.2: Backup Database ##################################################

#### Debug ####
echo -n `${CDS}`' ###INFO> Step.2: Backup PostgreSQL... '

#### Make Directory ####
## Exec
mkdir -p ${DIR_ARCHIVE}/postgresql 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Make Directory!'
  echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE}'/postgresql]'
  _error
  _end
  _exit1
fi

#### Change Mode ####
## Exec
chmod 755 ${DIR_ARCHIVE}/postgresql 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Change Mode!'
  echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE}'/postgresql]'
  _error
  _end
  _exit1
fi

#### Backup (DSpace) ####
## Exec
pg_dump ${DB_DSPACE} > ${DIR_ARCHIVE}/postgresql/dspace.dump 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Backup Database DSpace!'
  _error
  _end
  _exit1
fi

#### Backup (G2D) ####
## Exec
pg_dump ${DB_G2D} > ${DIR_ARCHIVE}/postgresql/g2d.dump 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Backup Database G2D!'
  _error
  _end
  _exit1
fi

#### Debug ####
echo '[OK]'

#### Sleep ####
#sleep 2



#### [START] Step.3: Backup Lucene ####################################################

#### Debug ####
echo -n `${CDS}`' ###INFO> Step.3: Backup Lucene... '

#### Make Directory ####
## Exec
mkdir -p ${DIR_ARCHIVE}/lucene 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Make Directory!'
  echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE}'/lucene]'
  _error
  _end
  _exit1
fi

#### Change Mode ####
## Exec
chmod 755 ${DIR_ARCHIVE}/lucene 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Change Mode!'
  echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE}'/lucene]'
  _error
  _end
  _exit1
fi

#### Backup ####
## Exec
cp -pr ${DIR_LUCENE} ${DIR_ARCHIVE}/lucene/. 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Backup Lucene Index!'
  _error
  _end
  _exit1
fi

#### Debug ####
echo '[OK]'

#### Sleep ####
#sleep 2



#### [START] Step.4: Compression (Option) #############################################

#### Debug ####
echo -n `${CDS}`' ###INFO> Step.4: Compress Archive Directory... '

#### Change Directory ####
cd ${G2D_HOME} 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Change Directory!'
  echo `${CDS}`' !!ERROR> Directory --> ['${G2D_HOME}']'
  _error
  _end
  _exit1
fi

#### Compression ####
if [ ${ARCHIVEMODE} = 1 ]; then
  #### Change Directory ####
  cd ${DIR_ARCHIVE_BASE} 2>/dev/null
  #### Compress ####
  tar -czf ${CURRENTDATE}.tar.gz ${CURRENTDATE} 2>/dev/null
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could Not Compress Archive Directory!'
    echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE_BASE}'/'${CURRENTDATE}']'
    _error
    _end
    _exit1
  fi
  #### Remove this Directory ####
  rm -rf ${CURRENTDATE} 2>/dev/null
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could Not Remove Archive Directory!'
    echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE_BASE}'/'${CURRENTDATE}']'
    _error
    _end
    _exit1
  fi
  #### Debug ####
  echo '[OK]'
else
  #### Debug ####
  echo '[Passed] (ARCHIVEMODE=['${ARCHIVEMODE}'])'
fi

#### Sleep ####
#sleep 2



#### [START] Step.5: Rotation #########################################################

#### Debug ####
echo -n `${CDS}`' ###INFO> Step.5: Rotate Archives... '

#### Define ####
COUNTER=1

#### Change Directory ####
cd ${DIR_ARCHIVE_BASE} 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Change Directory!'
  echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE_BASE}']'
  _error
  _end
  _exit1
fi

#### Get Directory List ####
## Exec
DLIST=(`ls -r ${DIR_ARCHIVE_BASE} 2>/dev/null`)
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Get Archive List!'
  echo `${CDS}`' !!ERROR> Directory --> ['${DIR_ARCHIVE_BASE}']'
  _error
  _end
  _exit1
fi

#### Debug ####
echo ''    ## Enter Code

#### Rotation ####
for alist in ${DLIST[@]}; do
  ## Debug
  echo -n `${CDS}`' ###INFO> Archive #'${COUNTER}': '
  ## Keep
  if [ $COUNTER -le $ARCHIVEMAX ]; then
    echo ${alist}' ... [keep]'
  ## Delete
  else
    if [ ${alist:0:2} = '20' ]; then  ## Nen-No Tame...
      if [ -d ${alist} ]; then
        rm -rf ${alist} 2>/dev/null
      else
        rm -f ${alist} 2>/dev/null
      fi
      echo ${alist}' ... [deleted]'
    fi
  fi
  ## Count Up
  COUNTER=`expr ${COUNTER} + 1`
done

#### Debug ####
echo `${CDS}`' ###INFO> Step.5: Rotate Archives... [OK]'

#### Sleep ####
#sleep 2



#### [START] Finalize #################################################################

#### Change Directory ####
cd ${G2D_HOME}

#### Debug ####
_end

#### Exit ####
_exit0
