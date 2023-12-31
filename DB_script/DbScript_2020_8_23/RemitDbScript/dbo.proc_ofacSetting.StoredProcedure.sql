USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ofacSetting]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_ofacSetting]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL	
	,@ofacTracker                       VARCHAR(30)		= NULL
	,@ofacTran							VARCHAR(30)		= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	

	IF @flag='u'
	BEGIN
		--SELECT * FROM OFACSETTING
		UPDATE OFACSETTING SET 
			OFAC_TRACKER=@ofacTracker
			,OFAC_TRAN=@ofacTran
			,MODIFY_BY=@USER
			,MODIFY_DATE=GETDATE()
			
		EXEC proc_errorHandler 0, 'Record updated successfully.', '1'
						
	END	
	IF @flag='a'
	BEGIN
		SELECT * FROM OFACSETTING
						
	END
	

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, '1'
END CATCH



GO
