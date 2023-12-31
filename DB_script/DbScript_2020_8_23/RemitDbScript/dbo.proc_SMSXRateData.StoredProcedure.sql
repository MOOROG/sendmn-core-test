USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_SMSXRateData]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	EXEC proc_SMSData @flag = 'SMSToSender',@controlNo= '99266917270',@branchId = '4681', @user = 'admin',@sAgent ='4672'

*/

CREATE proc [dbo].[proc_SMSXRateData] 
(	 
	 @flag				VARCHAR(50)
	,@user				VARCHAR(50)		= NULL
	,@branchId			INT				= NULL
	,@agentId			INT				= NULL		
) 
AS

SET NOCOUNT ON
SET XACT_ABORT ON

	DECLARE @msg VARCHAR(MAX)--,@code varchar(10),@length int,@mobile varchar(50)
	
	declare @country varchar(50) = 'Nepal'
	select mobile from SystemEmailSetup with(nolock) where country = @country and isXRate  = 'Yes'


	SELECT @msg = 'IME M, IME Nepal ExRate for 1 USD = 98.75 NPR as of date 10/9/2013 6:28:02 PM'

	insert into SMSQueue(mobileNo,msg,createdDate,createdBy,country,agentId,branchId)
	select mobile,@msg,getdate(),@user,@country,@agentId,@branchId 
	from SystemEmailSetup with(nolock) where country = @country and isXRate  = 'Yes' 
	
	/*
	select 
		 @code = countryMobCode
		,@length = countryMobLength
	from countryMaster with(nolock) 
	where countryName = @country

	if @code is null or @length is null
		return;

	if len(@mobile) <> @length
	begin
		if left(@mobile,len(@code)) <> @code
			set @mobile = @code + @mobile		
	end

	if len(@mobile)<> @length
		return;	
	*/
	


	


GO
