ALTER  PROCEDURE [dbo].[PROC_MIGATE_DEPOSIT_DATA]
(
  @flag						VARCHAR(20)
 ,@user						VARCHAR(30)		
 ,@customerId				BIGINT			=	NULL
 --,@bankId					INT				=	NULL
 ,@tranId					BIGINT			=	NULL
 ,@tranDate					DATETIME		=	NULL
 ,@depositAmount			MONEY			=	NULL
 ,@paymentAmount			MONEY			=	NULL
 ,@particulars				NVARCHAR(500)	=	NULL
 ,@closingBalance			VARCHAR(100)	=	NULL
 ,@isAuto					CHAR(1)			=	NULL
 ,@bankName					VARCHAR(100)	=	NULL
 ,@processedBy				VARCHAR(100)	=	NULL
 ,@processedDate			DATETIME		=	NULL
 ,@isSkipped				CHAR(1)			=	NULL
 ,@skippedBy				VARCHAR(100)	=	NULL
 ,@skippedDate				DATETIME		=	NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	IF @FLAG = 'I'
	DECLARE @newCustomerId BIGINT=NULL
	BEGIN
		SELECT @newCustomerId=customerId FROM dbo.customerMaster WHERE obpId=@customerId;
		
		IF @newCustomerId IS NULL
		BEGIN
			EXEC dbo.proc_errorHandler 1, 'No Customer Available', NULL 
			RETURN;
		END
		
		IF NOT EXISTS (SELECT 1 FROM CUSTOMER_DEPOSIT_LOGS (NOLOCK) WHERE tranId = @tranId AND processedBy IS NULL AND customerId IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'The log you are trying to Map does not exists or already mapped!', null
			RETURN;
		END
		IF NOT EXISTS (SELECT 1 FROM CUSTOMERMASTER (NOLOCK) WHERE customerId = @newCustomerId AND approvedDate IS NOT NULL AND verifiedDate IS NOT NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'The customer you are trying to map does not exists or is not approved yet!', null
			RETURN;
		END

		BEGIN TRANSACTION
			--UPDATE LOG TABLE AS PROCESSED
			UPDATE CUSTOMER_DEPOSIT_LOGS SET processedBy = @user
											,processedDate = GETDATE()
											,customerId = @customerId
			WHERE tranId = @tranId
			
			--INSERT INTO TRANSACTION TABLE(MAP DEPOSIT TXN WITH CUSTOMER)
			INSERT INTO CUSTOMER_TRANSACTIONS (customerId, tranDate, particulars, deposit, withdraw, refereceId, head, createdBy, createdDate )--,bankId)
			SELECT	@customerId, tranDate, particulars, depositAmount, paymentAmount, tranId, 'Customer Deposit', @user, GETDATE() --,@bankId
			FROM CUSTOMER_DEPOSIT_LOGS
			WHERE tranId = @tranId

			SET @tranId = @@IDENTITY

			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION

			EXEC proc_errorHandler 0, 'Data Mapped Successfully!', null

			EXEC SendMnPro_Account.dbo.PROC_DEPOSIT_REFUND_VOUCHER_ENTRY @flag = 'D', @user = 'A', @rowId = @tranId
	END
END TRY
BEGIN CATCH	
	IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     DECLARE @errorMessage VARCHAR(MAX)  
     SET @errorMessage = ERROR_MESSAGE() 
	 SELECT '1' ErrorCode, @errorMessage Msg ,NULL ID
END CATCH

GO
