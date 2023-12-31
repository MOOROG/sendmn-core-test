USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_contractExpiryDate]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_contractExpiryDate]
	 @flag                             VARCHAR(10)		= NULL
    ,@userId						   INT				= NULL
    ,@user                             VARCHAR(30)		= NULL
    ,@userName                         VARCHAR(30)		= NULL
	,@requestedDate                    VARCHAR(100)     = NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE
     @remDays INT
	 ,@days   INT

IF @flag ='s'
BEGIN
	SELECT '1' errorCode,'' msg, NULl Id
	RETURN
	SELECT	
		@userId=main.userId
		,@userName=au.userName
		,@requestedDate=main.requestedDate		
	FROM certificateMaster main WITH(NOLOCK)
	INNER JOIN applicationUsers au WITH(NOLOCK) ON main.userId = au.userId
	INNER JOIN agentMaster am WITH(NOLOCK) ON au.agentId = am.agentId
	WHERE main.approvedBy IS NOT NULL AND main.requestedDate IS NOT NULL AND au.userName=@userName		
		
	SET @remDays = DATEDIFF(d,@requestedDate, GETDATE() )	
	SET @days=365-@remDays		
	--IF @remDays > 350 AND @remDays < 366	
	IF @remDays > 364 AND @remDays < 366		
	BEGIN
		SELECT  '0' errorCode ,'IME Certificate is going to expire on ' + CONVERT(VARCHAR(13),@requestedDate,103)+
			'.You will be unable to log in to IME system after '+CAST(@days AS VARCHAR) + ' days.' as msg, NULL Id
		RETURN		
	END
	ELSE
		SELECT '1' errorCode,'' msg, NULl Id
	RETURN
END



GO
