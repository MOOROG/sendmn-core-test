USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[ConvertUnixDate]    Script Date: 5/18/2021 6:38:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[ConvertUnixDate]

(

      @TimeValue bigint

)

RETURNS datetime

AS

BEGIN

	DECLARE @DateTime datetime

	DECLARE @GMTOffsetInSeconds bigint

	DECLARE @isDateDST bit

	DECLARE @isCurrDateDST bit

	SET @GMTOffsetInSeconds = DateDiff(ss, GetUTCDate(), GetDate())

	IF DATEPART(m,GETDATE()) BETWEEN 4 AND 10

		SET @isCurrDateDST = 1

	ELSE

		SET @isCurrDateDST = 0

	IF DATEPART(m,DATEADD(s,@TimeValue+@GMTOffsetInSeconds,'01/01/1970')) BETWEEN 4 AND 10

		SET @isDateDST = 1

	ELSE

		SET @isDateDST = 0				

	IF @isCurrDateDST = 1 AND @isDateDST = 0

		SET @GMTOffsetInSeconds = @GMTOffsetInSeconds - 3600

	IF @isCurrDateDST = 0 AND @isDateDST = 1

		SET @GMTOffsetInSeconds = @GMTOffsetInSeconds + 3600

	SELECT @DateTime = DATEADD(s,@TimeValue + @GMTOffsetInSeconds,'1/1/1970')

	RETURN @DateTime

END
GO
