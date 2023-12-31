USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Proc_RemitTopupRequest]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Proc_RemitTopupRequest]
@flag		VARCHAR(10),
@userName	VARCHAR(50) = NULL,
@pwd		VARCHAR(50) = NULL,
@Password	varchar(50) = null,
@code		INT			= NULL,
@TranId		BIGINT		= NULL,
@topupId	VARCHAR(30) = NULL,
@MSG		VARCHAR(500)= NULL

AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

if @pwd is null
	set @pwd = @Password

DECLARE @mobileNo VARCHAR(15)
BEGIN TRY
IF @flag = 'TbyID'   ---- ## RemitTopupByID
BEGIN
	
	IF CONVERT(VARBINARY,'R3m17U53r') <> CONVERT(VARBINARY,@userName) 
	BEGIN
		SELECT 1 code, 'Invalid Login Details,please try with valid user' msg
		RETURN
	END

	IF CONVERT(VARBINARY,'70pUp@R3m17U53r') <> CONVERT(VARBINARY,@pwd) 
	BEGIN
		SELECT 1 code, 'Invalid Login Details,please try with valid user' msg
		RETURN
	END
	IF CONVERT(VARBINARY,'1043') <> CONVERT(VARBINARY,@code) 
	BEGIN
		SELECT 1 code, 'Invalid Login Details,please try with valid user' msg
		RETURN
	END

	----IF NOT EXISTS(SELECT TOP 1 'A' FROM Admins WITH(NOLOCK) WHERE CONVERT(VARBINARY,UserName) = CONVERT(VARBINARY,@userName) 
	----	AND CONVERT(VARBINARY,UserPassword) = CONVERT(VARBINARY,@pwd) and AdminID = @code )
	----BEGIN
	----	SELECT 1 code, 'Invalid Login Details,please try with valid user' msg
	----	RETURN
	----END
	
	SELECT @mobileNo = mobileNo FROM topupQueue WITH(NOLOCK) WHERE tranId = @TranId AND ISNULL(tranStatus,'Suspicious') = 'Suspicious'
	
	IF ISNULL(@mobileNo,'') = ''
	BEGIN
		SELECT 1 code, 'Mobile Number not found' msg
		RETURN
	END

	--## FOR NCELL
	--SELECT 0 code,'9803212345' mobileNo,'NCELL' Company,'NCELL' product,10 amt, 0 serviceCode,'' refStan
	--	,1 agent_id,'Remit agent' agent_name,1 branchId,'remit branch' branchName
	
	DECLARE @company VARCHAR(10),@product VARCHAR(20),@serviceCode INT

	SELECT @company = company,@product = product,@serviceCode = serviceCode ,@mobileNo = mobileNo
	FROM DBO.GetCompanyServiceCodeByMobileNo(@mobileNo)

	----SELECT @product,@company,@serviceCode,@mobileNo

	IF @company = 'INVALID' OR @product = 'INVALID' OR @serviceCode IS NULL
	BEGIN
	PRINT 'A'
		UPDATE topupQueue SET 
			processDate = GETDATE(),
			tranStatus = 'Invalid' ,
			msg = 'Invalid Mobile Number Found'
		WHERE tranId = @TranId

		select 1 code, 'Invalid Mobile Number Found ' msg
		RETURN
	END

	IF (LEN(ISNULL(@mobileNo,'')) <> 13 AND @company = 'NTC')
	BEGIN
		UPDATE  topupQueue SET 
			processDate = GETDATE(),
			tranStatus = 'Invalid',
			msg = 'Invalid Mobile Number Found'
		WHERE tranId = @TranId
		select 1 code, 'Invalid Mobile Number Found' msg
		RETURN
	END

	IF (LEN(ISNULL(@mobileNo,'')) <> 10 AND @company = 'NCELL')
	BEGIN
		UPDATE topupQueue SET 
			processDate = GETDATE(),
			tranStatus = 'Invalid',
			msg = 'Invalid Mobile Number Found'
		WHERE tranId = @TranId
		select 1 code, 'Invalid Mobile Number Found' msg
		RETURN
	END

	UPDATE topupQueue SET 
		tranStatus = 'Ready',
		processDate = GETDATE()
	WHERE tranId = @TranId

	SELECT 0 CODE,@mobileNo AS mobileNo,CAST(TopupAmt AS INT) TopupAmt,topupId AS refStan,@company AS Company,@product AS product
		,@serviceCode AS serviceCode
		,agentId = '9993172',agentName = 'Business Promo(Free Topup)'
		,branchId = '9993172',branchName = 'Business Promo(Free Topup)'
	FROM topupQueue WITH(NOLOCK) WHERE tranId = @TranId

	RETURN
