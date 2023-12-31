USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sendValidation]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_sendValidation]
	 @agentId				INT				= NULL
	,@senIdType				VARCHAR(50)		= NULL
	,@senIdNo				VARCHAR(50)		= NULL
	,@senIdValidDate		VARCHAR(50)		= NULL
	,@senDob				VARCHAR(50)		= NULL
	,@senAddress			VARCHAR(200)	= NULL
	,@senCity				VARCHAR(100)	= NULL
	,@senContact			VARCHAR(100)	= NULL
	,@senOccupation			VARCHAR(100)	= NULL
	,@senCompany			VARCHAR(100)	= NULL
	,@senSalaryRange		VARCHAR(50)		= NULL
	,@purposeOfRemittance	VARCHAR(100)	= NULL
	,@sourceOfFund			VARCHAR(100)	= NULL
	,@recIdType				VARCHAR(50)		= NULL
	,@recIdNo				VARCHAR(50)		= NULL
	,@recPlaceOfIssue		VARCHAR(100)	= NULL
	,@recAddress			VARCHAR(200)	= NULL
	,@recCity				VARCHAR(100)	= NULL
	,@recContact			VARCHAR(100)	= NULL
	,@recRelationship		VARCHAR(100)	= NULL
	,@senNativeCountry		VARCHAR(100)	= NULL
	,@recDob				VARCHAR(50)		= NULL
	,@recIdValidDate		VARCHAR(50)		= NULL
	,@paymentMethod			VARCHAR(50)		= NULL
	,@deliveryMethodId		INT				= NULL
	,@pBank					INT				= NULL
	,@pBankBranchName		VARCHAR(100)	= NULL
	,@accountNo				VARCHAR(50)		= NULL
	,@pAgent				INT				= NULL
	,@pAgentLocation		VARCHAR(200)	= NULL
	,@pBankType				CHAR(1)			= NULL
	,@pCountryId			INT				= NULL
	,@sCountryId			INT				= NULL
	,@checkExpiryDate		CHAR(1)			= NULL

AS

DECLARE @id CHAR(1), @idValidDate CHAR(1), @dob CHAR(1), @address CHAR(1), @city CHAR(1), @contact CHAR(1), @occupation CHAR(1), @company CHAR(1), 
	@salaryRange CHAR(1), @por CHAR(1), @sof CHAR(1), @rId CHAR(1), @rPlaceOfIssue CHAR(1), @rAddress CHAR(1), @rCity CHAR(1), @rContact CHAR(1),
	@rRelationShip CHAR(1), @nativeCountry CHAR(1), @rowId INT

SELECT @rowId = rowId FROM sendPayTable WITH(NOLOCK) WHERE agent = @agentId AND ISNULL(isDeleted, 'N') = 'N'
IF @rowId IS NULL
	SELECT @rowId = rowId FROM sendPayTable WITH(NOLOCK) WHERE country = @sCountryId AND agent IS NULL AND ISNULL(isDeleted, 'N') = 'N'
	
SELECT 
	 @id				= id
	,@idValidDate		= iDValidDate
	,@dob				= dob
	,@address			= address
	,@city				= city
	,@contact			= contact
	,@occupation		= occupation 
	,@company			= company
	,@salaryRange		= salaryRange
	,@por				= purposeofRemittance
	,@sof				= sourceofFund
	,@rId				= rId
	,@rPlaceOfIssue		= rPlaceOfIssue
	,@rAddress			= raddress
	,@rCity				= rcity
	,@rContact			= rContact
	,@rRelationShip		= rRelationShip
	,@nativeCountry		= nativeCountry
FROM sendPayTable spt WITH(NOLOCK) WHERE rowId = @rowId

--SELECT * FROM receiveTranLimit WITH(NOLOCK)
	IF @pBankType = 'I'
	BEGIN
		DECLARE @rtlId INT
		SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK) WHERE agentId = @pBank AND tranType = @deliveryMethodId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		IF @rtlId IS NULL
			SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK) WHERE agentId = @pBank AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		IF @rtlId IS NULL
			SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK) WHERE agentId IS NULL AND countryId = @pCountryId AND tranType = @deliveryMethodId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		IF @rtlId IS NULL
			SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK) WHERE agentId IS NULL AND countryId = @pCountryId AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		
		DECLARE @branchSelection VARCHAR(20), @acLengthFrom INT, @acLengthTo INT, @acNumberType VARCHAR(10)
			
		SELECT
			 @branchSelection			= branchSelection
			,@rId						= ISNULL(benificiaryIdReq, @rId)
			,@rContact					= ISNULL(benificiaryContactReq, @rContact)
			,@acLengthFrom				= ISNULL(acLengthFrom, 0)
			,@acLengthTo				= ISNULL(acLengthTo, 0)
			,@acNumberType				= acNumberType
		FROM receiveTranLimit WITH(NOLOCK)
		WHERE rtlId = @rtlId
	END
	
	ELSE IF @pBankType = 'E'
	BEGIN
		--SELECT * FROM externalBank
		SELECT
			 @branchSelection		= IsBranchSelectionRequired
		FROM externalBank WITH(NOLOCK)
		WHERE extBankId = @pBank
	END
	ELSE
	BEGIN
		SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK) WHERE agentId IS NULL AND countryId = @pCountryId AND tranType = @deliveryMethodId AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
		IF @rtlId IS NULL
			SELECT @rtlId = rtlId FROM receiveTranLimit WITH(NOLOCK) WHERE agentId IS NULL AND countryId = @pCountryId AND tranType IS NULL AND ISNULL(isActive, 'N') = 'Y' AND ISNULL(isDeleted, 'N') = 'N'
			
		SELECT
			 @branchSelection			= branchSelection
			,@rId						= ISNULL(benificiaryIdReq, @rId)
			,@rContact					= ISNULL(benificiaryContactReq, @rContact)
			,@acLengthFrom				= ISNULL(acLengthFrom, 0)
			,@acLengthTo				= ISNULL(acLengthTo, 0)
			,@acNumberType				= acNumberType
		FROM receiveTranLimit WITH(NOLOCK)
		WHERE rtlId = @rtlId
	END

