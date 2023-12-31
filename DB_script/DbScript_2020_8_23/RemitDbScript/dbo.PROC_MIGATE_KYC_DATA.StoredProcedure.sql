USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_MIGATE_KYC_DATA]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,Gagan>
-- Create date: <Date,3/19/2019>
-- Description:	<Migrate KYC Data,,>
-- =============================================
create PROCEDURE  [dbo].[PROC_MIGATE_KYC_DATA]
	 @flag 	          VARCHAR(50)
	,@user			  VARCHAR(130)
	,@customerId	  INT				 =		NULL
	,@kycMethod       VARCHAR(100)		 =		NULL
	,@kycStatus       VARCHAR(100)		 =		NULL
	,@deletedDate     DATETIME			 =		NULL
	,@deletedBy       VARCHAR(30)		 =		NULL
	,@isDeleted       CHAR(1)				 =		NULL
	,@modifiedDate    DATETIME			 =		NULL
	,@createdBy		  VARCHAR(50)		 =		NULL
	,@createdDate     DATETIME			 =		NULL
	,@modifiedBy	  VARCHAR(50)		 =		NULL
	,@remarks         NVARCHAR(800)		 =		NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	IF @flag = 'I'
		DECLARE @newCustomerId BIGINT=NULL,@kycMethodId INT =NULL,@kycStatusId INT =NULL; 
		BEGIN
			SELECT @newCustomerId=customerId FROM dbo.customerMaster WHERE obpId=@customerId;
			IF @newCustomerId IS NULL
			BEGIN
			    EXEC dbo.proc_errorHandler @errorCode = '1',@msg =  'No Customer Available',@id = '' ;
				RETURN;
			END
			---not map
			SELECT @kycStatusId = CASE @kycStatus 
								  WHEN 'KYC Completed' THEN '11044'
								  WHEN 'KYC Processing' THEN '11045'
								  WHEN 'KYC Rejected' THEN '11046'
								  WHEN 'Documents Sent' THEN '11047'
								  ELSE NULL
								  END

			SELECT @kycMethodId = CASE @kycMethod 
								  WHEN 'Counter Visit' THEN '11048'
								  WHEN 'Staff Visit' THEN '11049'
								  WHEN 'By Postal Service' THEN '11050'
								  WHEN 'By Event' THEN '11051'
								  WHEN 'BY YOMATA' THEN '11052'
								  WHEN 'Net / Post' THEN '11053'
								  ELSE NULL
								  END
												
			INSERT INTO dbo.TBL_CUSTOMER_KYC(
						customerId,kycMethod,kycStatus,remarks,createdBy,createdDate,
						modifiedBy,modifiedDate,isDeleted,deletedBy,deletedDate
			        )
					VALUES(
						@customerId,@kycMethod,@kycStatus,@remarks,@createdBy,@createdDate,
						@modifiedBy,@modifiedDate,CASE WHEN @isDeleted='Y' THEN 1 ELSE 0 END,@deletedBy,@deletedDate	
			       )
		
		SELECT  '0' errorCode ,'KYC Data Successfully added.' msg ,id = @customerId;
        RETURN;
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
