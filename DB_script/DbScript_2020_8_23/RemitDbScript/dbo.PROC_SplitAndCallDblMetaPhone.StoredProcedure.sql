USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_SplitAndCallDblMetaPhone]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[PROC_SplitAndCallDblMetaPhone]
AS
BEGIN


     DECLARE @Str VARCHAR(30)='AAA BBB CCC DDDD'
     DECLARE @strList VARCHAR(300)

     DECLARE @TempWord TABLE
	(
		  rowid INT,
		  name VARCHAR(200),
		  FN1 VARCHAR(200)
	 )
	

     INSERT INTO @TempWord(rowid, name)
     SELECT *  from dbo.Split(' ', @str)
	        
     UPDATE @TempWord SET 
		  FN1 = dbo.fnDoubleMetaphoneScalar(1,name)


    --INSERT INTO BlackListSound(BlackListId, FN1)
    --SELECT @blId, REPLACE(@strList,' ','') FROM @TempWord


     --SELECT * FROM @TempWord
     SELECT @strList = COALESCE(@strList + ',', '')+
	   CAST(FN1 AS varchar(5))
     FROM @TempWord

     

    SELECT  REPLACE(@strList,' ','')

END



GO
