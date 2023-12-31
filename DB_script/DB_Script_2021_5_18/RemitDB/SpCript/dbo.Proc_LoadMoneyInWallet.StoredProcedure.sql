USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_LoadMoneyInWallet]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[Proc_LoadMoneyInWallet]
(
@flag			VARCHAR(50)		
,@user			VARCHAR(50)		= NULL
,@mobileNo		VARCHAR(20)		= NULL
,@walletNo		VARCHAR(20)		= NULL
,@tellerId		VARCHAR(20)		= NULL
,@requestFrom	VARCHAR(20)		= NULL
,@uploadAmount	MONEY		= NULL
,@sessionId		VARCHAR(200) =NULL
)
AS

SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY

CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), membershipId INT)

DECLARE   
 @errorMsg			VARCHAR(500)
,@isActive			VARCHAR(1)
,@approvedBy 		VARCHAR(250)
,@isDeleted  		VARCHAR(1)
,@isLocked   		VARCHAR(1)
,@DrAcc   			VARCHAR(20)
,@CrAcc  			VARCHAR(20)
,@controlNo			VARCHAR(50) =@sessionId
,@vNarration		VARCHAR(200) = 'Wallet Upload Voucher'
,@TxnDate			date
,@narration			VARCHAR(100)
,@customerId   		VARCHAR(20)
,@sAgent   			VARCHAR(20)
		
DECLARE @TranId INT, 
@ReceiverID AS VARCHAR(100),
@MongoliaHO	AS VARCHAR(10) =(SELECT agentid FROM dbo.Vw_GetAgentID WHERE SearchText='payBankHO')

IF @flag = 'loadWalletDetails'
BEGIN
	
	IF NOT EXISTS(SELECT * FROM CustomerMaster(NOLOCK) WHERE walletAccountNo= @walletNo)
	BEGIN
		SELECT '1' errorcode,'Wallet ID Doest Not Exist' errorMsg
		RETURN
	END 

	SELECT 
		@isActive	= ISNULL(isActive,'N'),
		@approvedBy = approvedBy,
		@isDeleted  = ISNULL(isDeleted,'N'),
		@isLocked   = ISNULL(islocked,'N')
	FROM CustomerMaster(NOLOCK) WHERE walletAccountNo= @walletNo

	 IF @isActive IS NULL OR @isActive != 'Y'
	 BEGIN
		SELECT '1' errorcode,'User Is Not Exist!!, Contact Head Office' errorMsg
		RETURN
	 END 

	 IF @approvedBy IS NULL
	 BEGIN
		SELECT '1' errorcode,'User Is Not Approved Yet!!, Contact Head Office' errorMsg
		RETURN
	 END 

	 IF @isDeleted IS NULL OR @isLocked !='N'
	 BEGIN
		SELECT '1' errorcode,'User Has Been Deleted!!, Contact Head Office' errorMsg
		RETURN
	 END 
	
	 IF @isLocked IS NULL OR @isLocked !='N'
	 BEGIN
		SELECT '1' errorcode,'User Has Been Locked, Contact Head Office!!' errorMsg
		RETURN
	 END 

	SELECT  
		errorcode='0',
		errorMsg='Success',
		mobileNo= cm.mobile, 
		fullName = ISNULL(cm.fullName,'N/A'),
		walletNo = walletAccountNo
	FROM CustomerMaster(NOLOCK) cm 
	WHERE walletAccountNo= @walletNo

RETURN
END	
ELSE IF @flag = 'loadMoney'
BEGIN
	IF NOT EXISTS(SELECT * FROM CustomerMaster(NOLOCK) WHERE walletAccountNo= @walletNo)
	BEGIN
		SELECT '1' errorcode,'Wallet ID Doest Not Exist' errorMsg,@walletNo
		RETURN
	END 

	SET @TxnDate = GETDATE()

	IF @requestFrom = 'admin'
	BEGIN 
		--'Mongolia Main Branch(Head Office)':agentId = '394419'
		SELECT @DrAcc = acct_num From SendMnPro_Account.dbo.ac_Master(NOLOCK) 
		WHERE agent_id = @MongoliaHO and acct_rpt_code = 'VAC'
		SET @sAgent = @MongoliaHO
	END
	ELSE 
	BEGIN
		IF NOT EXISTS (SELECT 'x' FROM agentMaster(NOLOCK) WHERE agentId = @tellerId)
		BEGIN
			SELECT '1' errorcode,'Unauthorised Access!!, Contact Head Office' errorMsg,@walletNo
			RETURN
		END

		SELECT @DrAcc = acct_num From SendMnPro_Account.dbo.ac_Master(NOLOCK) 
		WHERE agent_id = @tellerId and acct_rpt_code = 'TCA'

		SET @sAgent = @tellerId

		IF @DrAcc IS NULL OR @DrAcc = ''
		BEGIN
			SELECT '1' errorcode,'Teller Account Missing!!, Contact Head Office' errorMsg,@walletNo
			RETURN
		END

	END

	SELECT @customerId= customerId FROM CustomerMaster(NOLOCK) WHERE walletAccountNo= @walletNo

	SELECT @CrAcc = acct_num From SendMnPro_Account.dbo.ac_Master(NOLOCK) 
	WHERE agent_id = @customerId and acct_rpt_code = 'WAC'

	IF @CrAcc IS NULL OR @CrAcc = ''
	BEGIN
		SELECT '1' errorcode,'Customer Account Missing!!, Contact Head Office' errorMsg,@walletNo
		RETURN
	END


	BEGIN TRANSACTION
	--:DR
		INSERT INTO SendMnPro_Account.dbo.temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@DrAcc,'s','DR',ISNULL(@uploadAmount,0) ,ISNULL(@uploadAmount,0) ,NULL,@TxnDate
			,@vNarration,'MNT',NULL,@walletNo,'Wallet Upload Voucher', @sAgent, @sAgent

		--:CR 
		INSERT INTO SendMnPro_Account.dbo.temp_tran(sessionID,entry_user_id,acct_num,v_type,part_tran_type,tran_amt,usd_amt,usd_rate,tran_date
		,rpt_code,trn_currency,emp_name,field1,field2,dept_id,branch_id)	
		SELECT @controlNo,'system',@CrAcc,'s','CR',ISNULL(@uploadAmount,0) ,ISNULL(@uploadAmount,0) ,NULL,@TxnDate
			,@vNarration,'MNT',NULL,@walletNo,'Wallet Upload Voucher', @customerId, @customerId


COMMIT TRAN 
	SET @narration = 'Wallet Load Money |  wallet No:  '+@walletNo 

	EXEC SendMnPro_Account.dbo.[spa_saveTempTrnUSD] @flag='i',@sessionID=@controlNo,@date=@TxnDate
	,@narration=@narration,@company_id=1,@v_type='s',@user='system'

	UPDATE customerMaster SET availableBalance = ISNULL(availableBalance,0) + ISNULL(@uploadAmount,0) 
	WHERE walletAccountNo = @walletNo

	SET @errorMsg= 'Congratulations! You have successfully uploaded amount : ' + cast(@uploadAmount as varchar) + '  in your wallet.'
	SELECT 0,@errorMsg,@walletNo
END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, NULL
END CATCH













GO
