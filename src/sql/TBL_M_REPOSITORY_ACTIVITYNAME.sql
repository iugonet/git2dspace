-- -------------------------------------------------------------------------- --
--  TBL_M_REPOSITORY.sql                                                      --
-- -------------------------------------------------------------------------- --

-- Step.1 DROP TABLE
DROP TABLE TBL_M_REPOSITORY_ACTIVITYNAME;

-- Step.2 CREATE TABLE
CREATE TABLE TBL_M_REPOSITORY_ACTIVITYNAME(
  REPOSITORY_ACTIVITY_CODE  CHAR(1)                    NOT NULL    PRIMARY KEY,
  REPOSITORY_ACTIVITY_NAME  CHAR(10)                   NOT NULL,
  DEL_FLAG                  CHAR(1)                    NOT NULL,
  RCDNEWDATE                CHAR(8)                    NOT NULL,
  RCDNEWTIME                CHAR(6)                    NOT NULL,
  RCDMDFDATE                CHAR(8)      DEFAULT ''            ,
  RCDMDFTIME                CHAR(6)      DEFAULT ''
);


-- Step.3 CREATE SEQUENCE
-- DO NOT USE SEQUENCE

-- Step.4 INSERT DEFALUT VALUE
INSERT INTO TBL_M_REPOSITORY_ACTIVITYNAME VALUES('1', 'ACTIVE', '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY_ACTIVITYNAME VALUES('8', 'PAUSE',  '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY_ACTIVITYNAME VALUES('9', 'STOP',   '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');

-- Step.5 CREATE FUNCTION
-- DONOT USE FUNCTION

