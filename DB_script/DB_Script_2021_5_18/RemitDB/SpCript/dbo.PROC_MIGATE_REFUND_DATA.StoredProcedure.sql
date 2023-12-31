USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_MIGATE_REFUND_DATA]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Gagan Maharjan>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[PROC_MIGATE_REFUND_DATA] 
   @flag					VARCHAR(20)							
  ,@user					VARCHAR(30)				
  ,@rowId					INT					=		NULL
  ,@customerId				BIGINT				=		NULL
  ,@refundAmount			MONEY				=		NULL	
  ,@refundCharge   			MONEY				=		NULL	
  ,@refundRemarks   		VARCHAR(200)		=		NULL	
  ,@refundChargeRemarks   	VARCHAR(200)		=		NULL	
  ,@createdBy   			VARCHAR(40)			=		NULL	
  ,@createdDate				DATETIME			=		NULL
  ,@approvedBy				VARCHAR(40)			=		NULL
  ,@approvedDate			DATETIME			=		NULL
  ,@isDeleted				BIT					=		NULL
  ,@deletedBy				VARCHAR(40)			=		NULL
  ,@deletedDate				DATETIME			=		NULL
  ,@collMode				VARCHAR(15)			=		NULL
  ,@bankName				VARCHAR(100)		=		NULL

AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY 
	IF @flag = 'i'
		BEGIN
			DECLARE @newCustomerId		BIGINT	=	NULL,
					@bankId				BIGINT	=	NULL

			SELECT @newCustomerId=customerId FROM dbo.customerMaster WHERE obpId=@customerId;
			IF @newCustomerId IS NULL
			BEGIN
				EXEC dbo.proc_errorHandler 1, 'No Customer Available', NULL 
				RETURN
			END

			SELECT @bankId=valueId FROM dbo.staticDataValue WHERE typeID=7010 AND detailTitle=@bankName;
			IF @newCustomerId IS NULL
			BEGIN
				EXEC dbo.proc_errorHandler 1, 'Bank Name Not Available', NULL 
				RETURN
			END
			
			INSERT INTO dbo.CUSTOMER_REFUND(
							customerId,refundAmount,refundCharge,refundRemarks,refundChargeRemarks,createdBy,createdDate,
							approvedBy,approvedDate,isDeleted,deletedBy,deletedDate,collMode,bankId
						)
						VALUES(
							@newCustomerId,@refundAmount,@refundCharge,@refundRemarks,@refundChargeRemarks,@createdBy,@createdDate,
							@approvedBy,@approvedDate,CASE WHEN @isDeleted='Y' THEN 1 ELSE 0 END,@deletedBy,@deletedDate,@collMode,@bankId
						)

			EXEC dbo.proc_errorHandler '0', 'Customer Refund saved successfully', NULL 
			RETURN;
		END;
END TRY 
BEGIN CATCH
	IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;  
	DECLARE @errorMessage VARCHAR(MAX);  
    SET @errorMessage = ERROR_MESSAGE();  
    EXEC proc_errorHandler 1, @errorMessage, NULL;   
END CATCH;
GO
