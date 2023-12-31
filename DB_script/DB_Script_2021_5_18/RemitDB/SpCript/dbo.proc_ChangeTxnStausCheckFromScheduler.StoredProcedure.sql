USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ChangeTxnStausCheckFromScheduler]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[proc_ChangeTxnStausCheckFromScheduler]
	-- Add the parameters for the stored procedure here
	@flag			VARCHAR(20)		=	NULL,
	@id				BIGINT			=	NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF @flag ='changeStatus'
	BEGIN
		BEGIN TRANSACTION
			UPDATE dbo.remitTran SET tranStatus ='PAID', payStatus ='PAID', paidBy='scheduler',paidDate=GETDATE()
			WHERE id=@id
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Status changed successfully', @id
		RETURN
	END

END
GO
