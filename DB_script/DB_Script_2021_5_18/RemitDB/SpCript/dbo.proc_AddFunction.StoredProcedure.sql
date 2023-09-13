USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_AddFunction]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_AddFunction] (
	 @FunctionId VARCHAR(8)
	,@ParentFunctionId VARCHAR(8)
	,@FunctionText VARCHAR(200)
)
AS
IF NOT EXISTS (SELECT 'X' FROM applicationFunctions WHERE functionId = @FunctionId)
BEGIN
	INSERT INTO applicationFunctions (functionId, parentFunctionId, functionName)
	SELECT @FunctionId, @ParentFunctionId, @FunctionText
	PRINT 'Added function ' + @FunctionId
END	

GO
