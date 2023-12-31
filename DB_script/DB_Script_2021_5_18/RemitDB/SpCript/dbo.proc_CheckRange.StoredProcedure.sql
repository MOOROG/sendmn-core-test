USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_CheckRange]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*



*/

CREATE proc [dbo].[proc_CheckRange]
	 @sql		VARCHAR(MAX)
	,@from		MONEY
	,@to		MONEY
	,@id		INT			= NULL
	,@success	INT			= 0 OUTPUT

AS
	DECLARE @message VARCHAR(1000)
	DECLARE @dataArray TABLE(amtFrom MONEY, amtTo MONEY)

	INSERT @dataArray
	EXEC(@sql)
	

	IF @from > @to
	BEGIN
		EXEC proc_errorHandler 1, '[Amount To] is less than [Amount From]', @id			
		RETURN
	END

	IF EXISTS (SELECT 'X' FROM @dataArray WHERE amtFrom = @from)
	BEGIN
		SET @message = 'Starting from ' + CAST(@from AS VARCHAR) + ' has already been defined.'
		EXEC proc_errorHandler 1, @message, @id			
		RETURN 
	END

	IF EXISTS (SELECT 'X' FROM @dataArray WHERE amtTo = @to)
	BEGIN
		SET @message = 'Ending with ' + CAST(@to AS VARCHAR) + ' has already been defined.'
		EXEC proc_errorHandler 1, @message, @id
		RETURN 
	END

	IF EXISTS (SELECT 'X' FROM @dataArray WHERE amtFrom = @to)
	BEGIN
		SET @message = 'You can not set a parameter ending with ' + CAST(@to AS VARCHAR) + ' because a parameter starting from this value has already been defined.'
		EXEC proc_errorHandler 1, @message, @id			
		RETURN 
	END

	IF EXISTS (SELECT 'X' FROM @dataArray WHERE amtTo= @from)
	BEGIN
		SET @message = 'You cant not set a paramter starting from ' + CAST(@from  AS VARCHAR) + ' because a parameter ending with this value has already been defined.'

		EXEC proc_errorHandler 1, @message, @id			
		RETURN  
	END

	IF EXISTS (SELECT 'X' FROM @dataArray WHERE @from >= amtFrom AND @from <= amtTo)
	BEGIN
		SET @message = 'You can not set a parameter starting from ' + CAST(@from AS VARCHAR) + ' because a parameter covering this value in its range has already been defined.'

		EXEC proc_errorHandler 1, @message, @id			
		RETURN			
	END
	
	IF EXISTS (SELECT 'X' FROM @dataArray WHERE @to >= amtFrom AND @to <= amtTo)
	BEGIN
		SET @message = 'You can not set a parameter ending with ' + CAST(@to AS VARCHAR) + ' because a parameter covering this value in its range has already been defined.'

		EXEC proc_errorHandler 1, @message, @id			
		RETURN			
	END
	
	IF EXISTS (SELECT 'X' FROM @dataArray WHERE @from <= amtFrom AND @to >= amtTo)
	BEGIN
		SET @message = 'You can not set this parameter because parameter within ' + CAST(@from AS VARCHAR) + ' and ' + + CAST(@to AS VARCHAR) + ' has already been defined.'

		EXEC proc_errorHandler 1, @message, @id			
		RETURN			
	END
	
	
--	SELECT * from @range WHERE @from >= a AND @from <= b
--SELECT * from @range WHERE @to >= a AND @to <= b
--SELECT * FROM @range WHERE @from <=a AND @to >= b

	
	SET @success = 1

GO
