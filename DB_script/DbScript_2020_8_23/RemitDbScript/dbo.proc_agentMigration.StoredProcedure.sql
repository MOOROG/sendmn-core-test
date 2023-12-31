USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentMigration]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_agentMigration]
	 @flag	VARCHAR(50)		= NULL
AS
/*
	TRUNCATE TABLE agentMaster
	TRUNCATE TABLE agentContactPerson
	TRUNCATE TABLE agentBankAccount
	TRUNCATE TABLE creditLimit
	
	SELECT * FROM agentmaster
	EXEC proc_agentMigration 'i'
	EXEC proc_agentMigration 'approve'
	EXEC proc_agentMigration 'groupMap'
*/
IF @flag = 'i'
BEGIN
	CREATE TABLE #result(errorCode INT, msg VARCHAR(200), id INT)
	DECLARE @parentId INT = NULL, @bankId INT = NULL, @agentId INT = NULL
	IF NOT EXISTS(SELECT 'X' FROM agentMaster WHERE agentName = 'Head Office')
	BEGIN
		INSERT INTO agentMaster(
			 parentId
			,agentName
			,agentCode
			,agentAddress
			,agentCity
			,agentCountry
			,agentState
			,agentDistrict
			,agentLocation
			,agentType
			,isActive
			,createdDate
			,createdBy
			,approvedDate
			,approvedBy
			,agentCountryId
		)
		SELECT
			 0
			,'Head Office'
			,'HO'
			,'Kathmandu'
			,'Kathmandu'
			,'Nepal'
			,'Bagmati'
			,'Kathmandu'
			,137
			,2901
			,'Y'
			,GETDATE()
			,'system'
			,GETDATE()
			,'system'
			,151
	END
	IF NOT EXISTS(SELECT 'X' FROM agentMaster WHERE agentId = 1002)
	BEGIN
		INSERT INTO agentMaster(parentId, agentName, agentAddress, agentCity, agentCountry, agentState, agentDistrict, agentLocation,
			agentPhone1, agentMobile1, agentEmail1, businessOrgType, businessType, agentRole, agentType, allowAccountDeposit, actAsBranch, isSettlingAgent,
			businessLicense, localTime, isActive, createdDate, createdBy, approvedDate, approvedBy, agentCountryId)
		SELECT 1001, 'International Money Express (IME) Pvt. Ltd', 'Pani Pokhari, Kathmandu', 'Kathmandu', 'Nepal', 'Bagmati', 'Kathmandu', 137,
			'4254578', '9841412145', 'imeremit@imeremit.com.np', '4503', '6200', 'B', '2902', 'N', 'N', 'N',
			'1', '23', 'Y', GETDATE(), 'admin', GETDATE(), 'imeadmin', 151
		
	END
	SET @parentId = 1002
	DECLARE @agentName VARCHAR(200), @bankName VARCHAR(200), @agentAddress VARCHAR(200), @agentCity VARCHAR(100), @agentCountryId INT, @agentCountry VARCHAR(100), @agentState VARCHAR(100),
		@agentDistrict VARCHAR(100), @agentZip VARCHAR(15), @agentLocation INT, @agentPhone1 VARCHAR(20), @agentPhone2 VARCHAR(20), @agentFax1 VARCHAR(20), 
		@agentFax2 VARCHAR(20), @agentMobile1 VARCHAR(20), @agentMobile2 VARCHAR(20), @agentEmail1 VARCHAR(20), @agentEmail2 VARCHAR(20),
		@businessOrgType INT, @businessType INT, @agentRole CHAR(1), @agentType INT, @allowAccountDeposit CHAR(1), @actAsBranch CHAR(1), 
		@contractExpiryDate DATETIME, @renewalFollowupDate DATETIME, @isSettlingAgent CHAR(1), @agentGroup INT, @businessLicense VARCHAR(50), @agentBlock CHAR(1),
		@localTime INT, @agentDetails VARCHAR(200), @headMessage VARCHAR(200), @mapCodeInt VARCHAR(10), @mapCodeDom VARCHAR(10),
		@commCodeInt VARCHAR(10), @commCodeDom VARCHAR(10), @isHO CHAR(1), @bank_name VARCHAR(100), @bankBranchName VARCHAR(100), @bankAccount VARCHAR(50),
		@contactPerson VARCHAR(100), @joinedDate DATETIME

	--Agent Act As Branch
	DECLARE @branchList TABLE(rowId INT IDENTITY(1,1), district_bank VARCHAR(100), agent_branch_code VARCHAR(8), branch VARCHAR(100), address VARCHAR(100),
	city VARCHAR(100), email VARCHAR(100), contactPerson VARCHAR(100), telephone VARCHAR(50), fax VARCHAR(50), bank_name VARCHAR(100),
	bankBranchName VARCHAR(100), bankAccount VARCHAR(50), interCommId VARCHAR(8), domesticId VARCHAR(8), domesticCommId VARCHAR(8), location INT, startHour INT, endhour INT,
	letterHead VARCHAR(MAX), certificate VARCHAR(200), limitPtran MONEY, creditLimit MONEY, created DATETIME, joined DATETIME, headOffice CHAR(1),
	PAN VARCHAR(30), Constitution VARCHAR(100))

	INSERT INTO @branchList
	SELECT * FROM FINALAGENT WHERE District_Bank NOT IN(
		SELECT District_Bank FROM FINALAGENT WHERE 
		District_Bank LIKE '%Bank%' OR
		District_Bank LIKE '%Finance%' OR
		District_Bank LIKE '%Ltd%' OR 
		District_Bank LIKE '%Limited%')
	ORDER BY District_Bank, branch ASC
	DECLARE @totalRows INT, @count INT
	SET @count = 1
	SELECT @totalRows = COUNT(*) FROM @branchList
	WHILE(@count <= @totalRows)
	BEGIN
		SELECT DISTINCT @mapCodeInt = agent_branch_code, @agentName = branch, @agentAddress = [address], @agentCity = city, @agentEmail1 = email, @agentPhone1 = telephone, 
		@agentFax1 = fax, @commCodeInt = interCommID, @mapCodeDom = domesticId, @commCodeDom = domesticCommId, @agentLocation = location, @headMessage = letterHead,
		@isHO = HeadOffice, @businessLicense = PAN, @bank_name = bank_name, @bankBranchName = bankBranchname, @bankAccount = bankAccount,
		@contactPerson = contactPerson, @joinedDate = joined,
		@businessOrgType = CASE WHEN Constitution = 'Partnership Firm' THEN 4502 WHEN Constitution = 'Limited Company' THEN 6003 
							WHEN Constitution = 'IME exchange counter' THEN 6002 WHEN Constitution = 'Private Ltd. Firm' THEN 6002
							WHEN Constitution = 'Proprietorship Firm' THEN 4501 END
		FROM @branchList WHERE rowId = @count
		
		SELECT @agentCountryId = 151, @agentCountry = 'Nepal', @localTime = 23, @isSettlingAgent = 'Y', @actAsBranch = 'Y', @agentType = 2903
		SELECT DISTINCT @agentDistrict = zdm.districtName, @agentState = csm.stateName FROM apiLocationMapping alm 
		INNER JOIN zoneDistrictMap zdm ON alm.districtId = zdm.districtId
		INNER JOIN countryStateMaster csm ON zdm.zone = csm.stateId WHERE alm.apiDistrictCode = @agentLocation
		
		INSERT INTO #result
		EXEC proc_agentMasterMigration @flag = 'i', @user = 'admin', @agentId = null, @parentId = @parentId, @agentName = @agentName, @agentAddress = @agentAddress
				, @agentCity = @agentCity, @agentCountryId = @agentCountryId, @agentCountry = @agentCountry, @agentState = @agentState
				, @agentDistrict = @agentDistrict, @agentZip = @agentZip, @agentLocation = @agentLocation, @agentPhone1 = @agentPhone1
				, @agentPhone2 = @agentPhone2, @agentFax1 = @agentFax1, @agentFax2 = @agentFax1, @agentMobile1 = @agentMobile1, @agentMobile2 = @agentMobile2
				, @agentEmail1 = @agentEmail1, @agentEmail2 = @agentEmail2, @businessOrgType = @businessOrgType, @businessType = @businessType
				, @agentRole = @agentRole, @agentType = @agentType, @allowAccountDeposit = @allowAccountDeposit, @actAsBranch = @actAsBranch
				, @contractExpiryDate = @contractExpiryDate, @renewalFollowupDate = @renewalFollowupDate, @isSettlingAgent = @isSettlingAgent
				, @agentGroup = @agentGroup, @businessLicense = @businessLicense, @agentBlock = @agentBlock, @localTime = @localTime
				, @agentDetails = @agentDetails, @headMessage = @headMessage
				, @mapCodeInt = @mapCodeInt, @mapCodeDom = @mapCodeDom, @commCodeInt = @commCodeInt, @commCodeDom = @commCodeDom
				, @joinedDate = @joinedDate
	    
		SELECT @agentId = id FROM #result
		DELETE FROM #result
		INSERT INTO agentBankAccount(agentId, bankName, bankBranch, accountNo, createdBy, createdDate)
		SELECT @agentId, @bank_name, @bankBranchName, @bankAccount, 'admin', GETDATE()
	    
		INSERT INTO agentContactPerson(agentId, name, isPrimary, createdBy, createdDate)
		SELECT @agentId, @contactPerson, 'Y', 'admin', GETDATE()
	    
	    INSERT INTO agentGroupMaping(agentId, groupCat, groupDetail, createdBy, createdDate)
	    SELECT @agentId, 6900, 6220, 'admin', GETDATE() UNION ALL
	    SELECT @agentId, 6600, CASE WHEN @agentLocation IN (137, 177, 225) THEN 7018 ELSE 7021 END, 'admin', GETDATE()
		SET @count = @count + 1
	END  

	IF OBJECT_ID('tempdb..#bankBranchList') IS NOT NULL
		DROP TABLE #bankBranchList
	DELETE FROM @branchList
	INSERT INTO @branchList
	SELECT * FROM FINALAGENT WHERE 
	District_Bank LIKE '%Bank%' OR
	District_Bank LIKE '%Finance%' OR
	District_Bank LIKE '%Ltd%' OR 
	District_Bank LIKE '%Limited%'
	ORDER BY District_Bank, headoffice DESC 

	SELECT @totalRows = @totalRows + COUNT(*) FROM @branchList
	WHILE(@count <= @totalRows)
	BEGIN
		SELECT DISTINCT @mapCodeInt = agent_branch_code, @agentName = branch, @bankName = district_bank, @agentAddress = [address], @agentCity = city, @agentEmail1 = email, @agentPhone1 = telephone, 
		@agentFax1 = fax, @commCodeInt = interCommID, @mapCodeDom = domesticId, @commCodeDom = domesticCommId, @agentLocation = location, @headMessage = letterHead,
		@agentCountryId = 151, @agentCountry = 'Nepal', @localTime = 23, 
		@isHO = HeadOffice, @businessLicense = PAN, @bank_name = bank_name, @bankBranchName = bankBranchname, @bankAccount = bankAccount,
		@contactPerson = contactPerson, @joinedDate = joined,
		@businessOrgType = CASE WHEN Constitution = 'Partnership Firm' THEN 4502 WHEN Constitution = 'Limited Company' THEN 6003 
							WHEN Constitution = 'IME exchange counter' THEN 6002 WHEN Constitution = 'Private Ltd. Firm' THEN 6002
							WHEN Constitution = 'Proprietorship Firm' THEN 4501 END
		FROM @branchList WHERE rowId = @count

		SELECT DISTINCT @agentDistrict = zdm.districtName, @agentState = csm.stateName FROM apiLocationMapping alm 
		INNER JOIN zoneDistrictMap zdm ON alm.districtId = zdm.districtId
		INNER JOIN countryStateMaster csm ON zdm.zone = csm.stateId WHERE alm.apiDistrictCode = @agentLocation
		
		IF ISNULL(@isHO, 'N') = 'Y'
		BEGIN
			SELECT @isSettlingAgent = 'Y', @actAsBranch = 'N', @agentType = 2903
			INSERT INTO #result(errorCode, msg, id)
			EXEC proc_agentMasterMigration @flag = 'i', @user = 'admin', @agentId = null, @parentId = @parentId, @agentName = @bankName, @agentAddress = @agentAddress
				, @agentCity = @agentCity, @agentCountryId = @agentCountryId, @agentCountry = @agentCountry, @agentState = @agentState
				, @agentDistrict = @agentDistrict, @agentZip = @agentZip, @agentLocation = @agentLocation, @agentPhone1 = @agentPhone1
				, @agentPhone2 = @agentPhone2, @agentFax1 = @agentFax1, @agentFax2 = @agentFax1, @agentMobile1 = @agentMobile1, @agentMobile2 = @agentMobile2
				, @agentEmail1 = @agentEmail1, @agentEmail2 = @agentEmail2, @businessOrgType = @businessOrgType, @businessType = @businessType
				, @agentRole = @agentRole, @agentType = @agentType, @allowAccountDeposit = @allowAccountDeposit, @actAsBranch = @actAsBranch
				, @contractExpiryDate = @contractExpiryDate, @renewalFollowupDate = @renewalFollowupDate, @isSettlingAgent = @isSettlingAgent
				, @agentGroup = @agentGroup, @businessLicense = @businessLicense, @agentBlock = @agentBlock, @localTime = @localTime
				, @agentDetails = @agentDetails, @headMessage = @headMessage
				, @mapCodeInt = @mapCodeInt, @mapCodeDom = @mapCodeDom, @commCodeInt = @commCodeInt, @commCodeDom = @commCodeDom
				, @joinedDate = @joinedDate
	           
			SELECT @bankId = id FROM #result
			DELETE FROM #result
	        
			INSERT INTO agentBankAccount(agentId, bankName, bankBranch, accountNo, createdBy, createdDate)
			SELECT @bankId, @bank_name, @bankBranchName, @bankAccount, 'admin', GETDATE()
		    
			INSERT INTO agentContactPerson(agentId, name, isPrimary, createdBy, createdDate)
			SELECT @bankId, @contactPerson, 'Y', 'admin', GETDATE()
	    
		END
		SELECT @isSettlingAgent = 'N', @actAsBranch = 'N', @agentType = 2904
		INSERT INTO #result
		EXEC proc_agentMasterMigration @flag = 'i', @user = 'admin', @agentId = null, @parentId = @bankId, @agentName = @agentName, @agentAddress = @agentAddress
				, @agentCity = @agentCity, @agentCountryId = @agentCountryId, @agentCountry = @agentCountry, @agentState = @agentState
				, @agentDistrict = @agentDistrict, @agentZip = @agentZip, @agentLocation = @agentLocation, @agentPhone1 = @agentPhone1
				, @agentPhone2 = @agentPhone2, @agentFax1 = @agentFax1, @agentFax2 = @agentFax1, @agentMobile1 = @agentMobile1, @agentMobile2 = @agentMobile2
				, @agentEmail1 = @agentEmail1, @agentEmail2 = @agentEmail2, @businessOrgType = @businessOrgType, @businessType = @businessType
				, @agentRole = @agentRole, @agentType = @agentType, @allowAccountDeposit = @allowAccountDeposit, @actAsBranch = @actAsBranch
				, @contractExpiryDate = @contractExpiryDate, @renewalFollowupDate = @renewalFollowupDate, @isSettlingAgent = @isSettlingAgent
				, @agentGroup = @agentGroup, @businessLicense = @businessLicense, @agentBlock = @agentBlock, @localTime = @localTime
				, @agentDetails = @agentDetails, @headMessage = @headMessage
				, @mapCodeInt = @mapCodeInt, @mapCodeDom = @mapCodeDom, @commCodeInt = @commCodeInt, @commCodeDom = @commCodeDom
				, @joinedDate = @joinedDate
	    
		SELECT @agentId = id FROM #result
		DELETE FROM #result
	        
		INSERT INTO agentBankAccount(agentId, bankName, bankBranch, accountNo, createdBy, createdDate)
		SELECT @agentId, @bank_name, @bankBranchName, @bankAccount, 'admin', GETDATE()
	    
		INSERT INTO agentContactPerson(agentId, name, isPrimary, createdBy, createdDate)
		SELECT @agentId, @contactPerson, 'Y', 'admin', GETDATE()
		
		INSERT INTO agentGroupMaping(agentId, groupCat, groupDetail, createdBy, createdDate)
	    SELECT @agentId, 6900, 6220, 'admin', GETDATE() UNION ALL
	    SELECT @agentId, 6600, CASE WHEN @agentLocation IN (137, 177, 225) THEN 7018 ELSE 7021 END, 'admin', GETDATE()
	    
		SET @count = @count + 1
	END 
