USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[int_proc_sendSync_from_route_UK]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[int_proc_sendSync_from_route_UK] (
	 @flag		VARCHAR(50)
	,@routeId	VARCHAR(5) = NULL
	,@xml		XML = NULL
)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY	

	IF @flag = 'bulk'
	BEGIN
		SELECT
			 tranId					= p.value('@tranId', 'BIGINT')
			,controlNo				= p.value('@controlNo', 'VARCHAR(50)')
			,sCurrCostRate			= p.value('@sCurrCostRate', 'FLOAT')
			,sCurrHoMargin			= p.value('@sCurrHoMargin', 'FLOAT')
			,sCurrSuperAgentMargin	= p.value('@sCurrSuperAgentMargin', 'FLOAT')
			,sCurrAgentMargin		= p.value('@sCurrAgentMargin', 'FLOAT')
			,pCurrCostRate			= p.value('@pCurrCostRate', 'FLOAT')
			,pCurrHoMargin			= p.value('@pCurrHoMargin', 'FLOAT')
			,pCurrSuperAgentMargin	= p.value('@pCurrSuperAgentMargin', 'FLOAT')
			,pCurrAgentMargin		= p.value('@pCurrAgentMargin', 'FLOAT')
			,agentCrossSettRate		= p.value('@agentCrossSettRate', 'FLOAT')
			,customerRate			= p.value('@customerRate', 'FLOAT')
			,sAgentSettRate			= p.value('@sAgentSettRate', 'FLOAT')
			,pDateCostRate			= p.value('@pDateCostRate', 'FLOAT')
			,agentFxGain			= p.value('@agentFxGain', 'MONEY')
			,treasuryTolerance		= p.value('@treasuryTolerance', 'FLOAT')
			,customerPremium		= p.value('@customerPremium', 'FLOAT')
			,schemePremium			= p.value('@schemePremium', 'FLOAT')
			,sharingValue			= p.value('@sharingValue', 'MONEY')
			,sharingType			= p.value('@sharingType', 'CHAR(1)')
			,serviceCharge			= p.value('@serviceCharge', 'MONEY')
			,handlingFee			= p.value('@handlingFee', 'MONEY')
			,sAgentComm				= p.value('@sAgentComm', 'FLOAT')
			,sAgentCommCurrency		= p.value('@sAgentCommCurrency', 'VARCHAR(3)')
			,sSuperAgentComm		= p.value('@sSuperAgentComm', 'MONEY')
			,sSuperAgentCommCurrency= p.value('@sSuperAgentCommCurrency', 'VARCHAR(3)')
			,pAgentComm				= p.value('@pAgentComm', 'FLOAT')
			,pAgentCommCurrency		= p.value('@pAgentCommCurrency', 'VARCHAR(3)')
			,pSuperAgentComm		= p.value('@pSuperAgentComm', 'MONEY')
			,pSuperAgentCommCurrency= p.value('@pSuperAgentCommCurrency', 'VARCHAR(3)')
			,promotionCode			= p.value('@promotionCode', 'VARCHAR(50)')
			,promotionType			= p.value('@promotionType', 'VARCHAR(50)')
			,pMessage				= p.value('@pMessage', 'VARCHAR(150)')
			,sCountry				= p.value('@sCountry', 'VARCHAR(100)')
			,sSuperAgent			= p.value('@sSuperAgent', 'VARCHAR(10)')
			,sSuperAgentName		= p.value('@sSuperAgentName', 'VARCHAR(100)')
			,sAgent					= p.value('@sAgent', 'VARCHAR(10)')
			,sAgentName				= p.value('@sAgentName', 'VARCHAR(100)')
			,sBranch				= p.value('@sBranch', 'VARCHAR(10)')
			,sBranchName			= p.value('@sBranchName', 'VARCHAR(100)')
			,pCountry				= p.value('@pCountry', 'VARCHAR(100)')
			,pSuperAgent			= NULLIF(p.value('@pSuperAgent', 'VARCHAR(10)'), '')
			,pSuperAgentName		= NULLIF(p.value('@pSuperAgentName', 'VARCHAR(100)'), '')
			,pAgent					= NULLIF(p.value('@pAgent', 'VARCHAR(10)'), '')
			,pAgentName				= NULLIF(p.value('@pAgentName', 'VARCHAR(100)'), '')
			,pBranch				= NULLIF(p.value('@pBranch', 'VARCHAR(10)'), '')
			,pBranchName			= NULLIF(p.value('@pBranchName', 'VARCHAR(100)'), '')
			,paymentMethod			= NULLIF(p.value('@paymentMethod', 'VARCHAR(100)'), '')
			,pBank					= NULLIF(p.value('@pBank', 'VARCHAR(10)'), '')
			,pBankName				= NULLIF(p.value('@pBankName', 'VARCHAR(100)'), '')
			,pBankBranch			= NULLIF(p.value('@pBankBranch', 'VARCHAR(10)'), '')
			,pBankBranchName		= NULLIF(p.value('@pBankBranchName', 'VARCHAR(100)'), '')
			,pBankType				= NULLIF(p.value('@pBankType', 'CHAR(1)'), '')
			,expectedPayoutAgent	= NULLIF(p.value('@expectedPayoutAgent', 'VARCHAR(100)'), '')
			,accountNo				= NULLIF(p.value('@accountNo', 'VARCHAR(50)'), '')
			,externalBankCode		= p.value('@externalBankCode', 'VARCHAR(50)')
			,collMode				= p.value('@collMode', 'VARCHAR(50)')
			,collCurr				= p.value('@collCurr', 'VARCHAR(3)')
			,tAmt					= p.value('@tAmt', 'MONEY')
			,cAmt					= p.value('@cAmt', 'MONEY')
			,pAmt					= p.value('@pAmt', 'MONEY')
			,payoutCurr				= p.value('@payoutCurr', 'VARCHAR(3)')
			,relWithSender			= NULLIF(p.value('@relWithSender', 'VARCHAR(100)'), '')
			,purposeOfRemit			= NULLIF(p.value('@purposeOfRemit', 'VARCHAR(100)'), '')
			,sourceOfFund			= NULLIF(p.value('@sourceOfFund', 'VARCHAR(100)'), '')
			,tranStatus				= p.value('@tranStatus', 'VARCHAR(50)')
			,payStatus				= p.value('@payStatus', 'VARCHAR(20)')
			,createdDate			= p.value('@createdDate', 'DATETIME')
			,createdDateLocal		= p.value('@createdDateLocal', 'DATETIME')
			,createdBy				= p.value('@createdBy', 'VARCHAR(50)')
			,modifiedDate			= p.value('@modifiedDate', 'DATETIME')
			,modifiedDateLocal		= p.value('@modifiedDateLocal', 'DATETIME')
			,modifiedBy				= p.value('@modifiedBy', 'VARCHAR(50)')
			,approvedDate			= p.value('@approvedDate', 'DATETIME')
			,approvedDateLocal		= p.value('@approvedDateLocal', 'DATETIME')
			,approvedBy				= p.value('@approvedBy', 'VARCHAR(50)')
			,tranType				= 'I'
			,ContNo					= p.value('@ContNo', 'VARCHAR(50)')
			,company				= p.value('@company', 'VARCHAR(200)')
			,voucherNo				= p.value('@voucherNo', 'VARCHAR(20)')
			,controlNo2				= p.value('@controlNo2', 'VARCHAR(200)')
			,routedBy				= p.value('@routedBy', 'VARCHAR(50)')
			,routedDate				= p.value('@routedDate', 'DATETIME')
			,senderName				= p.value('@senderName', 'VARCHAR(200)')
			,receiverName			= p.value('@receiverName', 'VARCHAR(200)')
			,routeId				= p.value('@routeId', 'VARCHAR(5)')
			,pRouteId				= p.value('@pRouteId', 'VARCHAR(5)')
			,incrRpt				= p.value('@incrRpt', 'CHAR(1)')
			,SchemeId				= p.value('@SchemeId', 'INT')
			,calBy					= p.value('@calBy', 'CHAR(1)')
			,lockStatus				= p.value('@lockStatus', 'VARCHAR(10)')
			,pCommissionType		= p.value('@pCommissionType', 'CHAR(1)')
		
			--Data for tranSenders Table
			,sCustomerId			= p.value('@sCustomerId', 'BIGINT')
			,sMembershipId			= p.value('@sMembershipId', 'VARCHAR(20)')
			,sFirstName				= p.value('@sFirstName', 'VARCHAR(100)')
			,sMiddleName			= p.value('@sMiddleName', 'VARCHAR(100)')
			,sLastName1				= p.value('@sLastName1', 'VARCHAR(100)')
			,sLastName2				= p.value('@sLastName2', 'VARCHAR(100)')
			,sFullName				= p.value('@sFullName', 'VARCHAR(200)')
			,ssCountry				= p.value('@ssCountry', 'VARCHAR(100)')
			,sAddress				= p.value('@sAddress', 'VARCHAR(MAX)')
			,sState					= p.value('@sState', 'VARCHAR(50)')
			,sDistrict				= p.value('@sDistrict', 'VARCHAR(50)')
			,sZipCode				= p.value('@sZipCode', 'VARCHAR(50)')
			,sCity					= p.value('@sCity', 'VARCHAR(100)')
			,sEmail					= p.value('@sEmail', 'VARCHAR(150)')
			,sHomePhone				= p.value('@sHomePhone', 'VARCHAR(50)')
			,sWorkPhone				= p.value('@sWorkPhone', 'VARCHAR(15)')
			,sMobile				= p.value('@sMobile', 'VARCHAR(50)')
			,sNativeCountry			= p.value('@sNativeCountry', 'VARCHAR(100)')
			,sDob					= p.value('@sDob', 'VARCHAR(30)')
			,sPlaceOfIssue			= p.value('@sPlaceOfIssue', 'VARCHAR(50)')
			,sCustomerType			= p.value('@sCustomerType', 'VARCHAR(50)')
			,sOccupation			= p.value('@sOccupation', 'VARCHAR(50)')
			,sIdType				= p.value('@sIdType', 'VARCHAR(50)')
			,sIdNumber				= p.value('@sIdNumber', 'VARCHAR(50)')
			,sIdPlaceOfIssue		= p.value('@sIdPlaceOfIssue', 'VARCHAR(50)')
			,sIssuedDate			= p.value('@sIssuedDate', 'VARCHAR(30)')
			,sValidDate				= p.value('@sValidDate', 'VARCHAR(30)')
			,sExtCustomerId			= p.value('@sExtCustomerId', 'VARCHAR(50)')
			,sCwPwd					= p.value('@cwPwd', 'VARCHAR(10)')
			,sTtName				= p.value('@sTtName', 'NVARCHAR(200)')
			,sIsFirstTran			= p.value('@sIsFirstTran', 'CHAR(1)')
			,sCustomerRiskPoint		= p.value('@sCustomerRiskPoint', 'FLOAT')
			,sCountryRiskPoint		= p.value('@sCountryRiskPoint', 'FLOAT')
			,sGender				= p.value('@sGender', 'VARCHAR(10)')
			,sSalary				= p.value('@sSalary', 'VARCHAR(20)')
			,sCompanyName			= p.value('@sCompanyName', 'VARCHAR(100)')
			,sAddress2				= p.value('@sAddress2', 'VARCHAR(MAX)')
			,sDcInfo				= p.value('@sDcInfo', 'VARCHAR(100)')
			,sIpAddress				= p.value('@sIpAddress', 'VARCHAR(20)')
			,sNotifySms				= p.value('@sNotifySms', 'CHAR(1)')
			,sTxnTestQuestion		= p.value('@sTxnTestQuestion', 'VARCHAR(500)')
			,sTxnTestAnswer			= p.value('@sTxnTestAnswer', 'VARCHAR(500)')
			
			--Data for tranReceivers Table
			,rCustomerId			= p.value('@rCustomerId', 'BIGINT')
			,rMembershipId			= p.value('@rMembershipId', 'VARCHAR(20)')
			,rFirstName				= p.value('@rFirstName', 'VARCHAR(100)')
			,rMiddleName			= p.value('@rMiddleName', 'VARCHAR(100)')
			,rLastName1				= p.value('@rLastName1', 'VARCHAR(100)')
			,rLastName2				= p.value('@rLastName2', 'VARCHAR(100)')
			,rFullName				= p.value('@rFullName', 'VARCHAR(200)')
			,rCountry				= p.value('@rCountry', 'VARCHAR(100)')
			,rAddress				= p.value('@rAddress', 'VARCHAR(MAX)')
			,rState					= p.value('@rState', 'VARCHAR(50)')
			,rDistrict				= p.value('@rDistrict', 'VARCHAR(50)')
			,rZipCode				= p.value('@rZipCode', 'VARCHAR(50)')
			,rCity					= p.value('@rCity', 'VARCHAR(100)')
			,rEmail					= p.value('@rEmail', 'VARCHAR(150)')
			,rHomePhone				= p.value('@rHomePhone', 'VARCHAR(50)')
			,rWorkPhone				= p.value('@rWorkPhone', 'VARCHAR(15)')
			,rMobile				= p.value('@rMobile', 'VARCHAR(50)')
			,rNativeCountry			= p.value('@rNativeCountry', 'VARCHAR(100)')
			,rPlaceOfIssue			= p.value('@rPlaceOfIssue', 'VARCHAR(50)')
			,rCustomerType			= p.value('@rCustomerType', 'VARCHAR(50)')
			,rOccupation			= p.value('@rOccupation', 'VARCHAR(50)')
			,rIdType				= p.value('@rIdType', 'VARCHAR(50)')
			,rIdNumber				= p.value('@rIdNumber', 'VARCHAR(50)')
			,rIdPlaceOfIssue		= p.value('@rIdPlaceOfIssue', 'VARCHAR(50)')
			,rIssuedDate			= p.value('@rIssuedDate', 'VARCHAR(30)')
			,rValidDate				= p.value('@rValidDate', 'VARCHAR(30)')
			,rIdType2				= p.value('@rIdType2', 'VARCHAR(50)')
			,rIdNumber2				= p.value('@rIdNumber2', 'VARCHAR(50)')
			,rIdPlaceOfIssue2		= p.value('@rIdPlaceOfIssue2', 'VARCHAR(50)')
			,rIssuedDate2			= p.value('@rIssuedDate2', 'VARCHAR(30)')
			,rValidDate2			= p.value('@rValidDate2', 'VARCHAR(30)')
			,rRelationType			= p.value('@rRelationType', 'VARCHAR(50)')
			,rRelativeName			= p.value('@rRelativeName', 'VARCHAR(200)')
			,rGender				= p.value('@rGender', 'VARCHAR(10)')
			,rAddress2				= p.value('@rAddress2', 'VARCHAR(200)')
			,rDcInfo				= p.value('@rDcInfo', 'VARCHAR(100)')
			,rIpAddress				= p.value('@rIpAddress', 'VARCHAR(20)')
		INTO #synTran
		FROM @xml.nodes('/root/row') AS tmp(p) 
		
		--SELECT * FROM #synTran

		DELETE FROM #synTran
		FROM #synTran st
		INNER JOIN remitTran rt ON st.controlNo = rt.controlNo
	   
	   CREATE TABLE #controlNoTemp(controlNo VARCHAR(50))
	   INSERT INTO #controlNoTemp(controlNo)
	   SELECT controlNo FROM #synTran
		--RETURN
	
	   BEGIN TRANSACTION
	   
		   INSERT INTO remitTran(
					 controlNo
					,sCurrCostRate
					,sCurrHoMargin
					,sCurrAgentMargin
					,sAgentSettRate
					,pCurrCostRate
					,pCurrHoMargin
					,pCurrAgentMargin
					,pDateCostRate
					,customerRate
					,customerPremium
					,schemePremium
					,agentCrossSettRate
					,serviceCharge,handlingFee,agentFxGain
					,sAgentComm,sAgentCommCurrency,sSuperAgentComm,sSuperAgentCommCurrency
					,pAgentComm
					,pAgentCommCurrency,pSuperAgentComm,pSuperAgentCommCurrency
					,senderName,receiverName
					,sSuperAgent,sSuperAgentName
					,sAgent,sAgentName
					,sBranch,sBranchName,sCountry
					,pAgent,pAgentName
					,pBranch,pBranchName
					,pBank
					,pBankName
					,pBankBranch
					,pBankBranchName
					,externalBankCode
					,pBankType
					,accountNo
					,pCountry
					,paymentMethod
					,collCurr,tAmt,cAmt,pAmt,pAmtAct,payoutCurr
					,relWithSender,purposeOfRemit,sourceOfFund
					,tranStatus,payStatus
					,createdDate,createdDateLocal,createdBy,approvedBy,approvedDate,approvedDateLocal
					,tranType
					,pMessage,sRouteId			
				)	
				SELECT 
					 controlNo
					,sCurrCostRate
					,sCurrHoMargin
					,sCurrAgentMargin
					,sAgentSettRate
					,pCurrCostRate
					,pCurrHoMargin
					,pCurrAgentMargin
					,pDateCostRate
					,customerRate
					,customerPremium
					,schemePremium
					,agentCrossSettRate
					,serviceCharge,handlingFee,agentFxGain
					,sAgentComm = serviceCharge - ISNULL(actrn.pAgentComm, 0),sAgentCommCurrency = collCurr,sSuperAgentComm,sSuperAgentCommCurrency
					,pAgentComm = NULL
					,pAgentCommCurrency = NULL,pSuperAgentComm = ISNULL(actrn.pAgentComm, 0),pSuperAgentCommCurrency = actrn.pAgentCommCurrency
					,senderName,receiverName
					,sSuperAgent = 4641,sSuperAgentName = 'INTERNATIONAL AGENTS'
					,sAgent,sAgentName = sam.agentName
					,sBranch,sBranchName = sbm.agentName
					,sCountry
					,pAgent = eb.internalCode,pam.agentName
					,pBranch = NULL,pBranchName
					,pBank
					,pBankName
					,pBankBranch
					,pBankBranchName
					,externalBankCode
					,pBankType
					,accountNo
					,pCountry
					,paymentMethod
					,collCurr,tAmt,cAmt,pAmt = ROUND(pAmt, 0, 1),pAmtAct = pAmt,payoutCurr
					,relWithSender,purposeOfRemit,sourceOfFund
					,CASE WHEN tranStatus = 'ModificationRequest' THEN 'Payment' ELSE tranStatus END,payStatus
					,actrn.createdDate,createdDateLocal,actrn.createdBy,actrn.approvedBy,actrn.approvedDate,approvedDateLocal
					,tranType
					,pMessage,'UK'
			FROM #synTran actrn WITH(NOLOCK)
			INNER JOIN agentMaster sam WITH(NOLOCK) ON actrn.sAgent = sam.agentId
			INNER JOIN agentMaster sbm WITH(NOLOCK) ON actrn.sBranch = sbm.agentId
			LEFT JOIN externalBank eb WITH(NOLOCK) ON actrn.pBank = eb.extBankId
			LEFT JOIN agentMaster pam WITH(NOLOCK) ON eb.internalCode = pam.agentId
			
			UPDATE #synTran SET
				 tranId			= rt.id
			FROM #synTran st
			INNER JOIN remitTran rt ON st.controlNo = rt.controlNo
			
			--SELECT * FROM tranSenders WITH(NOLOCK)

			INSERT INTO tranSenders(
				 tranId
				,firstName
				,middleName
				,lastName1
				,lastName2
				,fullName
				,[address],mobile,city,country,homePhone
				,idType,idNumber
				,nativeCountry
				,dcInfo
				,ipAddress
			)
			SELECT
				 tranId
				,NULLIF(sfirstName, '')
				,NULLIF(sMiddleName, '')
				,NULLIF(sLastName1, '')
				,NULLIF(slastName2, '')
				,NULLIF(sfullName, '')
				,NULLIF(sAddress, ''),NULLIF(sMobile, ''),NULLIF(sCity, ''),NULLIF(sCountry, ''),NULLIF(sHomePhone, '')
				,NULLIF(sIdType, ''),NULLIF(sIdNumber, '')
				,NULLIF(sNativeCountry, '')
				,NULLIF(sDcInfo, '')
				,NULLIF(sIpAddress, '')
			FROM #synTran actrn
			--End-------------------------------------------------------------------------------------------------------------------------------


			--3. Receiver Information------------------------------------------------------------------------------------------------------------------
			INSERT INTO tranReceivers(
				 tranId
				,firstName
				,middleName
				,lastName1
				,lastName2
				,fullName
				,address,mobile,homePhone,city,country
				,idType,idNumber,idType2,idNumber2
			)
			SELECT
				 tranId
				,NULLIF(rFirstName, '')
				,NULLIF(rMiddleName, '')
				,NULLIF(rLastName1, '')
				,NULLIF(rLastName2, '')
				,NULLIF(rFullName, '')
				,NULLIF(rAddress, ''),NULLIF(rMobile, ''),NULLIF(rHomePhone, ''),NULLIF(rCity, ''),NULLIF(rCountry, '')
				,NULLIF(rIdType, ''),NULLIF(rIdNumber, ''),NULLIF(rIdType2, ''),NULLIF(rIdNumber2, '')
			FROM #synTran actrn
			
	    IF @@TRANCOUNT>0
		COMMIT TRANSACTION

		DECLARE @cnt VARCHAR(30) = CAST((SELECT COUNT(*) FROM #synTran) AS VARCHAR)
		SELECT 0 errorCode, @cnt + ' Row(s) Sync Successfully' Msg, NULL Id

		SELECT controlNo  FROM #synTran
		RETURN;
	END

END TRY
BEGIN CATCH

	IF @@TRANCOUNT>0
	ROLLBACK TRANSACTION

	SELECT 1 errorCode, ERROR_MESSAGE() Msg, NULL Id
	SELECT 1 errorCode, ERROR_MESSAGE() Msg, NULL Id

END CATCH

GO
