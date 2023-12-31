USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_APPLICATION_LOGS_REFERRAL]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PROC_APPLICATION_LOGS_REFERRAL]
(
	 @rowId				BIGINT			= NULL
	,@logType			VARCHAR(50)		= NULL
	,@tableName			VARCHAR(100)	= NULL	
	,@dataId			VARCHAR(50)		= NULL
	,@user				VARCHAR(30)		= NULL
	,@oldData			VARCHAR(MAX)	= NULL
	,@newData			VARCHAR(MAX)	= NULL
	,@module			VARCHAR(50)		= NULL
	,@tableDescription	VARCHAR(50)		= NULL
	,@createdBy			VARCHAR(30)		= NULL
	,@createdDate		DATETIME        = NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(5)		= NULL
	,@pageSize			INT				= NULL
	,@pageNumber		INT				= NULL
    ,@IP			    VARCHAR(50)		= NULL
	,@Reason		    VARCHAR(2000)	= NULL
	,@UserData			VARCHAR(max)	= NULL
	,@fieldValue		VARCHAR(2000)	= NULL
	,@agentId			VARCHAR(20)		= NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

INSERT INTO dbo.REFERRAL_LOGIN_LOGS
        ( 
			referralUserId,logType,IP,Reason,
			fieldValue,createdBy,createdDate,UserData
        )
SELECT	
		@agentId,@logType,@IP,@Reason,
		@fieldValue,@user,GETDATE(),@UserData
GO
