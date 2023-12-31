USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[Proc_MistakelyPostViewAdd]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[Proc_MistakelyPostViewAdd]
	@flag		VARCHAR(10),
	@agentId	VARCHAR(50),
	@branchId	VARCHAR(50) = NULL,
	@tranType	VARCHAR(10)	= NULL,
	@controlNo	VARCHAR(50) = NULL,
	@payAmt		MONEY		= NULL,
	@payDate	DATE		= NULL,
	@commAmt	MONEY		= NULL,
	@commDate	DATE		= NULL,
	@id			INT			= NULL,
	@COMPANY	VARCHAR(100) = NULL
	
AS
SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET XACT_ABORT ON;

IF @flag = 'A'
BEGIN
	SELECT 
		* 
	FROM ErroneouslyPayment WHERE ref_no ='12345678900'
END
IF @flag = 'bDisp' -----------displaying a branch
BEGIN
	
	IF (select central_sett from agentTable where map_code= @agentId)='Y'
	BEGIN
		select map_code,agent_name,central_sett from agentTable where central_sett_code 
		=  @agentId order by agent_name
	END
	ELSE
		SELECT agent_id,agent_name,central_sett from agentTable WHERE 1=2
END
IF @flag = 'I'
BEGIN

	IF (SELECT COUNT(*) FROM ErroneouslyPayment WHERE ref_no = @controlNo AND mode =@tranType)=2
	BEGIN
		SELECT 1 error,'<b><font color="red">Control Number already added..</font></b>' AS REMARKS
		RETURN;
	END	

	IF @payAmt IS NULL AND @commAmt IS NULL
	BEGIN
		SELECT 1 error,'<b><font color="red">Must enter Payout Amount or commission Amount..</font></b>' AS REMARKS
		RETURN;
	END	
	
	IF @payDate IS NULL AND @commDate IS NULL
	BEGIN
		SELECT 1 error,'<b><font color="red">Must enter Payout Date or commission Date..</font></b>' AS REMARKS
		RETURN;
	END	
	
IF (select central_sett from agentTable where map_code= @agentId)='Y'
	BEGIN
		IF @branchId IS NULL
		BEGIN
			SELECT 1 error,'<b><font color="red">Branch Name cannot blank for central Agent..</font></b>' AS REMARKS
			RETURN;
		END
END
	
	IF @tranType ='cr' 
	BEGIN
		IF EXISTS(SELECT 'A' FROM ErroneouslyPayment WHERE ref_no = @controlNo AND mode<>'DR')
		BEGIN
			SELECT 1 error,'<b><font color="red">Mistakely post transaction not found..</font></b>' AS REMARKS
			RETURN;
		END
	END
	
	IF EXISTS(SELECT 'A' FROM ErroneouslyPayment WHERE ref_no = @controlNo AND companyName<>'Commission Account')
	BEGIN
		INSERT INTO ErroneouslyPayment(ref_no,tranno,Amount,mode,agentCode,branch_code,approved_ts,companyName,sno)
		SELECT *,0 FROM (
		SELECT @controlNo [CONTROLNO],null [TRANNO],@payAmt [Amount]
			,@tranType [mode],@agentId[agentCode],@branchId [branch_code],@payDate[DATE]
			,(SELECT AGENT_NAME FROM agentTable WHERE map_code =@agentId) [COMPANY]
		)X WHERE Amount IS NOT NULL
		
		SELECT 0 error,'<b><font color="green">Successfully added..</font></b>' AS REMARKS
		RETURN;
	END
	
	IF EXISTS(SELECT 'A' FROM ErroneouslyPayment WHERE ref_no = @controlNo AND companyName='Commission Account')
	BEGIN
		INSERT INTO ErroneouslyPayment(ref_no,tranno,Amount,mode,agentCode,branch_code,approved_ts,companyName,sno)
		SELECT @controlNo,null,@commAmt,@tranType,@agentId,@branchId,@commDate,'Commission Account',0
		
		SELECT 0 error,'<b><font color="green">Successfully added..</font></b>' AS REMARKS
		RETURN;
	END

	INSERT INTO ErroneouslyPayment(ref_no,tranno,Amount,mode,agentCode,branch_code,approved_ts,companyName,sno)
	SELECT *,0 FROM (
	SELECT @controlNo [CONTROLNO],null [TRANNO],@payAmt [Amount]
		,@tranType [mode],@agentId[agentCode],@branchId [branch_code],@payDate[DATE]
		,(SELECT AGENT_NAME FROM agentTable WHERE map_code =@agentId) [COMPANY]
	UNION ALL
	SELECT @controlNo,null,@commAmt,@tranType,@agentId,@branchId,@commDate,'Commission Account'
	)X WHERE Amount IS NOT NULL
	
	SELECT 0 error,'<b><font color="green">Successfully added..</font></b>' AS REMARKS
END

IF @flag = 'U'
BEGIN
	IF (select central_sett from agentTable where map_code= @agentId)='Y'
		BEGIN
			IF @branchId IS NULL
			BEGIN
				SELECT 1 error,'<b><font color="red">Branch Name cannot blank for central Agent..</font></b>' AS REMARKS
				RETURN;
			END
	END

	IF @COMPANY ='Commission Account'
	BEGIN
		UPDATE ErroneouslyPayment
			SET Amount = @commAmt,
			approved_ts = @commDate,
			agentCode = @agentId,
			branch_code = @branchId
		WHERE rowid = @id
	END
	ELSE
		UPDATE ErroneouslyPayment
			SET Amount = @payAmt,
			approved_ts = @payDate,
			agentCode = @agentId,
			branch_code = @branchId
		WHERE rowid = @id
	SELECT 0 error,'<b><font color="green">Successfully updated..</font></b>' AS REMARKS
END


GO
