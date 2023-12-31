USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_txnmigration]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,ANOJ KATTEL>
-- Create date: <2019/3/18>
-- Description:	<Description,This is used for transaction data migration,>
-- =============================================
create PROCEDURE [dbo].[proc_txnmigration]
	-- Add the parameters for the stored procedure here
(
 @flag											VARCHAR(50)
,@user											VARCHAR(50)
,@controlNo										VARCHAR(20)		=	NULL
--------------------------------------------------------------------------------
,@customerId									BIGINT			=	NULL
,@receiverId 									VARCHAR(100)	=	NULL
,@sCurrCostRate									DECIMAL(10,8)	=	NULL
,@sCurrHoMargin									DECIMAL(10,8)	=	NULL
,@sCurrAgentMargin								DECIMAL(10,8)	=	NULL
,@pCurrCostRate									DECIMAL(10,8)	=	NULL
,@pCurrHoMargin									DECIMAL(10,8)	=	NULL
,@pCurrAgentMargin								DECIMAL(10,8)	=	NULL
,@customerRate 									DECIMAL(10,8)	=	NULL		
,@serviceCharge									MONEY			=	NULL
,@sAgentComm									MONEY			=	NULL
,@pAgentComm									MONEY			=	NULL
,@pAgentCommCurrency							CHAR(3)			=	NULL
,@sBranch										INT				=	NULL
,@pCountry										VARCHAR(100)	=	NULL
,@paymentMethod 								VARCHAR(50)		=	NULL
,@pSearchAgent									INT				=	NULL
,@pBankBranch									INT				=	NULL
,@accountNo										VARCHAR(30)		=	NULL
,@collMode										VARCHAR(30)		=	NULL
,@tAmt											MONEY			=	NULL
,@cAmt											MONEY			=	NULL
,@pAmt											MONEY			=	NULL
,@payourCurr									VARCHAR(3)		=	NULL
,@purposeOfRemit								VARCHAR(200)	=	NULL
,@sourceOfFund									VARCHAR(200)	=	NULL
,@tranStatus									VARCHAR(200)	=	NULL
,@payStatus										VARCHAR(200)	=	NULL
,@createdDate									DATETIME		=	NULL
,@createdBy										VARCHAR(50)		=	NULL
,@modifiedDate									DATETIME		=	NULL
,@modifiedBy									VARCHAR(50)		=	NULL
,@approvedDate									DATETIME		=	NULL
,@approvedBy									VARCHAR(50)		=	NULL
,@cancelRequestDate								DATETIME		=	NULL
,@cancelRequestBy								VARCHAR(50)		=	NULL
,@cancelApprovedDate							DATETIME		=	NULL
,@cancelApprovedBy								VARCHAR(50)		=	NULL
,@agentCrossSettRate 							DECIMAL(10,8)	=	NULL		
,@agentFxGain									DECIMAL(10,8)	=	NULL
,@controlNo2									VARCHAR(20)		=	NULL
,@isScManual									CHAR(1)				=	NULL
,@originalSC									MONEY			=	NULL
-------------- Sender Details-------------------------------------------
,@firstName										VARCHAR(100)	=	NULL
,@middleName									VARCHAR(100)	=	NULL
,@lastName										VARCHAR(100)	=	NULL
,@lastName2										VARCHAR(100)	=	NULL
,@state											VARCHAR(100)	=	NULL
,@district										VARCHAR(100)	=	NULL
,@zipCode										VARCHAR(50)		=	NULL
,@city											VARCHAR(100)	=	NULL
,@email											VARCHAR(100)	=	NULL
,@homePhone										VARCHAR(25)		=	NULL
,@mobile										VARCHAR(15)		=	NULL
,@nativeCountry									VARCHAR(100)	=	NULL
,@placeOfIssue 									INT				=	NULL		
,@occupation 									INT				=	NULL		
,@idType										VARCHAR(50)		=	NULL
,@idNumber										VARCHAR(50)		=	NULL
,@issuedDate									DATETIME		=	NULL
,@validDate										DATETIME		=	NULL
,@fullName										VARCHAR(500)	=	NULL		
,@ipAddress										VARCHAR(20)		=	NULL
-----------------------Receiver Details --------------------------------
,@rFirstName									VARCHAR(200)	=	NULL
,@rMiddleName									VARCHAR(50)		=	NULL
,@rLastName										VARCHAR(50)		=	NULL
,@rLastName2									VARCHAR(50)		=	NULL
,@rAddress										VARCHAR(500)	=	NULL
,@rEmail										VARCHAR(150)	=	NULL
,@rMobile										VARCHAR(50)		=	NULL
,@rIdType										VARCHAR(50)		=	NULL
,@rIdNumber										VARCHAR(50)		=	NULL
,@rGender										VARCHAR(10)		=	NULL
,@rFullName										VARCHAR(500)	=	NULL
,@rCountry										VARCHAR(50)		=	NULL	
,@introducer									VARCHAR(100)	=	NULL
,@relWithSender									VARCHAR(50)		=	NULL
)
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--SET @sAgentCommCurrency='JPY';
	--SET @sCountry='Japan';
	--SET @collCurr='JPY';
	--SET @tranType='I';
	--SET @country='Japan'; ---tran sender country
	IF @flag='I'
		BEGIN
				DECLARE @controlNoEncrypted						VARCHAR(20)		=	NULL,
						@id										BIGINT			=	NULL,
						@newCustomerId							BIGINT			=	NULL,
						@newReceiverId							BIGINT			=	NULL,
						@sSuperAgentId 							INT				=	NULL,
						@sAgentId								INT				=	NULL,
						@sBranchId								INT				=	NULL,
						@purposeOfRemitId						INT				=	NULL,
						@sourceOfFundId							INT				=	NULL,
						@tranStatusId							INT				=	NULL,
						@payStatusId							INT				=	NULL,
						@stateId								INT				=	NULL,
						@placeOfIssueId							INT				=	NULL,
						@occupationId							INT				=	NULL,
						@nativeCountryId						INT				=	NULL,
						@idTypeId								INT				=	NULL,
						@relWithSenderId						INT				=	NULL,
						@SAGENTNAME								VARCHAR(100)	=	NULL,
						@SBRANCHCODE							INT				=	NULL,
						@SBRANCHNAME							VARCHAR(100)	=	NULL,
						@SSUPERAGENTNAME						VARCHAR(100)	=	NULL,
						@BranchId								INT				=	NULL,
						@pSearchAgentId							INT				=	NULL,
						@pSuperAgentId							INT				=	NULL,
						@pSuperAgentName						VARCHAR(100)	=	NULL,
						@pAgentId								INT				=	NULL,
						@pAgentName								VARCHAR(100)	=	NULL,
						@pBranchId								INT				=	NULL,
						@pBranchName							VARCHAR(100)	=	NULL,
						@pBankBranchId							INT				=	NULL,
						@pBankId								INT				=	NULL,
						@pBankName								VARCHAR(100)	=	NULL,
						@pBankBranchName						VARCHAR(100)	=	NULL,
						@pBankBranchSid							INT				=	NULL,
						@collectionMode							VARCHAR(100)	=	NULL
						
						
				BEGIN TRANSACTION



				SELECT @purposeOfRemitId = CASE @purposeOfRemit
										   WHEN 'BUSINESS TRAVEL'				THEN '8055'
										   WHEN 'EDUCATIONAL EXPENSES'			THEN '8057'
										   WHEN 'FAMILY MAINTENANCE/SAVINGS'	THEN '8060'
										   WHEN 'INVESTMENT IN REAL ESTATE'		THEN '8066'
										   WHEN 'MEDICAL EXPENSES'				THEN '8058'
										   WHEN 'PERSONAL TRAVELS  EXPENSES'	THEN '8056'
										   WHEN 'REPAYMENT OF LOANS'			THEN '8063'
										   WHEN 'TRADE REMITTANCE'				THEN '11067'
										   WHEN 'GIFT'							THEN '11068'
										   WHEN 'DONATION'						THEN '11069'
										   WHEN 'Advertisement'					THEN '11140'
										   WHEN 'Trading'						THEN '11141'
										   ELSE NULL END;
				
				SELECT @sourceOfFundId = CASE @sourceOfFund
										 WHEN 'Salary'								THEN '3901'
										 WHEN 'Business Income'						THEN '3902'
										 WHEN 'Return from Investment'				THEN '8076'
										 WHEN 'Borrow from others-Loan'				THEN '8079'
										 WHEN 'Others (please specific in remark)'	THEN '11070'
										 WHEN 'Accumulated Salary'					THEN '8073'
										 ELSE NULL END;	
				
				SELECT @tranStatusId = CASE @tranStatus
									   WHEN 'Cancel'			THEN '9917'
									   WHEN 'CancelHOLD'		THEN '11072'
									   WHEN 'Commit-Hold'		THEN '11071'
									   WHEN 'Compliance'		THEN '9918'
									   WHEN 'Hold'				THEN '9919'
									   WHEN 'Payment'			THEN '9921'
									   ELSE NULL END;			

				SELECT @payStatusId = CASE @payStatus
									  WHEN 'Cancel Processing'		THEN '11073'
									  WHEN 'Commit-Hold'			THEN '11074'
									  WHEN 'Compliance'				THEN '11075'
									  WHEN 'Hold'					THEN '11076'
									  WHEN 'OFAC'					THEN '11077'
									  WHEN 'Paid'					THEN '5501'
									  WHEN 'Post'					THEN '5502'
									  WHEN 'Un-Paid'				THEN '5500'
									  ELSE NULL END;

				SELECT  @BRANCHID=agentId FROM dbo.agentMaster WHERE swiftCode =@sBranch;

				SELECT  @SBRANCHID = SBRANCH, @SBRANCHNAME = SBRANCHNAME,
						@SAGENTID = SAGENT, @SAGENTNAME = SAGENTNAME,
						@SSUPERAGENTID = SSUPERAGENT, @SSUPERAGENTNAME = SSUPERAGENTNAME
				FROM DBO.FNAGetBranchFullDetails(@BRANCHID)

				SELECT  @pSearchAgentId=agentId FROM dbo.agentMaster WHERE swiftCode =@pSearchAgentId;

				SELECT  @PBRANCHID = SBRANCH, @PBRANCHNAME = SBRANCHNAME,
						@pAgentId = SAGENT, @pAgentName = SAGENTNAME,
						@SSUPERAGENTID = SSUPERAGENT, @SSUPERAGENTNAME = SSUPERAGENTNAME
				FROM DBO.FNAGetBranchFullDetails(@pSearchAgentId)

				IF @paymentMethod NOT IN('Cash Pay','Home Delivery')
				BEGIN
					SELECT  @pBankBranchSid=agentId FROM dbo.agentMaster WHERE swiftCode =@pBankBranch;
					SELECT  @pBankBranchId = SBRANCH, @pBankBranchName = SBRANCHNAME,
							@pBankId = SAGENT, @pBankName = SAGENTNAME
					FROM DBO.FNAGetBranchFullDetails(@pBankBranchSid)
				END

				----------------------------------------- Sender Details --------------------------------------------
				SELECT @newCustomerId =	customerId FROM dbo.customerMaster WHERE obpId=@customerId;
				IF @newCustomerId IS NULL
				BEGIN
				     EXEC proc_errorHandler 0, 'Customer Details Not Found Please Check Customer Id', NULL
                     RETURN;
				END
				
				SELECT @stateId= stateId FROM dbo.countryStateMaster WHERE countryId=113 and stateName=@state;
				IF @stateId IS NULL
				BEGIN
					EXEC dbo.proc_errorHandler @errorCode = '1',@msg = 'State Name Not Match',@id = '' ;
					RETURN;
				END;

				SELECT @nativeCountryId= countryId FROM dbo.countryMaster WHERE countryName=@nativeCountry;
				
				SELECT @placeOfIssueId= countryId FROM dbo.countryMaster WHERE countryName=@placeOfIssue;

				SELECT @occupationId =  CASE @occupation
										WHEN 'BUSINESS OWNER'							THEN '8080'
										WHEN 'STUDENT'									THEN '8084'
										WHEN 'DEPENDENT'								THEN '4701'
										WHEN 'COMPANY EMPLOYEE'							THEN '4701'
										WHEN 'UNEMPLOYED'								THEN '4701'
										WHEN 'TRAINEE'									THEN '8083'
										WHEN 'Others (please specific in remark)'		THEN '2012'
										WHEN 'Part Time Job Holder'						THEN '4701'
										WHEN 'HOUSE WIFE'								THEN '8085'
										ELSE NULL END;
				
				SELECT @idTypeId = CASE @idType
								   WHEN 'Passport' THEN '10997'
								   WHEN 'Insurance Card' THEN '8080'
								   WHEN 'Driver License' THEN '8080'
								   WHEN 'Residence Card' THEN '8008'
								   WHEN 'Tohon' THEN '8080'
								   WHEN 'Company Registration No' THEN '10988'
								   ELSE NULL END;			
				----------------------------------------- End Sender Details ------------------------------------------
				
				----------------------------------------- Receiver Details --------------------------------------------
				SELECT @newReceiverId =	receiverId FROM dbo.receiverInformation WHERE tempRId=@receiverId;
				IF @newReceiverId IS NULL
				BEGIN
				    EXEC proc_errorHandler 0, 'Receiver Details Not Found Please Check Customer Id', NULL
                    RETURN;
				END
				
				SELECT @relWithSenderId = CASE @relWithSender
										  WHEN 'Parents' THEN '11062'
										  WHEN 'Spouse' THEN '2106'
										  WHEN 'Children' THEN '11063'
										  WHEN 'Brother/ Sister' THEN '11063'
										  WHEN 'Uncle/ Auntie' THEN '11063'
										  WHEN 'Cousin' THEN '11063'
										  WHEN 'Business Partner' THEN '11063'
										  WHEN 'Employer' THEN '11063'
										  WHEN 'Employee' THEN '11063'
										  WHEN 'Friends' THEN '2120'
										  WHEN 'Family' THEN '11063'
										  WHEN 'SELF' THEN '2121'
										  WHEN 'BROTHER' THEN '2109'
										  WHEN 'SISTER' THEN '2111'
										  WHEN 'Air Ticket' THEN '11063'
										  WHEN 'Donee' THEN '11063'
										  WHEN 'father in law' THEN '2107'
										  ELSE 'Other' END;

				----------------------------------------- End Receiver Details ----------------------------------------
				SET @collectionMode = CASE @collMode 
									  WHEN 'Bank Transfer'  THEN 'Bank Deposit'
									  WHEN 'Account Deposit to Other Bank'  THEN 'Bank Deposit'
									  WHEN 'INSTANT BANK DEPOSIT'  THEN 'Bank Deposit'
									  WHEN 'THIRD BANK DEPOSIT'  THEN 'Bank Deposit'
									  WHEN 'THIRD PARTY BANK DEPOSIT'  THEN 'Bank Deposit'
									  WHEN 'Cash Pay'  THEN 'Cash Collect'
									  WHEN 'Home Delivery' THEN 'Home Delivery'
									  ELSE NULL END;

				SET @controlNoEncrypted=dbo.FNAEncryptString(@controlNo)
				SET @rFullName=@rFirstName+ISNULL(' '+@rMiddleName,'')+ISNULL(' '+@rLastName,'')+ISNULL(' '+@rLastName2,'');
				SET @customerRate= (@pCurrCostRate+@pCurrHoMargin+@pCurrAgentMargin)/(@sCurrCostRate+@sCurrHoMargin+@sCurrAgentMargin);
				SET @agentFxGain = (@tAmt) * ((@agentCrossSettRate + @customerRate)/@agentCrossSettRate);

				INSERT INTO remitTranTemp
						(
							controlNo,sCurrCostRate,sCurrHoMargin,sCurrAgentMargin,pCurrCostRate,pCurrHoMargin,pCurrAgentMargin,customerRate,
							serviceCharge,sAgentComm,sAgentCommCurrency,pAgentComm,pAgentCommCurrency,sCountry,sSuperAgent,sSuperAgentName,sAgent,sAgentName,sBranch,
							pCountry,pSuperAgent,pSuperAgentName,pAgent,pAgentName,pBranch,pBranchName,paymentMethod,pBank,pBankName,pBankBranch,
							pBankBranchName,accountNo,collMode,collCurr,tAmt,cAmt,pAmt,payoutCurr,relWithSender,purposeOfRemit,sourceOfFund,tranStatus,
							payStatus,createdDate,createdBy,modifiedDate,modifiedBy,approvedDate,approvedBy,tranType,senderName,receiverName,agentCrossSettRate,
							agentFxGain,controlNo2,isScMaunal,originalSC,promotionCode,cancelApprovedBy,cancelApprovedDate,cancelRequestBy,cancelRequestDate
						)				
						VALUES
						(
							@controlNoEncrypted,@sCurrCostRate,@sCurrHoMargin,@sCurrAgentMargin,@pCurrCostRate,@pCurrHoMargin,@pCurrAgentMargin,@customerRate,
							@serviceCharge,@sAgentComm,'JPY',@pAgentComm,@pAgentCommCurrency,'Japan',@sSuperAgentId,@SSUPERAGENTNAME,@sAgentId,@SAGENTNAME,@sBranch,
							@pCountry,@pSuperAgentId,@pSuperAgentName,@pAgentId,@pAgentName,@pBranchId,@pBranchName,@paymentMethod,@pBankId,@pBankName,@pBankBranchId,
							@pBankBranchName,@accountNo,@collMode,'JPY',@tAmt,@cAmt,@pAmt,@payourCurr,@relWithSenderId,@purposeOfRemitId,@sourceOfFundId,@tranStatusId,
							@payStatusId,@createdDate,@createdBy,@modifiedDate,@modifiedBy,@approvedDate,@approvedBy,'I',@fullName,@rFullName,@agentCrossSettRate,
							@agentFxGain,@controlNo2,CASE WHEN @isScManual = 'Y' THEN 1 ELSE 0 END,@originalSC,@introducer,@cancelApprovedBy,@cancelApprovedDate,@cancelRequestBy,@cancelRequestDate
						)

				SET @id	= SCOPE_IDENTITY()

				INSERT INTO dbo.controlNoList(controlNo)VALUES(@controlNo)

				INSERT INTO dbo.tranSendersTemp
					(
						tranId,customerId,firstName,middleName,lastName1,lastName2,fullName,country,[state],district,zipCode,city,email,
						homePhone,mobile,nativeCountry,placeOfIssue,occupation,idType,idNumber,issuedDate,validDate,ipAddress
					)
					VALUES 
					(
						@id,@customerId,@firstName,@middleName,@lastName,@lastName2,@fullName,'Japan',@stateId,@district,@zipCode,@city,@email,
						@homePhone,@mobile,@nativeCountryId,@placeOfIssueId,@occupationId,@idTypeId,@idNumber,@issuedDate,@validDate,@ipAddress
			        )

				INSERT INTO tranReceiversTemp
					(
						tranId,customerId,firstName,middleName,lastName1,lastName2,fullName,country,[address],email,mobile,idType,idNumber,gender,relationType
					)
					VALUES
					(
						@id,@customerId,@rFirstName,@rMiddleName,@rLastName,@rLastName2,@rFullName,@rCountry,@rAddress,@rEmail,@rMobile,@rIdType,@rIdNumber,@rGender,@relWithSender
					)

				EXEC proc_customerTxnHistory @controlNo = @controlNoEncrypted
				--EXEC proc_ApproveHoldedTXN @flag = 'approve',@user=@user,@id=@id

			IF @@TRANCOUNT>0
			BEGIN
				COMMIT TRANSACTION
				EXEC proc_errorHandler 0, 'Success', null
				RETURN;
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Error', NULL
			END
		END
    -- Insert statements for procedure here
END

GO
