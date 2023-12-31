USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[PROC_MIGATE_RECEIVER_DATA]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[PROC_MIGATE_RECEIVER_DATA]
(
	  @flag						VARCHAR(50)		=	NULL,
      @user						VARCHAR(40)		=	NULL,
      @receiverId				BIGINT			=	NULL,
      @customerId				BIGINT			=	NULL,
      @firstName				VARCHAR(100)	=	NULL,
      @middleName				VARCHAR(100)	=	NULL,
      @lastName1				VARCHAR(100)	=	NULL,
      @lastName2				VARCHAR(100)	=	NULL,
      @country					VARCHAR(100)	=	NULL,
      @state					VARCHAR(200)	=	NULL,
      @address					VARCHAR(500)	=	NULL,
      @email					VARCHAR(150)	=	NULL,
      @homePhone				VARCHAR(100)	=	NULL,
      @workPhone				VARCHAR(100)	=	NULL,
      @mobile					VARCHAR(100)	=	NULL,
      @zipCode					VARCHAR(50)		=	NULL,
      @city						VARCHAR(100)	=	NULL,
      @relationship				VARCHAR(60)		=	NULL,
      @receiverType				VARCHAR(100)	=	NULL,
      @idType					VARCHAR(100)	=	NULL,
      @idNumber					VARCHAR(25)		=	NULL,
      @paymentMode				VARCHAR(100)	=	NULL,
      @bankLocation				VARCHAR(100)	=	NULL,
      @payOutPartner			VARCHAR(100)	=	NULL,
      @bankName					VARCHAR(150)	=	NULL,
      @receiverAccountNo		VARCHAR(40)		=	NULL,
      @remarks					NVARCHAR(800)	=	NULL,
      @purposeOfRemit			VARCHAR(100)	=	NULL,
	  @otherRelationDesc		VARCHAR(60)		=	NULL,
	  @createdBy                VARCHAR(30)		=	NULL,
	  @createdDate              DATETIME		=	NULL,
	  @modifiedBy               VARCHAR(40)		=	NULL,
	  @modifiedDate             DATETIME		=	NULL
)
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY 
	IF @flag = 'i'
			DECLARE @newCustomerId			BIGINT			=	NULL,
					@newReceiverId			BIGINT			=	NULL,
					@receiverTypeId			INT				=	NULL,
					@idTypeId				INT				=	NULL,
					@paymentModeId			INT				=	NULL,
					@payOutPartnerId		INT				=	NULL,
					@membershipId			VARCHAR(50)		=	NULL
          
		  BEGIN
			
			IF EXISTS(SELECT 1 FROM dbo.receiverInformation WHERE tempRId=@receiverId)
			BEGIN
			      EXEC dbo.proc_errorHandler 1, 'Receiver Information Already Exists On System.', @receiverId 
				RETURN;
			END

			IF @receiverType IS NULL
			BEGIN
			    EXEC dbo.proc_errorHandler 1, 'Receiver Type Is Required', @receiverId 
				RETURN;
			END

			IF @paymentMode IS NULL
			BEGIN
			    EXEC dbo.proc_errorHandler 1, 'Payment Mode Is Required', @receiverId 
				RETURN;
			END

			SELECT @newCustomerId=customerId,@membershipId=membershipId FROM dbo.customerMaster WHERE obpId=@customerId
			IF @newCustomerId IS NULL
			BEGIN
			    EXEC dbo.proc_errorHandler 1, 'No Customer Available', @receiverId 
				RETURN;
			END
			
			SELECT @receiverTypeId = CASE @receiverType
									 WHEN 'I' THEN '4700'
									 WHEN 'B' THEN '4701'
									 ELSE NULL END;

			SELECT @paymentModeId = CASE @paymentMode
									WHEN 'Cash Pay' THEN '1'
									WHEN 'Home Delivery' THEN '12'
									ELSE 2 END;

			SELECT @idTypeId = CASE @idType
							   WHEN 'Passport' THEN '10997'
							   WHEN 'Insurance Card' THEN '8080'
							   WHEN 'Driver License' THEN '8080'
							   WHEN 'Residence Card' THEN '8008'
							   WHEN 'Tohon' THEN '8080'
							   WHEN 'Company Registration No' THEN '10988'
							   ELSE NULL END;

			IF @payOutPartner IS NOT NULL
			BEGIN
			    SELECT @payOutPartnerId=agentId FROM dbo.agentMaster WHERE agentId=@payOutPartner
				IF @payOutPartnerId IS NULL
				BEGIN
				    EXEC dbo.proc_errorHandler 1, 'Payout Partner Not Match', @receiverId 
					RETURN;
				END
			END

			IF @state IS NOT NULL
			BEGIN
			    SELECT @payOutPartnerId=agentId FROM dbo.agentMaster WHERE swiftCode=@payOutPartner
				IF @payOutPartnerId IS NULL
				BEGIN
				    EXEC dbo.proc_errorHandler 1, 'Payout Partner Not Match', @receiverId 
					RETURN;
				END
			END

			INSERT  INTO receiverInformation
                    (
					  membershipId ,customerId ,firstName ,middleName ,lastName1 ,lastName2 ,country,[address] ,[state] ,zipCode ,city ,email ,
                      homePhone ,workPhone ,mobile ,relationship ,receiverType ,idType ,idNumber  ,paymentMode ,bankLocation ,payOutPartner ,
                      bankName ,receiverAccountNo ,remarks ,purposeOfRemit ,createdBy ,createdDate,otherRelationDesc,modifiedBy,modifiedDate,tempRId			
		            )
                    SELECT  @membershipId ,@newCustomerId ,@firstName ,@middleName ,@lastName1 ,@lastName2 ,@country ,@address ,@state ,@zipCode ,@city ,@email ,
                            @homePhone ,@workPhone ,@mobile ,@relationship ,@receiverTypeId ,@idTypeId ,@idNumber ,@paymentModeId ,@bankLocation ,@payOutPartnerId ,
                            @bankName ,@receiverAccountNo ,@remarks ,@purposeOfRemit ,@user ,@createdDate,@otherRelationDesc,@modifiedBy,@modifiedDate,@receiverId;	
			  SET @newReceiverId=SCOPE_IDENTITY();						
              SELECT  '0' errorCode ,'Receiver Successfully added.' msg ,id = @newReceiverId;
              RETURN; 			
          END;
END TRY
BEGIN CATCH  
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;  
    DECLARE @errorMessage VARCHAR(MAX);  
    SET @errorMessage = ERROR_MESSAGE();  
    EXEC proc_errorHandler 1, @errorMessage, null;  
END CATCH
GO
