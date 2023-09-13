

ALTER PROC [dbo].[proc_messageDisplay]
 		 @flag                      VARCHAR(50)		= NULL
		,@userType					VARCHAR(10)		= NULL
		,@countryId					VARCHAR(50)		= NULL
		,@agentId					VARCHAR(50)		= NULL	
		,@branchId					VARCHAR(50)		= NULL
		,@msgId						VARCHAR(50)     = NULL	
		,@user						VARCHAR(50)     = NULL	

	AS
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @agentNature AS VARCHAR(50) = null
	if @agentId is not null
		SELECT @agentNature = agentRole FROM agentMaster with(nolock) where agentId = @agentId
	
	if @userType is null 
		select @userType = userType, @countryId = countryId  from applicationUsers with(nolock) where username=@user

	IF @flag='s'
	BEGIN		 
		
		if @userType='HO'
		begin
			SELECT TOP 10 datename(dw, createdDate)+', '+ convert(varchar(50),cast(createdDate as datetime)) msgDate,newsFeederMsg,msgId 
			from [message] WITH(NOLOCK)
			where newsFeederMsg is not null 
			--and isnull(countryId,@countryId) =  @countryId
			and isnull(agentId,isnull(@agentId,'')) = isnull(@agentId,'')
			and isnull(branchId,isnull(@branchId,'')) = isnull(@branchId,'')
			and (userType = @userType or userType is null)
			and ISNULL(isDeleted,'N') = 'N' 
			and isnull(isActive,'Active') = 'Active'
			order by createdDate desc
			return;
		end
		
		IF @agentNature = 'B'
		BEGIN
			select TOP 10 datename(dw, createdDate)+', '+ convert(varchar(50),cast(createdDate as datetime)) msgDate,newsFeederMsg ,msgId from [message] WITH(NOLOCK)
			where newsFeederMsg is not null 
			and isnull(countryId,@countryId)	= @countryId 
			and isnull(agentId,@agentId)		= @agentId 
			and isnull(branchId,@branchId)		= @branchId
			and isnull(usertype,@userType)		= @userType
			and (msgType IN ('B', 'S', 'R'))
			and ISNULL(isDeleted,'N') = 'N' 
			and isnull(isActive,'Active') = 'Active'
			order by createdDate DESC
		END
		ELSE
		BEGIN
			select TOP 10 datename(dw, createdDate)+', '+ convert(varchar(50),cast(createdDate as datetime)) msgDate,newsFeederMsg ,msgId from [message] WITH(NOLOCK)
			where newsFeederMsg is not null 
			and isnull(countryId,@countryId)	= @countryId 
			and isnull(agentId,@agentId)		= @agentId 
			and isnull(branchId,@branchId)		= @branchId
			and isnull(usertype,@userType)		= @userType
			--and (msgType IN ('B', @agentNature))
			and ISNULL(isDeleted,'N') = 'N' 
			and isnull(isActive,'Active') = 'Active'
			order by createdDate DESC
		END

	END

   IF @flag = 'getNewsfeederById'
   BEGIN 
   select newsFeederMsg
		,datename(dw, createdDate)+', '+ convert(varchar(50),cast(createdDate as datetime)) msgDate
		,datename(dw, createdDate)+', '+ convert(varchar(50),cast(createdDate as datetime)) createdDate
		,createdBy 
	from [message] WITH(NOLOCK)
	where newsFeederMsg is not null 
	and msgId = @msgId
	and ISNULL(isDeleted,'N') = 'N' 
	and isnull(isActive,'Active') = 'Active'
   END
