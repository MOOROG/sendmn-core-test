USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_modifyTXNEduPay]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
  EXEC [proc_modifyTXN]  @flag = 'u', @user = 'admin', @tranId = '2', 
@fieldName = 'senderName', @oldValue = 'Shiva Khanal', @newTxtValue = null, 
@newDdlValue = null, @firstName = 'Bijay', @middleName = null, @lastName1 = 'Shahi', @lastName2 = null

*/
CREATE proc [dbo].[proc_modifyTXNEduPay]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@tranId							INT				= NULL
	,@fieldName							VARCHAR(200)	= NULL
	,@oldValue							VARCHAR(200)	= NULL
	,@newTxtValue						VARCHAR(200)	= NULL
	,@newDdlValue						VARCHAR(200)	= NULL
	,@firstName							VARCHAR(200)	= NULL
	,@middleName						VARCHAR(200)	= NULL
	,@lastName1							VARCHAR(200)	= NULL
	,@lastName2							VARCHAR(200)	= NULL
	,@contactNo							VARCHAR(200)	= NULL
	,@bankNewName						VARCHAR(100)    = NULL
	,@branchNewName						VARCHAR(100)	= NULL
	,@isAPI								CHAR(1)			= NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE @controlNo varchar(30), @message VARCHAR(100), @agentRefId VARCHAR(15)
	
	SET @agentRefId = '1' + LEFT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(10)) + '000000000', 8)
		
	SELECT @controlNo = dbo.FNADecryptString(controlNo) FROM remitTran WITH(NOLOCK) WHERE id = @tranId
	
	IF @flag='u'
	BEGIN
		IF @fieldName='senderName'	
		BEGIN
			if @firstName is null or @lastName1 is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid first name and first last name!', @tranId
				return
			end
			update tranSenders	SET
				 firstName = @firstName
				,middleName = @middleName
				,lastName1 = @lastName1
				,lastName2 = @lastName2
			WHERE tranId = @tranId
			
			SET @message = 'Sender Name:'+ ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' +@lastName2, '')
			insert into  tranModifyLog (tranId,message,createdBy,createdDate,MsgType)
			select @tranId, @message, @user,dbo.FNAGetDateInNepalTZ(),'M'
		end
		
		ELSE IF @fieldName='receiverName'
		BEGIN
			if @firstName is null or @lastName1 is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid first name and first last name!' , @tranId
				return
			end
			update tranReceivers SET
				 firstName = @firstName
				,middleName = @middleName
				,lastName1 = @lastName1
				,lastName2 = @lastName2
			WHERE tranId = @tranId
			
			SET @message = 'Receiver Name:' + ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@firstName, '') + ISNULL(' ' + @middleName, '') + ISNULL(' ' + @lastName1, '') + ISNULL(' ' + @lastName2, '')
			insert into  tranModifyLog   (tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'
		end
		
		ELSE IF @fieldName='sIdType'
		BEGIN
			if @newDdlValue is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid id type!', @tranId
				return
			end			
			update tranSenders SET
				 idType = @newDdlValue
			WHERE tranId = @tranId
			
			SET @message = 'Sender Id Type:' + ISNULL(@oldValue, '') + ' has been changed to ' + ISNULL(@newDdlValue, '')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'
		end
	
		ELSE IF @fieldName='rAddress'
		BEGIN
			if @newTxtValue is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid address!', @tranId
				return
			end	
		   update tranReceivers SET
				 address = @newTxtValue
			WHERE tranId = @tranId
			
			SET @message = 'Receiver Address:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')
			INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			SELECT @tranId, @message, @user, dbo.FNAGetDateInNepalTZ(), 'M'
		END
		
		ELSE IF @fieldName='sAddress'
		BEGIN
			if @newTxtValue is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid address!', @tranId
				return
			end	
		   update tranSenders SET
				 address = @newTxtValue
			WHERE tranId = @tranId
			
			SET @message = 'Sender Address:' + ISNULL(@oldValue,'') + ' has been changed to ' + ISNULL(@newTxtValue, '') 
			INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M' 
		end
		
		ELSE IF @fieldName='sContactNo'
		BEGIN
			if @contactNo is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid contact number!', @tranId
				return
			end	
		   update tranSenders SET
				 mobile = @contactNo
			WHERE tranId = @tranId 
			
			SET @message = 'Sender Contact No:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@contactNo,'')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M' 
		end
		
		ELSE IF @fieldName='rContactNo'
		BEGIN
			if @contactNo is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid contact number!', @tranId
				return
			end	
		   update tranReceivers SET
				 mobile = @contactNo
			WHERE tranId = @tranId 
			
			SET @message = 'Receiver Contact No:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@contactNo,'')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'
		end
		
		ELSE IF @fieldName='sIdNo'
		BEGIN
			if @newTxtValue is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid id number!', @tranId
				return
			end	
		   update tranSenders SET
				 idNumber = @newTxtValue
			WHERE tranId = @tranId 
			
			SET @message = 'Sender ID No:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M' 
		end
		
		ELSE IF @fieldName='pAgentLocation'	
		BEGIN
			DECLARE @pDistrict VARCHAR(100), @pDistrictId INT, @pState VARCHAR(100), @pStateId INT
			IF @newDdlValue IS NULL 
			BEGIN
				EXEC proc_errorHandler 1, 'Please enter valid agent payout location!', @tranId
				RETURN
			END
			
			DECLARE 
					 @deliveryMethodId	INT
					,@deliveryMethod	VARCHAR(50)
					,@sBranch			INT
					,@pSuperAgent		INT
					,@sCountryId		INT
					,@sCountry			VARCHAR(100)
					,@pCountryId		INT
					,@pCountry			VARCHAR(100)
					,@pLocation			INT
					,@agentId			INT
					,@amount			MONEY
					,@oldSc				MONEY
					,@newSc				MONEY
					,@collCurr			VARCHAR(3)
			
			SELECT
				 @deliveryMethod	= paymentMethod
				,@sBranch			= sBranch
				,@pSuperAgent		= pSuperAgent
				,@sCountry			= sCountry
				,@pCountry			= pCountry
				,@agentId			= pBranch
				,@amount			= tAmt
				,@oldSc				= serviceCharge	
				,@collCurr			= collCurr
				,@controlNo			= dbo.FNADecryptString(controlNo)
				,@pLocation			= pLocation
			FROM remitTran WITH(NOLOCK)
			WHERE id = @tranId
			
			--Check if txn is paid from View
			IF EXISTS(SELECT 'X' FROM hremit.dbo.AccountTransaction WITH(NOLOCK) WHERE refno = dbo.encryptDbLocal(@controlNo) AND [status] = 'Paid')
			BEGIN
				SET @message = 'Transaction ' + @controlNo + ' is paid. Cannot modify transaction'
				EXEC proc_errorHandler 1, @message, @tranId
				RETURN
			END
	
			IF (@pLocation = 137 AND @newDdlValue <> 137)
			BEGIN
				EXEC proc_errorHandler 1, 'Service Charge or Commission for this location varies. Cannot modify Location.', @tranId
				RETURN
			END
			IF (@newDdlValue = 137 AND @pLocation <> 137)
			BEGIN
				EXEC proc_errorHandler 1, 'Service Charge or Commission for this location varies. Cannot modify Location.', @tranId
				RETURN
			END
			
			SELECT @deliveryMethodId = serviceTypeId FROM serviceTypeMaster WITH(NOLOCK) WHERE typeTitle = @deliveryMethod AND ISNULL(isDeleted, 'N') = 'N'
			SELECT @sCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @sCountry
			SELECT @pCountryId = countryId FROM countryMaster WITH(NOLOCK) WHERE countryName = @pCountry
			IF(@sCountry = 'Nepal')
				SELECT @newSc = ISNULL(serviceCharge, 0) FROM dbo.FNAGetDomesticSendComm(@sBranch, NULL, @newDdlValue, @deliveryMethodId, @amount)
			ELSE
				SELECT @newSc = ISNULL(amount, -1) FROM [dbo].FNAGetSC(@sBranch, @pSuperAgent, @pCountryId, @newDdlValue, @agentId , @deliveryMethodId, @amount, @collCurr)
			IF (@oldSc <> @newSc)
			BEGIN
				EXEC proc_errorHandler 1, 'Service charge for this location varies. Cannot modify location.', @tranId
				RETURN
			END
			
			SELECT @pDistrictId = districtId FROM apiLocationMapping WITH(NOLOCK) WHERE apiDistrictCode = @newDdlValue
			SELECT @pDistrict = districtName, @pStateId = zone FROM zoneDistrictMap WITH(NOLOCK) WHERE districtId = @pDistrictId
			SELECT @pState = stateName FROM countryStateMaster WITH(NOLOCK) WHERE stateId = @pStateId
			
			UPDATE remitTran SET
				  pLocation	= @newDdlValue
				 ,pDistrict	= @pDistrict
				 ,pState	= @pState
			WHERE id = @tranId
			
			SELECT @message = 'Agent Payout Location :' + ISNULL(@oldValue,'') + ' has been changed to ' + ISNULL(districtName, '') FROM api_districtList WHERE districtCode = @newDdlValue
			INSERT INTO tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			SELECT @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'
		END
		
		ELSE IF @fieldName='accountNo'
		BEGIN
			if @newDdlValue is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid account number!', @tranId
				return
			end	
		    update remitTran SET
				 accountNo = @newDdlValue
			WHERE id = @tranId 
			
			SET @message = 'Account Number:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newDdlValue,'')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'
		END
		
		ELSE IF @fieldName='BankName'
		BEGIN
			if @bankNewName is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid bank name!', @tranId
				return
			end	
			if @branchNewName is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid bank name!', @tranId
				return
			end	
			
		    update remitTran SET
				 pBank = @bankNewName,				 
				 pBankName=dbo.GetAgentNameFromId(@bankNewName),
				 pBankBranch = @branchNewName,
				 pBankBranchName=dbo.GetAgentNameFromId(@branchNewName)
			WHERE id = @tranId 
			
			SET @message = 'Bank Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(dbo.GetAgentNameFromId(@bankNewName),'')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'
			
			DECLARE @message2 VARCHAR(200) = NULL
			SET @message2 = 'Branch name has been changed to '+isnull(dbo.GetAgentNameFromId(@branchNewName),'')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message2,@user,dbo.FNAGetDateInNepalTZ(),'M'

		END
		
		ELSE IF @fieldName='BranchName'
		BEGIN
			if @newDdlValue is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid branch name!', @tranId
				return
			end	
		    update remitTran SET
				 pBankBranch = @newDdlValue,
				 pBankBranchName=dbo.GetAgentNameFromId(@newDdlValue)
			WHERE id = @tranId 
			
			SET @message = 'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(dbo.GetAgentNameFromId(@newDdlValue),'')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'
		END
		
		ELSE IF @fieldName='pBranchName'
		BEGIN
			--EXEC [proc_modifyTXN]  @flag = 'u', @user = 'admin', @tranId = '44', @fieldName = 'pBranchName', @oldValue = null, @newDdlValue = '3826'
			if @newDdlValue is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid branch name!', @tranId
				return
			end	
			
	
			declare @parentId as int,
					@branchName as varchar(200),
					@agentName as varchar(200),
					@locationCode as int,
					@locationName as varchar(200),
					@oldLocation as varchar(200),
					@oldAgentId as int,
					@oldAgentName as varchar(200),
					@supAgentId	as int,
					@supAgentName as varchar(200)
							

			select @locationCode=agentLocation from agentMaster where agentId=@newDdlValue
			select @locationName=districtName from api_districtList where districtCode=@locationCode
			select @oldLocation=districtName from api_districtList where districtCode=(select pLocation from remitTran where id=@tranId)
			
			select @oldAgentId= case when isnull(pAgent,0)=isnull(pBranch,0) then pSuperAgent else pAgent end
			from remitTran where id=@tranId
			
			select @oldAgentName=agentName from agentMaster where agentId=@oldAgentId			
					
			if exists(select actAsBranch from agentMaster where agentId=@newDdlValue and actAsBranch='y')
			begin
				
				-- ## branch name
				select @branchName=agentName
				from agentMaster 
				where agentId=@newDdlValue
				
				-- ## super agent
				select @supAgentId=parentId
				from agentMaster where agentId=@newDdlValue
				
				select @supAgentName=agentName
				from agentMaster where agentId=@supAgentId
				
				-- ## update if agent act as a branch 
				update remitTran SET
					 pAgent = @newDdlValue,
					 pBranch=@newDdlValue,
					 pAgentName=@branchName,
					 pBranchName=@branchName,
					 pLocation=@locationCode,
					 pSuperAgent=@supAgentId,
					 pSuperAgentName=@supAgentName
				WHERE id = @tranId 
				
				-- ## update transaction log 			
				insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
				select @tranId,'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@branchName,''),@user,dbo.FNAGetDateInNepalTZ(),'M'
				
				insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
				select @tranId,'Agent Name:'+ isnull(@oldAgentName,'')+' has been changed to '+isnull(@supAgentName,''),@user,dbo.FNAGetDateInNepalTZ(),'M'
				
				insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
				select @tranId,'Location Name:'+ isnull(@oldLocation,'')+' has been changed to '+isnull(@locationName,''),@user,dbo.FNAGetDateInNepalTZ(),'M'
				
			end
			else
			begin
				
				-- ## branch name & agent name
				select @parentId=parentId,@branchName=agentName 
				from agentMaster 
				where agentId=@newDdlValue 
				
				select @agentName=agentName 
				from agentMaster 
				where agentId=@parentId 
				
				-- ## super agent
				select @supAgentId=parentId
				from agentMaster where agentId=@parentId
				
				select @supAgentName=agentName
				from agentMaster where agentId=@supAgentId
				
				-- ## update remitTran
				update remitTran SET
					 pAgent = @parentId,
					 pBranch=@newDdlValue,
					 pAgentName=@agentName,
					 pBranchName=@branchName,
					 pLocation=@locationCode,
					 pSuperAgent=@supAgentId,
					 pSuperAgentName=@supAgentName
				WHERE id = @tranId 
				
				-- ## update transaction log 							
				insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
				select @tranId,'Branch Name:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@branchName,''),@user,dbo.FNAGetDateInNepalTZ(),'M'
				
				insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
				select @tranId,'Agent Name:'+ isnull(@oldAgentName,'')+' has been changed to '+isnull(@agentName,''),@user,dbo.FNAGetDateInNepalTZ(),'M'
				
				insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
				select @tranId,'Location Name:'+ isnull(@oldLocation,'')+' has been changed to '+isnull(@locationName,''),@user,dbo.FNAGetDateInNepalTZ(),'M'
			end		
			
		END

		ELSE IF @fieldName='stdName'
		BEGIN
			if @newTxtValue is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid Student Name!', @tranId
				return
			end	
		   update tranReceivers SET
				 stdName = @newTxtValue
			WHERE tranId = @tranId 
			
			SET @message = 'Student Name :'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'
		end

		ELSE IF @fieldName='stdLevel'
		BEGIN
			if @newDdlValue is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid Student Class/Level!', @tranId
				return
			end	
		   update tranReceivers SET
				 stdLevel = @newDdlValue
			WHERE tranId = @tranId 
			
			select @newDdlValue = name from schoolLevel with(nolock) where rowId = @newDdlValue
			SET @message = 'Student Class/Level:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newDdlValue,'')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'
		end

		ELSE IF @fieldName='stdRollRegNo'
		BEGIN
			if @newTxtValue is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid Student Reg. No./Roll No.!', @tranId
				return
			end	
		   update tranReceivers SET
				 stdRollRegNo = @newTxtValue
			WHERE tranId = @tranId 
			
			SET @message = 'Student Reg. No./Roll No.:'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newTxtValue,'')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'
		end

		ELSE IF @fieldName='stdSemYr'
		BEGIN
			if @newDdlValue is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid Student Semester/Year!', @tranId
				return
			end	
		   update tranReceivers SET
				 stdRollRegNo = @newDdlValue
			WHERE tranId = @tranId 
			SET @message = 'Student Semester/Year:'+ isnull(@oldValue,'')+' has been changed to '+isnull(dbo.FNAGetDataValue(@newDdlValue),'')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'
		end		

		ELSE IF @fieldName='feeTypeId'
		BEGIN
			if @newDdlValue is null
			begin
				EXEC proc_errorHandler 1, 'Please enter valid Fee Type!', @tranId
				return
			end	
		   update tranReceivers SET
				 feeTypeId = @newDdlValue
			WHERE tranId = @tranId 
			
			select @newDdlValue = feeType from schoolFee with(nolock) where rowId = @newDdlValue
			SET @message = 'Fee Type :'+ isnull(@oldValue,'')+' has been changed to '+isnull(@newDdlValue,'')
			insert into  tranModifyLog(tranId,message,createdBy,createdDate,MsgType)
			select @tranId,@message,@user,dbo.FNAGetDateInNepalTZ(),'M'
		end

		EXEC proc_errorHandler 0, 'Record has been updated successfully.', @tranId
		
		IF (ISNULL(@isAPI, 'N') = 'Y')
		BEGIN
			IF(@fieldName = 'pAgentLocation')
			BEGIN
				EXEC proc_modifyTxnAPI @flag = 'mpl', @controlNo = @controlNo, @user = @user, @newPLocation = @newDdlValue, @agentRefId = NULL
			END
			ELSE
			BEGIN
				EXEC proc_addCommentAPI @flag = 'i', @controlNo = @controlNo, @user = @user, @message = @message, @agentRefId = NULL
			END
		END
	END 
	
	IF @flag='sa'
	BEGIN
		SELECT pBank FROM remitTran WHERE id=@tranId	
	END	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @tranId
END CATCH


GO
