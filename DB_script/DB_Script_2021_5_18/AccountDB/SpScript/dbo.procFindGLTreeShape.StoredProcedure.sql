USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procFindGLTreeShape]    Script Date: 5/18/2021 5:20:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select * from GL_GROUP where p_id='r27'  
-- select * from GL_GROUP where p_id='99'  
-- Exec procFindGLTreeShape '99','This is test','24'  
-- Exec procFindGLTreeShape '33','This is test','12'  
  
CREATE PROC [dbo].[procFindGLTreeShape]
    @p_id				VARCHAR(20) ,
    @gl_name			VARCHAR(200) ,
    @bal_grp			VARCHAR(20) ,
	@accountPrifix		VARCHAR(20)
AS
BEGIN  
SET NOCOUNT ON;  
  
IF EXISTS ( SELECT  'X' FROM    GL_Group WHERE   gl_name = @gl_name )
	BEGIN
	    SELECT  '1' ERRORCODE ,'GL with same name already exist!!' AS MSG ,NULL ID; 
	END;
ELSE
BEGIN
-----############### TREE SHAPE FIND########################  
DECLARE @strNewTreeId AS VARCHAR(20);  
IF NOT EXISTS ( SELECT  tree_sape FROM    GL_Group WHERE   p_id = @p_id ) AND ISNUMERIC(@p_id) = 1
BEGIN  
    SELECT  @strNewTreeId = tree_sape FROM    GL_Group WHERE   gl_code = @p_id;  
    SET @strNewTreeId = @strNewTreeId + '.01';  
 END;  
ELSE
BEGIN  
	SELECT TOP 1 @strNewTreeId = tree_sape FROM    GL_Group WHERE   p_id = @p_id ORDER BY gl_code DESC;  
    IF @strNewTreeId IS NULL
        BEGIN  
            SET @strNewTreeId = '00' + REPLACE(@p_id, 'r','') + '.01';  
        END;  
    ELSE
    BEGIN  
	IF CAST(RIGHT(@strNewTreeId, 2) AS INT) > 9
		SET @strNewTreeId  = SUBSTRING(@strNewTreeId,1,LEN(@strNewTreeId)- 2) + CAST(RIGHT(@strNewTreeId, 2) + 1 AS VARCHAR);  
	ELSE
		SET @strNewTreeId = SUBSTRING(@strNewTreeId,1,LEN(@strNewTreeId)- 2) + '0' + CAST(RIGHT(@strNewTreeId, 2) + 1 AS VARCHAR);  
       
END;  
END;  
				
SET @bal_grp = LEFT(@strNewTreeId,4)
  -- select @strNewTreeId  
---------########## INSERT PROCESS  
INSERT  INTO GL_Group( p_id ,gl_name ,bal_grp ,tree_sape,acc_Prefix,seq_Number) VALUES  ( @p_id ,@gl_name ,@bal_grp ,@strNewTreeId,@accountPrifix,1);  
 SELECT  '0' ERRORCODE ,'SUCCESS' AS MSG ,NULL ID; 
END;
END;  





GO
