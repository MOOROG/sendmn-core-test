USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_CANCEL_TXN_CASH]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[PROC_CANCEL_TXN_CASH]
(
	@TRAN_ID BIGINT
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @cAmt MONEY, @cancelApprovedDate VARCHAR(25), @message VARCHAR(200), @userId INT, @sAgent INT, @controlNo VARCHAR(30),
			@collMode VARCHAR(50), @tranType VARCHAR(10), @user VARCHAR(50), @tranStatus VARCHAR(30), @introducer VARCHAR(30),
			@customerId BIGINT, @createdDate VARCHAR(20), @isOnbehalf CHAR(1)
	--CASH COLLECT MODE
	SELECT
			@cAmt = cAmt
			,@userId = A.userId
			,@controlNo = dbo.FNADecryptString(controlNo)
			,@sAgent	= sAgent
			,@tranType	= tranType
			,@collMode = COLLMODE
			,@cancelApprovedDate = r.cancelApprovedDate
			,@createdDate = r.createddate
			,@user = ISNULL(r.CANCELAPPROVEDBY, 'SYSTEM')
			,@introducer = promotionCode
			,@tranStatus = R.tranStatus
			,@customerId = T.CUSTOMERID
			,@isOnbehalf = (CASE WHEN ISONBEHALF = '1' THEN 'Y' ELSE 'N' END)
	FROM remitTran r WITH(NOLOCK)
	INNER JOIN TRANSENDERS T(NOLOCK) ON T.TRANID = R.ID
	LEFT JOIN applicationUsers A(NOLOCK) ON A.USERNAME = R.CREATEDBY
	WHERE r.id = @TRAN_ID

	DECLARE @SAME_DAY_CANCEL BIT = 0

	--IF CAST(@createdDate AS DATE) = CAST(@cancelApprovedDate AS DATE)
	SET @SAME_DAY_CANCEL = 1

	--IF ISNULL(@tranStatus, '') <> 'Cancel'
	--BEGIN
	--	EXEC proc_errorHandler 1, 'Transaction not found or is not cancel!', @TRAN_ID
	--	RETURN
	--END
	
	----INSERT INTO TRANSACTION TABLE(MAP DEPOSIT TXN WITH CUSTOMER)
	--INSERT INTO CUSTOMER_TRANSACTIONS (customerId, tranDate, particulars, deposit, withdraw, refereceId, head, createdBy, createdDate)
	--SELECT	@customerId, GETDATE(), 'Cancel TXN: '+@controlNo, @cAmt, 0, @TRAN_ID, 'Cancel Txn', @user, GETDATE()

	IF @SAME_DAY_CANCEL = 1
	BEGIN
		--UN COMMENT WHILE GOING LIVE
		EXEC PROC_UPDATE_AVAILABALE_BALANCE @FLAG='CANCEL',@S_AGENT = @sAgent,@S_USER = @userId,@REFERRAL_CODE = @introducer
		,@C_AMT = @cAmt,@ONBEHALF =@isOnbehalf

		IF NOT EXISTS(SELECT 1 FROM BRANCH_CASH_IN_OUT_HISTORY (NOLOCK) WHERE REFERENCEID = @TRAN_ID AND HEAD = 'Txn Cancel') AND NOT EXISTS(SELECT 1 FROM BRANCH_CASH_IN_OUT (NOLOCK) WHERE REFERENCEID = @TRAN_ID AND HEAD = 'Txn Cancel') 
		BEGIN
			IF @collMode = 'Cash Collect' AND (EXISTS(SELECT 1 FROM REFERRAL_AGENT_WISE (NOLOCK) WHERE REFERRAL_CODE = @introducer AND REFERRAL_TYPE_CODE = 'RB') OR ISNULL(@introducer, '') = '')
			BEGIN
				IF EXISTS(SELECT 1 FROM AGENTMASTER (NOLOCK) WHERE AGENTID = @sAgent AND ISNULL(ISINTL, 0) = 1)
				BEGIN
					SELECT @userId = USERID
					FROM APPLICATIONUSERS AU(NOLOCK) 
					WHERE AGENTID = @sAgent
				END
			
				SET @message = 'Cancel TXN: '+@controlNo
				IF EXISTS(SELECT 1 FROM REFERRAL_AGENT_WISE (NOLOCK) WHERE REFERRAL_CODE = @introducer AND REFERRAL_TYPE_CODE = 'RB') 
				BEGIN
					IF EXISTS(SELECT 1 FROM APPLICATIONUSERS (NOLOCK) WHERE USERID = @userId AND AGENTID = @sAgent)
					BEGIN
						--INSERT INTO CASH AND VAULT TABLE FOR BRANCH CASH HOLD LIMIT CHECK
						EXEC PROC_PUSH_CASH_IN_OUT @flag='OUT', @user=@USER,@amount=@cAmt,
													@tranDate=@cancelApprovedDate,@head='Txn Cancel',
													@remarks=@message,@branchId=@sAgent,
													@isAutoApprove=1,@userId=@userId,@referenceId=@TRAN_ID
					END
					ELSE
					BEGIN
						--INSERT INTO CASH AND VAULT TABLE FOR BRANCH CASH HOLD LIMIT CHECK
						EXEC PROC_PUSH_CASH_IN_OUT @flag='OUT', @user=@USER,@amount=@cAmt,
													@tranDate=@cancelApprovedDate,@head='Txn Cancel',
													@remarks=@message,@branchId=@sAgent,
													@isAutoApprove=1,@userId=0,@referenceId=@TRAN_ID
					END
				END
				ELSE 
				BEGIN
					--INSERT INTO CASH AND VAULT TABLE FOR BRANCH CASH HOLD LIMIT CHECK
					EXEC PROC_PUSH_CASH_IN_OUT @flag='OUT', @user=@USER,@amount=@cAmt,
												@tranDate=@cancelApprovedDate,@head='Txn Cancel',
												@remarks=@message,@branchId=@sAgent,
												@isAutoApprove=1,@userId=@userId,@referenceId=@TRAN_ID
				END
			END
		END
	END
	
	IF ISNULL(@introducer, '') <> '' AND NOT EXISTS (SELECT 'X' FROM agentMaster(NOLOCK) WHERE agentId = @sAgent AND ISNULL(isSettlingAgent,	'N') = 'Y' 
				AND ISNULL(isIntl, 0) = 1 AND isApiPartner = 0 AND ISNULL(ACTASBRANCH, 'N') = 'N')
	BEGIN
		IF EXISTS(SELECT 1 FROM REFERRAL_AGENT_WISE (NOLOCK) WHERE REFERRAL_CODE = @introducer AND REFERRAL_TYPE_CODE = 'RB')
		BEGIN
			RETURN;
		END
		
		IF EXISTS(SELECT 1 FROM REFERRAL_AGENT_WISE (NOLOCK) WHERE REFERRAL_CODE = @introducer AND REFERRAL_TYPE_CODE = 'RR') AND NOT EXISTS(SELECT 1 FROM REFERRAL_INCENTIVE_TRANSACTION_WISE (NOLOCK) WHERE IS_CANCEL = 1 AND TRAN_ID = @TRAN_ID)
		BEGIN
			INSERT INTO REFERRAL_INCENTIVE_TRANSACTION_WISE
					(REFERRAL_ID, TRAN_ID, COMMISSION_PCNT, PAID_COMMISSION, FX_PCNT, PAID_FX, FLAT_RATE, PAID_FLAT, 
						PAID_NEW_CUSTOMER_RATE, PAID_NEW_CUSTOMER, CUSTOMER_ID, CREATED_DATE, PARTNER_ID, IS_CANCEL, TXN_DATE, TAX_AMOUNT)

			SELECT REFERRAL_ID, TRAN_ID, COMMISSION_PCNT, PAID_COMMISSION*-1, FX_PCNT, PAID_FX*-1, FLAT_RATE, PAID_FLAT*-1, 
						PAID_NEW_CUSTOMER_RATE, PAID_NEW_CUSTOMER*-1, CUSTOMER_ID, GETDATE(), PARTNER_ID, 1, @cancelApprovedDate , TAX_AMOUNT*-1
			FROM REFERRAL_INCENTIVE_TRANSACTION_WISE WHERE TRAN_ID = @TRAN_ID
		END 

		IF @SAME_DAY_CANCEL = 1 AND NOT EXISTS(SELECT 1 FROM SendMnPro_Account.dbo.TRANSIT_CASH_SETTLEMENT (NOLOCK) WHERE REFERENCE_ID = @TRAN_ID AND IN_AMOUNT = 0)
		BEGIN
			INSERT INTO SendMnPro_Account.dbo.TRANSIT_CASH_SETTLEMENT(REFERRAL_CODE, RECEIVING_MODE, RECEIVING_ACCOUNT, IN_AMOUNT, OUT_AMOUNT, TRAN_DATE, CREATED_BY, CREATED_DATE, REFERENCE_ID)
			SELECT REFERRAL_CODE, 'T', NULL, OUT_AMOUNT, IN_AMOUNT, @cancelApprovedDate, @USER, GETDATE(), REFERENCE_ID
			FROM SendMnPro_Account.dbo.TRANSIT_CASH_SETTLEMENT
			WHERE REFERENCE_ID = @TRAN_ID
		END
	END
END


GO
