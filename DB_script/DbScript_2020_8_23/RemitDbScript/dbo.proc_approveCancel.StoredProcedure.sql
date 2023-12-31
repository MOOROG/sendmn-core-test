USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_approveCancel]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

EXEC proc_approveCancel @flag = 's', @user = 'shree_b1'
SELECT * FROM remitTran where controlNo = '91181462426'

*/

CREATE PROC [dbo].[proc_approveCancel] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@tranId			INT				= NULL	
	,@sCountry			INT				= NULL
	,@sFirstName		VARCHAR(30)		= NULL
	,@sMiddleName		VARCHAR(30)		= NULL
	,@sLastName1		VARCHAR(30)		= NULL
	,@sLastName2		VARCHAR(30)		= NULL
	,@sMemId			VARCHAR(30)		= NULL
	,@sId				BIGINT			= NULL	
	,@sTranId			VARCHAR(50)		= NULL	
	,@rCountry			INT				= NULL
	,@rFirstName		VARCHAR(30)		= NULL
	,@rMiddleName		VARCHAR(30)		= NULL
	,@rLastName1		VARCHAR(30)		= NULL
	,@rLastName2		VARCHAR(30)		= NULL
	,@rMemId			VARCHAR(30)		= NULL
	,@rId				BIGINT			= NULL

	,@customerId		INT				= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
) 
AS

--SELECT * FROM customers
--select * from customerDocument
--select * from customerIdentity


DECLARE 
	 @select_field_list VARCHAR(MAX)
	,@extra_field_list  VARCHAR(MAX)
	,@table             VARCHAR(MAX)
	,@sql_filter        VARCHAR(MAX)

SET NOCOUNT ON
SET XACT_ABORT ON
--select * from customers

SELECT @pageSize = 1000, @pageNumber = 1

