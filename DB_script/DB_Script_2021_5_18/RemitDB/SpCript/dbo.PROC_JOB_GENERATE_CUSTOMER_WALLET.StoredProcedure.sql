USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_JOB_GENERATE_CUSTOMER_WALLET]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[PROC_JOB_GENERATE_CUSTOMER_WALLET]
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN


DECLARE @CUSTOMERID BIGINT, @BRANCHIDENTIFIER CHAR(1), @MEMBESHIP_ID VARCHAR(20), @USER VARCHAR(60)

WHILE EXISTS (SELECT TOP 1 1 FROM CUSTOMERMASTER WHERE MEMBERSHIPID IS NULL)
BEGIN
	SELECT TOP 1 @BRANCHIDENTIFIER = LEFT(postalCode, 1), @CUSTOMERID = CUSTOMERID 
	FROM CUSTOMERMASTER (NOLOCK) WHERE MEMBERSHIPID IS NULL
	ORDER BY CUSTOMERID ASC

	SET @USER = CASE @BRANCHIDENTIFIER 
					WHEN '9' THEN 'deepmala'
					WHEN '4' THEN 'shikshya'
					WHEN '7' THEN 'shikshya'
					WHEN '5' THEN 'anu'
					ELSE 'anisha'
				END

	EXEC PROC_GENERATE_MEMBERSHIP_ID @USER = @USER, @CUSTOMERID = @CUSTOMERID, @MEMBESHIP_ID = @MEMBESHIP_ID OUT
	EXEC PROC_CREATE_CUSTOMER_WALLET @CUSTOMER_ID = @CUSTOMERID,  @USER = @USER
	
	UPDATE customerMaster SET MEMBERSHIPID = @MEMBESHIP_ID WHERE CUSTOMERID = @CUSTOMERID
	--SET @CUSTOMERID = @CUSTOMERID + 1
END
END
GO
