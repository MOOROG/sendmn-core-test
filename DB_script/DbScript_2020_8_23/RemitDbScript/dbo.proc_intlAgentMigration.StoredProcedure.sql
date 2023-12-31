USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_intlAgentMigration]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	SELECT * FROM intlAgents
	EXEC proc_intlAgentMigration @flag = 'i'
	EXEC proc_intlAgentMigration @flag = 'approve'
*/
CREATE PROCEDURE [dbo].[proc_intlAgentMigration]
	 @flag		VARCHAR(20)		= NULL

AS

DECLARE @result TABLE(errorCode INT, msg VARCHAR(200), id INT)
DECLARE @tempIntlBranchList TABLE(rowId INT IDENTITY(1,1), companyName VARCHAR(255), agentCode VARCHAR(10), agent_branch_code VARCHAR(10), branch VARCHAR(200), country VARCHAR(200),
[address] VARCHAR(255), city VARCHAR(200), telephone VARCHAR(200), fax VARCHAR(200), isHeadOffice VARCHAR(100), contactPerson VARCHAR(200))

IF @flag = 'i'
BEGIN
	DECLARE @parentId INT, @agentCountryId INT, @agentType INT, @agentRole CHAR(1), @isSettlingAgent CHAR(1)
	DECLARE @rowId INT, @agentName VARCHAR(255), @agentCode VARCHAR(10), @agent_branch_code VARCHAR(10), @branch VARCHAR(200), @country VARCHAR(200),
@agentAddress VARCHAR(255), @agentCity VARCHAR(200), @telephone VARCHAR(200), @fax VARCHAR(200), @isHeadOffice VARCHAR(100), @contactPerson VARCHAR(200)
	INSERT INTO @tempIntlBranchList
	SELECT * FROM intlAgents
	
	SELECT @agentRole = 'B'

	WHILE EXISTS(SELECT 'X' FROM @tempIntlBranchList)
	BEGIN
		SELECT TOP 1 
			 @rowId = rowId, @agentName = companyName, @agentCode = agentCode, @agent_branch_code = agent_branch_code, @branch = branch, @country = country
			,@agentAddress = [address], @agentCity = city, @telephone = telephone, @fax = fax, @isHeadOffice = isHeadOffice, @contactPerson = contactPerson 
		FROM @tempIntlBranchList
		
		SELECT @agentCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @country
		
		IF NOT EXISTS(SELECT 'X' FROM agentMaster WITH(NOLOCK) WHERE mapCodeInt = @agentCode)
		BEGIN
			SELECT @parentId = 4641, @agentType = 2903, @isSettlingAgent = 'Y'

			EXEC proc_agentMasterMigration @flag = 'i', @user = 'admin', @agentId = null, @parentId = @parentId, @agentName = @agentName, @agentAddress = @agentAddress
					, @agentCity = @agentCity, @agentCountryId = @agentCountryId, @agentCountry = @country, @agentPhone1 = @telephone
					, @agentFax1 = @fax
					, @agentRole = @agentRole, @agentType = @agentType
					, @isSettlingAgent = @isSettlingAgent
					, @mapCodeInt = @agentCode
		END
		SET @agentType = 2904
		SET @isSettlingAgent = 'N'
		SELECT @parentId = agentId FROM agentMaster WITH(NOLOCK) WHERE mapCodeInt = @agentCode
		SELECT @agentName = companyName + ISNULL(' - ' + branch, '') FROM @tempIntlBranchList WHERE rowId = @rowId

		EXEC proc_agentMasterMigration @flag = 'i', @user = 'admin', @agentId = null, @parentId = @parentId, @agentName = @agentName, @agentAddress = @agentAddress
				, @agentCity = @agentCity, @agentCountryId = @agentCountryId, @agentCountry = @country, @agentPhone1 = @telephone
				, @agentFax1 = @fax
				, @agentRole = @agentRole, @agentType = @agentType
				, @isSettlingAgent = @isSettlingAgent
				, @mapCodeInt = @agent_branch_code
		
		DELETE FROM @tempIntlBranchList WHERE rowId = @rowId
		
		SELECT
			 @agentName = NULL, @agentCode = NULL, @agent_branch_code = NULL, @branch = NULL, @country = NULL
			,@agentAddress = NULL, @agentCity = NULL, @telephone = NULL, @fax = NULL, @isHeadOffice = NULL, @contactPerson = NULL 
	END
END

ELSE IF @flag = 'approve'
BEGIN
	DECLARE @agentIds TABLE(rowId INT IDENTITY(1,1), agentId INT, mapCodeInt VARCHAR(8))
	DECLARE @totalRows INT, @count INT, @agentId INT, @mapCodeInt VARCHAR(10)
	INSERT @agentIds
	SELECT agentId, mapCodeInt FROM agentMaster WHERE approvedBy IS NULL
	
	SELECT @totalRows = COUNT(*) FROM @agentIds
	SET @count = 1
	WHILE (@count <= @totalRows)
	BEGIN
		SELECT @agentId = agentId, @mapCodeInt = mapCodeInt FROM @agentIds WHERE rowId = @count
		EXEC proc_agentMaster @flag = 'approve', @user = 'imeadmin', @agentId = @agentId
		SET @count = @count + 1
	END
END 
ELSE IF @flag = 'otherInfo'
BEGIN
	SELECT * FROM intlAgentsInfo
	SELECT * FROM agentContactPerson
	
	UPDATE am SET
		 am.agentAddress = iai.[address]
		,am.agentPhone1 = iai.phone1
		,am.agentPhone2 = iai.phone2
		,am.agentFax1 = iai.fax
		,am.agentEmail1 = iai.email
		,am.joinedDate = iai.dateofjoin
	FROM agentMaster am
	INNER JOIN intlAgentsInfo iai ON am.mapCodeInt = iai.agentCode
	
	/*
	INSERT INTO agentContactPerson(agentId, name, country, address, phone, mobile1, fax, email, post, isPrimary, createdBy, createdDate)
	SELECT am.agentId, iai.contactname1, cm.countryId, am.agentAddress, iai.phone1, iai.phone2, iai.fax, iai.email, iai.post1, 'Y', 'admin', GETDATE()
	FROM agentMaster am 
	INNER JOIN intlAgentsInfo iai ON am.mapCodeInt = iai.agentCode
	LEFT JOIN countryMaster cm ON cm.countryName = iai.country
	*/
END



GO
