ALTER TABLE dbo.receiverInformation ADD otherRelationDesc VARCHAR(60)
ALTER TABLE dbo.receiverInformation ADD IsDeleted VARCHAR(1) NULL
ALTER TABLE dbo.receiverInformation ADD DeletedBy VARCHAR(1) NULL
ALTER TABLE dbo.receiverInformation ADD DeletedDate DATETIME NULL
ALTER TABLE dbo.receiverInformation ADD NativeCountry INT NULL

ALTER TABLE dbo.receiverInformation ADD agentId BIGINT NULL