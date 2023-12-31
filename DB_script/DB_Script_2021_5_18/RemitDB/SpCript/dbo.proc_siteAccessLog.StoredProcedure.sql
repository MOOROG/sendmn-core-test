USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_siteAccessLog]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_siteAccessLog]
	 @flag			VARCHAR(10) = NULL
	,@dcId			VARCHAR(100) = NULL
	,@dcUserName	VARCHAR(100) = NULL
	,@ipAddress		VARCHAR(100) = NULL

AS
SET NOCOUNT ON

IF @flag = 'i'
BEGIN
	INSERT INTO siteAccessLog(
		 dcId
		,dcUserName
		,ipAddress
		,accessDate
	)
	SELECT
		 @dcId
		,@dcUserName
		,@ipAddress
		,GETDATE()
END

ELSE IF @flag = 'v'
BEGIN
	IF EXISTS(SELECT TOP 1 'X' FROM blacklistedDc WITH(NOLOCK) WHERE dcId = @dcId)
	BEGIN
		EXEC proc_errorHandler 1, 'Blacklisted Digital Certificate ID', NULL
		INSERT INTO siteAccessLog(
			 dcId
			,dcUserName
			,ipAddress
			,accessDate
		)
		SELECT
			 @dcId
			,@dcUserName
			,@ipAddress
			,GETDATE()
	END
	EXEC proc_errorHandler 0, 'Digital Certificate ID Validation Successful', NULL
END

/*
INSERT INTO blacklistedDc(dcId, createdBy, createdDate)
SELECT '61-99-2a-79-a9-3e-51-de-6c-90-d9-c6-21-74-04-25', 'bijay', GETDATE() UNION ALL
SELECT '1f-8c-72-57-00-05-00-00-e2-c6', 'bijay', GETDATE() UNION ALL
SELECT '1f-6f-a1-cf-00-05-00-00-e2-c5', 'bijay', GETDATE() UNION ALL
SELECT '1f-47-a6-dd-00-05-00-00-e2-c4', 'bijay', GETDATE()

CREATE TABLE siteAccessLog(
	 rowId			BIGINT IDENTITY(1,1)
	,dcId			VARCHAR(100)
	,dcUserName		VARCHAR(100)
	,ipAddress		VARCHAR(100)
	,accessDate		DATETIME
)

CREATE TABLE blacklistedDc(
	 rowId			INT IDENTITY(1,1)
	,dcId			VARCHAR(100)
	,createdBy		VARCHAR(50)
	,createdDate	DATETIME
)

ALTER TABLE applicationUsers ADD dcSerialNumber VARCHAR(100), dcUserName VARCHAR(100)
ALTER TABLE loginLogs ADD dcSerialNumber VARCHAR(100), dcUserName VARCHAR(100)

*/

GO
