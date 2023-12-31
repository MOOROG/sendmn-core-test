USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetDocPath]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FNAGetDocPath](@flag VARCHAR(50),@customerId VARCHAR(50),@sessionId VARCHAR(60),@createdDate DATETIME)
RETURNS VARCHAR(50)
AS
BEGIN
		DECLARE @result VARCHAR(50)
		DECLARE @createdBy VARCHAR(20), @agentId VARCHAR(50),@branchId VARCHAR(50)
		
		IF @customerId IS NOT NULL AND ISNUMERIC(@customerId)=1
		BEGIN		
			SELECT @createdBy = createdBy FROM dbo.customerMaster c WITH(NOLOCK)  WHERE customerId = @customerId or sessionId = @sessionId
		END		
		
		SELECT @agentId=CAST(agentId AS VARCHAR)   FROM applicationUsers c WITH(NOLOCK) WHERE userName = @createdBy
	
	IF @flag='df' -- document folder
	BEGIN
		
		 SET @result=
			CASE WHEN @createdDate>= CAST('2013-10-15' AS DATETIME)
				THEN 
					CASE WHEN @createdBy='online' THEN 'online' WHEN @createdBy is null THEN 'IME' ELSE CAST(@agentId AS VARCHAR) 
					END
				ELSE '20141015'
			END
			
		--SET @result=''
	END
	ELSE IF @flag='dftxn' -- txtDoc folder is default folder for transaction docs
	BEGIN
	
			SET @result= 'txnDoc'			
	
	END
	ELSE IF @flag='bid' -- Branch ID
	BEGIN
	
	
		SET @branchId=
		CASE WHEN @createdBy='online' THEN 'online'
			 WHEN @createdBy IS NULL THEN 'IME'
			 ELSE CAST(@agentId AS VARCHAR) 
		END
					
		IF @branchId is null
			SET @branchId='IME'
	
		SET @result=@branchId
		
	END
	ELSE IF @flag='bidtxn' -- transaction docs now stored in txnDoc folder
	BEGIN
		
		SET @branchId='txnDoc'	
		SET @result=@branchId
	
	END
	
	RETURN @result;

END
GO
