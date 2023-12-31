USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_proc_VirtualAccountDepositNotification]    Script Date: 8/23/2020 5:48:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[ws_proc_VirtualAccountDepositNotification]
(
@RequestJSon	Nvarchar(500),
@rowId			int = null,
@flag			char(1),
@methodName		VARCHAR(50) = NULL
)

AS 
SET NOCOUNT ON 
SET XACT_ABORT ON

----ADDED COLUMN METHOD NAME 
--ALTER TABLE apiRequstLogVaccountDeposit ADD MethodName VARCHAR(50) 

BEGIN TRY
if @flag='i'
begin
BEGIN TRANSACTION
	INSERT INTO apiRequstLogVaccountDeposit(RequestJSon,logDate,MethodName) 
	values(@RequestJSon,GETDATE(),@methodName)	
	set @rowId = @@IDENTITY
	IF @@TRANCOUNT > 0						 					
COMMIT TRANSACTION		
	select 0 as code , 'Record saved successfully' message 	,@rowId id	
end	 
else if @flag='u'
begin
	update apiRequstLogVaccountDeposit set ResponseMsg=@RequestJSon where id = @rowId
end  
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRAN
	SELECT '9001' code , 'Technical Error : ' + ERROR_MESSAGE() message,null id
END CATCH

GO
