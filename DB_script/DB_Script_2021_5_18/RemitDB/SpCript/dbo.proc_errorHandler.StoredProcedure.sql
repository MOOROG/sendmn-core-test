USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_errorHandler]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_errorHandler](
	 @errorCode	VARCHAR(10)
	,@msg		VARCHAR(MAX)
	,@id		VARCHAR(50)	
)	
AS
SET NOCOUNT ON
SELECT @errorCode errorCode, @msg msg, @id id


GO
