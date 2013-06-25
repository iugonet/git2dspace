#!/bin/bash
# ----------------------------------------------------------------------------------- #
#  clean.sh for IUGONET ver 0.10
#  Released on 2013.04.11, STEL, N.UMEMURA
# ----------------------------------------------------------------------------------- #
#  -- INTRODUCTION --
#  This Script Cleans the G2D Directory Up.
#  (Delete the Work Files on the G2D Process).
#
#  -- HOW TO RUN --
#  Run this command.
#  $ ./clean.sh [-h]
#  Options:
#    -h  :Do NOT Set Header and Footer
#
#  -- MORE DETAILS --
#  See Operation Manual or Development Manual.
#
# ----------------------------------------------------------------------------------- #
#

#### [START] Define ###################################################################

#### Invariable Parameters ####
## Variables
HFLAG=0                      ## Do or Not Add Headers
## Env
WORK_DIR=${G2D_HOME}'/WorkDir'
SRC_SHELL=${G2D_HOME}'/src/shell'
## Target
LISTDIR=${WORK_DIR}'/list'
DSMDDIR=${WORK_DIR}'/Regist'
LOGDIR=${G2D_HOME}'/log'
FLIST=()                     ## Set Later
## Utils
CDS=${G2D_HOME}'/src/shell/lib/CreateDate.sh'

#### Function ####
_start() {
  if [ ${HFLAG} = 0 ]; then
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
    echo `${CDS}`' ##                   [clean.sh] Git2DSpace CLEANING  START                    ##'
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
    echo `${CDS}`' ## INTRODUCTION:                                                              ##'
    echo `${CDS}`' ##   This Script Cleans the G2D Directory Up.                                 ##'
    echo `${CDS}`' ##   (Delete the Work Files on the G2D Process).                              ##'
    echo `${CDS}`' ## VERSION INFORMATION:                                                       ##'
    echo `${CDS}`' ##   ver.0.10: Released on 2013.04.11, STEL, N.UMEMURA                        ##'
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  else
    echo `${CDS}`' ###INFO> START: clean.sh'
  fi
}
_error() {
  echo `${CDS}`' !!ERROR> Program Exit. See Operation Manual.'
}
_end() {
  if [ ${HFLAG} = 0 ]; then
    echo `${CDS}`
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
    echo `${CDS}`' ##                    [clean.sh] Git2DSpace CLEANING  END                     ##'
    echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  else
    echo `${CDS}`' ###INFO> END: clean.sh'
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


#### [START] Step.1: Cleaning #########################################################

#### LISTFILES --> remove ####
## Debug
echo -n `${CDS}`' ###INFO> Step.1: Cleaning List Files... '
## Exec
if [ -d ${LISTDIR} ]; then
  rm -rf ${LISTDIR} 2>/dev/null
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could Not Delete List Files!'
    echo `${CDS}`' !!ERROR> Directory --> ['${LISTDIR}']'
    _error
    _end
    _exit1
  fi
fi
## on Normal --> Go Next
echo '[OK]'


#### DSMDDIR --> remove ####
## Debug
echo -n `${CDS}`' ###INFO> Step.2: Cleaning Temporary Directories of Metadata... '
## Exec
if [ -d ${DSMDDIR} ]; then
  rm -rf ${DSMDDIR} 2>/dev/null
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could Not Delete Temporary Directories of Metadata!'
    echo `${CDS}`' !!ERROR> Directory --> ['${DSMDDIR}']'
    _error
    _end
    _exit1
  fi
fi
## on Normal --> Go Next
echo '[OK]'


#### SHELLFILES --> remove ####
## Debug
echo -n `${CDS}`' ###INFO> Step.3: Cleaning Shell Files... '

## Change Directory
cd ${SRC_SHELL} 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Change Directory!'
  echo `${CDS}`' !!ERROR> Directory --> ['${SRC_SHELL}']'
  _error
  _end
  _exit1
fi

## Get File List
FLIST=(`ls *.sh 2>/dev/null`)
## on Error --> exit 1
##   If Files Not Exit, Receive Exit Code '1'.
##   Therefore, Pass Such Case.
#if [ $? != "0" ]; then
#  echo '[Failed]'
#  echo `${CDS}`' !!ERROR> Could Not Get File List!'
#  echo `${CDS}`' !!ERROR> Directory --> ['${SRC_SHELL}']'
#  _error
#  _end
#  _exit1
#fi

## Delete
for file in ${FLIST[@]}; do
  rm -f ${file} 2>/dev/null
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could Not Delete Shell Files!'
    echo `${CDS}`' !!ERROR> Directory --> ['${SRC_SHELL}']'
    echo `${CDS}`' !!ERROR> File --> ['${file}']'
    _error
    _end
    _exit1
  fi
done
## on Normal --> Go Next
echo '[OK]'


#### LOGDIR --> remove and make newly ####
## Debug
echo -n `${CDS}`' ###INFO> Step.4: Cleaning Log Directory... '
## Delete
if [ -d ${LOGDIR} ]; then
  rm -rf ${LOGDIR} 2>/dev/null
  ## on Error --> exit 1
  if [ $? != "0" ]; then
    echo '[Failed]'
    echo `${CDS}`' !!ERROR> Could Not Delete Log Directory!'
    echo `${CDS}`' !!ERROR> Directory --> ['${LOGDIR}']'
    _error
    _end
    _exit1
  fi
fi

## Make Directory
mkdir ${LOGDIR} 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Create Log Directory Again!'
  echo `${CDS}`' !!ERROR> Directory --> ['${LOGDIR}']'
  _error
  _end
  _exit1
fi

## Change Mode
chmod 755 ${LOGDIR} 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Change Mode!'
  echo `${CDS}`' !!ERROR> Directory --> ['${LOGDIR}']'
  _error
  _end
  _exit1
fi

## on Normal --> Go Next
echo '[OK]'


#### [START] Finalize #################################################################

#### Change Directory ####
cd ${G2D_HOME}

#### Debug ####
_end

#### Exit ####
_exit0

