-- -------------------------------------------------------------------------- --
--  TBL_M_REPOSITORY.sql                                                      --
-- -------------------------------------------------------------------------- --

-- Step.1 DROP TABLE
DROP TABLE TBL_M_REPOSITORY;

-- Step.2 CREATE TABLE
CREATE TABLE TBL_M_REPOSITORY(
  REPOSITORY_CODE           CHAR(4)                    NOT NULL    PRIMARY KEY,
  REPOSITORY_NICKNAME       CHAR(20)                   NOT NULL,
  REPOSITORY_ACTIVITY_CODE  CHAR(1)                    NOT NULL,
  REMOTE_HOST               CHAR(40)                   NOT NULL, 
  REMOTE_PATH               CHAR(80)                   NOT NULL,
  LOGIN_ACCOUNT             CHAR(20)     DEFAULT ''            ,
  LOGIN_PASSWORD            CHAR(20)     DEFAULT ''            ,
  PROTOCOL_CODE             CHAR(1)                    NOT NULL,
  LOCAL_DIRECTORY           CHAR(40)                   NOT NULL,
  DEL_FLAG                  CHAR(1)                    NOT NULL,
  RCDNEWDATE                CHAR(8)                    NOT NULL,
  RCDNEWTIME                CHAR(6)                    NOT NULL,
  RCDMDFDATE                CHAR(8)      DEFAULT ''            ,
  RCDMDFTIME                CHAR(6)      DEFAULT ''
);

-- Step.3 CREATE SEQUENCE
DROP SEQUENCE SEQ_REPOSITORY_CODE;
CREATE SEQUENCE SEQ_REPOSITORY_CODE
  INCREMENT        1
  MINVALUE         1
  MAXVALUE      9999
  START            1
  CYCLE
;

-- Step.4 INSERT DEFALUT VALUE
-- KyotoU_OBS
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'KyotoU_Obs',         '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/KyotoU_Observatory.git',         'git', '', '1', 'IUGONET/KyotoU_Obs',         '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'KyotoU_Obs#Granule', '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/KyotoU_Observatory/Granule.git', 'git', '', '1', 'IUGONET_Granule/KyotoU_Obs', '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
-- KyotoU_RISH #1
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'RISH1',              '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/KyotoU_RISH.git',                'git', '', '1', 'IUGONET/RISH1',              '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'RISH1#Granule',      '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/KyotoU_RISH/Granule.git',        'git', '', '1', 'IUGONET_Granule/RISH1',      '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
-- KyotoU_RISH #2
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'RISH2',              '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/KyotoU_RISH_2.git',              'git', '', '1', 'IUGONET/RISH2',              '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'RISH2#Granule',      '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/KyotoU_RISH_2/Granule.git',      'git', '', '1', 'IUGONET_Granule/RISH2',      '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
-- KyotoU_SPEL
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'SPEL',               '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/KyotoU_SPEL.git',                'git', '', '1', 'IUGONET/SPEL',               '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'SPEL#Granule',       '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/KyotoU_SPEL/Granule.git',        'git', '', '1', 'IUGONET_Granule/SPEL',       '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
-- KyotoU_WDC
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'WDC',                '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/KyotoU_WDC.git',                 'git', '', '1', 'IUGONET/KyotoU_WDC',         '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'WDC#Granule',        '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/KyotoU_WDC/Granule.git',         'git', '', '1', 'IUGONET_Granule/KyotoU_WDC', '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
-- KyushuU
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'KyushuU',            '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/KyushuU.git',                    'git', '', '1', 'IUGONET/KyushuU',            '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'KyushuU#Granule',    '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/KyushuU/Granule.git',            'git', '', '1', 'IUGONET_Granule/KyushuU',    '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
-- NIPR
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'NIPR',               '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/NIPR.git',                       'git', '', '1', 'IUGONET/NIPR',               '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'NIPR#Granule',       '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/NIPR/Granule.git',               'git', '', '1', 'IUGONET_Granule/NIPR',       '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
-- STEL
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'STEL',               '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/STEL.git',                       'git', '', '1', 'IUGONET/STEL',               '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'STEL#Granule',       '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/STEL/Granule.git',               'git', '', '1', 'IUGONET_Granule/STEL',       '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
-- TohokuU
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'TohokuU',            '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/TohokuU.git',                    'git', '', '1', 'IUGONET/TohokuU',            '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'TohokuU#Granule',    '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/TohokuU/Granule.git',            'git', '', '1', 'IUGONET_Granule/TohokuU',    '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
-- NAOJ
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'NAOJ',               '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/NAOJ.git',                       'git', '', '1', 'IUGONET/NAOJ',               '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'NAOJ#Granule',       '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/NAOJ/Granule.git',               'git', '', '1', 'IUGONET_Granule/NAOJ',       '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
-- NICT
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'NICT',               '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/NICT.git',                       'git', '', '1', 'IUGONET/NICT',               '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'NICT#Granule',       '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/NICT/Granule.git',               'git', '', '1', 'IUGONET_Granule/NICT',       '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
-- JMA
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'JMA',                '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/JMA.git',                        'git', '', '1', 'IUGONET/JMA',                '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');
INSERT INTO TBL_M_REPOSITORY VALUES(NEXTVAL('SEQ_REPOSITORY_CODE'), 'JMA#Granule',        '9', 'iugonet7.serc.kyushu-u.ac.jp', '/~git/git/Metadata/Draft/JMA/Granule.git',                'git', '', '1', 'IUGONET_Granule/JMA',        '0', TO_CHAR(NOW(), 'YYYYMMDD'), TO_CHAR(NOW(), 'HH24MISS'), '', '');


-- Step.5 CREATE FUNCTION
-- DONOT USE FUNCTION

