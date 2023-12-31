USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_REMIT_DATA_UPDATE]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[PROC_REMIT_DATA_UPDATE]
     @flag varchar(20) -- s,p
    ,@mapCode		varchar(20)=null
    ,@user		varchar(50)=null
    ,@pAgentComm	money = null
    ,@controlNo	varchar(20)=null

    ,@sFirstName	varchar(100)=null
    ,@sMiddleName	varchar(100)=null
    ,@sLastName1	varchar(100)=null
    ,@sLastName2	varchar(100)=null

    ,@rFirstName	varchar(100)=null
    ,@rMiddleName	varchar(100)=null
    ,@rLastName1	varchar(100)=null
    ,@rLastName2	varchar(100)=null

    ,@cAmt	money =null
    ,@pAmt	money =null
    ,@serviceCharge	money =null
    ,@sAgentComm	money =null

    ,@pBank	varchar(20) =null
    ,@pBankName	varchar(20) =null
    ,@pBankBranch	varchar(20) =null
    ,@deliveryMethod	varchar(100) =null
    ,@pMapCode		     varchar(100) =null
    ,@tranId	     varchar(100) =null
    ,@pBankBranchName	VARCHAR(100) = NULL
    ,@paidDate			DATETIME = NULL
AS

SET @user = 'SW:'+ @user
SET NOCOUNT ON;

DECLARE @LastCharInDomTxn CHAR(1) = dbo.FNALastCharInDomTxn()

if @flag ='c'
begin

    --select  * from [REMIT_TRN_LOCAL] 
    --where TRN_REF_NO = dbo.encryptDbLocal('7128289986D')
	IF RIGHT(@controlNo,1) = @LastCharInDomTxn
    BEGIN
		UPDATE [REMIT_TRN_LOCAL] SET
			CANCEL_USER = @user
		   ,CANCEL_DATE = GETDATE()
		   ,PAY_STATUS  = 'Un-Paid'
		   ,TRN_STATUS  = 'Cancel'
		WHERE TRN_REF_NO = dbo.encryptDbLocal(@controlNo)
	END
	ELSE
	BEGIN
		UPDATE remit_trn_master SET
		   CANCEL_DATE = GETDATE()
		   ,TRN_STATUS  = 'Cancel'
		WHERE TRN_REF_NO = dbo.encryptDbLocal(@controlNo)
	END

end

if @flag ='s'
begin


	   --@tranId
	   --ALTER TABLE [REMIT_TRN_LOCAL] ADD TranIdNew bigint


	   INSERT INTO [REMIT_TRN_LOCAL] 
	   (
		   [TRN_REF_NO],[S_AGENT]
		  ,[SENDER_NAME]
		  ,[RECEIVER_NAME]
		  ,[S_AMT],[P_AMT],[ROUND_AMT],[TOTAL_SC],[OTHER_SC],[S_SC],[R_SC]
		  ,[R_BANK],[R_BANK_NAME],[R_BRANCH]
		  ,[TRN_TYPE]
		  ,TRN_STATUS,PAY_STATUS
		  ,[TRN_DATE],CONFIRM_DATE
		  ,SEMPID,TranIdNew
	   )
	 SELECT
	 dbo.encryptDBlocal(@controlNo),@mapCode
	,@sFirstName + ISNULL(' ' + @sMiddleName, '') + ISNULL(' ' + @sLastName1, '') + ISNULL(' ' + @sLastName2, '')
	,@rFirstName + ISNULL(' ' + @rMiddleName, '') + ISNULL(' ' + @rLastName1, '') + ISNULL(' ' + @rLastName2, '')
	,@cAmt,@pAmt,@pAmt,@serviceCharge,0,@sAgentComm,@pAgentComm
	,@pBank,@pBankName,@pBankBranch
	,CASE WHEN @deliveryMethod = 'Cash Payment' THEN 'Cash Pay' 
				    WHEN @deliveryMethod = 'Bank Deposit' THEN 'Bank Transfer' END
	,'Un-Paid','Payment'
	,GETDATE(),GETDATE()
	,@user,@tranId


end


if @flag ='p'
begin

    if right(@controlNo,1) = @LastCharInDomTxn
    BEGIN
    	
	    UPDATE [REMIT_TRN_LOCAL] SET
			R_BRANCH			= @mapCode
		    ,R_AGENT			= @mapCode
		    ,paidBy			= @user
		    ,P_DATE			= GETDATE()
		    ,PAY_STATUS		= 'Paid'
		    ,TRN_STATUS		= 'Paid'
		    ,R_SC			= @pAgentComm
	    WHERE TRN_REF_NO = dbo.encryptDbLocal(@controlNo)


    end
    else
    begin

	   UPDATE [REMIT_TRN_MASTER] SET
			P_BRANCH			= @mapCode
		    ,P_AGENT			= @pMapCode
		    ,paidBy			= @user
		    ,PAID_DATE		= GETDATE()
		    ,PAY_STATUS		= 'Paid'
		    ,TRN_STATUS		= 'Paid'
		    ,SC_P_AGENT		= @pAgentComm
		    ,TranIdNew			= @tranId
	    WHERE TRN_REF_NO = dbo.encryptDb(@controlNo)

    end	

end

if @flag ='b'
begin

    if right(@controlNo,1) = @LastCharInDomTxn
    BEGIN
    	
	    UPDATE [REMIT_TRN_LOCAL] SET
			R_BRANCH			= @pBankBranchName
		    ,R_AGENT			= @mapCode
		    ,paidBy			= @user
		    ,PAY_STATUS		= 'Paid'
		    ,TRN_STATUS		= 'Paid'
		    ,R_SC			= @pAgentComm
		    ,P_DATE			= @paidDate
	    WHERE TRN_REF_NO = dbo.encryptDbLocal(@controlNo)


    end
    else
    begin

	   UPDATE [REMIT_TRN_MASTER] SET
			P_BRANCH			= @mapCode
		    ,P_AGENT			= @pMapCode
		    ,paidBy			= @user
		    ,PAID_DATE		= GETDATE()
		    ,PAY_STATUS		= 'Paid'
		    ,TRN_STATUS		= 'Paid'
		    ,SC_P_AGENT		= @pAgentComm
		    ,TranIdNew			= @tranId
	    WHERE TRN_REF_NO = dbo.encryptDb(@controlNo)

    end	

end




GO
