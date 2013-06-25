-- -------------------------------------------------------------------------- --
--  TBL_T_METADATA_REGISTSTATUS.sql                                           --
-- -------------------------------------------------------------------------- --

-- Step.1 DROP TABLE
DROP TABLE TBL_T_METADATA_REGISTSTATUS;

-- Step.2 CREATE TABLE
CREATE TABLE TBL_T_METADATA_REGISTSTATUS(
  REGIST_ID                 CHAR(8)                    NOT NULL    PRIMARY KEY,
  REPOSITORY_CODE           CHAR(4)                    NOT NULL,
  STARTDATE                 CHAR(8)      DEFAULT ''            ,
  STARTTIME                 CHAR(6)      DEFAULT ''            ,
  ENDDATE                   CHAR(8)      DEFAULT ''            ,
  ENDTIME                   CHAR(6)      DEFAULT ''            ,
  REGIST_STATUS_CODE        CHAR(1)      DEFAULT '0'   NOT NULL,
  DEL_FLAG                  CHAR(1)                    NOT NULL,
  RCDNEWDATE                CHAR(8)                    NOT NULL,
  RCDNEWTIME                CHAR(6)                    NOT NULL,
  RCDMDFDATE                CHAR(8)      DEFAULT ''            ,
  RCDMDFTIME                CHAR(6)      DEFAULT ''
);


-- Step.3 CREATE SEQUENCE
DROP SEQUENCE SEQ_REGIST_ID;
CREATE SEQUENCE SEQ_REGIST_ID
  INCREMENT        1
  MINVALUE         1
  MAXVALUE  99999999
  START            1
  CYCLE
;


-- Step.4 INSERT DEFALUT VALUE
-- DONOT USER DEFAULT VALUE

-- Step.5 CREATE FUNCTION
-- DONOT USE FUNCTION