END
ELSE IF @flag = 'ListData'   ---- ## topup list for bulk topup
BEGIN
	
	IF CONVERT(VARBINARY,'R3m17U53r') <> CONVERT(VARBINARY,@userName) 
	BEGIN
		SELECT 1 code, 'Invalid Login Details,please try with valid user' msg
		RETURN
	END

	IF CONVERT(VARBINARY,'70pUp@R3m17U53r') <> CONVERT(VARBINARY,@pwd) 
	BEGIN
		SELECT 1 code, 'Invalid Login Details,please try with valid user' msg
		RETURN
	END
	IF CONVERT(VARBINARY,'1043') <> CONVERT(VARBINARY,@code) 
	BEGIN
		SELECT 1 code, 'Invalid Login Details,please try with valid user' msg
		RETURN
	END
	
	------IF (select COUNT(*) from systemDown (NOLOCK) WHERE company IN ('prepaid','postpaid','ncell') AND ISNULL(ISDOWN,'N')='Y') = 3
	------BEGIN
	------	SELECT 1 code, 'Topup system is down' msg
	------	RETURN
	------END

	------IF EXISTS(select 'a' from systemDown (NOLOCK) WHERE company IN ('prepaid','postpaid') AND ISNULL(ISDOWN,'N')='Y' )
	------BEGIN
	------	SELECT TOP 30  '0' code,* 
	------	FROM [192.168.0.155].topupQueue WITH(NOLOCK) 
	------	WHERE ISNULL(tranStatus,'Suspicious') = 'Suspicious' AND LEFT(mobileNo,3) IN ('980','981','982')
	------	RETURN
	------END
	------IF EXISTS (select 'a' from systemDown WHERE company = 'ncell' AND ISNULL(ISDOWN,'N')='Y')
	------BEGIN
	------	SELECT TOP 30  '0' code,* 
	------	FROM [192.168.0.155].topupQueue WITH(NOLOCK) 
	------	WHERE ISNULL(tranStatus,'Suspicious') = 'Suspicious' AND LEFT(mobileNo,3) IN ('984','985','986')
	------	RETURN
	------END
	----SELECT TOP 100  FROM topupQueue t
	----CROSS APPLY DBO.GetCompanyServiceCodeByMobileNo(mobileNo) f

	SELECT TOP 30  '0' code,* FROM topupQueue WITH(NOLOCK) 
	WHERE ISNULL(tranStatus,'Suspicious') = 'Suspicious' AND LEFT(mobileNo,3) <> '985'

	RETURN
END

ELSE IF @flag = 'update'   ---- ## for updating status 
BEGIN
	
	IF @MSG NOT LIKE '%succes%'  
	BEGIN
		IF @MSG NOT LIKE '%already used%'  
			SET @code = 1
	END

	UPDATE topupQueue SET 
		tranStatus = CASE @code WHEN 0 THEN 'Success' WHEN 12 THEN 'Suspicious' WHEN 1 THEN null  ELSE 'Success' END
		,msg = @MSG
		,topupId = case when topupId is null then  @topupId else topupId end
	 WHERE tranId = @TranId

	RETURN
END

END TRY

BEGIN CATCH
IF @@ERROR <>0
ROLLBACK TRANSACTION
SELECT 1 code, ERROR_MESSAGE() msg
END CATCH 




GO
