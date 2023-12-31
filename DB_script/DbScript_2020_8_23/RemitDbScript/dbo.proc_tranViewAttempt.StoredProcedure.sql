USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tranViewAttempt]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_tranViewAttempt]
	 @flag				VARCHAR(50)
	,@user				VARCHAR(30)		= NULL
	,@isNewAttempt		CHAR(1)			= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(5)		= NULL
	,@pageSize			INT				= NULL
	,@pageNumber		INT				= NULL
AS

/*
	@flag,	
	i				= Insert
	
*/
DECLARE @sql VARCHAR(MAX), @lockReason VARCHAR(500)

IF @flag = 'i'
BEGIN
	IF NOT EXISTS(SELECT 'X' FROM tranViewAttempt WHERE userName = @user)
	BEGIN
		INSERT INTO tranViewAttempt (	
			 userName
			,continuosAttempt
			,wholeDayAttempt
		)
		SELECT 
			 @user
			,1
			,1
	END
	ELSE
	BEGIN
		UPDATE tranViewAttempt SET
			 continuosAttempt	= CASE WHEN @isNewAttempt = 'Y' THEN 1 ELSE continuosAttempt + 1 END
			,wholeDayAttempt	= CASE WHEN @isNewAttempt = 'Y' THEN ISNULL(wholeDayAttempt, 0) ELSE ISNULL(wholeDayAttempt, 0) + 1 END
		WHERE userName = @user	
	END
	DELETE FROM tranViewAttempt WHERE userName IS NULL
	DECLARE 
		 @continuosAttempt	INT
		,@wholeDayAttempt	INT
	
	SELECT @continuosAttempt = continuosAttempt, @wholeDayAttempt = wholeDayAttempt FROM tranViewAttempt WHERE userName = @user
	IF EXISTS(SELECT 'X' FROM passwordFormat WHERE invControlNoContinous <= @continuosAttempt)
	BEGIN
		UPDATE tranViewAttempt SET
			 continuosAttempt = 0
		WHERE userName = @user
		
		SET @lockReason = 'Your account has been locked by system due to continuous Invalid Control Number Input Attempt'
		EXEC proc_errorHandler 1, @lockReason, NULL
		EXEC [proc_applicationUsers] @flag = 'loc', @userName = @user, @lockReason = @lockReason
		RETURN
	END
	IF EXISTS(SELECT 'X' FROM passwordFormat WHERE invControlNoForDay <= @wholeDayAttempt)
	BEGIN
		UPDATE tranViewAttempt SET
			 wholeDayAttempt = 0
		WHERE userName = @user
		
		SET @lockReason = 'Your account has been locked by system. Invalid Control Number Input Attempt has reached its limit.'
		EXEC proc_errorHandler 2, @lockReason, NULL
		EXEC [proc_applicationUsers] @flag = 'loc', @userName = @user, @lockReason = @lockReason
		RETURN	
	END
	EXEC proc_errorHandler 0, '', NULL
END


GO
