USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[mobile_proc_realtime_validation]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[mobile_proc_realtime_validation]
(
	 @flag		VARCHAR(30) = NULL
	,@username	VARCHAR(30) = NULL
	,@idNumber	VARCHAR(50) = NULL
	,@idType	VARCHAR(100) = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	IF @flag = 'validation'
	BEGIN
		SELECT  '0' ErrorCode, 'valid' Msg, NULL Id, NULL Extra, NULL Extra2
		RETURN
		IF @username IS NOT NULL
		BEGIN
			IF EXISTS(SELECT 'x' FROM dbo.customerMaster(NOLOCK) WHERE email = @username ) OR EXISTS(SELECT 'x' FROM dbo.customerMasterTemp(NOLOCK) WHERE username = @username )
			BEGIN
				SELECT  '1' ErrorCode, 'Username already taken. Please use another id.'	Msg, NULL Id, NULL Extra, NULL Extra2
				RETURN
			END
			SELECT  '0' ErrorCode, 'Username is valid'	Msg, NULL Id, NULL Extra, NULL Extra2
			RETURN
		END	
		ELSE IF @idType IS NOT NULL AND @idNumber IS NOT NULL
		BEGIN
			  IF EXISTS(SELECT 'x',idType FROM dbo.customerMaster(NOLOCK) WHERE idType = @idType AND idNumber = @idNumber) 
			  OR 
			  EXISTS(SELECT 'x' FROM dbo.customerMasterTemp(NOLOCK) WHERE idType = @idType AND idNumber = @idNumber)
				BEGIN
					SELECT  '1' ErrorCode, 'Id number already exist. Please contact GME HO.' Msg, NULL Id, NULL Extra, NULL Extra2
					RETURN
				END
				SELECT  '0' ErrorCode, 'Valid Id number' Msg, NULL Id, NULL Extra, NULL Extra2
				RETURN
		END
	END
	SELECT  '0' ErrorCode, 'valid' Msg, NULL Id, NULL Extra, NULL Extra2
	RETURN
END
GO
