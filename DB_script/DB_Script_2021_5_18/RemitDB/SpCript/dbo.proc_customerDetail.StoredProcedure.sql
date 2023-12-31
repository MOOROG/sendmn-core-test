USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customerDetail]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE proc [dbo].[proc_customerDetail]
 	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(50)		= NULL
	,@membershipId						VARCHAR(50)		= NULL
	,@id								INT				= NULL

	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL

	,@name								VARCHAR(200)	= NULL
	,@fileName							VARCHAR(50)		= NULL
	,@fileDescription                   VARCHAR(100)	= NULL
	,@fileType                          VARCHAR(10)		= NULL
	,@hasChanged						CHAR(1)			= NULL

	,@sMembershipId						VARCHAR(50)		= NULL
	,@sFirstName						VARCHAR(200)	= NULL
	,@sMiddleName						VARCHAR(200)	= NULL
	,@sLastName							VARCHAR(200)	= NULL
	,@sContactNo						VARCHAR(50)		= NULL
	,@rMembershipId						VARCHAR(50)		= NULL
	,@rFullName							VARCHAR(100)	= NULL
    ,@rMobile							VARCHAR(50)		= NULL
    ,@rReceiverId						INT				= NULL
	,@isApproved						CHAR(1)			= NULL
	,@searchBy							VARCHAR(50)		= NULL
	,@searchValue						VARCHAR(200)	= NULL
	,@customerId						VARCHAR(50)		= NULL
	,@sAmount							MONEY			= NULL
	,@sAmountThreshold					MONEY			= NULL
            
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)
		,@errorMsg			VARCHAR(MAX)
		
	SELECT
		 @logIdentifier = 'id'
		,@logParamMain = 'Customer Master'		
		,@module = '20'
		,@tableAlias = 'customerMaster'
		
	DECLARE @TranId INT, 
			@ReceiverID AS VARCHAR(100) 
	
	-- ## sender information for normal send
	IF @flag = 'CS'	
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK)
			 WHERE membershipId = @membershipId AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Customer with this Membership Id not found', NULL
		END

		ELSE IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) WHERE membershipId  = @membershipId AND ISNULL(isDeleted, 'N') <> 'Y' AND rejectedDate IS NULL AND expiryDate<=Convert(date,GETDATE(),101))
		BEGIN
					
			SELECT 1 errorCode, 'This IME membership ID has expired on '+Cast(expiryDate as varchar)+', please inform to renew Membership card!' msg, NULL from customerMaster WITH(NOLOCK) 
				WHERE membershipId  = @membershipId  
		END
		ELSE IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) 
					WHERE membershipId = @membershipId 
					AND ISNULL(isDeleted, 'N') <> 'Y' 
					AND ISNULL(isBlackListed, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'This customer is blacklisted. Cannot proceed for transaction.', NULL
		END
		ELSE IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) 
					WHERE membershipId = @membershipId 
					AND ISNULL(isDeleted, 'N') <> 'Y' 
					AND approvedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Customer with this membership ID has not been approved yet. Please contact head office.', NULL
		END
		ELSE
		BEGIN
			EXEC proc_errorHandler 0, 'Customer Found', NULL
		END
		
		SELECT 
				cm.customerId customerId
				,isnull(cm.firstName,'') firstName
				,isnull(cm.middleName,'') middleName
				,isnull(cm.lastName,'') lastName1
				,'' lastName2
				,isnull(cm.pMunicipality,'')+' '+isnull(cm.pdistrict,'')+' '+isnull(cm.pzone,'')+' '+isnull(cm.pcountry,'') [address]
				,isnull(cm.mobile,'')	 mobile		
				--,'1301' idType
				,sdv.valueId idType				
				,cm.citizenshipNo idNumber
				,isnull(cm.email,'') email
		FROM customerMaster cm WITH(NOLOCK)
		LEFT JOIN staticDataValue sdv with(nolock) on sdv.detailTitle=cm.idType		 			
		WHERE cm.membershipId = @membershipId 
				AND ISNULL(cm.isDeleted, 'N') <> 'Y' 
				AND ISNULL(cm.isActive, 'Y') = 'Y'
		
		RETURN
	END
	
	-- ## sender & receiver information for normal send
	IF @flag = 'CS1'	
	BEGIN

		-->>select * from customerMaster
		IF NOT EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) 
				WHERE membershipId  = @membershipId AND ISNULL(isDeleted, 'N') <> 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'Customer with this CUSTOMER CARD NUMBER not found!', NULL
			RETURN;
		END	
		IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) 
				WHERE membershipId  = @membershipId AND ISNULL(isDeleted, 'N') <> 'Y' AND expiryDate<=Convert(date,GETDATE(),101))
		BEGIN
			
			SELECT 1 errorCode, 'This IME membership ID has expired on '+Cast(expiryDate as varchar)+', please inform to renew Membership card!' msg, NULL from customerMaster WITH(NOLOCK) 
				WHERE membershipId  = @membershipId  
			RETURN;
		END	
		
		IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) 
					WHERE membershipId = @membershipId 
					AND ISNULL(isDeleted, 'N') <> 'Y' 
					AND ISNULL(isBlackListed, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'This customer is blacklisted. Cannot proceed for transaction.', NULL
			RETURN;
		END
		IF EXISTS(
			SELECT 'X' FROM customerMaster WITH(NOLOCK) 
				WHERE membershipId = @membershipId 
				AND ISNULL(isDeleted, 'N') <> 'Y' 
				AND ISNULL(isActive, 'Y') <> 'Y'
		)
					--AND approvedDate IS NULL)
		BEGIN
			--EXEC proc_errorHandler 1, 'Customer with this membership ID has not been approved yet. Please contact head office.', NULL
			EXEC proc_errorHandler 1, 'Customer with this membership ID is not active. Please contact head office.', NULL
			RETURN;
		END
		
		IF EXISTS(
			SELECT 'X' FROM customerMaster WITH(NOLOCK) 
			WHERE membershipId = @membershipId 
			AND ISNULL(isDeleted, 'N') <> 'Y' 
			AND approvedDate IS NULL
		)
		BEGIN
			IF ISNULL(@sAmountThreshold,0) <> 0 AND ISNULL(@sAmount,0)<>0
			BEGIN
				IF @sAmount >= @sAmountThreshold
				BEGIN
					EXEC proc_errorHandler 1, 'Customer with this membership ID is not approved yet. Unapproved customer cannot send money greater than or equals to threshold amount using customer card. Please contact head office.', NULL
					RETURN;
				END
			END
		END

		SELECT 
			TOP 1 @TranId =  C.tranId			
		FROM tranSenders C WITH(NOLOCK)
		WHERE C.membershipId = @membershipId 
		order by id desc

		SELECT  errCode = ISNULL(errCode,'') ,
				sCustomerId = ISNULL(sCustomerId,''),
				sCustomerCardNo = ISNULL(sCustomerCardNo,''),
				sFirstName = ISNULL(sFirstName,''),
				sMiddleName = ISNULL(sMiddleName,''),
				sLastName1 = ISNULL(sLastName1,''),
				sLastName2 = ISNULL(sLastName2,''),
				sAddress = ISNULL(sAddress,''),
				sMobile = ISNULL(sMobile,''),
				sIdType = ISNULL(cast(sIdType as varchar),''),
				sIdType1 = ISNULL(sIdType1,''),
				sIdNumber = ISNULL(sIdNumber,''),
				sEmail = ISNULL(sEmail,''),
				tranId = ISNULL(sen.tranId,''), 
				rCustomerId = ISNULL(rCustomerId,''),
				rCustomerCardNo = ISNULL(rCustomerCardNo,''),
				rFirstName = ISNULL(rFirstName,''),
				rMiddleName = ISNULL(rMiddleName,''),
				rLastName1 = ISNULL(rLastName1,''),
				rLastName2 = ISNULL(rLastName2,''),
				rAddress = ISNULL(rAddress,''),
				rMobile = ISNULL(rMobile,''),
				rIdType = ISNULL(cast(rIdType as varchar),''),
				rIdNumber = ISNULL(rIdNumber,''),
				rEmail = ISNULL(rEmail,''),
				sIdIssuedDate=ISNULL(issueDate,''),
				sIdIssuedDateBs=ISNULL(issueDateNp,''),
				sDOB=ISNULL(dobEng,''),
				sDOBBs=ISNULL(dobNep,''),
				sIdExpiryDate=ISNULL(expiryDate,''),
				sIdExpiryDateBs=ISNULL(expiryDateNp,''),
				sOccupation=ISNULL(occupation,''),
				sGender=ISNULL(gender,''),
				sFatherMotherName=ISNULL(fatherMotherName,''),
				sPlaceOfIssue=ISNULL(placeOfIssue,'')

		FROM 
		(
			SELECT TOP 1
				  errCode = '0' 				  
				 ,sCustomerId = cust.customerId 
				 ,sCustomerCardNo = cust.membershipId 
				 ,sFirstName = ISNULL(cust.firstName,'')
				 ,sMiddleName = ISNULL(cust.middleName,'') 
				 ,sLastName1 = ISNULL( cust.lastName,'') 
				 ,sLastName2 = '' 
				 ,sAddress = ISNULL(' '+cust.pMunicipality,'')+isnull(' '+cust.pdistrict,'')+isnull(' '+cust.pzone,'')+isnull(' '+cust.pcountry,'') +ISNULL(' '+cust.pTole,'')
				 ,sMobile = ISNULL(cust.mobile,'')		 
				 ,sIdType = ISNULL(cust.idType,'') --'1301'
				 ,sIdType1 =  dbo.FNAGetIDType(cust.idType,'151')+ '|' + ISNULL(cit.expiryType, 'E') --CAST(cust.idType AS VARCHAR) 
				 ,sIdNumber = cust.citizenshipNo
				 ,sEmail = ISNULL(cust.email,'') 
				 ,tranId = @TranId
				 ,issueDate=convert(varchar,issueDate,101)
				 ,issueDateNp
				 ,dobEng,dobNep
				 ,expiryDate=convert(varchar,expiryDate,101)
				 ,expiryDateNp
				 ,occupation
				 ,gender
				 ,fatherMotherName= ISNULL(fatherName,motherName)
				 ,placeOfIssue

			FROM customerMaster cust WITH(NOLOCK) 
			--LEFT JOIN countryIdType cit WITH(NOLOCK) ON cust.idType = CAST(cit.IdTypeId AS VARCHAR) AND countryId='151'
			LEFT JOIN countryIdType cit WITH(NOLOCK) ON dbo.FNAGetIDType(cust.idType,'151') = CAST(cit.IdTypeId AS VARCHAR) AND countryId='151'
			WHERE cust.membershipId = @membershipId 
				AND ISNULL(cust.isDeleted, 'N') <> 'Y'
				AND ISNULL(cust.isActive, 'Y') = 'Y'
		
		)sen left join
		(			
			SELECT 
				  rCustomerId = ISNULL(cust.customerId,rec.customerId) 
				 ,rCustomerCardNo = ISNULL(cust.membershipId,rec.membershipId)
				 ,rFirstName = ISNULL(cust.firstName,rec.firstName)
				 ,rMiddleName = ISNULL(cust.middleName,rec.middleName)
				 ,rLastName1 = ISNULL(cust.lastName,rec.lastName1)
				 ,rLastName2 = ISNULL(rec.lastName2,'')
				 ,rAddress = case when cust.customerId is not null then 
								isnull(cust.pMunicipality,'')+' '+isnull(cust.pdistrict,'')+' '+isnull(cust.pzone,'')+' '+isnull(cust.pcountry,'') 
							  else 
								rec.address
							  end						
				 ,rMobile = ISNULL(cust.mobile,rec.mobile)		 
				 ,rIdType = '1301'
				 ,rIdNumber = cust.citizenshipNo
				 ,rEmail = isnull(cust.email,rec.email) 		
				 ,tranId = @TranId  	 
			FROM tranReceivers rec with(nolock)
				LEFT JOIN customerMaster cust WITH(NOLOCK) on rec.membershipId=cust.membershipId	
				LEFT JOIN staticDataValue sdv with(nolock) on sdv.detailTitle=rec.idType
				AND ISNULL(cust.isDeleted, 'N') <> 'Y'		 
				AND ISNULL(cust.isActive, 'Y') = 'Y'
			WHERE rec.tranId=@TranId
		) rec on sen.tranId=rec.tranId
		return
	END
	
	
	IF @flag='p'
	BEGIN
		
		IF @membershipId IS NULL
			SELECT @membershipId=membershipId FROM customerMaster with(nolock) WHERE customerId=@id

		SELECT fileName [fileName],
			CASE 
				WHEN fileDescription='Enrollform' 
					THEN 'Enrollment Form'
				WHEN fileDescription='IdCard'  
					THEN 'Primary Id Card'
				ELSE fileDescription 
			END fileDescription
		FROM customerDocument a WITH(NOLOCK) 
		INNER JOIN customerMaster b WITH(NOLOCK) ON a.customerId=b.customerId		
		WHERE b.membershipId=@membershipId  ORDER BY isProfilePic DESC
	END		
	
	-- ## receiver information for third party payment
	IF @flag = 'CS2'	
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK)
			 WHERE membershipId = @membershipId AND ISNULL(isDeleted, 'N') <> 'Y' AND rejectedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Customer with this Membership Id not found', NULL
		END
		ELSE IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) 
					WHERE membershipId = @membershipId 
					AND ISNULL(isDeleted, 'N') <> 'Y' 
					AND ISNULL(isBlackListed, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'This customer is blacklisted. Cannot proceed for transaction.', NULL
		END
		ELSE IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) 
					WHERE membershipId = @membershipId 
					AND ISNULL(isDeleted, 'N') <> 'Y' 
					AND approvedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Customer with this membership ID has not been approved yet. Please contact head office.', NULL
		END
		ELSE
		BEGIN
			EXEC proc_errorHandler 0, 'Customer Found', NULL
		END
		
		SELECT 
			 customerId customerId
			,'1301' idType
			,ISNULL(citizenshipNo,'') idNumber
			,ISNULL(pDistrict,'') district
			,ISNULL(mobile,'') mobile
			,REPLACE(ISNULL(firstName, '') + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, ''), '  ', ' ') fullName
			,'2101' relationType
			,isnull(fatherName,'') relativeName
		FROM customerMaster cust WITH(NOLOCK) 
		WHERE cust.membershipId = @membershipId 
			AND ISNULL(cust.isDeleted, 'N') <> 'Y'
			AND ISNULL(cust.isActive, 'Y') = 'Y'
				
		RETURN
	END
	
	-- ## receiver information for money gram
	IF @flag = 'rPayMg'	
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK)
			 WHERE membershipId = @membershipId AND ISNULL(isDeleted, 'N') <> 'Y' AND rejectedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Customer with this Membership Id not found', NULL
		END
		ELSE IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) 
					WHERE membershipId = @membershipId 
					AND ISNULL(isDeleted, 'N') <> 'Y' 
					AND ISNULL(isBlackListed, 'N') = 'Y')
		BEGIN
			EXEC proc_errorHandler 1, 'This customer is blacklisted. Cannot proceed for transaction.', NULL
		END
		ELSE
		BEGIN
			EXEC proc_errorHandler 0, 'Customer Found', NULL
		END
		
		SELECT 
			 customerId customerId
			,'1301' idType
			,ISNULL(citizenshipNo,'') idNumber
			,ISNULL(pDistrict,'') district
			,ISNULL(mobile,'') mobile
			,REPLACE(ISNULL(firstName, '') + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, ''), '  ', ' ') fullName
			,'2101' relationType
			,isnull(fatherName,'') relativeName
		FROM customerMaster cust WITH(NOLOCK) 
		WHERE cust.membershipId = @membershipId 
			AND ISNULL(cust.isDeleted, 'N') <> 'Y'
			AND ISNULL(cust.isActive, 'Y') = 'Y'
				
		RETURN
	END
	
	-- ## Select Receiver History By Sender Information
	IF @flag = 'viewHistory'	
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'id'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '(
					SELECT 
						Id  = rec.id,
						rCustomerId = rec.customerId,
						rMembershipId = rec.membershipId,
						rFullName = ISNULL(rec.firstName, '''') + ISNULL('' '' + rec.middleName, '''')+ ISNULL('' '' + rec.lastName1, '''')+ ISNULL('' '' + rec.lastName2, '''') ,
						rMobile = rec.mobile,
						rIdType = rec.idType,
						rIdNumber = rec.idNumber,
						rAddress = rec.address
					FROM tranReceivers rec WITH(NOLOCK) 
					INNER JOIN tranSenders sen WITH(NOLOCK) ON rec.tranId=sen.tranId
					WHERE 1=1	
					'						
			
		IF @sMembershipId IS NOT NULL
			SET @table = @table + ' AND sen.membershipId = ''' + CAST(@sMembershipId AS VARCHAR) + ''''		
		ELSE
		BEGIN
			SET @table = @table + ' AND isnull(sen.firstName,'''') = ''' + CAST(ISNULL(@sFirstName,'') AS VARCHAR) + ''''	
			SET @table = @table + ' AND isnull(sen.middleName,'''')= ''' + CAST(ISNULL(@sMiddleName,'') AS VARCHAR) + ''''	
			SET @table = @table + ' AND isnull(sen.lastName1,'''') = ''' + CAST(ISNULL(@sLastName,'') AS VARCHAR) + ''''	
			SET @table = @table + ' AND isnull(sen.mobile,'''')= ''' + CAST(ISNULL(@sContactNo,'') AS VARCHAR) + ''''	
		END
		SET @table = @table + ')x'	
		SET @sql_filter = ''
		
		IF @rMembershipId IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(rMembershipId,'''') = ''' + @rMembershipId + ''''
		IF @rFullName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(rFullName,'''') LIKE ''%' + @rFullName + '%'''
		IF @rMobile IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND ISNULL(rMobile,'''') = ''' + @rMobile + ''''
				
		SET @select_field_list ='
			 id
			,rCustomerId
			,rMembershipId
			,rFullName
			,rMobile
			,rIdType
			,rIdNumber
			,rAddress'
			
		EXEC dbo.proc_paging
			@table
			,@sql_filter
			,@select_field_list
			,@extra_field_list
			,@sortBy
			,@sortOrder
			,@pageSize
			,@pageNumber
					
	END 
		
	IF @flag='getReceiverById'
	BEGIN	
			EXEC proc_errorHandler 0, 'Customer Found', NULL			                              
			SELECT
				id, 
				membershipId,
				customerId,
				ISNULL(firstName,'') firstName,
				ISNULL(middleName,'') middleName,
				ISNULL(lastName1,'') lastName1,
				ISNULL(mobile,'') mobile,
				ISNULL(val.valueId,'') idType,
				ISNULL(idNumber,'') idNumber,
				ISNULL(address,'') 	address 
			FROM tranReceivers rec WITH(NOLOCK) 
			LEFT JOIN staticDataValue val WITH(NOLOCK) ON rec.idType=val.detailTitle
			WHERE rec.id=@rReceiverId	
	END

	IF @flag = 'LoadImages'
	BEGIN
		DECLARE @enrollForm VARCHAR(200),@idCard VARCHAR(200)		
		select @enrollForm = [fileName] from customerDocument with(nolock) where customerId = @customerId and fileDescription ='Enrollform'
		select @idCard = [fileName] from customerDocument with(nolock) where customerId = @customerId and fileDescription ='IdCard'
		select 
			imgForm =
				case when @enrollForm is not null 
					then 'Enrollment Form : <img alt = "Enrollment Form" onclick = "ShowSenderCustomer();" style="height:50px;width:50px;" src="../../../../../doc/'+@enrollForm+'"/>' 
					else 'Enrollment Form : <img alt = "Enrollment Form" onclick = "ShowSenderCustomer();" style="height:50px;width:50px;" src="../../../../../Images/na.gif" />' 
				end
		   ,imgID = 
				case when @idCard is not null 
					then 'ID Card : <img alt = "ID Card" onclick = "ShowSenderCustomer();" style="height:50px;width:50px;" src="../../../../../doc/'+@idCard+'"/>' 
					else 'ID Card : <img alt = "ID Card" onclick = "ShowSenderCustomer();" style="height:50px;width:50px;" src="../../../../../Images/na.gif" />' 
				end
	END

	IF @flag = 'LoadImagesAgent'
	BEGIN
		DECLARE @enrollForm1 VARCHAR(200),@idCard1 VARCHAR(200)		
		select @enrollForm1 = [fileName] from customerDocument with(nolock) where customerId = @customerId and fileDescription ='Enrollform'
		select @idCard1 = [fileName] from customerDocument with(nolock) where customerId = @customerId and fileDescription ='IdCard'
		select 
			imgForm =
				case when @enrollForm1 is not null 
					then 'Enrollment Form : <img alt = "Enrollment Form" onclick = "ShowSenderCustomer();" style="height:50px;width:50px;" src="../../../../../doc/'+@enrollForm1+'"/>' 
					else 'Enrollment Form : <img alt = "Enrollment Form" onclick = "ShowSenderCustomer();" style="height:50px;width:50px;" src="../../../../../Images/na.gif" />' 
				end
		   ,imgID = 
				case when @idCard1 is not null 
					then 'ID Card : <img alt = "ID Card" onclick = "ShowSenderCustomer();" style="height:50px;width:50px;" src="../../../../../doc/'+@idCard1+'"/>' 
					else 'ID Card : <img alt = "ID Card" onclick = "ShowSenderCustomer();" style="height:50px;width:50px;" src="../../../../../Images/na.gif" />' 
				end
	END
	
	-- ## SELECT CUSTOMER ACCRODING TO CUSTOMER CARD NUMBER FROM PAY PAGE To SHOW ON THIRD PARY PAY PAGE
	IF @flag = 'searchRecForThp'	
	BEGIN
		IF NOT EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK)
			 WHERE membershipId = @membershipId AND ISNULL(isDeleted, 'N') <> 'Y' AND rejectedDate IS NULL)
		BEGIN
			select errorCode ='1',errorMsg= 'Customer with this Membership Id not found'
			return
		END
		IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) WHERE membershipId  = @membershipId AND ISNULL(isDeleted, 'N') <> 'Y' AND rejectedDate IS NULL AND expiryDate<=Convert(date,GETDATE(),101))
		BEGIN
					
			SELECT 1 errorCode, 'This IME membership ID has expired on '+Cast(expiryDate as varchar)+', please inform to renew Membership card!' errorMsg, NULL from customerMaster WITH(NOLOCK) 
				WHERE membershipId  = @membershipId  
				RETURN
		END
		ELSE IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) 
					WHERE membershipId = @membershipId 
					AND ISNULL(isDeleted, 'N') <> 'Y'
					AND ISNULL(isBlackListed, 'N') = 'Y')
		BEGIN
			select errorCode ='1',errorMsg= 'This customer is blacklisted. Cannot proceed for transaction.'
			return
		END	
		ELSE IF EXISTS(SELECT 'X' FROM customerMaster WITH(NOLOCK) 
					WHERE membershipId = @membershipId 
					AND ISNULL(isDeleted, 'N') <> 'Y'
					AND approvedDate is null)
		BEGIN
			select errorCode ='1',errorMsg= 'Customer has not been approved yet.'
			return
		END			
		
		SELECT 
			 customerId 
			--,idType			= '1301'
			,idType			= sdv.valueId
			,IdType1		=  dbo.FNAGetIDType(cust.idType,'151')+ '|' + ISNULL(cit.expiryType, 'E') --CAST(cust.idType AS VARCHAR) 
			,idNumber		= ISNULL(citizenshipNo,'')
			,district		= ISNULL(pDistrict,'')
			,mobile			= ISNULL(mobile,'')
			,fullName		= REPLACE(ISNULL(firstName, '') + ISNULL(' ' + middleName, '') + ISNULL(' ' + lastName, ''), '  ', ' ')
			,relationType	= '2101'
			,relativeName	= ISNULL(fatherName,'')
			,country		= isnull(pCountry,'')
			,dob			= isnull(dobNep,'')
			,recOccupation	= isnull(occupation,'')
			,membershipId	= @membershipId
			,errorCode		= '0'
			,errorMsg		= 'Customer Found'
			,issueDate		= convert(varchar,issueDate,101)
			,issueDateNp
			,dobEng			= convert(varchar,dobEng,101)
			,dobNep
			,expiryDate		= convert(varchar,expiryDate,101)
			,expiryDateNp
			,occupation
			,gender			
			,placeOfIssue
		FROM customerMaster cust WITH(NOLOCK) 
		LEFT JOIN staticDataValue sdv with(nolock) on sdv.detailTitle=cust.idType
		LEFT JOIN countryIdType cit WITH(NOLOCK) ON dbo.FNAGetIDType(cust.idType,'151') = CAST(cit.IdTypeId AS VARCHAR) AND countryId='151'	
		WHERE cust.membershipId = @membershipId 
			AND ISNULL(cust.isDeleted, 'N') <> 'Y'
			AND ISNULL(cust.isActive, 'Y') = 'Y'
				
		RETURN
	END
	

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @id
END CATCH





GO
