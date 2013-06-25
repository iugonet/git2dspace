#!/bin/bash
# ----------------------------------------------------------------------------------- #
#  CreateDate.sh for IUGONET ver 0.10
#  Released on 2013.04.04, STEL, N.UMEMURA
# ----------------------------------------------------------------------------------- #
#  -- INTRODUCTION --
#
#
#  -- HOW TO RUN --
#  Run this command.
#  $ ./CreateDate.sh
#
#  -- MORE DETAILS --
#
#
# ----------------------------------------------------------------------------------- #
#

#### [START] Exec #####################################################################

#### Exec ####
DATE1=`date '+%Y/%m/%d %H:%M:%S'`      # Current Date and Time
MICROSEC=`date '+%N'`                  # Current Time [microsec]
MICROSEC=`expr $MICROSEC / 1000`
MICROSEC=`printf '%06d' $MICROSEC`

#### Return ####
echo -n ${DATE1}'.'${MICROSEC}

#### Exit ####
exit 0
