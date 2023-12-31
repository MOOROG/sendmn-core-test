USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_topupQueue]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_topupQueue]  
     @flag			VARCHAR(20)   
    ,@user			VARCHAR(50)		= NULL  
    ,@tranId		VARCHAR(100)	= NULL  
	,@tranType		CHAR(1)			= NULL  
	,@mode			CHAR(1)			= NULL  
	,@topupMobileNo	VARCHAR(20)		= NULL
	
	,@userName		VARCHAR(50)		= NULL
	,@password		VARCHAR(50)		= NULL
	,@code			VARCHAR(100)	= NULL
	,@refNo			VARCHAR(50)		= NULL
	,@msg			VARCHAR(MAX)	= NULL
	,@processId		VARCHAR(100)	= NULL
AS  
SET NOCOUNT ON;  
BEGIN TRY 
IF @flag = 's'
BEGIN
	IF (@userName = 'R3m17U53r' AND @password = '70pUp@R3m17U53r')
	BEGIN    
		SELECT TOP 50
			errorCode = 0,
			rowId,
			mobileNo,
			TopupAmt,
			topupId,
			msg = 'Success'
		FROM topupQueue WITH(NOLOCK) 
		WHERE (tranStatus IS NULL OR tranStatus ='Suspicious') AND LEFT(mobileNo,3) <> '985'
		AND  msg IS NULL
		ORDER BY createdDate
		RETURN;
	END
	SELECT 
		errorCode = 1,
		rowId = null,
		mobileNo = NULL,
		TopupAmt = NULL,
		topupId = NULL,
		msg = 'Authentication failed.'
    
END
IF @flag = 'lu'
BEGIN
	IF (@userName = 'R3m17U53r' AND @password = '70pUp@R3m17U53r')
	BEGIN  
		UPDATE  dbo.topupQueue SET 
			tranStatus = CASE when @code = 0 THEN 'Success' 
							WHEN @code = 12 THEN 'Suspicious' 
							WHEN @code =  1 THEN null  
							WHEN @code =  2 THEN 'Invalid' 
							WHEN @processId IS NOT NULL AND @code = 1 THEN 'FAIL'
						 ELSE 'Success' END,
			msg = @msg,
			topupId = case when topupId is null then  @processId else topupId END,
			processDate = GETDATE()
		WHERE rowId = @refNo
		EXEC proc_errorHandler 0, 'Record has been updated successfully.', NULL
		RETURN;
	END 
	EXEC proc_errorHandler 1, 'Authentication failed.', NULL
	RETURN;
