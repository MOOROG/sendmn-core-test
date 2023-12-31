USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_messageBroadCast]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_messageBroadCast]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@msgBroadCastId                    VARCHAR(30)		= NULL
	,@countryId                         VARCHAR(30)		= NULL
	,@agentId                           VARCHAR(30)		= NULL
	,@branchId                          VARCHAR(30)		= NULL
	

AS
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN
	IF @flag = 'msg-title'
	BEGIN
		IF @agentId IS NULL
		BEGIN
			SELECT msgBroadCastId 
				  ,msgTitle 
			FROM msgBroadCast
			WHERE   
				 ISNULL(isActive ,'N') <> 'N'
				AND ISNULL(isDeleted , 'N') <> 'Y'
				AND (userType IS NULL  OR userType ='HO')
			RETURN;
		END
		SELECT msgBroadCastId 
			  ,msgTitle 
		FROM msgBroadCast
		WHERE   ISNULL(countryId,@countryId)= @countryId
			AND ISNULL(agentId,@agentId)	= @agentId 
			AND isnull(branchId,@branchId)	= @branchId
			AND ISNULL(isActive ,'N') <> 'N'
			AND ISNULL(isDeleted , 'N') <> 'Y'
			AND (userType IS NULL OR userType <> 'HO')
	END
	
	ELSE IF @flag = 'msg-detail'
	BEGIN
		SELECT  msgTitle
			   ,msgDetail 
		FROM msgBroadCast
		WHERE msgBroadCastId = @msgBroadCastId
	END
END




GO
