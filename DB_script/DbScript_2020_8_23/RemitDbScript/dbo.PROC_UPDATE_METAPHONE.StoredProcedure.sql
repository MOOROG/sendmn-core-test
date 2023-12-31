USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_UPDATE_METAPHONE]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*

SELECT TOP 10 rowId,name  from blacklist WHERE name <>''
SELECT dbo.FNASplitAndCallDblMetaPhone(1,'asdfdfdf')

select * from BlackListSound
-- SELECT * FROM blacklist

EXEC PROC_UPDATE_METAPHONE
GO

*/
CREATE proc [dbo].[PROC_UPDATE_METAPHONE]

AS
BEGIN

	   SET NOCOUNT ON;

	   update BLACKLIST set 
			 MP =  dbo.FNASplitAndCallDblMetaPhone(name)
	   where isnull(name,'') <> '' 

	   DECLARE	
		   @I1	int,
		   @I2	int,
		   @I3	int,
		   @I4	int,
		   @I5	int,@I6	int,@I7	int,@I8	int,@I9	int,@I10	int


	   UPDATE U
	   SET
		     @I1 = CHARINDEX(',', MP + ',')
		   ,[MP1] = LEFT(MP, @I1-1)

		   ,@I2 =  NullIf(CHARINDEX(',', MP + ',', @I1+1), 0)
		   ,[MP2] = SUBSTRING(MP, @I1+1, @I2-@I1-1)

		   ,@I3 =  NullIf(CHARINDEX(',', MP + ',', @I2+1), 0)
		   ,[MP3] = SUBSTRING(MP, @I2+1, @I3-@I2-1)

		   ,@I4 =  NullIf(CHARINDEX(',', MP + ',', @I3+1), 0)
		   ,[MP4] = SUBSTRING(MP, @I3+1, @I4-@I3-1)

		   ,@I5 =  NullIf(CHARINDEX(',', MP + ',', @I4+1), 0)
		   ,[MP5] = SUBSTRING(MP, @I4+1, @I5-@I4-1)

		   ,@I6 =  NullIf(CHARINDEX(',', MP + ',', @I5+1), 0)
		   ,[MP6] = SUBSTRING(MP, @I5+1, @I6-@I5-1)

		   ,@I7 =  NullIf(CHARINDEX(',', MP + ',', @I6+1), 0)
		   ,[MP7] = SUBSTRING(MP, @I6+1, @I7-@I6-1)

		   ,@I8 =  NullIf(CHARINDEX(',', MP + ',', @I7+1), 0)
		   ,[MP8] = SUBSTRING(MP, @I7+1, @I8-@I7-1)

		   ,@I9 =  NullIf(CHARINDEX(',', MP + ',', @I8+1), 0)
		   ,[MP9] = SUBSTRING(MP, @I8+1, @I9-@I8-1)
            
		   ,@I10 =  NullIf(CHARINDEX(',', MP + ',', @I9+1), 0)
		   ,[MP10] = SUBSTRING(MP, @I9+1, @I10-@I9-1)

	   FROM blacklist U

	   TRUNCATE TABLE BlackListSound
	 
	   insert into BlackListSound (BlackListId, FN1)
	   select rowId,MP1 from blacklist where isnull(MP1,'') <>'' UNION ALL
	   select rowId,MP2 from blacklist where isnull(MP2,'') <>'' UNION ALL
	   select rowId,MP3 from blacklist where isnull(MP3,'') <>'' UNION ALL
	   select rowId,MP4 from blacklist where isnull(MP4,'') <>'' UNION ALL
	   select rowId,MP5 from blacklist where isnull(MP5,'') <>'' UNION ALL
	   select rowId,MP6 from blacklist where isnull(MP6,'') <>'' UNION ALL
	   select rowId,MP7 from blacklist where isnull(MP7,'') <>'' UNION ALL
	   select rowId,MP8 from blacklist where isnull(MP8,'') <>'' UNION ALL
	   select rowId,MP9 from blacklist where isnull(MP9,'') <>'' UNION ALL
	   select rowId,MP10 from blacklist where isnull(MP10,'') <>''
	
END


GO