END
IF @flag ='a'  
BEGIN  
	DECLARE   
		@membershipId VARCHAR(50),  
		@mobileNo VARCHAR(50),  
		@serviceCharge MONEY,  
		@topupAmt MONEY,  
		@txnDate DATETIME  
   
	DECLARE   
		  @date VARCHAR(20) = CONVERT(VARCHAR, GETDATE(),101),  
		  @monthStartDate VARCHAR(20),  
		  @monthEndDate VARCHAR(20),  
		  @fiscalYear VARCHAR(10),  
		  @monthNumber CHAR(2),  
		  @txnCount INT,   
		  @lastName VARCHAR(200),  
		  @salutation VARCHAR(20)  
	SELECT @fiscalYear = dbo.FNAReturnCurrentFiscalYear(@date)  
	SELECT @monthNumber = dbo.GetNepaliMonth(@date)  
	SELECT @monthStartDate= dbo.GetMonthStartDateEng(@fiscalYear,@monthNumber)  
	SELECT @monthEndDate= dbo.GetMonthEndDateEng(@fiscalYear,@monthNumber)  
	IF @tranType = 'D'  
	BEGIN  
		SELECT   
			@membershipId = ISNULL(sen.membershipId,''),  
			@mobileNo = sen.mobile,  
			@serviceCharge = rt.serviceCharge,  
			@tranType = rt.tranType,  
			@txnDate = rt.approvedDate,  
			@salutation = CASE WHEN cm.gender = '1801' THEN 'Mr.'   
				--WHEN cm.gender = '1802' AND maritalStatus = 'Married' THEN 'Mrs.'  
				--WHEN cm.gender = '1802' AND maritalStatus = 'Unmarried' THEN 'Ms.'  
				ELSE 'Mr/Ms.'  
				END,  
			@lastName = UPPER(ISNULL(cm.lastName1,cm.firstName)),
			@topupMobileNo = sen.workPhone
		FROM remitTran rt WITH(NOLOCK)   
		INNER JOIN dbo.tranSenders sen WITH(NOLOCK) ON rt.id = sen.tranId  
		INNER JOIN dbo.customerMaster cm WITH(NOLOCK) ON cm.membershipId = sen.membershipId  
		WHERE rt.id = @tranId AND sen.membershipId IS NOT NULL  

		IF @txnDate > '2016-07-15' OR @txnDate <'2016-06-15'  
		RETURN;  
  
		SELECT @txnCount = COUNT('x') FROM topupQueue tq WITH(NOLOCK)   
		WHERE createdDate BETWEEN @monthStartDate AND @monthEndDate+' 23:59:59'  
		AND membershipId = @membershipId AND tranType = 'D'  
  
		IF @txnCount >= 1   
		RETURN;  

  		IF @topupMobileNo IS NOT NULL AND LEFT(@mobileNo,3) = '985' 
  		BEGIN
			SET @mobileNo = @topupMobileNo
			--UPDATE customerMaster SET topupMobileNo = @mobileNo WHERE membershipId = @membershipId 
		END
		IF LEN(@mobileNo) <> 10  
		RETURN;  
  
		IF @membershipId = ''  
		RETURN;   
  
		--SELECT @topupAmt =   
		--CASE   
		--WHEN @serviceCharge BETWEEN 100 AND 200 THEN 10  
		--WHEN @serviceCharge BETWEEN 201 AND 400 THEN 20  
		--WHEN @serviceCharge > 400 THEN 30  
		--ELSE 0  
		--END  
		
		SET @topupAmt = 10
		IF @topupAmt <> 0  AND @membershipId IS NOT NULL AND @mobileNo IS NOT NULL  
		BEGIN   
			--IF @mode='s'  
			--BEGIN      
				SELECT 
					@txnCount = COUNT('x') FROM SMSQueue tq WITH(NOLOCK)   
				WHERE createdDate BETWEEN @monthStartDate AND @monthEndDate+' 23:59:59'  
				AND membershipId = @membershipId AND tranType = 'D'  
  
				IF @txnCount >= 1 OR LEFT(@mobileNo,3) = '985'   
				RETURN;  
				
				SET @msg='Dear '+ISNULL(@salutation,'')+' '+ISNULL(@lastName, 'Customer')+',Thank you for choosing IME. You will receive FREE MOBILE RECHARGE of Rs.'+CAST(@topupAmt AS VARCHAR)+'.'  
				INSERT INTO SMSQueue(mobileNo,msg,createdDate,createdBy,country,tranId,txnDate,tranType,membershipId)  
				SELECT @mobileNo,@msg,GETDATE(),@user,'Nepal',@tranId,@txnDate,'D',@membershipId  
				RETURN;  
			--END   
			INSERT INTO topupQueue(tranId,mobileNo,topupAmt,createdDate,tranType,membershipId,txnDate)  
			SELECT @tranId,@mobileNo,@topupAmt,GETDATE(),'D',@membershipId,@txnDate  
		END   
	END  

	IF @tranType <> 'D'  
	BEGIN  
		IF @mode='s'  
		BEGIN   
			RETURN;  
		END 
		SELECT   
			@membershipId = ISNULL(rec.membershipId,''),  
			@mobileNo = rec.mobile,  
			@txnDate = rt.paidDate,  
			@salutation = CASE WHEN cm.gender = '1801'THEN 'Mr.'   
				--WHEN cm.gender = '1802' AND maritalStatus = 'Married' THEN 'Mrs.'  
				--WHEN cm.gender = '1802' AND maritalStatus = 'Unmarried' THEN 'Ms.'  
				END,  
			@lastName = UPPER(ISNULL(cm.lastName1,cm.firstName))  
		FROM remitTran rt WITH(NOLOCK)   
		INNER JOIN dbo.tranReceivers rec WITH(NOLOCK) ON rt.id = rec.tranId  
		INNER JOIN dbo.customerMaster cm WITH(NOLOCK) ON cm.membershipId = rec.membershipId  
		WHERE rt.id = @tranId AND rec.membershipId IS NOT NULL  
  
		IF @txnDate > '2016-07-15' OR @txnDate <'2016-06-15'  
		RETURN;  
  
		SELECT @txnCount = COUNT('x') FROM topupQueue tq WITH(NOLOCK)   
		WHERE txnDate BETWEEN @monthStartDate AND @monthEndDate+' 23:59:59'  
		AND membershipId = @membershipId AND tranType = 'I'  

		IF @topupMobileNo IS NOT NULL AND LEFT(@mobileNo,3) = '985' 
			SET @mobileNo = @topupMobileNo

		IF @txnCount >= 1  
		RETURN;  
  
		IF LEN(@mobileNo) <> 10  
		RETURN;  
  
		IF @membershipId = ''  
		RETURN;   
  
		SET @topupAmt = 10  
		IF @membershipId IS NOT NULL AND @mobileNo IS NOT NULL  
		BEGIN  
			INSERT INTO topupQueue(tranId,mobileNo,topupAmt,createdDate,tranType,membershipId,txnDate)  
			SELECT @tranId,@mobileNo,@topupAmt,GETDATE(),'I',@membershipId,@txnDate  
		END  
	END   
END  
END TRY
BEGIN CATCH
	--SELECT 1234, error_LINE(), ERROR_MESSAGE()
	--do nothing
END CATCH



GO
