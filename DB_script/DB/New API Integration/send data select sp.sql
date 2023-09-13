
alter PROCEDURE [dbo].[proc_GetHoldedTxnForApprovedByAdmin] 
(
	-- Add the parameters for the stored procedure here
	@user			VARCHAR(50),
	@tranId			VARCHAR(100),
	@callFro		VARCHAR(30)
)
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @PartnerId VARCHAR(100),
			@tranStatus VARCHAR(100),
			@koreaSupAgent VARCHAR(20)

	SELECT @PartnerId=pSuperAgent,@tranStatus=tranStatus FROM dbo.remitTranTemp WHERE id=@tranId
	
	BEGIN TRY
	IF @PartnerId= (SELECT agentId from  Vw_GetAgentID where SearchText = 'koreaAgent')		----- For GME Korea
	BEGIN

	   SELECT
			 RTT.id													tranId				----
			,'gmeKorea'												processId						
			,RTT.createdDate										txnDate
			,AU.userName											userName			--											notes -- Filds are use for jme nepal send model
			,ISNULL(AM.parentId,0)									partnerId			---- use for to get thirdparty api partner services 
			,ISNULL(CM.customerId,0)								customerId
			,isFirstTran											'Y'					---- 
			,ISNULL(CM.firstName,'')								sfirstName
			,ISNULL(CM.middleName,'')								smiddleName
			,ISNULL(CM.lastName1,'')								slastName1
			,ISNULL(CM.lastName2,'')								slastName2
			,CM.fullName											sfullName			--
			,ISNULL(CM.ADDITIONALADDRESS,CM.address)				saddress			--
			,CM.mobile												smobile				--
			,ISNULL(CT.City_Name,'Mongolia')						scity				--
			,SNC.countryCode										sCountry			--
			,CMT.countryCode										snativeCountry 
			,isnull(vw.[Value],'8008')								sidType				--
			,CM.idNumber											sidNumber			--
			,TRT.fullName											rfullName			--
			,TRT.address											raddress			--
			--,ISNULL(right(TRT.mobile,11),'')											rmobile				--
			,'01012345678'											rmobile				--
			,ISNULL(TRT.city,TRT.address)							rcity				--
			,RNC.countryCode										rcountry			--
			,ISNULL(RTT.sourceOfFund,'Other')						sourceOfFund		--	
		--	,ISNULL(vwR.[Key],'11085')								relationName		--
			,ISNULL(vwR.[Value],'11085')							relationName		--
			,ISNULL(RTT.purposeOfRemit,'Family support')			purposeOfRemit		--
			,ROUND(RTT.pAmt/pCurrCostRate,2) cAmt				-- KOrea ko lagi USD Amount ni pathauna parxa so
			,ISNULL(RTT.pAmt,0)										pAmt				--
			,ISNULL(RTT.tAmt,0)										tAmt				--
			,case when paymentMethod = 'bank deposit'
			 then 'BD' else 'CP' END								paymentMethod		--
			,RTT.pBankName											pBankName			--
			,ISNULL(PBID.BANK_CODE1,0)								pBank				--
			,ISNULL(PBBID.BRANCH_CODE1,'0')							pBankLocation		--
			,ISNULL(PBBID.BRANCH_NAME,'')							pBankBranchName		--
			,RTT.accountNo											raccountNo			--

			,CM.idIssueDate											sissuedDate			--
			,CM.idExpiryDate										svalidDate			--
			,CM.dob													sdob				--
			,''														semail
			,''														szipCode
			,CMT.countryCode										snativeCountry		--
			,0														occupationId		
			,ISNULL(OCU.detailTitle,0)								occupationName		--
			--------- receiver details
			,''														receiverId				
			,TRT.firstName											rfirstName
			,TRT.middleName											rmiddleName
			,TRT.lastName1											rlastName1
			,''														ridType
			,''														ridNumber
			,''														rvalidDate
			,''														rdob
			,''														rhomePhone
			--,RE.countryCode
			,RNC.countryCode										rnativeCountry
			,''														remail
			,''														branchId	
			,''														branchName
			,''														city
			,0														pAgent
			,''														pAgentName
			,''														pBankType
			,RTT.payoutCurr
			,RTT.collCurr
			,0														serviceCharge		--
			,''														pAgentComm
			,''														relationId
			,''														remarks
			,0														sAgent
			,''														sAgentName
			,0														sSuperAgent
			,''														ipAddress
			,0														countryId
			,''														rstate
			,0														sBranch
			,''														pLocation
			,dbo.decryptDb(RTT.controlNo)							controlNo			--
			,pCurrCostRate											exRate
			,''														rcityCode
			,CM.sessionId											sessionId			----
			,'true'													IsRealtime			----
			,RTT.accountNo															bankAccountNo
			,'Y'													IsRealtime
			,RTT.sessionId											FOREX_SESSION_ID	
		FROM remitTranTemp RTT WITH(NOLOCK)
		INNER JOIN dbo.tranSendersTemp TST(NOLOCK) ON TST.TRANID = RTT.ID
		INNER JOIN customerMaster CM(NOLOCK) ON CM.customerId = TST.customerId
		LEFT JOIN API_CITY_LIST CT (NOLOCK) ON Cm.city = CT.CITY_ID
		LEFT JOIN dbo.VW_GetEnumValue vw(NOLOCK) ON cm.idType = vw.searchText
		INNER JOIN dbo.tranReceiversTemp TRT(NOLOCK) ON TRT.TRANID = RTT.ID
		LEFT JOIN dbo.VW_GetEnumValue vwR(NOLOCK) ON (vwR.searchText = TRT.relationType OR CAST( vwR.searchValue AS VARCHAR)= TRT.relationType)
		LEFT JOIN applicationUsers AU(NOLOCK) ON AU.USERNAME = RTT.CREATEDBY
		LEFT JOIN dbo.countryMaster CMT (NOLOCK) ON CMT.countryId=CM.country
		INNER JOIN dbo.agentMaster AM(NOLOCK) ON AM.agentId=RTT.pAgent
		LEFT JOIN API_BANK_LIST PBID (NOLOCK) ON PBID.BANK_ID=RTT.pBank
		LEFT JOIN dbo.API_BANK_BRANCH_LIST PBBID (NOLOCK) ON PBBID.BRANCH_ID=RTT.pBankBranch
		LEFT JOIN dbo.staticDataValue OCU (NOLOCK) ON OCU.detailTitle=TRT.occupation OR CAST(OCU.valueId AS VARCHAR)=TRT.occupation
		--LEFT JOIN dbo.staticDataValue purpose (NOLOCK) ON purpose.detailTitle=RTT.purposeOfRemit OR CAST(purpose.valueId AS VARCHAR)=RTT.purposeOfRemit
		LEFT JOIN dbo.staticDataValue REL (NOLOCK) ON REL.valueId=CM.relationId
		LEFT JOIN dbo.countryMaster RNC (NOLOCK) ON RNC.countryName=ISNULL(TRT.country,'NEPAL') 
		LEFT JOIN dbo.countryMaster SNC (NOLOCK) ON SNC.countryName=ISNULL(RTT.Scountry,'NEPAL') 
		WHERE RTT.id = @tranId

		
	END

	IF @PartnerId= (SELECT agentId from  Vw_GetAgentID where SearchText = 'trangloAgent')		----- For tranglo
	BEGIN

	   SELECT
			 RTT.id													tranId				----
			,'gmeKorea'												processId						
			,RTT.createdDate										txnDate
			,AU.userName											userName			--											notes -- Filds are use for jme nepal send model
			,ISNULL(AM.parentId,0)									partnerId			---- use for to get thirdparty api partner services 
			,ISNULL(CM.customerId,0)								customerId
			,isFirstTran											'Y'					---- 
			,ISNULL(CM.firstName,'')								sfirstName
			,ISNULL(CM.middleName,'')								smiddleName
			,ISNULL(CM.lastName1,'')								slastName1
			,ISNULL(CM.lastName2,'')								slastName2
			,CM.fullName											sfullName			--
			,ISNULL(CM.ADDITIONALADDRESS,CM.address)				saddress			--
			,CM.mobile												smobile				--
			,ISNULL(CT.City_Name,'Mongolia')						scity				--
			,SNC.countryCode										sCountry			--
			,CMT.countryCode										snativeCountry 
			,CASE isnull(vw.[Value],'8008')
				WHEN 11168 THEN 5
				WHEN 8008 THEN 3
				WHEN 10997 THEN 2
				WHEN 1302 THEN 1
				ELSE 2 END											sidType				--
			,CM.idNumber											sidNumber			--
			,TRT.fullName											rfullName			--
			,TRT.address											raddress			--
			--,ISNULL(right(TRT.mobile,11),'')											rmobile				--
			,'01012345678'											rmobile				--
			,ISNULL(TRT.city,TRT.address)							rcity				--
			,RNC.countryCode										rcountry			--
			,CASE ISNULL(RTT.sourceOfFund,'Others')
				WHEN 'Others' THEN 16312 
				WHEN 'Salary' THEN 11  
				WHEN 'Business' THEN 23 --savings 
				ELSE 23 END										sourceOfFund		--	
		--	,ISNULL(vwR.[Key],'11085')								relationName		--
			,ISNULL(vwR.[Value],'11085')							relationName		--
			,ISNULL(RTT.purposeOfRemit,'Family support')			purposeOfRemit		--
			,CASE ISNULL(RTT.purposeOfRemit,'Family support')
				WHEN 'Payment' THEN 16312 --Premium Paid/Received on Other General Insurance
				WHEN 'Others' THEN 16850  --Other Personal Services
				WHEN 'Tuition fee' THEN 13500 --Education-Related
				WHEN 'Medical Expenses' THEN 13400 --health related
				WHEN 'Family support' THEN 21220 --Worker's Remittances / family maintenance
				ELSE 21220 END											purposeOfRemitCode		--
			,ROUND(RTT.pAmt/pCurrCostRate,2) cAmt				-- KOrea ko lagi USD Amount ni pathauna parxa so
			,ISNULL(RTT.pAmt,0)										pAmt				--
			,ISNULL(RTT.tAmt,0)										tAmt				--
			,paymentMethod								paymentMethod		--
			,RTT.pBankName											pBankName			--
			,ISNULL(PBID.BANK_CODE1,0)								pBank				--
			,ISNULL(PBBID.BRANCH_CODE1,'')							pBankLocation		--
			,ISNULL(PBBID.BRANCH_NAME,'')							pBankBranchName		--
			,RTT.accountNo											raccountNo			--

			,CM.idIssueDate											sissuedDate			--
			,CM.idExpiryDate										svalidDate			--
			,CM.dob													sdob				--
			,''														semail
			,''														szipCode
			,CMT.countryCode										snativeCountry		--
			,0														occupationId		
			,ISNULL(OCU.detailTitle,0)								occupationName		--
			--------- receiver details
			,''														receiverId				
			,TRT.firstName											rfirstName
			,TRT.middleName											rmiddleName
			,TRT.lastName1											rlastName1
			,''														ridType
			,''														ridNumber
			,''														rvalidDate
			,''														rdob
			,''														rhomePhone
			--,RE.countryCode
			,RNC.countryCode										rnativeCountry
			,''														remail
			,''														branchId	
			,''														branchName
			,''														city
			,0														pAgent
			,''														pAgentName
			,''														pBankType
			,RTT.payoutCurr
			,RTT.collCurr
			,0														serviceCharge		--
			,''														pAgentComm
			,''														relationId
			,''														remarks
			,0														sAgent
			,''														sAgentName
			,0														sSuperAgent
			,''														ipAddress
			,0														countryId
			,''														rstate
			,0														sBranch
			,''														pLocation
			,dbo.decryptDb(RTT.controlNo)							controlNo			--
			,pCurrCostRate											exRate
			,''														rcityCode
			,CM.sessionId											sessionId			----
			,'true'													IsRealtime			----
			,RTT.accountNo															bankAccountNo
			,'Y'													IsRealtime
			,RTT.sessionId											FOREX_SESSION_ID
			,SNC.countryCode										sCountryCode
			,PAY.countryCode										RCountryCode
		FROM remitTranTemp RTT WITH(NOLOCK)
		INNER JOIN dbo.tranSendersTemp TST(NOLOCK) ON TST.TRANID = RTT.ID
		INNER JOIN customerMaster CM(NOLOCK) ON CM.customerId = TST.customerId
		LEFT JOIN API_CITY_LIST CT (NOLOCK) ON Cm.city = CT.CITY_ID
		LEFT JOIN dbo.VW_GetEnumValue vw(NOLOCK) ON cm.idType = vw.searchText
		INNER JOIN dbo.tranReceiversTemp TRT(NOLOCK) ON TRT.TRANID = RTT.ID
		LEFT JOIN dbo.VW_GetEnumValue vwR(NOLOCK) ON (vwR.searchText = TRT.relationType OR CAST( vwR.searchValue AS VARCHAR)= TRT.relationType)
		LEFT JOIN applicationUsers AU(NOLOCK) ON AU.USERNAME = RTT.CREATEDBY
		LEFT JOIN dbo.countryMaster CMT (NOLOCK) ON CMT.countryId=CM.country
		INNER JOIN dbo.agentMaster AM(NOLOCK) ON AM.agentId=RTT.pAgent
		LEFT JOIN API_BANK_LIST PBID (NOLOCK) ON PBID.BANK_ID=RTT.pBank
		LEFT JOIN dbo.API_BANK_BRANCH_LIST PBBID (NOLOCK) ON PBBID.BRANCH_ID=RTT.pBankBranch
		LEFT JOIN dbo.staticDataValue OCU (NOLOCK) ON OCU.detailTitle=TRT.occupation OR CAST(OCU.valueId AS VARCHAR)=TRT.occupation
		--LEFT JOIN dbo.staticDataValue purpose (NOLOCK) ON purpose.detailTitle=RTT.purposeOfRemit OR CAST(purpose.valueId AS VARCHAR)=RTT.purposeOfRemit
		LEFT JOIN dbo.staticDataValue REL (NOLOCK) ON REL.valueId=CM.relationId
		LEFT JOIN dbo.countryMaster RNC (NOLOCK) ON RNC.countryName=ISNULL(TRT.country,'NEPAL') 
		LEFT JOIN dbo.countryMaster SNC (NOLOCK) ON SNC.countryName=ISNULL(RTT.Scountry,'NEPAL') 
		LEFT JOIN dbo.countryMaster PAY (NOLOCK) ON SNC.countryName=ISNULL(RTT.pCountry,'NEPAL') 
		WHERE RTT.id = @tranId

		
	END

	END TRY
	BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id
END CATCH
END












