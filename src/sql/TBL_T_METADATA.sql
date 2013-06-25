-- -------------------------------------------------------------------------- --
--  TBL_T_METADATA.sql
-- -------------------------------------------------------------------------- --

-- Step.1 DROP TABLE
DROP TABLE TBL_T_METADATA;

-- Step.2 CREATE TABLE
CREATE TABLE TBL_T_METADATA(
  HANDLE_ID                 INTEGER                    NOT NULL    PRIMARY KEY,
  RESOURCE_ID               CHAR(200)                  NOT NULL,
  OWNING_COLLECTION         INTEGER                    NOT NULL,
  ITEM_ID                   INTEGER                    NOT NULL,
  DEL_FLAG                  CHAR(1)                    NOT NULL,
  RCDNEWDATE                CHAR(8)                    NOT NULL,
  RCDNEWTIME                CHAR(6)                    NOT NULL,
  RCDMDFDATE                CHAR(8)      DEFAULT ''            ,
  RCDMDFTIME                CHAR(6)      DEFAULT ''
);

-- Step.2 CREATE PRIMARY_KEY, INDEX
CREATE INDEX
  IDX_RESOURCE_ID_ON_TBL_T_METADATA
ON
  TBL_T_METADATA(RESOURCE_ID)


-- Step.3 CREATE SEQUENCE
-- DONOT USER SEQUENCE

-- Step.4 INSERT DEFALUT VALUE
-- DONOT USER DEFAULT VALUE

-- Step.5 CREATE FUNCTION
-- DONOT USE FUNCTION

