USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_UserDefaultDevice]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_UserDefaultDevice](
	 @flag VARCHAR(10)=NULL
	,@userId	VARCHAR(30)=NULL
	,@scannerName VARCHAR(100)=NULL
)AS
BEGIN
	IF @flag='i'
	BEGIN
		
		IF EXISTS(SELECT 'x' FROM userDefaultDevice WHERE userId=@userId)
		BEGIN
			UPDATE userDefaultDevice SET scannerName=@scannerName WHERE userId=@userId
			SELECT '0' AS errorCode,@scannerName+' Scanner has been marked as default' msg,NULL
            RETURN
		END
		ELSE
		BEGIN
			INSERT INTO userDefaultDevice(
			 userId
			,scannerName
			)SELECT  
				 @userId
				,@scannerName

			SELECT '0' AS errorCode,@scannerName+' Scanner has been marked as default' msg,NULL
            RETURN
		END
	END
	IF @flag='s'
	BEGIN
		SELECT scannerName FROM userDefaultDevice WHERE userId=@userId
		RETURN
	END
END


GO
