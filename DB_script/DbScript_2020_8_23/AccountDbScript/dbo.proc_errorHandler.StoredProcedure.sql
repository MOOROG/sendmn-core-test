USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_errorHandler]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[proc_errorHandler](
	 @errorCode	VARCHAR(10)
	,@msg		VARCHAR(MAX)
	,@id		VARCHAR(MAX)	
)	
AS
SET NOCOUNT ON
SELECT @errorCode errorCode, @msg msg, @id id

GO
