USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_GetHoldedTxnForApprovedByAdmin]    Script Date: 8/23/2020 5:48:06 PM ******/
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
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @PartnerId VARCHAR(100),
			@tranStatus VARCHAR(100)

	SELECT @PartnerId=pSuperAgent,@tranStatus=tranStatus FROM dbo.remitTranTemp WHERE id=@tranId
	
	--IF @tranStatus <> 'Hold'
	--BEGIN
	--	SELECT 'NotForTPAPI' ErrorCode,  @tranStatus msg,@tranId id
	--	RETURN
	--END


	BEGIN TRY
	IF @PartnerId='394132'		--- for donga
	BEGIN
		SELECT RT.id							tranId
				,RT.createdDate				txnDate
				,'donga'					processId
				,RT.CREATEDBY				userName
				,RT.PSUPERAGENT				partnerId
				,S.CUSTOMERID				customerId
				,isFirstTran					'Y'
				,CM.firstName					sfirstName
				,CM.middleName					smiddleName
				,CM.lastName1					slastName1
				,CM.lastName2					slastName2
				,CM.fullName					sfullName
				,CM.idIssueDate					sissuedDate
				,CM.idExpiryDate				svalidDate
				,CM.dob							sdob
				,CM.email						semail
				,CM.city						scity
				,CM.zipCode						szipCode
				,CM.nativeCountry				snativeCountry
				,CM.idType						sidType
				,CM.idNumber					sidNumber
				,CM.mobile						smobile
				,''								saddress
				,0								occupationId
				,''								occupationName
				,R.CUSTOMERID					receiverId				
				,R.fullName						rfullName
				,R.firstName					rfirstName
				,R.middleName					rmiddleName
				,R.lastName1					rlastName1
				,R.idType						ridType
				,R.idNumber						ridNumber
				,R.validDate					rvalidDate
				,R.dob							rdob
				,R.homePhone					rhomePhone
				,R.mobile						rmobile
				,''								rnativeCountry
				,ISNULL(R.city,R.address)		rcity
				,R.address						raddress
				,R.email						remail
				,R.accountNo					raccountNo
				,R.country						rcountry
				,''								branchId
				,''								branchName
				,''								city
				,ISNULL(RT.pAgent,0)				pAgent
				,RT.pAgentName					pAgentName
				,RT.pBankType					pBankType
				,ISNULL(abl.BANK_CODE1,0)		pBank
				,ISNULL(abl.BANK_CODE2,0)		pBankLocation
				,RT.pBankName					pBankName
				,RT.payoutCurr					payoutCurr
				,RT.collCurr						collCurr
				,ISNULL(RT.cAmt,0)				cAmt
				,ISNULL(RT.pAmt,0)				pAmt
				,ISNULL(RT.tAmt,0)				tAmt
				,0								serviceCharge
				,ISNULL(RT.pAgentComm,0)		pAgentComm
				,RT.purposeOfRemit				purposeOfRemit
				,RT.sourceOfFund				sourceOfFund
				,ISNULL(CM.relationId,0)		relationId
				,''								relationName
				,CM.remarks						remarks
				,ISNULL(RT.sAgent,0)			sAgent
				,RT.sAgentName					sAgentName
				,ISNULL(RT.sSuperAgent,0)		sSuperAgent
				,CM.ipAddress					ipAddress
				,CCM.COUNTRYID					countryId		--SENDING COUNTRY
				,RT.sCountry					sCountry
				,ASL.STATE_CODE					rstate
				,ISNULL(RT.sBranch,0)			sBranch
				,''								pLocation
				,RT.paymentMethod				paymentMethod
				,dbo.decryptDb(RT.controlNo)	controlNo
				,ACL.CITY_CODE					rcityCode
				,CM.sessionId					sessionId
				,'true'							IsRealtime
				,''								bankAccountNo
				,'Y'							IsRealtime
		FROM REMITTRANTEMP RT(NOLOCK)
		INNER JOIN TRANSENDERSTEMP S(NOLOCK) ON S.TRANID = RT.ID
		INNER JOIN TRANRECEIVERSTEMP R(NOLOCK) ON R.TRANID = RT.ID
		INNER JOIN CUSTOMERMASTER CM(NOLOCK) ON CM.CUSTOMERID = S.CUSTOMERID
		LEFT JOIN API_BANK_LIST ABL(NOLOCK) ON RT.pBank = ABL.BANK_ID
		INNER JOIN COUNTRYMASTER CCM(NOLOCK) ON CCM.COUNTRYNAME = RT.SCOUNTRY
		LEFT JOIN dbo.API_STATE_LIST ASL (NOLOCK) ON asl.STATE_ID = RT.pState
		LEFT JOIN dbo.API_CITY_LIST acl (NOLOCK) ON acl.CITY_ID = RT.pDistrict
		WHERE RT.ID = @tranId
	END
	IF @PartnerId='394130'		--- for transfast
	BEGIN
		DECLARE @STATECODE VARCHAR(30), @CUSTOMERID BIGINT, @CITYCODE VARCHAR(30), @ISUPDATE CHAR(1) = 'N'

		SELECT @CUSTOMERID = CUSTOMERID 
		FROM TRANSENDERSTEMP (NOLOCK)
		WHERE TRANID = @tranId

		select top 1 @STATECODE = SSC.STATE_CODE 
		from customerMaster CM(NOLOCK)
		LEFT JOIN dbo.API_CITY_LIST SCC (NOLOCK) ON SCC.CITY_NAME=CM.city
		LEFT JOIN dbo.API_STATE_LIST SSC (NOLOCK) ON SSC.STATE_ID=SCC.STATE_ID
		where 1=1
		and cm.CUSTOMERID=@CUSTOMERID

		IF @STATECODE IN ('JP037') OR @STATECODE IS NULL
			SELECT @STATECODE = 'JP036', @CITYCODE = '113071', @ISUPDATE = 'Y'

	   SELECT top 1
			 RTT.id															tranId
			,'transfast'													processId
			,RTT.createdDate												txnDate
			,AU.userName													userName
			,ISNULL(am.parentId,0)											partnerId
			,ISNULL(cm.customerId,0)										customerId
			,isFirstTran													'Y'
			,''																sfirstName
			,''																smiddleName
			,''																slastName1
			,''																slastName2
			,LEFT(CM.fullName, 40)											sfullName
			,CM.idIssueDate													sissuedDate
			,CM.idExpiryDate												svalidDate
			,CM.dob															sdob
			,TST.email														semail
			,CASE WHEN @ISUPDATE = 'Y' THEN @CITYCODE 
					ELSE SCC.CITY_CODE END									scity
			,CASE WHEN @ISUPDATE = 'Y' THEN @STATECODE
					ELSE SSC.STATE_CODE END									sstate
			--,SSC.STATE_CODE													sstate
			,CM.zipCode														szipCode
			,SNCC.countryCode												snativeCountry 
			,CASE CM.idType
				  WHEN 'Business Registation' THEN 'BZ'
				  WHEN 'DRIVERS LICENSE' THEN 'DL'
				  WHEN 'National ID' THEN 'G2'
				  WHEN 'PASSPORT' THEN 'PA'
				  WHEN 'Tohon' THEN 'BZ'
				  ELSE 'PA'
				  END														sidType					 --- map idtype name and code with transfast sender idtype value
			,CM.idNumber													sidNumber
			,REPLACE(CM.mobile,'+','')										smobile
			,CASE 
				WHEN CM.customerType='4700' 
				THEN 1 
				ELSE 0 END													IsIndividual
			,ISNULL(CM.address,CM.city)										saddress
			,ISNULL(cm.occupation,0)										occupationId
			,ISNULL(OCU.detailTitle,0)										occupationName
			,'JP'															sCountry
			--------- receiver details
			,ISNULL(TRT.id,0)												receiverId				
			,TRT.firstName													rfirstName
			,TRT.middleName													rmiddleName
			,TRT.lastName1													rlastName1
			,TRT.firstName
						+ISNULL(' ' +TRT.middleName,'')
						+ISNULL(' '+TRT.lastName1,'')	
						+ISNULL(' '+TRT.lastName2,'')	
																			rfullName
			,--CASE RCON.countryCode 
			--	WHEN 'LK' THEN --------- for sri lanka
			--		CASE TRT.idType
			--		  WHEN 'Driver License' THEN '188'
			--		  WHEN 'Business Registation' THEN '189'
			--		  WHEN 'National ID' THEN '195'
			--		  WHEN 'Passport' THEN '197'
			--		  ELSE '195'
			--		  END

			--	WHEN 'ID' THEN		-- indonesia
			--		CASE TRT.idType
			--		  WHEN 'Driver License' THEN '286'
			--		  WHEN 'Passport' THEN '287'
			--		  WHEN 'National ID' THEN '288'
			--		  ELSE '287'
			--		  END

			--	WHEN 'PH' THEN		-- PHILIPPINES
			--		CASE TRT.idType
			--		  WHEN 'Tohon' THEN '307'
			--		  WHEN 'Driver License' THEN '310'
			--		  WHEN 'Passport' THEN '316'
			--		  WHEN 'Alien Registration Card' THEN '326'
			--		  ELSE '316'
			--		  END

			--	WHEN 'PK' THEN --- pakistan
			--		CASE TRT.idType
			--		  WHEN 'Passport' THEN '270'
			--		  WHEN 'Business Registation' THEN '272'
			--		  WHEN 'Driver License' THEN '269'
			--		  WHEN 'National ID' THEN '271'
			--		  ELSE '270'
			--		  END

			--	WHEN 'BD' THEN		--- bangladesh
			--		CASE TRT.idType
			--		  WHEN 'Passport' THEN '12'
			--		  WHEN 'National ID' THEN '13'
			--		  WHEN 'Driver License' THEN '14'
			--		  WHEN 'Business Registation' THEN '16'
			--		  ELSE '430'
			--		  END

			--	WHEN 'IN' THEN			--- india
			--		CASE TRT.idType
			--			  WHEN 'Passport' THEN '136'
			--			  WHEN 'Business Registation' THEN '137'
			--			  WHEN 'Alien Registration Card' THEN '140'
			--			  WHEN 'Driver License' THEN '142'
			--			  WHEN 'National ID' THEN '329'
			--			  ELSE '136'
			--			  END
			--	END
			''																ridType					 --- map with transfast receiver idtype id code
			,TRT.idNumber													ridNumber
			,TRT.validDate													rvalidDate
			,TRT.dob														rdob
			,TRT.homePhone													rhomePhone
			,TRT.mobile														rmobile
			,RNC.countryCode												rnativeCountry
			,ISNULL(TRT.city,TRT.address)									rcity
			,TRT.address													raddress
			,TRT.email														remail
			,raccountNo = CASE WHEN RTT.paymentMethod = 'Bank Deposit' THEN RTT.accountNo ELSE '' END
			,RCON.countryCode												rcountry
			--,PBD.PAYER_BRANCH_CODE										branchId
			,CASE RTT.paymentMethod 
					WHEN 'Bank Deposit' THEN PBD.PAYER_BRANCH_CODE
					WHEN 'Cash Payment' THEN ''  END						branchId				 -------- Need To Map With Transfast PayingBranchId
			,CASE RTT.paymentMethod 
					WHEN 'Bank Deposit' THEN PBD.PAYER_CODE
					WHEN 'Cash Payment' THEN ABL.BANK_CODE1	 END			payerId					 -------- Need To Map With Transfast PayerId
			,TRT.branchName													branchName
			,AU.city														city
			,ISNULL(RTT.pAgent,0)											pAgent
			,RTT.pAgentName													pAgentName						 
			,RTT.pBankType													pBankType						 
			,CASE RTT.paymentMethod 
					WHEN 'Bank Deposit' THEN ISNULL(ABL.BANK_CODE1,'')
					ELSE  '' END											pBank					 
			,ISNULL(abl.BANK_CODE2,0)										pBankLocation
			,CASE RTT.paymentMethod 
					WHEN 'Bank Deposit' THEN ISNULL(ABBL.BRANCH_CODE1,'')
					ELSE '' END												pBankBranchId			 
			,RTT.pBankName													pBankName						 
			,RTT.payoutCurr													payoutCurr						 
			,RTT.collCurr													collCurr						 
			,ISNULL(RTT.cAmt,0)												cAmt					 
			,ISNULL(RTT.pAmt,0)												pAmt					 
			,ISNULL(RTT.tAmt,0)												tAmt					 
			,serviceCharge													serviceCharge												 
			,ISNULL(RTT.pAgentComm,0)										pAgentComm				 
			,CASE RCON.countryCode 
				WHEN 'LK' THEN
				CASE RTT.purposeOfRemit
						WHEN 'Family maintenance' THEN '1'
						WHEN 'Educational expenses' THEN	'2'
						WHEN 'Medical Expenses' THEN '3'
						WHEN 'Business travel' THEN '7'
						WHEN 'Trading' THEN '14'
						WHEN 'Savings' THEN '18'
						WHEN 'Purchase of land / property' THEN	'23'
						WHEN 'Utility payment' THEN '24'
						WHEN 'Rent' THEN	'25'
						WHEN 'Personal travels and tours' THEN	'26'
						WHEN 'Trading' THEN '27'
						WHEN 'Salary / Commission' THEN '29'
						WHEN 'Loan payment / Interest' THEN '30'
						ELSE '1'
						END

				WHEN 'ID' THEN
				CASE RTT.purposeOfRemit
						WHEN 'Family maintenance' THEN '1'
						WHEN 'Educational expenses' THEN	'2'
						WHEN 'Medical Expenses' THEN '3'
						WHEN 'Purchase of land / property' THEN	'9'
						WHEN 'Trading' THEN '14'
						WHEN 'Savings' THEN '18'
						WHEN 'Utility payment' THEN '24'
						WHEN 'Personal travels and tours' THEN	'26'
						WHEN 'Loan payment / Interest' THEN '30'
						ELSE '1'
						END

				WHEN 'PH' THEN
				CASE RTT.purposeOfRemit
						WHEN 'Family maintenance' THEN '1'
						WHEN 'Educational expenses' THEN	'2'
						WHEN 'Medical Expenses' THEN '3'
						WHEN 'Business travel' THEN '7'
						WHEN 'Trading' THEN '14'
						WHEN 'Savings' THEN '18'
						WHEN 'Purchase of land / property' THEN	'23'
						WHEN 'Utility payment' THEN '24'
						WHEN 'Personal travels and tours' THEN	'26'
						WHEN 'Trading' THEN '27'
						WHEN 'Salary / Commission' THEN '29'
						WHEN 'Loan payment / Interest' THEN '30'
						ELSE '1'
						END

				WHEN 'PK' THEN
				 	CASE RTT.purposeOfRemit
						WHEN 'Family maintenance' THEN '1'
						WHEN 'Educational expenses' THEN	'2'
						WHEN 'Medical Expenses' THEN '3'
						WHEN 'Trading' THEN '14'
						WHEN 'Savings' THEN '18'
						WHEN 'Purchase of land / property' THEN	'23'
						WHEN 'Utility payment' THEN '24'
						WHEN 'Personal travels and tours' THEN	'26'
						WHEN 'Loan payment / Interest' THEN '30'
						ELSE '1'
						END
				WHEN 'BD' THEN
				CASE RTT.purposeOfRemit
						WHEN 'Family maintenance' THEN '1'
						WHEN 'Educational expenses' THEN	'2'
						WHEN 'Medical Expenses' THEN '3'
						WHEN 'Purchase of land / property' THEN	'9'
						WHEN 'Trading' THEN '14'
						WHEN 'Savings' THEN '18'
						WHEN 'Utility payment' THEN '24'
						WHEN 'Personal travels and tours' THEN	'26'
						WHEN 'Loan payment / Interest' THEN '30'
						ELSE '1'
						END

				WHEN 'IN' THEN
				CASE RTT.purposeOfRemit
						WHEN 'Family maintenance' THEN '1'
						WHEN 'Savings' THEN '18'
						WHEN 'Purchase of land / property' THEN	'23'
						WHEN 'Educational expenses' THEN	'24'
						WHEN 'Rent' THEN	'25'
						WHEN 'Personal travels and tours' THEN	'26'
						WHEN 'Trading' THEN '27'
						WHEN 'Utility payment' THEN '28'
						WHEN 'Salary / Commission' THEN '29'
						WHEN 'Loan payment / Interest' THEN '30'
						WHEN 'Medical Expenses' THEN '32'
						ELSE '1'
						END
				END															purposeOfRemit			 ----------- Map With Transfast code
			,CASE RTT.sourceOfFund
					WHEN 'Own business' THEN '1' 
					WHEN 'Business' THEN '2' 
					WHEN 'Salary / Wages' THEN '3' 
					WHEN 'Return from Investment' THEN '4' 
					WHEN 'Loan from bank' THEN '5' 
					WHEN 'Lottery' THEN '6' 
					WHEN 'Part time job' THEN '7' 
					WHEN 'Pension' THEN '8' 
					WHEN 'Savings or accumulated' THEN '10' 
					ELSE '9'
			 END															sourceOfFund
			,rel.detailTitle												relationName
			,cm.remarks														remarks
			,ISNULL(RTT.sAgent,0)											sAgent
			,RTT.sAgentName													sAgentName
			,ISNULL(RTT.sSuperAgent,0)										sSuperAgent
			,cm.ipAddress													ipAddress
			,AU.countryId													countryId
			,RSC.STATE_CODE													rstate					 ----- Receiver State Code
			,ISNULL(RTT.sBranch,0)											sBranch					 
			,RTT.pLocation													pLocation				 
			,CASE RTT.paymentMethod 
					WHEN 'Bank Deposit' THEN 'C' 
					WHEN 'Cash Payment' THEN '2'
			END																paymentMethod			 -------- map with transfast payoutmethod id
																						 
			,dbo.decryptDb(RTT.controlNo)									controlNo				 
			,RCC.CITY_CODE													rcityCode				 ----- Receiver City Code
			,RTC.TOWN_CODE													rTownCode				 ----- Receiver Town Code
			,cm.sessionId													sessionId
			,'true'															IsRealtime
			,bankAccountNo = CASE WHEN RTT.paymentMethod = 'Bank Deposit' THEN RTT.accountNo ELSE '' END
			,'CA'															formOfPaymentId
			,CM.SSNNO														ssnno
			,RTT.customerrate												Rate
			,'N'															IsRealtime
		FROM remitTrantemp RTT WITH(NOLOCK)
		INNER JOIN dbo.tranSendersTemp TST(NOLOCK) ON TST.TRANID = RTT.ID
		INNER JOIN customerMaster CM(NOLOCK) ON CM.customerId = TST.customerId
		INNER JOIN dbo.tranReceiversTemp TRT(NOLOCK) ON TRT.TRANID = RTT.id
		LEFT JOIN applicationUsers AU(NOLOCK) ON AU.USERNAME = RTT.CREATEDBY
		LEFT JOIN dbo.agentMaster AM(NOLOCK) ON AM.agentId=RTT.pAgent
		LEFT JOIN API_BANK_LIST ABL (NOLOCK) ON ABL.BANK_ID=RTT.pBank
		LEFT JOIN dbo.API_BANK_BRANCH_LIST ABBL (NOLOCK) ON ABBL.BRANCH_ID=RTT.pBankBranch -- OR ABBL.BRANCH_NAME=RTT.pBankBranchName
		LEFT JOIN dbo.staticDataValue OCU (NOLOCK) ON OCU.valueId=cm.occupation
		LEFT JOIN dbo.staticDataValue REL (NOLOCK) ON REL.detailTitle=RTT.relWithSender
		--LEFT JOIN dbo.staticDataValue IDT (NOLOCK) ON IDT.valueId=TRT.idType
		LEFT JOIN dbo.countryStateMaster CSM(NOLOCK) ON CSM.stateId=cm.state
		LEFT JOIN dbo.API_CITY_LIST SCC (NOLOCK) ON SCC.CITY_NAME=CM.city
		LEFT JOIN dbo.API_STATE_LIST SSC (NOLOCK) ON SSC.STATE_ID=SCC.STATE_ID
		LEFT JOIN dbo.API_STATE_LIST RSC (NOLOCK) ON RSC.STATE_NAME=TRT.STATE
		LEFT JOIN dbo.API_CITY_LIST RCC (NOLOCK) ON  SCC.CITY_NAME=TRT.city
		LEFT JOIN dbo.API_TOWN_LIST RTC (NOLOCK) ON RTC.TOWN_ID=RTT.pLocation
		LEFT JOIN dbo.countryMaster SNCC (NOLOCK) ON SNCC.countryId=CM.country
		LEFT JOIN dbo.countryMaster RCON (NOLOCK) ON RCON.countryName=TRT.country
		LEFT JOIN dbo.countryMaster RNC (NOLOCK) ON RNC.countryName=TRT.NativeCountry OR RNC.countryId = TRT.NativeCountry
		LEFT JOIN dbo.PAYER_BANK_DETAILS PBD(NOLOCK) ON PBD.PAYER_ID = RTT.PayerId
		--LEFT JOIN dbo.API_PAYOUT_LOACTION APL(NOLOCK) ON APL.Id=RTT.PayerId
		--LEFT JOIN dbo.API_PAYOUT_BRANCH_LOACTION APBL (NOLOCK) ON APBL.Id=RTT.PayerBranchId
		WHERE RTT.id =@tranId
	END
	IF @PartnerId= '393880'		----- For JME NEPAL
	BEGIN
	    SELECT
			 RTT.id								tranId				----
			 ,'jmenepal'						processId			
			,RTT.createdDate					txnDate
			,AU.userName						userName			--											notes -- Filds are use for jme nepal send model
			,ISNULL(AM.parentId,0)				partnerId			---- use for to get thirdparty api partner services 
			,ISNULL(CM.customerId,0)			customerId
			,isFirstTran						'Y'					---- 
			,''									sfirstName
			,''									smiddleName
			,''									slastName1
			,''									slastName2
			,CM.fullName						sfullName			--
			,CM.idIssueDate						sissuedDate			--
			,CM.idExpiryDate					svalidDate			--
			,CM.dob								sdob				--
			,''									semail
			,CM.city							scity				--
			,''									szipCode
			,CM.nativeCountry					snativeCountry		--
			,CM.idType							sidType				--
			,CM.idNumber						sidNumber			--
			,CM.mobile							smobile				--
			,ISNULL(CM.address,CM.city)			saddress			--
			,0									occupationId		
			,ISNULL(OCU.detailTitle,0)			occupationName		--
			--------- receiver details
			,''									receiverId				
			,TRT.fullName						rfullName			--
			,''									rfirstName
			,''									rmiddleName
			,''									rlastName1
			,''									ridType
			,''									ridNumber
			,''									rvalidDate
			,''									rdob
			,''									rhomePhone
			,TRT.mobile							rmobile				--
			--,RE.countryCode
			,''									rnativeCountry
			,ISNULL(TRT.city,TRT.address)		rcity				--
			,TRT.address						raddress			--
			,''									remail
			,TRT.accountNo						raccountNo			--
			,TRT.country						rcountry			--
			,''									branchId	
			,''									branchName
			,''									city
			,0									pAgent
			,''									pAgentName
			,''									pBankType
			,ISNULL(PBID.BANK_CODE1,0)			pBank				--
			,ISNULL(PBBID.BRANCH_CODE1,'0')		pBankLocation		--
			,ISNULL(PBBID.BRANCH_NAME,'')		pBankBranchName		--
			,RTT.pBankName						pBankName			--
			,RTT.payoutCurr
			,RTT.collCurr
			,ISNULL(RTT.cAmt,0)					cAmt				--
			,ISNULL(RTT.pAmt,0)					pAmt				--
			,ISNULL(RTT.tAmt,0)					tAmt				--
			,0									serviceCharge		--
			,''									pAgentComm
			,RTT.purposeOfRemit					purposeOfRemit		--
			,RTT.sourceOfFund					sourceOfFund		--	
			,''									relationId
			,REL.detailTitle					relationName		--
			,''									remarks
			,0									sAgent
			,''									sAgentName
			,0									sSuperAgent
			,''									ipAddress
			,0									countryId
			,RTT.sCountry						sCountry			--
			,''									rstate
			,0									sBranch
			,''									pLocation
			,RTT.paymentMethod					paymentMethod		--
			,dbo.decryptDb(RTT.controlNo)		controlNo			--
			,0									exRate
			,''									rcityCode
			,CM.sessionId						sessionId			----
			,'true'								IsRealtime			----
			,''									bankAccountNo
			,'Y'								IsRealtime
		FROM remitTranTemp RTT WITH(NOLOCK)
		INNER JOIN dbo.tranSendersTemp TST(NOLOCK) ON TST.TRANID = RTT.ID
		INNER JOIN customerMaster CM(NOLOCK) ON CM.customerId = TST.customerId
		INNER JOIN dbo.tranReceiversTemp TRT(NOLOCK) ON TRT.TRANID = RTT.ID
		LEFT JOIN applicationUsers AU(NOLOCK) ON AU.USERNAME = RTT.CREATEDBY
		INNER JOIN dbo.agentMaster AM(NOLOCK) ON AM.agentId=RTT.pAgent
		LEFT JOIN API_BANK_LIST PBID (NOLOCK) ON PBID.BANK_ID=RTT.pBank
		LEFT JOIN dbo.API_BANK_BRANCH_LIST PBBID (NOLOCK) ON PBBID.BRANCH_ID=RTT.pBankBranch
		LEFT JOIN dbo.staticDataValue OCU (NOLOCK) ON OCU.detailTitle=TRT.occupation OR OCU.valueId=TRT.occupation
		LEFT JOIN dbo.staticDataValue REL (NOLOCK) ON REL.valueId=CM.relationId
		WHERE RTT.id = @tranId
	END

	IF @PartnerId= '394396'		----- For GME NEPAL
	BEGIN
	    SELECT
			 RTT.id								tranId				----			
			,RTT.createdDate					txnDate
			,AU.userName						userName			--											notes -- Filds are use for jme nepal send model
			,ISNULL(AM.parentId,0)				partnerId			---- use for to get thirdparty api partner services 
			,ISNULL(CM.customerId,0)			customerId
			,isFirstTran						'Y'					---- 
			,''									sfirstName
			,''									smiddleName
			,''									slastName1
			,''									slastName2
			,CM.fullName						sfullName			--
			,ISNULL(CM.address,CM.city)			saddress			--
			,CM.mobile							smobile				--
			,CM.city							scity				--
			,RTT.sCountry						sCountry			--
			,CM.idType							sidType				--
			,CM.idNumber						sidNumber			--
			,TRT.fullName						rfullName			--
			,TRT.address						raddress			--
			,TRT.mobile							rmobile				--
			,ISNULL(TRT.city,TRT.address)		rcity				--
			,TRT.country						rcountry			--
			,RTT.sourceOfFund					sourceOfFund		--	
			,REL.detailTitle					relationName		--
			,RTT.purposeOfRemit					purposeOfRemit		--
			,ISNULL(RTT.cAmt,0)					cAmt				--
			,ISNULL(RTT.pAmt,0)					pAmt				--
			,ISNULL(RTT.tAmt,0)					tAmt				--
			,RTT.paymentMethod					paymentMethod		--
			,RTT.pBankName						pBankName			--
			,ISNULL(PBID.BANK_CODE1,0)			pBank				--
			,ISNULL(PBBID.BRANCH_CODE1,'0')		pBankLocation		--
			,ISNULL(PBBID.BRANCH_NAME,'')		pBankBranchName		--
			,TRT.accountNo						raccountNo			--

			,CM.idIssueDate						sissuedDate			--
			,CM.idExpiryDate					svalidDate			--
			,CM.dob								sdob				--
			,''									semail
			,''									szipCode
			,CM.nativeCountry					snativeCountry		--
			,0									occupationId		
			,ISNULL(OCU.detailTitle,0)			occupationName		--
			--------- receiver details
			,''									receiverId				
			,''									rfirstName
			,''									rmiddleName
			,''									rlastName1
			,''									ridType
			,''									ridNumber
			,''									rvalidDate
			,''									rdob
			,''									rhomePhone
			--,RE.countryCode
			,''									rnativeCountry
			,''									remail
			,''									branchId	
			,''									branchName
			,''									city
			,0									pAgent
			,''									pAgentName
			,''									pBankType
			,RTT.payoutCurr
			,RTT.collCurr
			,0									serviceCharge		--
			,''									pAgentComm
			,''									relationId
			,''									remarks
			,0									sAgent
			,''									sAgentName
			,0									sSuperAgent
			,''									ipAddress
			,0									countryId
			,''									rstate
			,0									sBranch
			,''									pLocation
			,dbo.decryptDb(RTT.controlNo)		controlNo			--
			,0									exRate
			,''									rcityCode
			,CM.sessionId						sessionId			----
			,'true'								IsRealtime			----
			,''									bankAccountNo
			,'Y'								IsRealtime
		FROM remitTranTemp RTT WITH(NOLOCK)
		INNER JOIN dbo.tranSendersTemp TST(NOLOCK) ON TST.TRANID = RTT.ID
		INNER JOIN customerMaster CM(NOLOCK) ON CM.customerId = TST.customerId
		INNER JOIN dbo.tranReceiversTemp TRT(NOLOCK) ON TRT.TRANID = RTT.ID
		LEFT JOIN applicationUsers AU(NOLOCK) ON AU.USERNAME = RTT.CREATEDBY
		INNER JOIN dbo.agentMaster AM(NOLOCK) ON AM.agentId=RTT.pAgent
		LEFT JOIN API_BANK_LIST PBID (NOLOCK) ON PBID.BANK_ID=RTT.pBank
		LEFT JOIN dbo.API_BANK_BRANCH_LIST PBBID (NOLOCK) ON PBBID.BRANCH_ID=RTT.pBankBranch
		LEFT JOIN dbo.staticDataValue OCU (NOLOCK) ON OCU.detailTitle=TRT.occupation OR OCU.valueId=TRT.occupation
		LEFT JOIN dbo.staticDataValue REL (NOLOCK) ON REL.valueId=CM.relationId
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
