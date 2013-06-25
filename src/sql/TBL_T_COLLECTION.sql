-- -------------------------------------------------------------------------- --
--  TBL_T_COLLECTION.sql
-- -------------------------------------------------------------------------- --

-- Step.1 DROP TABLE
DROP TABLE TBL_T_COLLECTION;

-- Step.2 CREATE TABLE
CREATE TABLE TBL_T_COLLECTION(
  COLLECTION_ID             INTEGER                    NOT NULL    PRIMARY KEY,
  HANDLE_ID                 INTEGER                    NOT NULL,
  COLLECTION_NAME           CHAR(200)                  NOT NULL,
  COMMUNITY_ID              INTEGER                    NOT NULL,
  DEL_FLAG                  CHAR(1)                    NOT NULL,
  RCDNEWDATE                CHAR(8)                    NOT NULL,
  RCDNEWTIME                CHAR(6)                    NOT NULL,
  RCDMDFDATE                CHAR(8)      DEFAULT ''            ,
  RCDMDFTIME                CHAR(6)      DEFAULT ''
);


-- Step.3 CREATE SEQUENCE
-- DONOT USER SEQUENCE

-- Step.4 INSERT DEFALUT VALUE
-- DONOT USER DEFAULT VALUE

-- Step.5 CREATE FUNCTION
-- DONOT USE FUNCTION

