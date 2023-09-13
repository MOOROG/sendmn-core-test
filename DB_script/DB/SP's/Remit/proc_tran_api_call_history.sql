USE 
FastMoneyPro_Remit
go
-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE proc_tran_api_call_history
	@ROW_ID					BIGINT			=	NULL,
	@TRAN_ID				BIGINT			=	NULL,
	@REQUESTED_DATE			DATETIME		=	NULL,
	@REQUESTED_BY			VARCHAR(100)	=	NULL,	
	@RESPOSE_DATE			DATETIME		=	NULL,	
	@RESPONSE_CODE			VARCHAR(100)	=	NULL,
	@RESPONSE_MSG			VARCHAR(1000)	=	NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY  
	INSERT INTO dbo.TRAN_API_CALL_HISTORY
	        ( 
			  TRAN_ID,
	          REQUESTED_BY,
	          RESPOSE_DATE,
	          RESPONSE_CODE,
	          RESPONSE_MSG
	        )
		VALUES  ( 
				@TRAN_ID,
				@REQUESTED_BY,
				GETDATE(),
				@RESPONSE_CODE,
				@RESPONSE_MSG
	        )
	END TRY  
	BEGIN CATCH  
		
	END CATCH
    -- Insert statements for procedure here
END
GO
		