END
ELSE IF @flag = 'approve'
BEGIN
	DECLARE @creditLimit MONEY
	DECLARE @agentIds TABLE(rowId INT IDENTITY(1,1), agentId INT, mapCodeInt VARCHAR(8))
	INSERT @agentIds
	SELECT agentId, mapCodeInt FROM agentMaster WHERE approvedBy IS NULL
	
	SELECT @totalRows = COUNT(*) FROM @agentIds
	SET @count = 1
	WHILE (@count <= @totalRows)
	BEGIN
		SELECT @agentId = agentId, @mapCodeInt = mapCodeInt FROM @agentIds WHERE rowId = @count
		EXEC proc_agentMasterMigration @flag = 'approve', @user = 'imeadmin', @agentId = @agentId
		
		SELECT @creditLimit = creditLimit FROM FINALAGENT WHERE agent_branch_Code = @mapCodeInt
		UPDATE creditLimit SET
			 limitAmt		= @creditLimit
			,maxLimitAmt	= @creditLimit
		WHERE agentId = @agentId
		SET @count = @count + 1
	END
END 
ELSE IF @flag = 'groupMap'
BEGIN
	--TRUNCATE TABLE agentGroupMaping
	DECLARE @agentIds2 TABLE(agentId INT, agentLocation INT, actAsBranch CHAR(1), agentType INT)
	INSERT @agentIds2
	SELECT agentId, agentLocation, actAsBranch, agentType FROM agentMaster
	
	SELECT @totalRows = COUNT(*) FROM @agentIds2
	SET @count = 1
	WHILE EXISTS(SELECT 'X' FROM @agentIds2)
	BEGIN
		SELECT TOP 1 @agentId = agentId, @agentLocation = agentLocation, @actAsBranch = actAsBranch, @agentType = agentType FROM @agentIds2
		IF (@agentType IN (2903,2904))
		BEGIN
			INSERT INTO agentGroupMaping(agentId, groupCat, groupDetail, createdBy, createdDate)
			SELECT @agentId, 6900, 6220, 'admin', GETDATE()
	    END
	    IF (@actAsBranch = 'Y' OR @agentType = 2904)
	    BEGIN
			INSERT INTO agentGroupMaping(agentId, groupCat, groupDetail, createdBy, createdDate)
			SELECT @agentId, 6600, CASE WHEN @agentLocation IN (137, 177, 225) THEN 7018 ELSE 7021 END, 'admin', GETDATE()
	    END
	    DELETE FROM @agentIds2 WHERE agentId = @agentId
	END
END   

/*
--Agent Act As Branch
SELECT * FROM FINALAGENT WHERE District_Bank NOT IN(
	SELECT District_Bank FROM FINALAGENT WHERE 
	District_Bank LIKE '%Bank%' OR
	District_Bank LIKE '%Finance%' OR
	District_Bank LIKE '%Ltd%' OR 
	District_Bank LIKE '%Limited%')
ORDER BY District_Bank, branch ASC

--Branches
SELECT * FROM FINALAGENT WHERE 
District_Bank LIKE '%Bank%' OR
District_Bank LIKE '%Finance%' OR
District_Bank LIKE '%Ltd%' OR 
District_Bank LIKE '%Limited%'
ORDER BY District_Bank, headoffice DESC 
*/

/*
DELETE FROM FINALAGENT WHERE district_bank IN (
	'Annapurna Bikas Bank Limited',
	'Annapurna Finance Company Ltd.'
	'Business Development Bank Ltd.', 
	'GLOBAL BANK LTD.', 
	'Himchuli Bikas Bank Ltd.',
	'Standard Finance Limited')
*/


GO
