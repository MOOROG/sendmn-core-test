USE FastMoneyPro_Remit
GO

ALTER PROC PROC_CALCULATE_REFERRAL_COMM
(
	@COMMISSION_AMT MONEY = NULL
	,@T_AMT MONEY = NULL
	,@P_AGENT_COMM_AMT MONEY = NULL
	,@FX MONEY = NULL
	,@IS_NEW_CUSTOMER CHAR(1) = NULL
	,@REFERRAL_CODE VARCHAR(50) = NULL
	,@PAYOUT_PARTNER INT = NULL
	,@CUSTOMER_ID BIGINT = NULL
	,@TRAN_ID BIGINT = NULL
	,@S_AGENT INT = NULL
	,@AMOUNT MONEY = NULL
	,@USER VARCHAR(60) = NULL
	,@TRAN_DATE VARCHAR(25) = NULL
	,@COLL_MODE VARCHAR(30) = NULL
	,@P_AGENT_COMM MONEY = NULL
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @FX_INCENTIVE MONEY, @COMM_INCENTIVE MONEY, @NEW_CUSTOMER_INCENTIVE MONEY, @FLAT_INCENTIVE MONEY, @DEDUCT_TAX_ON_SC BIT, @DEDUCT_P_COMM_ON_SC BIT
	DECLARE @FX_PCNT DECIMAL(5,2), @COMM_PCNT DECIMAL(5,2), @REFERRAL_ID INT, @UPDATE_TRN CHAR(1) = 'N', @NEW_CUSTOMER_RATE MONEY, @FLAT_RATE MONEY
	DECLARE @TAX_AMOUNT MONEY

	IF EXISTS (SELECT 'X' FROM agentMaster(NOLOCK) WHERE agentId = @S_AGENT	AND ISNULL(isSettlingAgent,	'N') = 'Y' 
				AND ISNULL(isIntl, 0) = 1 AND isApiPartner = 0 AND ISNULL(ACTASBRANCH, 'N') = 'N')
	BEGIN
		SET @UPDATE_TRN = 'Y'
		

		SELECT @REFERRAL_ID = ROW_ID FROM REFERRAL_AGENT_WISE (NOLOCK) WHERE AGENT_ID = @S_AGENT 

		IF NOT EXISTS (SELECT 1 FROM INCENTIVE_SETUP_REFERRAL_WISE (NOLOCK) WHERE REFERRAL_ID = @REFERRAL_ID AND PARTNER_ID = @PAYOUT_PARTNER AND IS_ACTIVE = 1)
		BEGIN
			SELECT TOP 1 @FX_PCNT = FX_PCNT, 
					@COMM_PCNT = COMM_PCNT, 
					@FLAT_INCENTIVE = FLAT_TXN_WISE, 
					@NEW_CUSTOMER_INCENTIVE = NEW_CUSTOMER,
					@DEDUCT_TAX_ON_SC = DEDUCT_TAX_ON_SC,
					@DEDUCT_P_COMM_ON_SC = DEDUCT_P_COMM_ON_SC
			FROM INCENTIVE_SETUP_REFERRAL_WISE (NOLOCK) 
			WHERE REFERRAL_ID = 0
			AND IS_ACTIVE = 1
			AND PARTNER_ID = @PAYOUT_PARTNER
			AND EFFECTIVE_FROM <= @TRAN_DATE
			ORDER BY EFFECTIVE_FROM DESC
		END
		ELSE
		BEGIN
			SELECT TOP 1 @FX_PCNT = FX_PCNT, 
					@COMM_PCNT = COMM_PCNT, 
					@FLAT_INCENTIVE = FLAT_TXN_WISE, 
					@NEW_CUSTOMER_INCENTIVE = NEW_CUSTOMER,
					@DEDUCT_TAX_ON_SC = DEDUCT_TAX_ON_SC,
					@DEDUCT_P_COMM_ON_SC = DEDUCT_P_COMM_ON_SC
			FROM INCENTIVE_SETUP_REFERRAL_WISE (NOLOCK) 
			WHERE REFERRAL_ID = @REFERRAL_ID
			AND IS_ACTIVE = 1
			AND PARTNER_ID = @PAYOUT_PARTNER
			AND EFFECTIVE_FROM <= @TRAN_DATE
			ORDER BY EFFECTIVE_FROM DESC
		END
	END
	ELSE IF ISNULL(@REFERRAL_CODE, '') <> ''
	BEGIN
		DECLARE @REFERRAL_TYPE CHAR(2) 

		SELECT @REFERRAL_TYPE = REFERRAL_TYPE_CODE, @REFERRAL_ID = ROW_ID
		FROM REFERRAL_AGENT_WISE (NOLOCK) 
		WHERE REFERRAL_CODE = @REFERRAL_CODE

		IF @REFERRAL_TYPE = 'RB'
		BEGIN
			RETURN;
		END

		IF @COLL_MODE = 'CASH COLLECT' AND NOT EXISTS(SELECT 1 FROM FASTMONEYPRO_ACCOUNT.DBO.TRANSIT_CASH_SETTLEMENT (NOLOCK) WHERE REFERENCE_ID = @TRAN_ID)
		BEGIN
			INSERT INTO FASTMONEYPRO_ACCOUNT.DBO.TRANSIT_CASH_SETTLEMENT(REFERRAL_CODE, RECEIVING_MODE, RECEIVING_ACCOUNT, IN_AMOUNT, OUT_AMOUNT, TRAN_DATE, CREATED_BY, CREATED_DATE, REFERENCE_ID)
			SELECT @REFERRAL_CODE, 'T', NULL, @AMOUNT, 0, @TRAN_DATE, @USER, GETDATE(), @TRAN_ID
		END
		
		IF @REFERRAL_TYPE = 'RC'
		BEGIN
			RETURN;
		END
		
		IF NOT EXISTS (SELECT 1 FROM INCENTIVE_SETUP_REFERRAL_WISE (NOLOCK) WHERE REFERRAL_ID = @REFERRAL_ID AND PARTNER_ID = @PAYOUT_PARTNER AND IS_ACTIVE = 1)
		BEGIN
			SELECT TOP 1 @FX_PCNT = FX_PCNT, 
					@COMM_PCNT = COMM_PCNT, 
					@FLAT_INCENTIVE = FLAT_TXN_WISE, 
					@NEW_CUSTOMER_RATE = NEW_CUSTOMER,
					@DEDUCT_TAX_ON_SC = DEDUCT_TAX_ON_SC,
					@DEDUCT_P_COMM_ON_SC = DEDUCT_P_COMM_ON_SC
			FROM INCENTIVE_SETUP_REFERRAL_WISE (NOLOCK) 
			WHERE REFERRAL_ID = 0
			AND PARTNER_ID = @PAYOUT_PARTNER
			AND IS_ACTIVE = 1
			AND EFFECTIVE_FROM <= @TRAN_DATE
			ORDER BY EFFECTIVE_FROM DESC
		END
		BEGIN
			SELECT TOP 1 @FX_PCNT = FX_PCNT, 
					@COMM_PCNT = COMM_PCNT, 
					@FLAT_INCENTIVE = FLAT_TXN_WISE, 
					@NEW_CUSTOMER_RATE = NEW_CUSTOMER,
					@DEDUCT_TAX_ON_SC = DEDUCT_TAX_ON_SC,
					@DEDUCT_P_COMM_ON_SC = DEDUCT_P_COMM_ON_SC
			FROM INCENTIVE_SETUP_REFERRAL_WISE (NOLOCK) 
			WHERE REFERRAL_ID = @REFERRAL_ID
			AND PARTNER_ID = @PAYOUT_PARTNER
			AND IS_ACTIVE = 1
			AND EFFECTIVE_FROM <= @TRAN_DATE
			ORDER BY EFFECTIVE_FROM DESC
		END
	END
	ELSE
	BEGIN
		RETURN
	END
	

	IF ISNULL(@DEDUCT_P_COMM_ON_SC, 0) = 1
		SET @COMMISSION_AMT = @COMMISSION_AMT - @P_AGENT_COMM_AMT

	IF ISNULL(@FX_PCNT, 0) <> 0
	BEGIN
		IF @PAYOUT_PARTNER = 393880
			SET @FX_INCENTIVE = (@FX_PCNT * @T_AMT) / 100
		ELSE 
			SET @FX_INCENTIVE = (@FX_PCNT * @FX) / 100
	END
	
	IF ISNULL(@COMM_PCNT, 0) <> 0
	BEGIN
		IF ISNULL(@DEDUCT_TAX_ON_SC, 0) = 0
			SET @COMM_INCENTIVE = (@COMM_PCNT * @COMMISSION_AMT) / 100
		ELSE 
		BEGIN
			SET @COMM_INCENTIVE = (@COMM_PCNT * (@COMMISSION_AMT / 1.1)) / 100
			SELECT @TAX_AMOUNT = (@COMM_PCNT * @COMMISSION_AMT) / 100 - @COMM_INCENTIVE
		END
	END

	IF ISNULL(@IS_NEW_CUSTOMER, 'N') = 'N'
		SET @NEW_CUSTOMER_INCENTIVE = 0
	ELSE 
		SET @NEW_CUSTOMER_INCENTIVE = @NEW_CUSTOMER_RATE

	IF @UPDATE_TRN = 'Y'
	BEGIN
		--DECLARE @CONTROLNO VARCHAR(30)

		--SELECT @CONTROLNO = DBO.DECRYPTDB(CONTROLNO)
		--FROM REMITTRAN (NOLOCK) 
		--WHERE ID = @TRAN_ID

		UPDATE REMITTRAN SET SAGENTCOMM = ISNULL(@FX_INCENTIVE, 0) + ISNULL(@COMM_INCENTIVE, 0) + ISNULL(@NEW_CUSTOMER_INCENTIVE, 0) + ISNULL(@FLAT_INCENTIVE, 0), SAGENTCOMMCURRENCY = 'JPY' WHERE ID = @TRAN_ID

		--UPDATE FASTMONEYPRO_ACCOUNT.DBO.TRAN_MASTER SET TRAN_AMT = ISNULL(@FX_INCENTIVE, 0) + ISNULL(@COMM_INCENTIVE, 0) + ISNULL(@NEW_CUSTOMER_INCENTIVE, 0),
		--USD_AMT = ISNULL(@FX_INCENTIVE, 0) + ISNULL(@COMM_INCENTIVE, 0) + ISNULL(@NEW_CUSTOMER_INCENTIVE, 0) 
		--WHERE FIELD1 = @CONTROLNO AND ACC_NUM IN ('910139266612', '500439205691')
		--AND FIELD2 = 'Remittance Voucher'
		--SELECT ISNULL(@FX_INCENTIVE, 0) + ISNULL(@COMM_INCENTIVE, 0) + ISNULL(@NEW_CUSTOMER_INCENTIVE, 0)
	END
	ELSE
	BEGIN
		INSERT INTO REFERRAL_INCENTIVE_TRANSACTION_WISE
				(REFERRAL_ID, TRAN_ID, COMMISSION_PCNT, PAID_COMMISSION, FX_PCNT, PAID_FX, FLAT_RATE, PAID_FLAT, 
					PAID_NEW_CUSTOMER_RATE, PAID_NEW_CUSTOMER, CUSTOMER_ID, CREATED_DATE, PARTNER_ID, IS_CANCEL, TXN_DATE, TAX_AMOUNT)

		SELECT @REFERRAL_ID, @TRAN_ID, ISNULL(@COMM_PCNT, 0), ISNULL(@COMM_INCENTIVE, 0), ISNULL(@FX_PCNT, 0), ISNULL(@FX_INCENTIVE, 0), ISNULL(@FLAT_INCENTIVE, 0), ISNULL(@FLAT_INCENTIVE, 0), 
					ISNULL(@NEW_CUSTOMER_RATE, 0), ISNULL(@NEW_CUSTOMER_INCENTIVE, 0), @CUSTOMER_ID, GETDATE(), @PAYOUT_PARTNER, 0, @TRAN_DATE, @TAX_AMOUNT
	END
END