IF @flag = 's'	--Load Data
BEGIN
	DECLARE @agentId INT = NULL
	
	SELECT @agentId = agentId FROM applicationUsers WHERE userName = @user
     
    SET @sortBy = ISNULL(@sortBy, 'Id')
    SET @sortOrder = ISNULL(@sortOrder, 'ASC')
    
	SET @table = '(
				SELECT 
					 trn.id
					,trn.controlNo
					,sCustomerId = sen.customerId
					,senderName = sen.firstName + ISNULL( '' '' + sen.middleName, '''') + ISNULL( '' '' + sen.lastName1, '''') + ISNULL( '' '' + sen.lastName2, '''')
					,sCountryName = sen.country
					,sStateName = sen.state
					,sCity = sen.city
					,sAddress = sen.address
					,rCustomerId = rec.customerId
					,receiverName = rec.firstName + ISNULL( '' '' + rec.middleName, '''') + ISNULL( '' '' + rec.lastName1, '''') + ISNULL( '' '' + rec.lastName2, '''')
					,rCountryName = rec.country
					,rStateName = rec.state
					,rCity = rec.city
					,rAddress = rec.address
					,tranStatus = ts.detailTitle
					,payStatus = ps.detailTitle
				FROM remitTran trn WITH(NOLOCK)
				LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
				LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
				LEFT JOIN staticDataValue ts WITH(NOLOCK) ON trn.tranStatus = ts.valueId
				LEFT JOIN staticDataValue ps WITH(NOLOCK) ON trn.payStatus = ps.valueId
				WHERE trn.cancelRequestBy IS NOT NULL 
					 
	'
	
	SET @sql_filter = ''
	
	IF @controlNo IS NOT NULL
		SET @table = @table + ' AND trn.controlNo = ''' + @controlNo + '''' 
		
	IF @sFirstName IS NOT NULL
		SET @table = @table + ' AND sen.firstName LIKE ''' + @sFirstName + '%'''
		
	IF @sMiddleName IS NOT NULL
		SET @table = @table + ' AND sen.middleName LIKE ''' + @sMiddleName + '%'''
		
	IF @sLastName1 IS NOT NULL
		SET @table = @table + ' AND sen.lastName1 LIKE ''' + @sLastName1 + '%'''
		
	IF @sLastName2 IS NOT NULL
		SET @table = @table + ' AND sen.lastName2 LIKE ''' + @sLastName2 + '%'''
		
	IF @sMemId IS NOT NULL
		SET @table = @table + ' AND sen.membershipId = ' + CAST(@sMemId AS VARCHAR)
			
	IF @rFirstName IS NOT NULL
		SET @table = @table + ' AND rec.firstName LIKE ''' + @rFirstName + '%'''
		
	IF @rMiddleName IS NOT NULL
		SET @table = @table + ' AND rec.middleName LIKE ''' + @rMiddleName + '%'''
		
	IF @rLastName1 IS NOT NULL
		SET @table = @table + ' AND rec.lastName1 LIKE ''' + @rLastName1 + '%'''
		
	IF @rLastName2 IS NOT NULL
		SET @table = @table + ' AND rec.lastName2 LIKE ''' + @rLastName2 + '%'''		
		
	IF @rMemId IS NOT NULL
		SET @table = @table + ' AND c.membershipId = ' + CAST(@rMemId AS VARCHAR)
		
	SET @select_field_list ='
				 id
				,controlNo
				,sCustomerId
				,senderName
				,sCountryName
				,sStateName
				,sCity
				,sAddress
				,rCustomerId
				,receiverName
				,rCountryName
				,rStateName
				,rCity
				,rAddress
				,tranStatus
				,payStatus				
			   '
	SET @table = @table + ') x'
	PRINT(@table)
	

	
	EXEC dbo.proc_paging
            @table
           ,@sql_filter
           ,@select_field_list
           ,@extra_field_list
           ,@sortBy
           ,@sortOrder
           ,@pageSize
           ,@pageNumber
END

ELSE IF @flag = 'approve'
BEGIN
	UPDATE remitTran SET
		 cancelApprovedBy = @user
		,cancelApprovedDate = GETDATE()
		,cancelApprovedDateLocal = DBO.FNADateFormatTZ(GETDATE(), @user)
	WHERE id = @tranId
END
ELSE IF @flag = 'reject'
BEGIN
	SELECT * FROM staticDataValue WHERE typeID = 5400
	UPDATE remitTran SET 
		 tranStatus = 5405
		,cancelApprovedBy = @user
		,cancelApprovedDate = GETDATE()
		,cancelApprovedDateLocal = DBO.FNADateFormatTZ(GETDATE(), @user)
	WHERE id = @tranId
END
ELSE IF @flag = 'details'
BEGIN
	SELECT 
			 trn.id
			,trn.controlNo
			,sMemId = sen.membershipId
			,sCustomerId = sen.customerId
			,senderName = sen.firstName + ISNULL( ' ' + sen.middleName, '') + ISNULL( ' ' + sen.lastName1, '') + ISNULL( ' ' + sen.lastName2, '')
			,sCountryName = sen.country
			,sStateName = sen.state
			,sDistrict = sen.district
			,sCity = sen.city
			,sAddress = sen.address
			
			,rMemId = rec.membershipId
			,rCustomerId = rec.customerId
			,receiverName = rec.firstName + ISNULL( ' ' + rec.middleName, '') + ISNULL( ' ' + rec.lastName1, '') + ISNULL( ' ' + rec.lastName2, '')
			,rCountryName = rec.country
			,rStateName = rec.state
			,rDistrict = rec.district
			,rCity = rec.city
			,rAddress = rec.address
			
			,pBranchName = ISNULL(pa.agentName, 'Any')
			,pCountryName = pcm.countryName
			,pDistrict = pDist.districtName
			,pAddress = pa.agentAddress
			
			,trn.tAmt
			,trn.serviceCharge
			,trn.handlingFee
			,trn.cAmt
			,trn.pAmt
			
			,relationship = ISNULL(rel.detailTitle, 'N/A')
			,purpose = ISNULL(pur.detailTitle, 'N/A')
			,sourceOfFund = ISNULL(sof.detailTitle, 'N/A')
			,trn.pAmt
			,collMode = col.detailTitle
			,paymentMethod = stm.typeTitle
			,trn.payoutCurr
			,tranStatus = ts.detailTitle
			,payStatus = ps.detailTitle
			,payoutMsg = ISNULL(trn.pMessage, 'N/A')
			
			,trn.sBranch
			,sa.parentId
			,sBranchName = sa.agentName
			,trn.cancelRequestBy
			,trn.cancelRequestDateLocal
			,trn.cancelReason
		FROM remitTran trn WITH(NOLOCK)
		LEFT JOIN tranSenders sen WITH(NOLOCK) ON trn.id = sen.tranId
		LEFT JOIN tranReceivers rec WITH(NOLOCK) ON trn.id = rec.tranId
		
		LEFT JOIN agentMaster sa WITH(NOLOCK) ON trn.sBranch = sa.agentId
		LEFT JOIN agentMaster pa WITH(NOLOCK) ON trn.pBranch = pa.agentId
		LEFT JOIN countryMaster pcm WITH(NOLOCK) ON trn.pCountry = pcm.countryId
		LEFT JOIN zoneDistrictMap pDist WITH(NOLOCK) ON trn.pDistrict = pDist.districtId
		
		LEFT JOIN staticDataValue ts WITH(NOLOCK) ON trn.tranStatus = ts.valueId
		LEFT JOIN staticDataValue ps WITH(NOLOCK) ON trn.payStatus = ps.valueId 
		
		LEFT JOIN staticDataValue col WITH(NOLOCK) ON trn.collMode = col.valueId
		LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON trn.paymentMethod = stm.serviceTypeId
		LEFT JOIN staticDataValue rel WITH(NOLOCK) ON sen.relationShip = rel.valueId
		LEFT JOIN staticDataValue pur WITH(NOLOCK) ON sen.purpose = pur.valueId
		LEFT JOIN staticDataValue sof WITH(NOLOCK) ON sen.sourceOfFunds = sof.valueId
		WHERE 
				trn.id = @tranId
		
END
	



GO
