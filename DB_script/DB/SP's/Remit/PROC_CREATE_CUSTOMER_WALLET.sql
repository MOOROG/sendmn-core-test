

ALTER PROC PROC_CREATE_CUSTOMER_WALLET
(
	@CUSTOMER_ID BIGINT 
	,@USER VARCHAR(50) 
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	DECLARE @WalletId BIGINT, @CUSTOMER_NAME VARCHAR(100)
	
	IF NOT EXISTS(SELECT 'X' FROM customerMaster (NOLOCK) WHERE customerId = @CUSTOMER_ID AND ISNULL(WALLETACCOUNTNO, '') = '')
	BEGIN
		RETURN;
	END

	--Linear congruential generator (LCG)
	DECLARE  @m   int  =9999889,@a int =9990499, @c int = 234,
	@FirstPrefix  int  =600, @New varchar(7) 	
	DECLARE @current  BIGINT=1111111
	SELECT TOP 1 @current =  RandomNumber from  VirtualAccountMapping (nolock) ORDER BY RowId desc 

	SET @New =CAST((@a  * @current + @C)%  @m AS VARCHAR)
	SET @New= REPLACE(STR(@New, 7), SPACE(1), '0')
	SET @WalletId = CONCAT (@FirstPrefix,@New)
		 
	IF NOT EXISTS(SELECT RandomNumber from  VirtualAccountMapping (nolock) WHERE RandomNumber=@New) 
	BEGIN
		INSERT INTO VirtualAccountMapping(bankName, virtualAccNumber, RandomNumber, customerId, createdBy, createdDate)
		SELECT '', @WalletId, @New, @CUSTOMER_ID, @USER, GETDATE()
	END
	ELSE
	BEGIN
		SELECT TOP 1 @current =  RandomNumber from  VirtualAccountMapping (nolock) 
		ORDER BY RowId desc 

		SET   @New =CAST((@a  * @current + @C)%  @m AS VARCHAR)
		SET @New= REPLACE(STR(@New, 7), SPACE(1), '0')
		SET   @WalletId =     CONCAT (@FirstPrefix,@New)
				 
		IF NOT EXISTS(SELECT RandomNumber from  VirtualAccountMapping (nolock) WHERE RandomNumber=@New) 
		BEGIN
			INSERT INTO VirtualAccountMapping(bankName, virtualAccNumber, RandomNumber, customerId, createdBy, createdDate)
			SELECT '', @WalletId, @New, @CUSTOMER_ID, @USER, GETDATE()
		END			 
	END

	UPDATE CUSTOMERMASTER SET walletAccountNo = @WalletId WHERE customerId = @CUSTOMER_ID
	SELECT @CUSTOMER_NAME = ISNULL(FULLNAME, FIRSTNAME) 
	FROM CUSTOMERMASTER (NOLOCK)
	WHERE CUSTOMERID = @CUSTOMER_ID
		
	----## AUTO CREATE LEDGER FOR CUSTOMER
	INSERT INTO FastMoneyPro_Account.dbo.ac_master (acct_num, acct_name,gl_code, agent_id, 
	acct_ownership,dr_bal_lim, acct_rpt_code,acct_opn_date,clr_bal_amt, system_reserved_amt, 
	lien_amt, utilised_amt, available_amt,created_date,created_by,company_id, ac_currency)
	VALUES(@WalletId,@CUSTOMER_NAME +' - Wallet Account','160', @CUSTOMER_ID,'o',0,'WAC',getdate(),0,0,0,0,0,getdate(),@user,1, 'MNT')
END





