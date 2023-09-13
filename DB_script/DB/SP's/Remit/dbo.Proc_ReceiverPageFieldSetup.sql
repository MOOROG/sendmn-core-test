SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER pROCEDURE [dbo].[Proc_ReceiverPageFieldSetup] 
   @flag				VARCHAR(15)  
  ,@PcountryId			VARCHAR (3)		=	NULL
  ,@PaymentMethodId		VARCHAR (3)		=	NULL
  ,@xml					NVARCHAR(MAX)	=	NULL 
  ,@user				VARCHAR(50)		=	NULL
 AS 
 SET NOCOUNT ON
IF @flag ='servicetype'
	BEGIN
		SELECT valueField=0,textField='All'
		UNION 
		SELECT valueField =serviceTypeId,textField =typeTitle FROM serviceTypeMaster(NOLOCK)
		WHERE isActive='Y' ORDER BY valueField
		RETURN
	END
IF @flag = 'countryPay'  
	BEGIN  
		SELECT countryId='0',countryName='All'
		UNION 
		SELECT 	countryId, countryName  FROM countryMaster  (NOLOCK) 
			 WHERE ISNULL(isOperativeCountry,'') = 'Y'  
			 AND ISNULL(operationType,'B') IN ('B','R')   
			 ORDER BY countryId ASC   
			 RETURN  
	END 
IF @flag = 'getdata' 
	BEGIN
		SELECT  field,	fieldRequired,	minfieldlength=isnull(minfieldlength,0),maxfieldlength=isnull(maxfieldlength,0),
				KeyWord =isnull(KeyWord, 'N')FROM  receiverFieldSetup(NOLOCK)	
		WHERE pCountry=@PcountryId AND PaymentMethodId=@PaymentMethodId
		RETURN
	END
IF @flag ='d'
	BEGIN
		IF EXISTS (SELECT 1   FROM receiverFieldSetup(NOLOCK) WHERE pCountry=@PcountryId AND paymentMethodId=@PaymentMethodId)
		BEGIN 
			DELETE FROM receiverFieldSetup WHERE pCountry=@PcountryId AND paymentMethodId=@PaymentMethodId
			EXEC proc_errorHandler 0, 'Record delete Successfully.', ''
		END
		ELSE 
		BEGIN
			EXEC proc_errorHandler 1, 'Failed to delete record.', ''
			END 
		RETURN
	END
IF @flag = 'U'
	BEGIN 
		DECLARE @xmlData XML
		SET @xmlData = CAST(@xml AS XML)
		IF  EXISTS (SELECT 1 FROM receiverFieldSetup(NOLOCK) WHERE paymentMethodId=@PaymentMethodId AND pCountry=@PcountryId)
		BEGIN
		BEGIN TRY
		BEGIN TRANSACTION
			UPDATE  dbo.receiverFieldSetup
			SET 
			fieldrequired =  XCol.value('(fieldRequired)[1]','varchar(25)'),
			minfieldlength = XCol.value('(minFieldlength)[1]','varchar(3)'),
			maxfieldlength = XCol.value('(maxFieldlength)[1]','varchar(3)'),
			KeyWord =XCol.value('(KeyWord)[1]','varchar(3)'),
			pCountry=@PcountryId,paymentMethodId= @PaymentMethodId, modifiedBy=@user, modifiedDate= GETDATE()
			FROM  @xmlData.nodes('/ArrayOfFieldsetting/Fieldsetting') AS XTbl(XCol)
				WHERE pCountry=@PcountryId AND paymentMethodId=@PaymentMethodId AND field=XCol.value('(field)[1]','varchar(25)')


				UPDATE receiverFieldSetup SET minfieldLength=-1,maxfieldLength=-1, isDropDown=1
				 WHERE field IN('Native Country','Province','District','Realation Group','Id Type','Transfer Reason', 'Bank Name','Branch Name')

		COMMIT 
		EXEC proc_errorHandler 0, 'Record Update Successfully ', ''
		END TRY
		BEGIN CATCH
		IF @@TRANCOUNT > 0
		ROLLBACK
		EXEC proc_errorHandler 1, 'Failed to update record.', ''
		END CATCH
		RETURN
	END
	ELSE 
	BEGIN
	BEGIN TRY	
	BEGIN TRAN 
		INSERT INTO dbo.receiverFieldSetup(field, fieldrequired,minfieldLength,maxfieldLength,KeyWord,pCountry,paymentMethodId,createdBy,createdDate)
		SELECT
		field = XCol.value('(field)[1]','varchar(25)'),
		fieldrequired =  XCol.value('(fieldRequired)[1]','varchar(1)'),
		minfieldLength = XCol.value('(minFieldlength)[1]','varchar(3)'),
		maxfieldLength =  XCol.value('(maxFieldlength)[1]','varchar(3)'),
		KeyWord =  XCol.value('(KeyWord)[1]','varchar(3)'),
		@PcountryId,@PaymentMethodId,@user,GETDATE()
		FROM  @xmlData.nodes('/ArrayOfFieldsetting/Fieldsetting') AS XTbl(XCol) 
		
		
			UPDATE receiverFieldSetup SET minfieldLength=-1,maxfieldLength=-1, isDropDown=1
			 WHERE field IN('Native Country','Province','District','Realation Group','Id Type','Transfer Reason', 'Bank Name','Branch Name')
  
	COMMIT 
		EXEC proc_errorHandler 0, 'Record save Successfully ', ''
		END TRY
	BEGIN CATCH
	IF @@TRANCOUNT > 0
    ROLLBACK
	EXEC proc_errorHandler 1, 'Failed to save record.', ''
	END CATCH
	RETURN
	END
END

GO

