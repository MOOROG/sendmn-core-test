
CREATE TABLE CASH_HOLD_LIMIT_USER_WISE
(
	cashHoldLimitId INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,cashHoldLimitBranchId INT NOT NULL
	,agentId INT NOT NULL
	,userId INT NOT NULL
	,cashHoldLimit MONEY DEFAULT(0) NOT NULL
	,ruleType CHAR(1) NOT NULL
	,isActive BIT DEFAULT(0) NOT NULL
	,createdBy VARCHAR(50) NOT NULL
	,createdDate DATETIME NOT NULL
	,modifiedBy VARCHAR(50) NULL
	,modifiedDate VARCHAR(50) NULL
	,approvedBy VARCHAR(50) NULL
	,approvedDate DATETIME NULL
);

CREATE TABLE CASH_HOLD_LIMIT_USER_WISE_MOD
(
	cashHoldLimitId INT NOT NULL
	,modType CHAR(1) NOT NULL 
	,cashHoldLimitBranchId INT NOT NULL
	,agentId INT NOT NULL
	,userId INT NOT NULL
	,cashHoldLimit MONEY DEFAULT(0) NOT NULL
	,ruleType CHAR(1) NOT NULL
	,isActive BIT DEFAULT(0) NOT NULL
	,createdBy VARCHAR(50) NOT NULL
	,createdDate DATETIME NOT NULL
	,modifiedBy VARCHAR(50) NULL
	,modifiedDate VARCHAR(50) NULL
	,approvedBy VARCHAR(50) NULL
	,approvedDate DATETIME NULL
);


CREATE TABLE CASH_HOLD_LIMIT_USER_WISE_HISTORY
(
	rowId INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,cashHoldLimitId INT NOT NULL
	,cashHoldLimitBranchId INT NOT NULL
	,agentId INT NOT NULL
	,userId INT NOT NULL
	,cashHoldLimit MONEY DEFAULT(0) NOT NULL
	,ruleType CHAR(1) NOT NULL
	,isActive BIT DEFAULT(0) NOT NULL
	,createdBy VARCHAR(50) NOT NULL
	,createdDate DATETIME NOT NULL
	,modifiedBy VARCHAR(50) NULL
	,modifiedDate VARCHAR(50) NULL
	,approvedBy VARCHAR(50) NULL
	,approvedDate DATETIME NULL
);

