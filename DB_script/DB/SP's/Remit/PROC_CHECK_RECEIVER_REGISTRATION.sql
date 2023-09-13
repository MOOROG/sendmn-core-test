USE FastMoneyPro_Remit
go

ALTER PROC PROC_CHECK_RECEIVER_REGISTRATION
(
	@flag					VARCHAR(20)
	,@user					VARCHAR(70) = NULL
	,@receiverName			VARCHAR(150)= NULL
	,@receiverIdNo			VARCHAR(20)	= NULL
	,@receiverIdType		VARCHAR(50)	= NULL
	,@receiverCountry		VARCHAR(30)	= NULL
	,@receiverAdd			VARCHAR(500)= NULL
	,@receiverCity			VARCHAR(150)= NULL
	,@receiverMobile		VARCHAR(20) = NULL
	,@receiverPhone			VARCHAR(20) = NULL
	,@receiverEmail			VARCHAR(150)= NULL
	,@receiverDOB			DATETIME    = NULL
	,@receiverGender		VARCHAR(30) = NULL
	,@receiverIdValidDate	DATETIME    = NULL
	,@receiverId			BIGINT		= NULL	OUT
	,@customerId			BIGINT		= NULL
	,@rfName				VARCHAR(100)	= NULL
	,@rmName				VARCHAR(100)	= NULL
	,@rlName				VARCHAR(100)	= NULL
	,@rlName2				VARCHAR(100)	= NULL
	,@rBankId				INT				=NULL
	,@paymentMethodId		INT				=NULL
	,@rAccountNo			VARCHAR(30)		=NULL
	,@fromTxnAmend			BIT				= NULL
	,@purpose				VARCHAR(100)	= NULL
	,@relationship			VARCHAR(100)	= NULL
	,@rBankBranchId			INT				= NULL
	,@loginBranchId		INT				= NULL
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	BEGIN
		IF @flag = 'i'
		BEGIN
			DECLARE @idTypeId INT, @isExist BIT = 0,@fullname varchar(500)

			
			DECLARE @PURPOSEID INT = NULL, @RELATION INT = NULL

			SELECT @PURPOSEID = valueId
			FROM STATICDATAVALUE (NOLOCK)
			WHERE detailTitle = @purpose
			AND typeID = '3800'

			IF @PURPOSEID IS NULL
				SET @PURPOSEID = @purpose

			SELECT @RELATION = valueId
			FROM STATICDATAVALUE (NOLOCK)
			WHERE detailTitle = @relationship
			AND typeID = '2100'

			IF @RELATION IS NULL
				SET @RELATION = @relationship


			SELECT @idTypeId = VALUEID FROM STATICDATAVALUE (NOLOCK) WHERE DETAILTITLE = @receiverIdType
			IF @fromTxnAmend IS NULL 
				SET @fromTxnAmend = 0

			IF @fromTxnAmend = 0
			BEGIN
				IF ISNULL(@receiverId,0)<>0
				BEGIN
				    SET @isExist=1
				END 
				ELSE
				BEGIN
					IF EXISTS(SELECT 1 FROM receiverInformation (NOLOCK) WHERE idNumber = @receiverIdNo AND idType = @idTypeId AND CUSTOMERID = @customerId AND ISNULL(ISDELETED,'0') <> '1')
					BEGIN
						SELECT @receiverId = receiverId FROM receiverInformation(NOLOCK) WHERE idNumber = @receiverIdNo AND idType = @idTypeId AND CUSTOMERID = @customerId 
						SET @isExist = 1
					END
					IF EXISTS(SELECT 1 FROM receiverInformation (NOLOCK) WHERE email = @receiverEmail AND CUSTOMERID = @customerId AND ISNULL(ISDELETED,'0') <> '1')
					BEGIN
						SELECT @receiverId = receiverId FROM receiverInformation (NOLOCK) WHERE email = @receiverEmail AND CUSTOMERID = @customerId
						SET @isExist = 1
					END
					IF EXISTS(SELECT 1 FROM receiverInformation (NOLOCK) WHERE firstName = @rfName
										AND ISNULL(middleName,'') = ISNULL(@rmName,'')
										AND ISNULL(lastName1,'') = ISNULL(@rlName,'')
										AND ISNULL(lastName2,'') = ISNULL(@rlName2,'')
										AND CUSTOMERID = @customerId
										AND ISNULL(ISDELETED,'0') <> '1')
					BEGIN
						SELECT @receiverId = receiverId FROM receiverInformation (NOLOCK) WHERE firstName = @rfName AND middleName = @rmName AND lastName1 = @rlName AND lastName2 = @rlName2 AND CUSTOMERID = @customerId
						SET @isExist = 1
					END

					DECLARE @newMobileNumber VARCHAR(20) = REPLACE(@receiverMobile, '+', '')
					SET @newMobileNumber = CASE WHEN @newMobileNumber LIKE '81%' THEN STUFF(@newMobileNumber, 1, 2, '') ELSE @newMobileNumber END
					SET @newMobileNumber = '%' + @newMobileNumber

					IF EXISTS(SELECT 1 FROM receiverInformation (NOLOCK) WHERE isnull(firstName,'') = isnull(@rfName,'')
									AND ISNULL(middleName,'') = ISNULL(@rmName,'')
									AND ISNULL(lastName1,'') = ISNULL(@rlName,'')
									AND ISNULL(lastName2,'') =ISNULL(@rlName2,'')
									AND ISNULL(mobile,'') LIKE @newMobileNumber
									AND CUSTOMERID = @customerId AND ISNULL(ISDELETED,'0') <> '1')
					BEGIN
						SELECT @receiverId = receiverId FROM receiverInformation (NOLOCK) WHERE firstName = @rfName AND middleName = @rmName AND lastName1 = @rlName AND lastName2 = @rlName2 AND mobile LIKE @newMobileNumber AND CUSTOMERID = @customerId
						SET @isExist = 1
					END
				END
			END
			set @fullname = ISNULL(@rfName,'') + ISNULL(' ' + @rmName,'') + ISNULL(' ' + @rlName,'') + ISNULL(' ' + @rlName2,'')
			
			IF @isExist = 0 OR @fromTxnAmend = 1 
			BEGIN
				INSERT  INTO receiverInformation
                ( customerId ,firstName ,middleName ,lastName1,lastName2 ,country ,address ,
                    city ,email ,homePhone ,mobile ,idType ,idNumber  ,
					createdBy , createdDate, paymentMode, payOutPartner,receiverAccountNo,fullname,agentId	
		        )
				SELECT    
					 @customerId, @rfName, @rmName, @rlName,@rlName2, @receiverCountry, @receiverAdd
					,@receiverCity, @receiverEmail, @receiverPhone, @receiverMobile, @idTypeId ,@receiverIdNo
					,@user, GETDATE(), @paymentMethodId, @rBankId, @rAccountNo,@fullname,@loginBranchId
				
				SET @receiverId = SCOPE_IDENTITY()  
				RETURN;
			END
			ELSE
			BEGIN
			
				EXEC PROC_RECEIVERMODIFYLOGS    @flag = 'edit-fromSendPage'		
												,@user = @user	
												,@receiverId = @receiverId		
												,@customerId = @customerId
												,@address = @receiverAdd
												,@mobile = @receiverMobile
												,@country = @receiverCountry
												,@paymentMode = @paymentMethodId
												,@payOutPartner = @rBankId
												,@bankLocation	=	@rBankBranchId
												,@receiverAccountNo = @rAccountNo
												,@purposeOfRemit =	@PURPOSEID
												,@relationship =@RELATION
													
				UPDATE dbo.receiverInformation SET address = @receiverAdd
												   ,mobile = @receiverMobile
												   ,country= @receiverCountry
												   ,paymentMode = @paymentMethodId
												   ,payOutPartner = @rBankId
												   ,bankLocation = @rBankBranchId
												   ,receiverAccountNo  = @rAccountNo
												   ,purposeofremit =	@PURPOSEID
												   ,relationship =@RELATION
										WHERE receiverId = @receiverId
					
			END
		END
	END
END TRY
    BEGIN CATCH
        IF @@TRANCOUNT <> 0
            ROLLBACK TRANSACTION;
		
        DECLARE @errorMessage VARCHAR(MAX);
        SET @errorMessage = ERROR_MESSAGE();
		SET @receiverId = '0000'

        EXEC proc_errorHandler 1, @errorMessage, @user;
END CATCH;




