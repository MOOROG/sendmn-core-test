USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_parseEmailTemplate]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	DECLARE @subject VARCHAR(MAX), @body VARCHAR(MAX), @controlNoEncrypted VARCHAR(20)
	SELECT @controlNoEncrypted = dbo.FNAEncryptString('7908628867D')
	EXEC proc_parseEmailTemplate 10004, @controlNoEncrypted, 'admin', 'Cancel', @subject OUTPUT, @body OUTPUT
	SELECT * FROM remitTran
*/
CREATE proc [dbo].[proc_parseEmailTemplate](
	 @agentFilterId		VARCHAR(100)
	,@controlNo			VARCHAR(30)
	,@username			VARCHAR(30)
	,@templateFor		VARCHAR(20)
	,@subject			VARCHAR(MAX)	= NULL OUTPUT
	,@body				VARCHAR(MAX)	= NULL OUTPUT
	,@complain			VARCHAR(200)	= NULL
)
AS 
SET NOCOUNT ON;
	DECLARE @variableList TABLE(variable_name VARCHAR(50), table_name VARCHAR(MAX), field_name VARCHAR(100), field_condition VARCHAR(100), letter_type VARCHAR(50), field_names VARCHAR(MAX) )
	
	INSERT INTO @variableList(variable_name, table_name, field_name, field_condition, letter_type, field_names)
	SELECT 
		letter_key_words, table_name, field_name, field_condition,letter_type, field_names  
	FROM letterKeywordSetting lks WHERE ISNULL(lks.letter_type, '')  IN('f', 't', 'd')
		
	DECLARE 
		 @variable_name VARCHAR(100)
		,@variable_value VARCHAR(MAX)
		,@table_name VARCHAR(MAX)
		,@field_name VARCHAR(100)		
		,@field_condition VARCHAR(100)
		,@letter_type VARCHAR(10)
		,@field_names VARCHAR(MAX)
		,@sql VARCHAR(MAX)
		
		
	DECLARE @value TABLE(value VARCHAR(MAX))
	SELECT @subject = emailSubject, @body = emailFormat from emailTemplate WHERE templateFor = @templateFor
	--SELECT * FROM emailTemplate WHERE templateFor = 'Cancel'
	--SELECT letter_key_words, table_name, field_name, field_condition,letter_type, field_names FROM letterKeywordSetting lks WHERE ISNULL(lks.letter_type, '')  IN('f', 't', 'd')
	
	WHILE EXISTS (SELECT 'X' FROM @variableList)
	BEGIN
		SELECT TOP 1
			 @variable_name = variable_name
			,@table_name = table_name
			,@field_name = field_name
			,@field_names = field_names
			,@letter_type = letter_type
			,@field_condition = field_condition
		FROM @variableList
		
		IF CHARINDEX('{filter_id}', @table_name) > 0
		BEGIN	
			SELECT @sql = REPLACE(
								 @table_name
								,'{filter_id}'
								,CASE 
									WHEN @field_condition = 'controlNo' THEN ISNULL(@controlNo, '')
									WHEN @field_condition = 'username' THEN @username ELSE CAST(@agentFilterId AS VARCHAR) END)	
		END
		ELSE		
		BEGIN
			SET @sql = @table_name + ' WHERE ' + @field_condition + ' = '''
			IF @field_condition = 'controlNo'
				SET @sql = @sql + ISNULL(@controlNo, '') + ''''
			ELSE IF @field_condition = 'username'
				SET @sql = @sql + ISNULL(@username, '') + ''''
			ELSE
				SET @sql = @sql  + CAST(@agentFilterId AS VARCHAR) + ''''			
		END
		IF @letter_type = 'f' --single data from one or more table
		BEGIN				
			DELETE FROM @value
			INSERT @value(value)
			EXEC (@sql)
			
			SET @variable_value = ''
			SELECT @variable_value = ISNULL(value, '') FROM @value			
		END
		
		ELSE IF @letter_type = 'd' --current date
		BEGIN		
			DECLARE @format INT
			IF ISNUMERIC(@table_name) = 1
				SET @format = CAST(@table_name AS INT)
			ELSE
				SET @format = 107
			
			SET @variable_value = CONVERT(VARCHAR, GETDATE(), @format)
			
		END
		
		ELSE IF @letter_type = 't'
		BEGIN
			SET @variable_value = ISNULL(@complain, '')
		END
		
		IF @letter_type IN ('f', 'd', 't')
		BEGIN
			SET @subject = REPLACE(@subject, @variable_name, @variable_value)
			SET @body = REPLACE(@body, @variable_name, @variable_value)
		END	
		
		DELETE FROM @variableList WHERE variable_name = @variable_name		
		
	END
	SET @subject = REPLACE(@subject, '  ', ' ')
	SET @body = REPLACE(@body, '  ', ' ')	

    SELECT @subject, @body

GO