IF @paymentMethod IN ('Bank Deposit', 'Account Deposit to Other Bank')
BEGIN
	IF @pBank IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Bank is missing', NULL
		RETURN
	END
	IF ISNULL(@accountNo, '') = ''
	BEGIN
		EXEC proc_errorHandler 1, 'Account number cannot be blank', NULL
		RETURN
	END
	IF @branchSelection = 'Select' AND ISNULL(@pBankBranchName, '') = ''
	BEGIN
		EXEC proc_errorHandler 1, 'Bank branch is missing', NULL
		RETURN
	END
	/*
	IF LEN(@accountNo) NOT BETWEEN @acLengthFrom AND @acLengthTo
	BEGIN
		EXEC proc_errorHandler 1, 'Account number is not valid', NULL
		RETURN
	END
	IF @acNumberType = 'Numeric' AND ISNUMERIC(@accountNo) = 0
	BEGIN
		EXEC proc_errorHandler 1, 'Account number is not valid', NULL
		RETURN
	END
	*/
END

ELSE IF @paymentMethod IN ('Cash Payment to Other Bank')
BEGIN
	IF @pBank IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Bank is missing', NULL
		RETURN
	END
	IF @pAgent IS NULL
	BEGIN
		EXEC proc_errorHandler 1, 'Please choose route through agent', NULL
		RETURN
	END
END

DECLARE @agentSelection CHAR(1)
SELECT @agentSelection = agentSelection FROM countryReceivingMode WITH(NOLOCK) WHERE countryId = @pCountryId AND receivingMode = @deliveryMethodId
IF @agentSelection = 'M' AND @pBank IS NULL
BEGIN
	EXEC proc_errorHandler 1, 'Payout Agent is missing', NULL
	RETURN
END

IF @id = 'M' AND (ISNULL(@senIdType, '') = '' OR ISNULL(@senIdNo, '') = '')
BEGIN
	EXEC proc_errorHandler 1, 'Sender ID Detail is missing', NULL
	RETURN
END

/*
IF @idValidDate = 'M' AND ISNULL(@senIdValidDate, '') = '' AND @senIdType <> 'NRIC'
BEGIN
	EXEC proc_errorHandler 1, 'Sender ID Expiry Date is missing', NULL
	RETURN
END


IF ISNULL(@checkExpiryDate, 'Y') = 'Y'
BEGIN
	IF DATEDIFF(D, GETDATE(), @senIdValidDate) < 0
	BEGIN
		EXEC proc_errorHandler 1, 'Sender ID is expired', NULL
		RETURN; 
	END
END
*/

IF @dob = 'M' AND ISNULL(@senDob, '') = ''
BEGIN
	EXEC proc_errorHandler 1, 'Sender DOB is missing', NULL
	RETURN
END

IF @senDob IS NOT NULL AND DATEDIFF(YEAR, @senDob, GETDATE()) < 18
BEGIN
	EXEC proc_errorHandler 1, 'DOB Issue : Customer not eligible. Customer must be at least 18 years', NULL
	RETURN
END
	
IF @address = 'M' AND ISNULL(@senAddress, '') = ''
BEGIN
	EXEC proc_errorHandler 1, 'Sender address is missing', NULL
	RETURN
END

IF @city = 'M' AND ISNULL(@senCity, '') = ''
BEGIN
	EXEC proc_errorHandler 1, 'Sender city is missing', NULL
	RETURN
END

IF @contact = 'M' AND ISNULL(@senContact, '') = ''
BEGIN
	EXEC proc_errorHandler 1, 'Sender contact number is missing', NULL
	RETURN
END

/*
IF @occupation = 'M' AND ISNULL(@senOccupation, '') = ''
BEGIN
	EXEC proc_errorHandler 1, 'Sender occupation is missing', NULL
	RETURN
END

IF @rId = 'M' AND (ISNULL(@recIdType, '') = '' OR ISNULL(@recIdNo, '') = '')
BEGIN
	EXEC proc_errorHandler 1, 'Receiver ID detail is missing', NULL
	RETURN
END
*/

IF @rAddress = 'M' AND ISNULL(@recAddress, '') = ''
BEGIN
	EXEC proc_errorHandler 1, 'Receiver address is missing', NULL
	RETURN
END

IF @rCity = 'M' AND ISNULL(@recCity, '') = ''
BEGIN
	EXEC proc_errorHandler 1, 'Receiver city is missing', NULL
	RETURN
END

IF @rContact = 'M' AND ISNULL(@recContact, '') = ''
BEGIN
	EXEC proc_errorHandler 1, 'Receiver contact number is missing', NULL
	RETURN
END

EXEC proc_errorHandler 0, 'Validation Sucessful', NULL


GO
