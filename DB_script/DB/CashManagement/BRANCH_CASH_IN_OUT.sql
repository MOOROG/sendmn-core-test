
ALTER TABLE BRANCH_CASH_IN_OUT ADD fromAcc VARCHAR(30) NULL, toAcc VARCHAR(30) NULL

CREATE TABLE BRANCH_CASH_IN_OUT
(
	rowId	BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,inAmount MONEY NOT NULL
	,outAmount MONEY NOT NULL
	,branchId	INT NOT NULL
	,userId	INT NOT NULL
	,referenceId	BIGINT DEFAULT(0) NOT NULL
	,tranDate DATETIME NOT NULL
	,head VARCHAR(100) NOT NULL
	,remarks NVARCHAR(250) NULL
	,createdBy VARCHAR(50) NOT NULL
	,createdDate DATETIME NOT NULL
	,approvedBy VARCHAR(50) NULL
	,approvedDate DATETIME NULL
	,mode VARCHAR(2) NULL
	,fromAcc VARCHAR(30) NULL
	,toAcc VARCHAR(30) NULL
);
--type (receiving mode)
--create reject table 
--user wise show 
--create history table 
--tailor balance (Running balance) new table 
--match tailor balance and in out table while running EOD (if not match reject EOD)


CREATE TABLE BRANCH_CASH_IN_OUT_MOD
(
	rowId	BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,modType CHAR(1) NOT NULL 
	,inAmount MONEY NOT NULL
	,outAmount MONEY NOT NULL
	,branchId	INT NOT NULL
	,userId	INT NOT NULL
	,referenceId	BIGINT DEFAULT(0) NOT NULL
	,tranDate DATETIME NOT NULL
	,head VARCHAR(100) NOT NULL
	,remarks NVARCHAR(250) NULL
	,createdBy VARCHAR(50) NOT NULL
	,createdDate DATETIME NOT NULL
	,approvedBy VARCHAR(50) NULL
	,approvedDate DATETIME NULL
	,mode VARCHAR(2) NULL
	,fromAcc VARCHAR(30) NULL
	,toAcc VARCHAR(30) NULL
);

CREATE TABLE BRANCH_CASH_IN_OUT_HISTORY
(
	rowId	BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,inAmount MONEY NOT NULL
	,outAmount MONEY NOT NULL
	,branchId	INT NOT NULL
	,userId	INT NOT NULL
	,referenceId	BIGINT DEFAULT(0) NOT NULL
	,tranDate DATETIME NOT NULL
	,head VARCHAR(100) NOT NULL
	,remarks NVARCHAR(250) NULL
	,createdBy VARCHAR(50) NOT NULL
	,createdDate DATETIME NOT NULL
	,approvedBy VARCHAR(50) NULL
	,approvedDate DATETIME NULL
	,mode VARCHAR(2) NULL
	,fromAcc VARCHAR(30) NULL
	,toAcc VARCHAR(30) NULL
);


CREATE TABLE BRANCH_CASH_IN_OUT_REJECT
(
	rowId	BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,inAmount MONEY NOT NULL
	,outAmount MONEY NOT NULL
	,branchId	INT NOT NULL
	,userId	INT NOT NULL
	,referenceId	BIGINT DEFAULT(0) NOT NULL
	,tranDate DATETIME NOT NULL
	,head VARCHAR(100) NOT NULL
	,remarks NVARCHAR(250) NULL
	,createdBy VARCHAR(50) NOT NULL
	,createdDate DATETIME NOT NULL
	,approvedBy VARCHAR(50) NULL
	,approvedDate DATETIME NULL
	,rejectedBy VARCHAR(50) NULL
	,rejectedDate DATETIME NULL
	,mode VARCHAR(2) NULL
	,fromAcc VARCHAR(30) NULL
	,toAcc VARCHAR(30) NULL
);

CREATE TABLE TELLER_CASH_BALANCE
(
	ROW_ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,[USER_ID] INT NOT NULL
	,[USER_NAME] VARCHAR(50)
	,BALANCE MONEY DEFAULT(0) NOT NULL 
)


