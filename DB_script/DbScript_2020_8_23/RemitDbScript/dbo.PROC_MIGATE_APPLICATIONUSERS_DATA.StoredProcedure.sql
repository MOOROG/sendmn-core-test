USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_MIGATE_APPLICATIONUSERS_DATA]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,Anoj Kattel>
-- Create date: <Create Date,2019/03/21>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[PROC_MIGATE_APPLICATIONUSERS_DATA]
(
  	@userName					VARCHAR(30)		=	NULL
   ,@firstName					VARCHAR(100)	=	NULL
   ,@middleName					VARCHAR(100)	=	NULL
   ,@lastName					VARCHAR(100)	=	NULL
   ,@salutation					VARCHAR(10)		=	NULL
   ,@gender						VARCHAR(10)		=	NULL
   ,@telephoneNo				VARCHAR(15)		=	NULL
   ,@address					VARCHAR(50)		=	NULL
   ,@countryName				VARCHAR(100)	=	NULL
   ,@state						VARCHAR(50)		=	NULL
   ,@mobileNo					VARCHAR(15)		=	NULL
   ,@email						VARCHAR(255)	=	NULL
   ,@isActive					CHAR(1) 		=	NULL
   ,@isLocked					CHAR(1) 		=	NULL
   ,@sessionTimeOutPeriod		INT				=	NULL
   ,@userAccessLevel			CHAR(1)			=	NULL
   ,@createdBy					VARCHAR(30)		=	NULL
   ,@createdDate				VARCHAR(15)		=	NULL
   ,@modifiedBy					VARCHAR(30)		=	NULL
   ,@modifiedDate				VARCHAR(15)		=	NULL
   ,@approvedBy					VARCHAR(30)		=	NULL
   ,@approvedDate				DATETIME		=	NULL
   ,@userType					VARCHAR(2)		=	NULL
   ,@oldSystemRowId				INT				=	NULL
   ,@countryId					INT				=	NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY 
		DECLARE @stateId  VARCHAR(10),@genderId VARCHAR(10),@agentCode VARCHAR(50),@salutationValueId VARCHAR(6),@agentId VARCHAR(50)
		
		IF @salutation IS NOT NULL
		BEGIN
			SELECT @salutationValueId=valueId FROM dbo.staticDataValue WHERE typeID = 1700 AND detailTitle = @salutation
			IF @salutationValueId IS NULL
			BEGIN
				EXEC dbo.proc_errorHandler @errorCode = '1',@msg = 'Salutation value not matched',@id = '';
				RETURN;
			END 
		END

		IF @state IS NOT NULL
		BEGIN
			SELECT @stateId= stateId FROM dbo.countryStateMaster WHERE countryId=113 and stateName=@state;
			IF @stateId IS NULL
			BEGIN
				EXEC dbo.proc_errorHandler @errorCode = '1',@msg = 'State Name Not Match',@id = '';
				RETURN;
			END
		END

		IF @gender IS NOT NULL
		BEGIN
			SELECT @genderId=valueId FROM dbo.staticdataVALUE WHERE typeID = 4 AND detailTitle = @gender
			IF  @genderId IS NULL 
			BEGIN
				EXEC dbo.proc_errorHandler @errorCode = '1',@msg = 'Gender not found',@id = ''; 
			END 
		END
		
		IF @countryName IS NOT NULL
		BEGIN
			SELECT @countryId= countryId FROM dbo.countryMaster WHERE countryName=@countryName;
			IF @countryId IS NULL
			BEGIN
				EXEC dbo.proc_errorHandler @errorCode = '1',@msg = 'Country Name Not Match',@id = '';
				RETURN;
			END
		END

		DECLARE @pwd VARCHAR(50)
		SET @pwd = DBO.FNAENCRYPTSTRING(@userName+'@jme@123')

		IF @userType='HO'
		BEGIN
		    SET @agentId='1001';
		END
		ELSE
		BEGIN
			SELECT @agentId = AGENTID, @agentCode=agentCode FROM agentMaster (NOLOCK) WHERE swiftCode = @oldSystemRowId
		END
			
		INSERT INTO dbo.applicationUsers
		( 
			userName,agentCode,firstName,middleName,lastName,salutation,gender,countryId,state,address,
			telephoneNo,mobileNo,email,pwd,agentId,sessionTimeOutPeriod,loginTime,logoutTime,
			userAccessLevel,fromSendTrnTime,toSendTrnTime,fromPayTrnTime,toPayTrnTime,
			isActive,
			isDeleted,
			isLocked,
			createdBy,createdDate,modifiedBy,modifiedDate,approvedBy,approvedDate,pwdChangeDays,
			pwdChangeWarningDays,lastPwdChangedOn,forceChangePwd,maxReportViewDays,employeeId,
			userType
		)
		VALUES
		(
			@userName,@agentCode,@firstName,@middleName,@lastName,@salutationValueId,@genderId,@countryId,@stateId,@address,
			@telephoneNo,@mobileNo,@email,@pwd,@agentId,ISNULL(@sessionTimeOutPeriod, 10),'00:00:00','00:00:00',
			@userAccessLevel,'00:00:00','00:00:00','00:00:00','00:00:00',
			@isActive,
			'N',
			@isLocked,
			@createdBy,@createdDate,@modifiedBy,@modifiedDate,@approvedBy,@approvedDate,30,
			20,NULL,'Y',60,@agentId,
			@userType
		)

		EXEC dbo.proc_errorHandler 1, 'User Information Added.', @oldSystemRowId 
		RETURN;
END TRY
BEGIN CATCH  
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;  
    DECLARE @errorMessage VARCHAR(MAX);  
    SET @errorMessage = ERROR_MESSAGE();  
    EXEC proc_errorHandler 1, @errorMessage, NULL;  
END CATCH; 

GO
