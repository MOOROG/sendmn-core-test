USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_MIGATE_DOCUMENT_DATA]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Gagan>
-- Create date: <3/19/2019,,>
-- Description:	<Migrate KYC Data,,>
-- =============================================
create PROCEDURE  [dbo].[PROC_MIGATE_DOCUMENT_DATA]
	 @flag 					 VARCHAR(50)
	,@user					 VARCHAR(130)
	,@customerId			 INT			=		NULL
	,@fileName				 VARCHAR(50)	=		NULL
	,@fileDescription	     VARCHAR(200)	=		NULL
	,@fileType				 VARCHAR(100)	=		NULL
	,@isDeleted				 CHAR(1)		=		NULL
	,@createdBy				 VARCHAR(50)	=		NULL
	,@createdDate			 DATETIME		=		NULL
	,@modifiedBy			 VARCHAR(50)	=		NULL
	,@modifiedDate			 DATETIME	 	=		NULL
	,@approvedBy			 VARCHAR(50)	=		NULL
	,@approvedDate		     DATETIME		=		NULL
	,@documentType			 INT			=		NULL
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	IF @flag = 'I'
		BEGIN
			DECLARE @newCustomerId		BIGINT	=	NULL,
					@documentTypeId		INT		=	NULL

			SELECT @newCustomerId=customerId FROM dbo.customerMaster WHERE obpId=@customerId
			IF @newCustomerId IS NULL
			BEGIN
			    EXEC dbo.proc_errorHandler 1, 'No Customer Available', NULL 
				RETURN;
			END

			SELECT @documentTypeId=valueId FROM dbo.staticDataValue WHERE typeID=7009 AND detailTitle=@documentType
			IF @documentTypeId IS NULL
			BEGIN
				INSERT INTO dbo.staticDataValue(typeID,detailTitle,detailDesc,createdDate,createdBy,modifiedDate,modifiedBy,isActive,IS_DELETE)
				VALUES  (7009 ,@documentType, @documentType ,GETDATE(),@user,GETDATE(),@user,'Y','N')
				SET @documentTypeId=SCOPE_IDENTITY();
			END
					
			INSERT INTO dbo.customerDocument(
						customerId,[fileName],fileDescription,fileType,isDeleted,createdBy,createdDate,modifiedBy,modifiedDate,
						approvedBy,approvedDate,agentId,branchId,isProfilePic,isKycDoc,isOnlineDoc,
						documentFolder,sessionId,documentType,archivedBy,archivedDate
			        )
					VALUES(
						@newCustomerId,@fileName,@fileDescription,@fileType,@isDeleted,@createdBy,@createdDate,@modifiedBy,@modifiedDate,
						@approvedBy,@approvedDate,NULL,NULL,NULL,NULL,NULL,
						NULL,NULL,@documentTypeId,NULL,NULL
			        )

			SELECT  '0' errorCode ,'Customer Document Successfully added.' msg ,id = @customerId;
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
