#!/bin/bash
# ----------------------------------------------------------------------------------- #
#  stop.sh for IUGONET ver 0.10
#  Released on 2013.04.11, STEL, N.UMEMURA
# ----------------------------------------------------------------------------------- #
#  -- INTRODUCTION --
#  This Script Stop the G2D Process (include Child Processes).
#
#  -- HOW TO RUN --
#  Run this command on SuperUser.
#  # ./stop.sh --stop-only
#  Options:
#    --stop-only  : Do Not Roll-Back.
#
#  -- MORE DETAILS --
#  See Operation Manual or Development Manual.
#
# ----------------------------------------------------------------------------------- #
#

#### [START] Define ###################################################################

#### Invariable Parameters ####
## Env
PID_FILE=${G2D_HOME}'/g2d.pid'
## Variables
PROCESSLIST=()     ## Array included PROCESSID
RBFLAG=0           ## Flag of Do or Not Roll-Back (0: Do, 1: Do NOT)
## Utils
CDS=${G2D_HOME}'/src/shell/lib/CreateDate.sh'

#### Function ####
_start() {
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  echo `${CDS}`' ##                  [stop.sh] Git2DSpace STOP_SIGNAL  START                   ##'
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  echo `${CDS}`' ## INTRODUCTION:                                                              ##'
  echo `${CDS}`' ##   This Script Stop the G2D Process (include Child Processes).              ##'
  echo `${CDS}`' ## VERSION INFORMATION:                                                       ##'
  echo `${CDS}`' ##   ver.0.10: Released on 2013.04.11, STEL, N.UMEMURA                        ##'
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  echo `${CDS}`
}
_error() {
  echo `${CDS}`' !!ERROR> Program Exit. See Operation Manual.'
}
_end() {
  echo `${CDS}`
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  echo `${CDS}`' ##                   [stop.sh] Git2DSpace STOP_SIGNAL  END                    ##'
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
}
_exit0() {
  exit 0
}
_exit1() {
  exit 1
}




#### [START] Get Args #################################################################

#### Get Args ####
ARGS=`getopt -o :s -l stop-only -- "$@"`

#### ReSet Args ####
eval set -- $ARGS

#### Catch Args ####
until [ $1 = "--" ];
do
  case $1 in
  ## Case: Do Not Roll-Back.
  -s|--stop-only)
    RBFLAG=1  ## Do Not Roll-Back.
    ;;
  esac
  shift
done
shift


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



#### [START] Step.2: Stop G2D Process #################################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                         [Step.2] Stop G2D Process                          ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Debug ####
echo -n `${CDS}`' ###INFO> Stop G2D Processes... '

#### Check .pid File, on Error --> exit 1 ####
if [ ! -r ${PID_FILE} ]; then
  echo '[Failed]'
  echo `${CDS}`' !!!WARN> .pid File Not Found.'
  _error
  _end
  _exit1
fi

#### Get Parent ProcessID ####
PROCESSID=`cat ${PID_FILE} 2>/dev/null`


#### Get Child ProcessIDs ####
while [ "${PROCESSID}" != "" ];
do
  ## Set ProcessID into Array
  if [ "${PROCESSID}" != "" ]; then
    PROCESSLIST+=($PROCESSID)
  fi
  ## Get More Child Process
  PROCESSID=`ps u --ppid=${PROCESSID} | grep -v PID | awk '{print $2}' 2>/dev/null`
done

#### Set Number of Processes ####
i=`expr ${#PROCESSLIST[@]} - 1 2>/dev/null`

#### Stop Processes ####
while [ $i -ge 0 ];
do
  ## kill Process
  kill ${PROCESSLIST[i]} > /dev/null 2>&1
  ## Count Down
  i=`expr ${i} - 1`
done

#### Debug ####
echo '[OK]'
echo `${CDS}`

#### Sleep ####
sleep 2



#### [START] Step.3: Roll-Back Database ###############################################

#### Debug ####
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
echo `${CDS}`' ##                        [Step.3] Roll-Back Database                         ##'
echo `${CDS}`' ## -------------------------------------------------------------------------- ##'

#### Debug ####
echo -n `${CDS}`' ###INFO> Roll-Back Database... '

#### Option: --stop-only --> exit 0 ####
if [ ${RBFLAG} = 1 ]; then
  echo '[Passed]'
  _end
  _exit0
fi

#### Restore ####
## Exec
./restore.sh -d HEAD > /dev/null 2>&1
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> Could Not Roll-Back Database!'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo '[OK]'
echo `${CDS}`' ###INFO> OK, Finished. Please Check the System is Running Correctly.'

#### Debug ####
echo `${CDS}`

#### Sleep ####
sleep 2



#### [START] Finalize #################################################################

#### Debug ####
_end

#### Exit ####
_exit0
