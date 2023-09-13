SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

--PROC_REGISTRATION_REPORT @flag ='customer',@user='admin',@FROM_DATE='2020-03-18',@TO_DATE='2020-03-24',@agentId='394389',@branchId=null,@withAgent='withAgent'

ALTER PROC PROC_REGISTRATION_REPORT

	@FLAG				VARCHAR(20)
	,@user				VARCHAR(30)		
	,@FROM_DATE			VARCHAR(10)	= NULL
	,@TO_DATE			VARCHAR(10)	= NULL
	,@agentId			BIGINT		= NULL
	,@branchId			BIGINT		= NULL
	,@withAgent			varchar(20) = NULL
AS
SET NOCOUNT ON;
BEGIN TRY
	DECLARE @agentCode varchar(10)
	select @agentCode = agentCode from applicationusers where username = @user
	IF @agentCode = '1001'
	BEGIN
		SET @USER = NULL
	END
	IF @FLAG = 'beneficiary'
	BEGIN 
		--select ROW_NUMBER() OVER (ORDER BY customerid) SN
		--	,MembershipId
		--	,CustomerName
		--	,PostalCode
		--	,mobile
		--	,Occupation
		--	,dob
		--	, receiverFirstName
		--	, receiverMiddle
		--	, receiverLastName
		--	,country
		--	,address
		--	,receiverMobile
		--	,PaymentMode
		--	,BANK_NAME
		--	,BRANCH_NAME
		--	,receiverAccountNo
		--	,relationship
		--	,purposeOfRemit
		--	,createdBy
		--	,createdDate
		--	FROM (SELECT top 500 
		--				CM.CUSTOMERID	
		--				,ISNULL(cm.postalcode,CM.membershipId) MembershipId
		--				,CM.FULLNAME [CustomerName]
		--				,cm.zipcode [PostalCode]
		--				,CM.mobile
		--				,CM.dob
		--				,sdv2.DETAILTITLE [Occupation]
		--				,ri.firstname receiverFirstName
		--				,ri.middlename receiverMiddle
		--				,ri.lastname1 receiverLastName
		--				,ri.country
		--				,ri.[address]
		--				,ri.mobile [receiverMobile]
		--				,stm.typeTitle PaymentMode
		--				,ABL.BANK_NAME
		--				,ISNULL(ABBL.BRANCH_NAME,'Any Where') BRANCH_NAME
		--				,ri.receiverAccountNo
		--				,SDV3.detailDesc relationship
		--				,SDV4.detailDesc purposeOfRemit
		--	             ,ROW_NUMBER() over(PARTITION BY ri.customerid ORDER BY ri.receiverid) ranknum
		--				,ri.createdby
		--				,ri.createddate
		--	        FROM    receiverInformation ri
		--	        INNER JOIN customerMaster cm on cm.customerid = ri.customerid
		--			INNER JOIN applicationusers au (nolock) on au.username = ri.createdBy
		--			LEFT JOIN STATICDATAVALUE SDV1 ON SDV1.VALUEID = CM.GENDER
		--			LEFT JOIN STATICDATAVALUE SDV2 ON SDV2.VALUEID = CM.occupation
		--			INNER JOIN serviceTypeMaster stm (nolock) ON stm.serviceTypeId = ri.paymentMode
		--			LEFT JOIN API_BANK_LIST ABL (nolock) ON ABL.BANK_ID = ri.PAYOUTPARTNER
		--			LEFT JOIN API_BANK_BRANCH_LIST ABBL (nolock) ON ABBL.BRANCH_ID = ri.BANKLOCATION 
		--			LEFT JOIN STATICDATAVALUE SDV3 (nolock) ON SDV3.VALUEID = ri.RELATIONSHIP
		--			LEFT JOIN STATICDATAVALUE SDV4 (NOLOCK) ON SDV4.VALUEID = ri.PURPOSEOFREMIT
		--			WHERE ri.createddate between @FROM_DATE and @TO_DATE + ' 23:59:59'
		--			AND au.agentid = @agentId
		--			  ) a
		--	WHERE   ranknum <> 1
			SELECT * INTO #temp1
			FROM (
			SELECT DISTINCT customerId FROM receiverinformation WHERE createddate between @FROM_DATE and @TO_DATE + ' 23:59:59'
			)x

			SELECT 
			MembershipId
			,CustomerName
			,PostalCode
			,mobile
			,dob
			,Occupation
			,receiverFirstName
			, receiverMiddle
			,receiverLastName
			,createddate
			,country
			,address
			,receiverMobile
			,PaymentMode
			,BANK_NAME
			,BRANCH_NAME
			,receiverAccountNo
			,relationship
			,purposeOfRemit
			,createdby
			FROM 
			(
				SELECT 
						ISNULL(cm.postalcode,CM.membershipId) MembershipId
						,CM.FULLNAME [CustomerName]
						,cm.zipcode [PostalCode]
						,CM.mobile
						,CM.dob
						,sdv2.DETAILTITLE [Occupation]
						,ri.firstname receiverFirstName
						,ri.middlename receiverMiddle
						,ri.lastname1 receiverLastName
						,ri.createddate
						,ri.country
						,ri.[address]
						,ri.mobile [receiverMobile]
						,stm.typeTitle PaymentMode
						,ABL.BANK_NAME
						,ISNULL(ABBL.BRANCH_NAME,'Any Where') BRANCH_NAME
						,ri.receiverAccountNo
						,SDV3.detailDesc relationship
						,SDV4.detailDesc purposeOfRemit
			             ,ROW_NUMBER() over(PARTITION BY ri.customerid ORDER BY ri.receiverid) ranknum
						,ri.createdby
						,RI.agentId
			 FROM receiverinformation ri (nolock)
			 INNER JOIN #temp1 tmp on tmp.customerid = ri.customerid
			 INNER JOIN customerMaster cm on cm.customerid = ri.customerid
			 INNER JOIN applicationusers au (nolock) on au.username = ri.createdBy
			 LEFT JOIN STATICDATAVALUE SDV1 ON SDV1.VALUEID = CM.GENDER
			 LEFT JOIN STATICDATAVALUE SDV2 ON SDV2.VALUEID = CM.occupation
			 INNER JOIN serviceTypeMaster stm (nolock) ON stm.serviceTypeId = ri.paymentMode
			 LEFT JOIN API_BANK_LIST ABL (nolock) ON ABL.BANK_ID = ri.PAYOUTPARTNER
			 LEFT JOIN API_BANK_BRANCH_LIST ABBL (nolock) ON ABBL.BRANCH_ID = ri.BANKLOCATION 
			 LEFT JOIN STATICDATAVALUE SDV3 (nolock) ON SDV3.VALUEID = ri.RELATIONSHIP
			 LEFT JOIN STATICDATAVALUE SDV4 (NOLOCK) ON SDV4.VALUEID = ri.PURPOSEOFREMIT
			)x
			WHERE ranknum <> 1
			AND createddate between @FROM_DATE and @TO_DATE + ' 23:59:59'
			AND agentid = @agentId
			--AND CREATEDBY = ISNULL(@USER,CREATEDBY)
			ORDER BY createddate

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'From Date' head,@FROM_DATE VALUE
		UNION ALL
		SELECT 'To Date' head,@TO_DATE VALUE

		SELECT 'New Beneficiary Regisration Report(Sending Agent)' title
	END
	ELSE IF @FLAG = 'customer'
	BEGIN
		IF @withAgent = 'withAgent'
		BEGIN
			SELECT customerId INTO #TEMP
			FROM customerMaster (NOLOCK) CM
			INNER JOIN APPLICATIONUSERS AU (NOLOCK) ON AU.USERNAME = CM.CREATEDBY
			WHERE CM.createdDate BETWEEN @FROM_DATE AND @TO_DATE + ' 23:59:59'
			AND AU.AGENTID = isnull(@agentId,au.agentId)
			
			SELECT RT.ID,T.CUSTOMERID,RT.PROMOTIONCODE,RT.CREATEDDATE INTO #TRAN
			FROM REMITTRAN RT (NOLOCK) 
			INNER JOIN TRANSENDERS TS (NOLOCK) ON TS.TRANID = RT.ID
			INNER JOIN #TEMP T (NOLOCK) ON T.CUSTOMERID = TS.CUSTOMERID
			WHERE RT.CREATEDDATE >= @FROM_DATE
			
			SELECT * INTO #MAIN
			FROM (
				SELECT ROW_NUMBER() OVER(PARTITION BY CUSTOMERID ORDER BY CREATEDDATE) SN,* 
				FROM #TRAN 
			)X
			WHERE SN = 1
			
			SELECT ROW_NUMBER() OVER (ORDER BY CM.CUSTOMERID) [SNo]
				   ,ISNULL(CM.POSTALCODE,MEMBERSHIPID) ID
				   ,CM.FULLNAME Name
				   ,isnull(cm.zipcode,'') + isnull(', ' + csm.stateName,'') +  isnull(', ' +cm.city,'') + isnull(', ' + cm.street,'')+isnull(', ' +cm.ADDITIONALADDRESS,'') Address
				   ,cm.mobile MobileNo
				   ,C.COUNTRYNAME Nationality
				   ,convert(varchar(10), dob,121) DOB
				   ,cm.createdby CreatedBy
				   ,RA.REFERRAL_NAME Agent
				   ,CM.createdDate CreatedDateTime
			FROM #MAIN M (NOLOCK)
			INNER JOIN REFERRAL_AGENT_WISE RA (NOLOCK) ON RA.REFERRAL_CODE = M.PROMOTIONCODE
			INNER JOIN CUSTOMERMASTER CM (NOLOCK) ON CM.CUSTOMERID = M.CUSTOMERID
			INNER JOIN AGENTMASTER am (nolock) on am.BRANCHCODE = SUBSTRING(CM.membershipid,1,3)
			LEFT JOIN countryStateMaster csm (nolock) on cast(csm.stateId as varchar) = cm.state
			LEFT JOIN countryMaster C (NOLOCK) ON C.COUNTRYID = CM.NATIVECOUNTRY
			WHERE am.agentid = ISNULL(@agentId, am.agentId)
			ORDER BY CM.createdDate
		END
		ELSE
		BEGIN
			select ROW_NUMBER() OVER (ORDER BY customerid) SN
				 ,membershipId
				,CustomerName
				,PostalCode
				,mobile
				,Gender
				,Occupation
				,dob
				,createdBy
				,createdDate
				, receiverFirstName
				, receiverMiddle
				, receiverLastName
				,country
				,address
				,receiverMobile
				,PaymentMode
				,BANK_NAME
				,BRANCH_NAME
				,receiverAccountNo
				,relationship
				,purposeOfRemit
				FROM  (SELECT  CM.CUSTOMERID
								,CM.FULLNAME [CustomerName]
								,cm.zipcode [PostalCode]
								,CM.mobile
								,ISNULL(CM.POSTALCODE,CM.membershipId) membershipId
								,sdv1.DETAILTITLE [Gender]
								,sdv2.DETAILTITLE [Occupation]
								,CM.dob
								,CM.createdBy
								,CM.createdDate
								,ri.firstname receiverFirstName
								,ri.middlename receiverMiddle
								,ri.lastname1 receiverLastName
								,ri.country
								,ri.[address]
								,ri.mobile [receiverMobile]
								,stm.typeTitle PaymentMode
								,ABL.BANK_NAME
								,ISNULL(ABBL.BRANCH_NAME,'Any Where') BRANCH_NAME
								,ri.receiverAccountNo
								,SDV3.detailDesc relationship
								,SDV4.detailDesc purposeOfRemit
				                ,ROW_NUMBER() over(PARTITION BY ri.customerid ORDER BY ISNULL(ri.receiverid,1)) ranknum
				        FROM customerMaster cm   
				        LEFT JOIN receiverInformation ri on cm.customerid = ri.customerid
						--INNER JOIN applicationusers au (nolock) on au.username = CM.createdBy
						INNER JOIN AGENTMASTER am (nolock) on am.BRANCHCODE = SUBSTRING(CM.membershipid,1,3)
						LEFT JOIN STATICDATAVALUE SDV1 ON SDV1.VALUEID = CM.GENDER
						LEFT JOIN STATICDATAVALUE SDV2 ON SDV2.VALUEID = CM.occupation
						LEFT JOIN serviceTypeMaster stm (nolock) ON stm.serviceTypeId = ri.paymentMode
						LEFT JOIN API_BANK_LIST ABL (nolock) ON ABL.BANK_ID = ri.PAYOUTPARTNER
						LEFT JOIN API_BANK_BRANCH_LIST ABBL (nolock) ON ABBL.BRANCH_ID = ri.BANKLOCATION 
						LEFT JOIN STATICDATAVALUE SDV3 (nolock) ON SDV3.VALUEID = ri.RELATIONSHIP
						LEFT JOIN STATICDATAVALUE SDV4 (NOLOCK) ON SDV4.VALUEID = ri.PURPOSEOFREMIT
						WHERE CM.createddate between @FROM_DATE and @TO_DATE + ' 23:59:59'
						AND am.agentid = ISNULL(@agentId,am.agentId)
						  ) a
				WHERE   ranknum = 1
				--and createdBy = ISNULL(@user,createdBy)
				ORDER BY CREATEDDATE
		END

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'From Date' head,@FROM_DATE VALUE
		UNION ALL
		SELECT 'To Date' head,@TO_DATE VALUE

		SELECT 'Customer Regisration Report(Sending Agent)' title
	END
	ELSE IF @FLAG = 'rejectedReport'
	BEGIN
		SELECT ROW_NUMBER() OVER(ORDER BY CTH.ID) SN
		,dbo.fnadecryptstring(CTH.CONTROLNO) ControlNo,
		sh.fullname,
		sh.mobile,
		cth.collmode,
		cth.paymentmethod,
		cth.camt,
		cth.cancelRequestdate [Reject Date],
		cancelApprovedBy [Rejected By]
	    FROM cancelTranHistory CTH (NOLOCK)
		INNER JOIN cancelTranSendersHistory SH (NOLOCK) ON SH.TRANID = CTH.TRANID
		INNER JOIN cancelTranReceiversHistory RH (NOLOCK) ON RH.TRANID = CTH.TRANID
		LEFT JOIN APPLICATIONUSERS AU (NOLOCK) ON AU.USERNAME = CTH.CREATEDBY
		WHERE CTH.CREATEDDATE BETWEEN @FROM_DATE AND @TO_DATE + ' 23:59:59'
		--AND AU.AGENTID = isnull(@agentId,AU.AGENTID)
		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

		SELECT 'From Date' head,@FROM_DATE VALUE
		UNION ALL
		SELECT 'To Date' head,@TO_DATE VALUE

		SELECT 'Rejected Transaction Report' title

	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	SELECT '1' ErrorCode ,ERROR_MESSAGE() Msg,null id 
END CATCH
GO