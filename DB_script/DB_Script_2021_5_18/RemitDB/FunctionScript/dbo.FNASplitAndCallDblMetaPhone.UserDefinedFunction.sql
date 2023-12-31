USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNASplitAndCallDblMetaPhone]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
    select dbo.FNASplitAndCallDblMetaPhone( 'DEV SOL SILAHLI DEVRIMCI BIRLIKLERI')
    
    SELECT 
	    dbo.fnDoubleMetaphoneScalar(1,'DEV')
	   ,dbo.fnDoubleMetaphoneScalar(1,'SOL')
	   ,dbo.fnDoubleMetaphoneScalar(1,'SILAHLI')
	   ,dbo.fnDoubleMetaphoneScalar(1,'DEVRIMCI')
	   ,dbo.fnDoubleMetaphoneScalar(1,'BIRLIKLERI')    
	   ,dbo.fnDoubleMetaphoneScalar(1,'Pralhad') 


 
    CREATE TABLE BlackListSound
    (
		  rowid INT IDENTITY,
		  BlackListId BigInt,
		  FN1 VARCHAR(200)
    )

    select * from BlackListSound

*/

CREATE FUNCTION [dbo].[FNASplitAndCallDblMetaPhone](@Str VARCHAR(300))
RETURNS VARCHAR(200)
AS
BEGIN


     --DECLARE @Str VARCHAR(30)='AAA BBB CCC DDDD'
     DECLARE @strList VARCHAR(3000)

     DECLARE @TempWord TABLE
	(
		  rowid INT,
		  name VARCHAR(200),
		  FN1 VARCHAR(200)
	 )
	

     INSERT INTO @TempWord(rowid, name)
     SELECT  *  from dbo.Split(' ', @str)
	        
     UPDATE @TempWord SET 
		  FN1 = dbo.fnDoubleMetaphoneScalar(1,name)

    --INSERT INTO BlackListSound(BlackListId, FN1)
    --SELECT @blId, REPLACE(@strList,' ','') FROM @TempWord


     --SELECT * FROM @TempWord
     SELECT @strList = COALESCE(@strList + ',', '')+
	    CAST(FN1 AS varchar(10))
     FROM @TempWord

     --SELECT  REPLACE(@strList,' ','')
	RETURN REPLACE(@strList,' ','')

END



GO
