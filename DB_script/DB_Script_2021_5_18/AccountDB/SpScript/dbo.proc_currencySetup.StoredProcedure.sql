USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_currencySetup]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_currencySetup]
@flag				VARCHAR(20),
@rowid				int			= null,
@curr_code			varchar(10) = null,
@curr_name			varchar(50) = null,
@curr_desc			varchar(100)= null,
@curr_decimalName	varchar(20) = null,
@decimal_count		int			= null,
@round_no			int			= null,
@user				varchar(50) = null,
@principalCode		VARCHAR(50)	= NULL,
@minRate			MONEY		= NULL,
@maxRate			MONEY		= NULL,

@currRoundOff		CHAR(1)		= NULL,
@sortBy				VARCHAR(50)	= NULL,
@sortOrder			VARCHAR(5)	= NULL,
@pageSize			INT			= NULL,
@pageNumber			INT			= NULL  

AS

SET NOCOUNT ON;	
if @flag = 'a'
BEGIN
	SELECT * FROM CURRENCY_SETUP WITH(NOLOCK)
	WHERE rowid= @rowid
	--WHERE created_by = @user AND rowid= @rowid
END

IF @FLAG = 'S'
BEGIN
	DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter			VARCHAR(MAX)
			
		--IF @sortBy IS NULL  
			SET @sortBy = 'curr_code'			
	
		SET @table = '(		
						SELECT rowid,curr_code,curr_name,curr_desc,created_date,created_by,modified_date,modified_by 
						FROM CURRENCY_SETUP WITH(NOLOCK)
					  ) x'	
					
		SET @sqlFilter = ''	
		IF @curr_code IS NOT NULL
			SET @sqlFilter +=' AND  curr_code =  '''+@curr_code + ''''
		IF @curr_name IS NOT NULL
			SET @sqlFilter +=' AND curr_name LIKE '''+@curr_name+'%'''
		
		SET @selectFieldList = '
							rowid,curr_code,curr_name,curr_desc,created_date,created_by,modified_date,modified_by
						'
		
		EXEC dbo.proc_paging
			@table					
			,@sqlFilter			
			,@selectFieldList		
			,@extraFieldList		
			,@sortBy				
			,@sortOrder			
			,@pageSize				
			,@pageNumber
	
	RETURN
END

IF @FLAG = 'I'
BEGIN
	IF EXISTS(SELECT 'A' FROM currency_setup WHERE curr_code = @curr_code)
	BEGIN
		exec proc_errorHandler 1,'Currency code already created!',@curr_code
		RETURN
	END
	IF @minRate <=0 
	BEGIN
		exec proc_errorHandler 1,'Min Rate cannot be 0 or Negative!',@curr_code
		RETURN
	END	
	IF @maxRate <=0 
	BEGIN
		exec proc_errorHandler 1,'Max Rate cannot be 0 or Negative!',@curr_code
		RETURN
	END	
	--alter table currency_setup add currRoundOff char(1)
		INSERT INTO currency_setup
		(
			curr_code,
			curr_name,
			curr_desc,
			curr_decimalname,
			decimal_Count,
			round_no,
			created_date,
			created_by,
			principalCode,
			minRate,
			maxRate,
			currRoundOff
		)	
		VALUES
		(
			@curr_code,
			@curr_name,
			@curr_desc,
			@curr_decimalName,
			@decimal_count,
			@round_no,
			getdate(),
			@user,
			@principalCode,
			@minRate,
			@maxRate,
			@currRoundOff
		)

	--###### Exec JobHistoryRecord 'i','JOB NAME','OLD VALUE','NEW VALUE','REMARKS','UPDATED ROW','user'
	Exec JobHistoryRecord 'i','CURRENCY ADDED','',@curr_code,@curr_desc ,'',@user
	
	exec proc_errorHandler 0,'Record added successfully!',@curr_code
	RETURN
END
	
IF @FLAG='U'
BEGIN
	IF EXISTS(SELECT 'A' FROM currency_setup WHERE curr_code = @curr_code AND rowid<> @rowid)
	BEGIN
		exec proc_errorHandler 1,'Currency code already created!',@curr_code
		RETURN
	END
	IF @minRate <=0 
	BEGIN
		exec proc_errorHandler 1,'Min Rate cannot be 0 or Negative!',@curr_code
		RETURN
	END	
	IF @maxRate <=0 
	BEGIN
		exec proc_errorHandler 1,'Max Rate cannot be 0 or Negative!',@curr_code
		RETURN
	END	
	UPDATE currency_setup SET
			curr_code		= @curr_code,
			curr_name		= @curr_name,
			curr_desc		= @curr_desc,
			curr_decimalname =@curr_decimalName,
			decimal_Count	= @decimal_count,
			round_no		= @round_no,
			modified_date	= getdate(),
			modified_by		= @user,
			principalCode	= @principalCode,
			minRate			= @minRate,
			maxRate			= @maxRate,
			currRoundOff	= @currRoundOff
	WHERE rowid = @rowid

	--###### Exec JobHistoryRecord 'i','JOB NAME','OLD VALUE','NEW VALUE','REMARKS','UPDATED ROW','user'
	Exec JobHistoryRecord 'u','CURRANCY MODIFIED','',@curr_name,@curr_desc ,@rowid,@user
	exec proc_errorHandler 0,'Record updated successfully!',@curr_code
	RETURN
END

IF @FLAG = 'D'
BEGIN	
	IF (SELECT SUM(available_amt)  FROM ac_master A INNER JOIN currency_setup C ON A.ac_currency = C.curr_code WHERE C.rowid =@rowid)>0
	BEGIN
		exec proc_errorHandler 1,'Balanced currency can not be deleted!',@rowid
		RETURN
	END
	
		SELECT @curr_name =curr_name,@curr_desc=curr_desc FROM currency_setup where rowid = @rowid
		Delete from currency_setup where rowid = @rowid
	
	Exec JobHistoryRecord 'd','CURRANCY DELETED','',@curr_name,@curr_desc ,@rowid,@user	
	exec proc_errorHandler 0,'Record deleted successfully!',@rowid
	RETURN
END
----## DENO SETUP
ELSE IF @flag = 'saveDeno'
BEGIN
	IF NOT EXISTS(SELECT 'A' FROM denoSetup WHERE currCode = @curr_code AND deno = @round_no)
	BEGIN
		INSERT INTO denoSetup(currCode,deno,createdBy,createdDate)
		SELECT @curr_code,@round_no,@user,GETDATE()
	END
	SELECT rowId,currCode,deno,createdBy,createdDate FROM denoSetup WITH(NOLOCK) WHERE currCode = @curr_code ORDER BY deno
	
	RETURN
END
ELSE IF @flag = 'deleteDeno'
BEGIN
	DELETE FROM denoSetup WHERE rowId = @rowid and currCode = @curr_code
	SELECT rowId,currCode,deno,createdBy,createdDate FROM denoSetup WITH(NOLOCK) WHERE currCode = @curr_code ORDER BY deno
RETURN
END
ELSE IF @flag ='loadDeno'
BEGIN
	SELECT rowId,currCode,deno,createdBy,createdDate FROM denoSetup WITH(NOLOCK) WHERE currCode = @curr_code ORDER BY deno
	RETURN
END
GO
