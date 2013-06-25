#!/bin/bash
# ----------------------------------------------------------------------------------- #
#  initialize.sh for IUGONET ver 0.10
#  Released on 2013.04.12, STEL, N.UMEMURA
# ----------------------------------------------------------------------------------- #
#  -- INTRODUCTION --
#  This Script Returns the Database System to the Initial State.
#
#  -- HOW TO RUN --
#  Run this command by SuperUser. (With No Args)
#  $ ./initialize.sh
#
#  -- MORE DETAILS --
#  See Operation Manual or Development Manual.
#
# ----------------------------------------------------------------------------------- #
#

#### [START] Define ###################################################################

#### Invariable Parameters ####
## Utils
CDS=${G2D_HOME}'/src/shell/lib/CreateDate.sh'

#### Function ####
_start() {
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  echo `${CDS}`' ##                [initialize.sh] Git2DSpace INITIALIZE  START                ##'
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  echo `${CDS}`' ## INTRODUCTION:                                                              ##'
  echo `${CDS}`' ##   This Script Return the Database System to the Initial State.             ##'
  echo `${CDS}`' ## VERSION INFORMATION:                                                       ##'
  echo `${CDS}`' ##   ver.0.10: Released on 2013.04.12, STEL, N.UMEMURA                        ##'
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
}
_error() {
  echo `${CDS}`' !!ERROR> Program Exit. See Operation Manual.'
}
_end() {
  echo `${CDS}`
  echo `${CDS}`' ## -------------------------------------------------------------------------- ##'
  echo `${CDS}`' ##                 [initialize.sh] Git2DSpace INITIALIZE  END                 ##'
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


#### Check Current User ####
## Debug
echo -n `${CDS}`' ###INFO> Checking Current User... '
## Exec
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

#### Change Directory ####
cd ${G2D_HOME}

#### Sleep ####
sleep 2


#### [START] Initialize (Using restore.sh) ############################################

#### Initialize ####
## Debug
echo `${CDS}`' ###INFO> Initializing... '
echo `${CDS}`
## Exec
./restore.sh -d default --no-header 2>/dev/null
## on Error --> exit 1
if [ $? != "0" ]; then
  echo `${CDS}`' !!ERROR> Initializing... [Failed]'
  _error
  _end
  _exit1
fi
## on Normal --> Go Next
echo `${CDS}`' ###INFO> Initializing... [OK]'

#### Sleep ####
sleep 2



#### [START] Finalize #################################################################

#### Debug ####
_end

#### Exit ####
_exit0

