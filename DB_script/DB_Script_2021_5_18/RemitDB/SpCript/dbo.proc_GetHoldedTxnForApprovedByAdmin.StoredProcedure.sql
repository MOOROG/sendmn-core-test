USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetHoldedTxnForApprovedByAdmin]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_GetHoldedTxnForApprovedByAdmin] 
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

	SELECT @koreaSupAgent = agentId from  Vw_GetAgentID where SearchText = 'koreaAgent'


	BEGIN TRY
	IF @PartnerId= @koreaSupAgent		----- For GME Korea
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
			,dbo.Cyrillic2Latin(CM.idNumber)						sidNumber			--
			,TRT.fullName											rfullName			--
			,TRT.address											raddress			--
		--	,ISNULL(right(TRT.mobile,11),'')						rmobile			
		--	,ISNULL(substring(TRT.mobile,4,20),'')                  rmobile
			,case when len(TRT.mobile) = 14 then ISNULL(substring(TRT.mobile,4,20),'')
			when len(TRT.mobile) = 13 then '0' + cast(ISNULL(substring(TRT.mobile,4,20),'') as varchar)
			else ISNULL(substring(TRT.mobile,4,20),'') end			rmobile

			,ISNULL(TRT.city,TRT.address)							rcity				--
			,RNC.countryCode										rcountry			--
			,ISNULL(RTT.sourceOfFund,'Other')						sourceOfFund		--	
		--	,ISNULL(vwR.[Key],'11085')								relationName		--
			,ISNULL(vwR.[Value],'11085')							relationName		--
			,ISNULL(RTT.purposeOfRemit,'Family support')			purposeOfRemit		--
			,ROUND(RTT.pAmt/pCurrCostRate,2)						cAmt				-- KOrea ko lagi USD Amount ni pathauna parxa so
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
		DECLARE @TOTAL_MONTHLY MONEY

		SELECT @TOTAL_MONTHLY = SUM(PAMT)
		FROM remitTran R(NOLOCK)
		INNER JOIN tranSenders S(NOLOCK) ON S.tranId = R.ID
		INNER JOIN API_BANK_LIST B(NOLOCK) ON B.BANK_ID = R.pBank AND B.BANK_CODE2 = 'Realtime Transfer'
		WHERE S.customerId = (SELECT customerId FROM tranSenders (NOLOCK) WHERE tranId = @tranId)
		AND R.pCountry = (SELECT pCountry FROM tranSenders (NOLOCK) WHERE tranId = @tranId)
		AND R.tranStatus <> 'Cancel'
		AND R.createdDate BETWEEN DATEADD(MONTH, -1, GETDATE()) AND GETDATE()
		
	   SELECT
			 RTT.id													tranId				----
			,'tranglo'												processId						
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
			,REPLACE(CM.mobile, ' ', '')							smobile				--
			,ISNULL(CT.City_Name,'Mongolia')						scity				--
			,SNC.countryCode										sCountry			--
			,CMT.countryCode										snativeCountry 
			,CASE WHEN RTT.pCountry = 'Turkey' THEN '7'
			ELSE CASE isnull(vw.[Value],'8008')
				WHEN 11168 THEN 5
				WHEN 8008 THEN 3
				WHEN 10997 THEN 2
				WHEN 1302 THEN 1
				ELSE 2 END	
			END														sidType				--
			,dbo.Cyrillic2Latin(CM.idNumber)						sidNumber			--
			,TRT.fullName											rfullName			--
			,CASE WHEN RTT.pCountry = 'Australia' THEN '' ELSE TRT.address END	raddress			--
			,CASE WHEN RTT.pCountry = 'Australia' THEN TRT.address ELSE '' END rPostCode
			,CASE RTT.pCountry 
					WHEN 'Australia' THEN CASE WHEN LEN(REPLACE(TRT.mobile, '+', '')) >= 10 
						THEN CASE WHEN LEFT(RIGHT(TRT.mobile, 10), 1) = '0' THEN RIGHT(TRT.mobile, 10)
							WHEN LEFT(RIGHT(TRT.mobile, 10), 1) <> '0' THEN '0' + RIGHT(TRT.mobile, 9)
							END
						ELSE LEFT('045647845', 10-LEN(TRT.mobile)) + TRT.mobile 
						END
					WHEN 'China' THEN RIGHT(TRT.mobile, 11)
					ELSE RIGHT(TRT.mobile, 10)		
					END												rmobile				--
			--,'01012345678'											rmobile				--
			,ISNULL(TRT.city,TRT.address)							rcity				--
			,RNC.countryCode										rcountry			--
			,CASE ISNULL(RTT.sourceOfFund,'Others')
				WHEN 'Others' THEN 16312 
				WHEN 'Salary' THEN 11  
				WHEN 'Business' THEN 23 --savings 
				ELSE 23 END											sourceOfFund		--	
		--	,ISNULL(vwR.[Key],'11085')								relationName		--
			,CASE isnull(RTT.relWithSender,'Self')
				WHEN 'Spouse' THEN 1
				WHEN 'Children' THEN 2
				WHEN 'Parents' THEN 3
				WHEN 'Brother/ Sister' THEN 4
				WHEN 'Uncle | Auntie' THEN 5
				WHEN 'Relative' THEN 5
				WHEN 'Self' THEN 6	
				WHEN 'Friend' THEN 8
				WHEN 'Business Partner' THEN 9
				WHEN 'Client' THEN 10
				WHEN 'Employer' THEN 11
				WHEN 'Employee' THEN 11
				ELSE 8 END											relationName		--
			 ,ISNULL(RTT.purposeOfRemit,'Family support')			purposeOfRemit		-- SELECT * FROM API_BANK_LIST WHERE BANK_COUNTRY='CHINA'
			,CASE WHEN PBID.BANK_CODE1 = 'EWALIPAY' THEN
					CASE ISNULL(RTT.purposeOfRemit,'Family support')
					WHEN 'Payment' THEN 14320 --Wages and Salaries in Kind/Benefits Attributable to Employees
					WHEN 'Others' THEN 21220  --Worker's Remittances
					WHEN 'Tuition fee' THEN 13220 --Education-Related
					WHEN 'Medical Expenses' THEN 13220 --Goods and Services by Short Term Workers
					WHEN 'Family support' THEN 14310 --Wages and Salaries in Cash
				ELSE 14310 END
			
			ELSE CASE ISNULL(RTT.purposeOfRemit,'Family support')
					WHEN 'Payment' THEN 16312 --Premium Paid/Received on Other General Insurance
					WHEN 'Others' THEN 16850  --Other Personal Services
					WHEN 'Tuition fee' THEN 13500 --Education-Related
					WHEN 'Medical Expenses' THEN 13400 --health related
					WHEN 'Family support' THEN 21220 --Worker's Remittances / family maintenance
				ELSE 21220 END
			END														purposeOfRemitCode		--
			,ROUND(RTT.pAmt/pCurrCostRate,2)						cAmt					-- KOrea ko lagi USD Amount ni pathauna parxa so
			,ISNULL(RTT.pAmt,0)										pAmt				--
			,ISNULL(RTT.tAmt,0)										tAmt				--
			,paymentMethod											paymentMethod		--
			,CASE WHEN paymentMethod = 'BANK DEPOSIT' AND RTT.pCountry = 'CHINA' THEN
							CASE WHEN PBID.BANK_CODE1 = '8600067' THEN '8'
							ELSE '7' END
					WHEN paymentMethod = 'BANK DEPOSIT' AND RTT.pCountry = 'INDIA' THEN 
							CASE WHEN ISNULL(PBID.BANK_CODE2, 'N') = 'Realtime Transfer' AND RTT.pAmt <= 200000 THEN '10'
							ELSE '1' END
					WHEN paymentMethod = 'BANK DEPOSIT' AND RTT.pCountry = 'Thailand' THEN 
							CASE WHEN ISNULL(PBID.BANK_CODE2, 'N') = 'Realtime Transfer' AND ISNULL(@TOTAL_MONTHLY, 0) <= 1500000 THEN '10'
							ELSE '1' END
					WHEN paymentMethod = 'BANK DEPOSIT' AND RTT.pCountry = 'Singapore' THEN 
							CASE WHEN ISNULL(PBID.BANK_CODE2, 'N') = 'Realtime Transfer' AND ISNULL(RTT.pAmt, 0) <= 200000.00  THEN '10'
							ELSE '1' END
					WHEN paymentMethod = 'CASH PAYMENT' THEN '5'
					WHEN paymentMethod = 'BANK DEPOSIT' AND RTT.pCountry NOT IN ('CHINA', 'INDIA', 'Thailand') THEN '1'
					WHEN paymentMethod = 'HOME DELIVERY' THEN '9'
					WHEN paymentMethod = 'MOBILE WALLET' THEN '2'
			END
																	paymentTypeId		--
			,RTT.pBankName											pBankName			--
			,ISNULL(PBID.BANK_CODE1,0)								pBank				--
			,PBBID.BRANCH_CODE1										pBankLocation		--
			--,ISNULL(PBBID.BRANCH_CODE1,'')							pBankLocation		--
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
			,CASE ISNULL(TRT.idType,'0')
				WHEN 11168 THEN 5
				WHEN 8008 THEN 3
				WHEN 10997 THEN 2
				WHEN 1302 THEN 1
				WHEN 0 THEN NULL
				ELSE 2 END											ridType		
			,trt.idNumber											ridNumber
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
			,PAY.countryCode										RCountryCode
			,TRT.city												rRegencyCode
			,rpc.partnerLocationId									rProvienceCode
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
		LEFT JOIN dbo.countryMaster PAY (NOLOCK) ON PAY.countryName=ISNULL(RTT.pCountry,'NEPAL') 
		LEFT JOIN tblServicewiseLocation rpc (NOLOCK) ON rpc.location=trt.STATE
		WHERE RTT.id = @tranId

		
	END

	END TRY
	BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id
END CATCH
END
GO
