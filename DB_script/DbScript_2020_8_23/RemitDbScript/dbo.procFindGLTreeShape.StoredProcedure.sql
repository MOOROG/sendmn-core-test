USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[procFindGLTreeShape]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
select * from GL_GROUP where gl_code='183'
Exec procFindGLTreeShape 'i', '183','asdf','15'
*/


CREATE proc [dbo].[procFindGLTreeShape]
		 @flag			    CHAR(1)
		,@p_id			    VARCHAR(20)		= NULL
		,@gl_name			VARCHAR(200)	= NULL
		,@bal_grp			VARCHAR(20)		= NULL
		,@ROWID				INT				= NULL
			
AS
SET NOCOUNT ON;

-----############### TREE SHAPE FIND########################

DECLARE @strNewTreeId AS VARCHAR(20)
BEGIN TRY

	IF @flag = 'i'
   
	BEGIN		
		IF NOT EXISTS(SELECT tree_sape FROM GL_GROUP  WHERE p_id = @p_id) AND ISNUMERIC(@p_id)=1
		BEGIN
			SELECT @strNewTreeId=tree_sape FROM GL_GROUP  WHERE gl_code=@p_id
			SET @strNewTreeId=@strNewTreeId + '.01'
		END
		ELSE
		BEGIN
			SELECT TOP 1 @strNewTreeId=tree_sape FROM GL_GROUP  WHERE p_id=@p_id ORDER BY gl_code DESC
			IF @strNewTreeId IS NULL
			BEGIN
				SET @strNewTreeId=  '00'+ REPLACE(@p_id,'r','') + '.01'
			END
			ELSE
			BEGIN
				SET @strNewTreeId=   SUBSTRING(@strNewTreeId,1,LEN(@strNewTreeId)-2) + '0' + CAST( right(@strNewTreeId,2)+1 as varchar)
			END
		END
		
		--SELECT @strNewTreeId
---------########## INSERT PROCESS

		INSERT INTO GL_GROUP(p_id,gl_name,bal_grp,tree_sape) 
		VALUES(@p_id,@gl_name,@bal_grp,@strNewTreeId)
		
		SET @ROWID  = SCOPE_IDENTITY();
		
		SELECT 0 errorCode, 'Key successfully inserted.' msg, @ROWID id	
	END
	
	ELSE IF @flag = 'u'
	BEGIN
		
		UPDATE GL_GROUP SET gl_name =@gl_name  WHERE gl_code = @ROWID
		
		SELECT 0 errorCode, 'Key successfully edited.' msg, @ROWID id	
   
	 END		
END TRY

BEGIN CATCH
    IF @@TRANCOUNT >0
       ROLLBACK TRANSACTION
     
     SELECT 1 errorCode, ERROR_MESSAGE() msg, @ROWID id

END CATCH


GO
