#!/bin/bash
# ----------------------------------------------------------------------------------- #
#  run.sh for IUGONET ver 0.10
#  Released on 2013.04.16, STEL, N.UMEMURA
# ----------------------------------------------------------------------------------- #
#  -- INTRODUCTION --
#  This Script Registers the Metadata into Database.
#
#  -- HOW TO RUN --
#  Run this command. (With No Args)
#  $ ./run.sh
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
SRC_DIR=${G2D_HOME}'/src'
SRC_RUBY=${SRC_DIR}'/ruby'
SRC_SHELL=${SRC_DIR}'/shell'
LOG_SHELL=${G2D_HOME}'/log/dspace.log'
## Variables
EXEC_FLAG=0
## Utils
CDS=${SRC_SHELL}'/lib/CreateDate.sh'


#### [START] Exec #####################################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##           [run.sh] IUGONET METADATA REGISTER (Git2DSpace)  START           ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ## INTRODUCTION:                                                              ##'
echo `${CDS}`' ##   This Script Registers the Metadata into Database.                        ##'
echo `${CDS}`' ## VERSION INFORMATION:                                                       ##'
echo `${CDS}`' ##   ver.0.10: Released on 2013.04.16, STEL, N.UMEMURA                        ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`


#### [START] Check Previous Process ###################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                       Check Previous Process  START                        ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Change Directory ####
cd ${G2D_HOME}

#### Check Process: If Already Running --> exit 0 ####
if [ -f ${PIDFILE} ]; then
  PROCESSNUM=`ps -p \`cat ${PIDFILE}\` | wc -l`
  if [ $PROCESSNUM -gt 1 ]; then
    echo `${CDS}`' >>> INFO> The Previous Process is Still Running. Pass this Process.'
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
    echo `${CDS}`' ##            [run.sh] IUGONET METADATA REGISTER (Git2DSpace)  END            ##'
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
    exit 0
  fi
fi

#### Debug ####
echo `${CDS}`' ###INFO> The Previous Process is Not Running. Go Next!'
echo `${CDS}`


#### [START] Cleaning #################################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                         [clean.sh] Cleaning  START                         ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Change Directory ####
cd ${G2D_HOME}

#### Cleaning ####
./clean.sh

#### Debug ####
echo `${CDS}`


#### [START] Create .pid File #########################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                      Creating .pid (Lock-File)  START                      ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Change Directory ####
cd ${G2D_HOME}

#### Create .pid File ####
echo $$ > ${PIDFILE}

#### Debug ####
echo `${CDS}`' ###INFO> Successful. Go Next!'
echo `${CDS}`


#### [START] Step.1: Exec Ruby ########################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                 Step.1: [main.rb] Setting Metadata  START                  ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Change Directory ####
cd ${SRC_RUBY}

#### Exec Ruby ####
ruby main.rb
RESULT_CODE=$?
#echo ${RESULT_CODE}

#### Change Directory ####
cd ${G2D_HOME}

#### Debug ####
echo `${CDS}`

#### Sleep ####
#sleep 10

#### [START] Step.2: Exec Shell #######################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##          Step.2: Exec Shell (Regist Metadata into DSpace)  START           ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Exec ####
if [ ${RESULT_CODE} -eq 0 ]; then

  #### Define ####
  RUN_IMPORT0='runImport0.sh'
  RUN_IMPORT='runImport.sh'
  RUN_REPLACE='runReplace.sh'
  RUN_DELETE='runDelete.sh'

  #### Change Directory ####
  cd ${SRC_SHELL}

  #### Exec Shell ####
  ## Import0
  if [ -f ${RUN_IMPORT0} ]; then
    EXEC_FLAG=1
    echo `${CDS}`' ###INFO> START: '${RUN_IMPORT0}
    ./${RUN_IMPORT0} >> ${LOG_SHELL} 2>&1
  fi
  ## Import
  if [ -f ${RUN_IMPORT} ]; then
    EXEC_FLAG=1
    echo `${CDS}`' ###INFO> START: '${RUN_IMPORT}
    ./${RUN_IMPORT} >> ${LOG_SHELL} 2>&1
  fi
  ## Replace
  if [ -f ${RUN_REPLACE} ]; then
    EXEC_FLAG=1
    echo `${CDS}`' ###INFO> START: '${RUN_REPLACE}
    ./${RUN_REPLACE} >> ${LOG_SHELL} 2>&1
  fi
  ## Delete
  if [ -f ${RUN_DELETE} ]; then
    EXEC_FLAG=1
    echo `${CDS}`' ###INFO> START: '${RUN_DELETE}
    ./${RUN_DELETE} >> ${LOG_SHELL} 2>&1
  fi

  #### Change Directory ####
  cd ${G2D_HOME}

#### on Error ####
else
  #### Debug ####
  echo `${CDS}`' ###INFO> Passed.'
fi

#### Debug ####
echo `${CDS}`


#### [START] Step.3: index-update #####################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                        Step.3: index-update  START                         ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Judge ####
if [ ${EXEC_FLAG} = 1 ]; then
  ## index-update
  echo `${CDS}`' ###INFO> START: /opt/dspace/bin/index-update'
  /opt/dspace/bin/index-update >> ${LOG_SHELL} 2>&1
else
  #### Debug ####
  echo `${CDS}`' ###INFO> Passed.'
fi

#### Debug ####
echo `${CDS}`


#### [START] Back Up ##################################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##             Backup (Database, Lucene and Log Files etc.)  START            ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Judge
if [ ${EXEC_FLAG} = 1 ]; then
  ## Change Directory
  cd ${G2D_HOME}
  ## Back Up
  ./backup.sh --no-header 2>/dev/null
else
  ## Debug
  echo `${CDS}`' ###INFO> Passed.'
fi

#### Debug ####
echo `${CDS}`


#### [START] Cleaning #################################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                         [clean.sh] Cleaning  START                         ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Change Directory ####
cd ${G2D_HOME}

#### Cleaning ####
./clean.sh --no-header 2>/dev/null

#### Debug ####
echo `${CDS}`


#### [START] Finalize #################################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##            [run.sh] IUGONET METADATA REGISTER (Git2DSpace)  END            ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Exit ####
exit 0;
