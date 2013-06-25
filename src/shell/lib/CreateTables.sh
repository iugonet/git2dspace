#!/bin/bash
# ----------------------------------------------------------------------------------- #
#  CreateTables.sh for IUGONET ver 0.10
#  Released on 2013.04.05, STEL, N.UMEMURA
# ----------------------------------------------------------------------------------- #
#  -- INTRODUCTION --
#  This Script Create Tables in the Database 'g2d' by dspace user.
#
#  -- HOW TO RUN --
#  Run this command. (With No Args)
#  $ ./CreateTables.sh
#
#  -- INTERFACE --
#  Return Code:
#    - NORMAL
#      - Successful   --> exit 0
#    - ERROR
#      - Failed       --> exit 1
#      - Other Errors --> exit 1
#
#  -- MORE DETAILS --
#  See Operation Manual or Development Manual.
#
# ----------------------------------------------------------------------------------- #
#

#### [START] Define ###################################################################

#### Invariable Parameters ####
## Env
SRC_SQL=${G2D_HOME}'/src/sql'
CDS=${G2D_HOME}'/src/shell/lib/CreateDate.sh'
## Variables
FILELIST=()         ## Array to Set *.sql Files


#### [START] Create Tables ############################################################

#### Set Table List ####
FILELIST=(`ls ${SRC_SQL}`)

#### Create Tables (Exec psql) ####
## Loop
for file in ${FILELIST[@]}; do
## Debug
echo -n `${CDS}`' ###INFO> Creating Table '${file}'... '
## Check File
if [ ! -r ${SRC_SQL}'/'${file} ]; then
  echo '[Failed]'
  echo `${CDS}`' !!ERROR> No Such File, '${SRC_SQL}'/'${file}
  exit 1
else
  TFILE=${SRC_SQL}'/'${file}
fi
## Exec psql
psql -U dspace g2d 1>/dev/null << _EOF_
  \i ${TFILE}
_EOF_
## on Error --> exit 1
if [ $? != "0" ]; then
  echo '[Failed]'
  exit 1
fi
## on Normal --> Go Next
echo '[OK]'
## sleep
sleep 1
done


#### [START] Finalize #################################################################

#### Exit ####
exit 0