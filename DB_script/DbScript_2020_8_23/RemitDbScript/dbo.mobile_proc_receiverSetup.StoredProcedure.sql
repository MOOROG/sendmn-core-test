USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[mobile_proc_receiverSetup]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[mobile_proc_receiverSetup]
(
	 @flag			VARCHAR	(50)	= NULL
	,@userId		VARCHAR (50)	= NULL
	,@customerId	VARCHAR (100)	= NULL
	,@firstName		VARCHAR(50)		= NULL
	,@middleName	VARCHAR(50)		= NULL
	,@lastName		VARCHAR(50)		= NULL
	,@country		VARCHAR(100)	= NULL
	,@address		VARCHAR(500)	= NULL
	,@state			VARCHAR(100)	= NULL
	,@district      VARCHAR(100)    = NULL
	,@city			VARCHAR(100) 	= NULL
	,@email			VARCHAR(100) 	= NULL
	,@mobile		VARCHAR(30)		= NULL
	,@relation		VARCHAR(50)		= NULL	
	,@recipientId	VARCHAR	(50)	= NULL --receiver Id
	,@purpose       VARCHAR(500)	= NULL
	,@idType        VARCHAR(500)	= NULL
	,@idNumber      VARCHAR(500)	= NULL
	,@page			INT				= NULL
	,@size			INT				= NULL
	,@search		VARCHAR	(50)	= NULL
)
AS 
BEGIN
	DECLARE @totalReceiverCount INT,@recMobile VARCHAR(50),@countryId VARCHAR(10),@stateName VARCHAR(50),@districtName VARCHAR(50)
	,@stateText VARCHAR(50),@districtText VARCHAR(50),@stateId BIGINT,@districtId BIGINT;

	SET @totalReceiverCount = 0;
	IF @flag='i'
	BEGIN
		SELECT 
			@customerId=cust.customerId 
		FROM customermaster(NOLOCK) cust 
		WHERE cust.email=@userId 

		SELECT @country = CM.countryName,@countryId = CM.countryId 
		FROM dbo.countryMaster(NOLOCK) AS CM 
		WHERE CM.countryId = @country OR cm.countryName=@country


		IF ISNULL(@customerId,'')=''
		BEGIN
			SELECT '1' errorCode,'The user with '+@userId+' does not exists.' msg,null id
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM receiverInformation WITH(NOLOCK) WHERE mobile=@mobile and customerId=@customerId and firstName = @firstName and lastName1 = @lastName and isActive = 1)
		BEGIN
			SELECT '1' errorCode,'The receiver with mobile Number '+@mobile+' already exists.' msg,null id
			RETURN
		END

		SET @stateText =CASE WHEN @countryId='151' then (SELECT Replace(stateName,char(9),'') FROM dbo.countriesStates rcs WITH(NOLOCK) 
						INNER JOIN dbo.countryMaster cm WITH(NOLOCK) ON cm.countryCode = rcs.countryCode WHERE countryId = '151' AND rcs.rowId=@state)	
						WHEN NOT EXISTS(SELECT 'A' FROM tblServicewiseLocation (NOLOCK) WHERE countryId = @countryId) THEN 'Any State'
						ELSE (SELECT location FROM tblServicewiseLocation loc (NOLOCK) WHERE countryId = @countryId AND isActive = 1 AND loc.rowId=@state)
						END
		
		SET	 @districtText =CASE WHEN @countryId='151' then (SELECT Replace(stateName,char(9),'') FROM dbo.countriesStates rcs WITH(NOLOCK) 
							INNER JOIN dbo.countryMaster cm WITH(NOLOCK) ON cm.countryCode = rcs.countryCode WHERE countryId = '151' AND rcs.rowId=@district)	
							WHEN NOT EXISTS(SELECT 'A' FROM tblSubLocation (NOLOCK) WHERE locationId = @state) THEN 'Any location'
							ELSE (SELECT subLocation FROM tblSubLocation (NOLOCK) WHERE locationId = @state AND rowId=@district AND isActive = 1)
							END

		INSERT INTO receiverInformation
		( customerId,firstName,middleName	,lastName1	,country,[address],[state],district	,city,email	,mobile,relationship,purposeOfRemit,isActive,idType,idNumber	)
		SELECT 			
			@customerId	,@firstName	,@middleName,@lastName,@country,@address,@stateText,@districtText,@city,@email	,@mobile
			,(SELECT sv.detailTitle FROM dbo.staticDataValue sv(NOLOCK) WHERE sv.valueId=@relation)	
			,(SELECT sv.detailTitle FROM dbo.staticDataValue sv(NOLOCK) WHERE sv.valueId=@purpose),1,@idType,@idNumber	

			SET @recipientId=SCOPE_IDENTITY()

			SELECT TOP 1 errorCode	= '0'
				,recipientId	= receiverId
				,firstname		  
				,middlename		  
				,lastname		= ISNULL(lastName1,'')+ISNULL(' '+lastName2,'')
				,fullname       = firstname +ISNULL(' ' + middlename,'') + ISNULL(' ' + lastName1,'')
				,[address]		= [address]
				,city
				,ISNULL([state],'Any State')  
				,stateId        = @state
				,ISNULL(district,'Any District')  
				,districtId		= @district			  
				,country	
				,countryId		= cm.countryId	  
				,relation		= relationship
				,relationId		= rel.valueId
				,mobile
				,email
				,transferReason = purposeOfRemit
				,reasonId		= rsn.valueId
				,dpUrl			= ''
				,userId			= @userId
				,countryCode	= cm.countryCode
				,idType			=  rec.idType
				,idNumber		= rec.idNumber
			FROM receiverInformation rec(NOLOCK)
			LEFT JOIN staticdatavalue rel (NOLOCK) ON rec.relationship=rel.detailTitle
			LEFT JOIN staticdatavalue rsn (NOLOCK) ON rec.purposeOfRemit=rsn.detailTitle
			LEFT JOIN countryMaster cm(NOLOCK) ON rec.country=cm.countryName
			WHERE receiverId =@recipientId  AND ISNULL(rec.isActive,1) = 1
		RETURN 			
	END
	ELSE IF @flag='u'
	BEGIN	
		/*================= check if contact details of recipient matches to detail of existing recipient while updating ###STARTS ============*/
		SELECT @customerId = ri.customerId 
		FROM dbo.receiverInformation ri(NOLOCK)
		WHERE ri.receiverId=@recipientId  AND ISNULL(isActive,1) = 1

		--IF ISNULL(@mobile,'') <> ''
		--BEGIN
		--IF EXISTS(SELECT 'X' FROM receiverInformation WITH(NOLOCK) WHERE mobile=@mobile AND customerId=@customerId)
		--BEGIN
		--	SELECT '1' errorCode,'The contact details already exists.Please re-enter correct contact details.' msg,null id
		--	RETURN
		--END
		--END
		/*================= ###ENDS ============*/

		IF EXISTS(SELECT 'X' FROM receiverInformation (NOLOCK) WHERE receiverId=@recipientId)
		BEGIN
			DECLARE @provinceId VARCHAR(50);
			SELECT @userId=ur.username ,@countryId=cm.countryId,@stateName=ri.state,@districtName=ri.district
			FROM mobile_userRegistration ur(NOLOCK)
			INNER JOIN receiverInformation ri (NOLOCK) ON ur.customerId=ri.customerId
			INNER JOIN dbo.countryMaster cm(NOLOCK) ON UPPER(cm.countryName)=UPPER(ri.country)
			WHERE ri.receiverId=@recipientId
			
			--PRINT @userId

			IF @country IS NOT NULL
			BEGIN
				SET @countryId=@country	
				--SELECT @countryId=CM.countryName FROM dbo.countryMaster(NOLOCK) AS CM WHERE CM.countryId=@country
            END 
			IF @state IS NOT NULL
			BEGIN
			SET @stateText =CASE WHEN @countryId='151' then 
								(SELECT Replace(stateName,char(9),'') 
								 FROM dbo.countriesStates rcs WITH(NOLOCK) 
								 INNER JOIN dbo.countryMaster cm WITH(NOLOCK) ON cm.countryCode = rcs.countryCode 
								 WHERE countryId = '151' AND rcs.rowId=@state)	
								WHEN NOT EXISTS(SELECT 'A' FROM tblServicewiseLocation (NOLOCK) WHERE countryId = @countryId) THEN 'Any State'
								ELSE (SELECT location FROM tblServicewiseLocation loc (NOLOCK) WHERE countryId = @countryId AND isActive = 1 AND loc.rowId=@state)
								END
			SET @stateName=@stateText;
			END
			
			IF @district IS NOT NULL
			BEGIN 
		    SET @districtText =CASE WHEN @countryId='151' then 
									(SELECT Replace(stateName,char(9),'') 
									FROM dbo.countriesStates rcs WITH(NOLOCK) INNER JOIN dbo.countryMaster cm WITH(NOLOCK) ON cm.countryCode = rcs.countryCode 
									WHERE countryId = '151' AND rcs.rowId=@district)	
									WHEN NOT EXISTS(SELECT 'A' FROM tblSubLocation (NOLOCK) WHERE rowId = @district) THEN 'Any location'
									ELSE (SELECT subLocation FROM tblSubLocation (NOLOCK) WHERE rowId=@district AND isActive = 1)
									END
			SET @districtName=@districtText;
			END

			SET @stateId  =CASE WHEN @countryId='151' then 
			                    (SELECT rcs.rowId 
								FROM dbo.countriesStates rcs WITH(NOLOCK) INNER JOIN dbo.countryMaster cm WITH(NOLOCK) ON cm.countryCode = rcs.countryCode 
								WHERE countryId = '151' AND UPPER(Replace(rcs.stateName,char(9),''))=UPPER(@stateName))	
					            WHEN NOT EXISTS(SELECT 'A' FROM tblServicewiseLocation (NOLOCK) WHERE countryId = @countryId) THEN '0'
					            ELSE (SELECT rowId FROM tblServicewiseLocation (NOLOCK) WHERE countryId = @countryId AND isActive = 1 AND location=@stateName)
					            END;
		
			SET @districtId  =CASE WHEN @countryId='151' then 
			                       (SELECT rcs.rowId 
								   FROM dbo.countriesStates rcs WITH(NOLOCK) INNER JOIN dbo.countryMaster cm WITH(NOLOCK) ON cm.countryCode = rcs.countryCode 
								   WHERE countryId = '151' AND UPPER(Replace(rcs.stateName,char(9),''))=UPPER(@districtName))	
								   WHEN NOT EXISTS(SELECT 'A' FROM tblSubLocation (NOLOCK) WHERE locationId = @stateId) THEN '0'
				                   ELSE (SELECT rowId FROM tblSubLocation (NOLOCK) WHERE locationId = @stateId AND subLocation=@districtName AND isActive = 1)
				                   END;	

			UPDATE receiverInformation SET 
				 firstName		= @firstName						
				,middleName		= @middleName
				,lastName1		= @lastName
				,lastName2		= ''
				,country		= CASE WHEN @country IS NOT NULL THEN (SELECT cm.countryName FROM dbo.countryMaster cm(NOLOCK) WHERE cm.countryId=@country)	
									   ELSE country
									   END
				,[address]		= @address
				,[state]		= CASE WHEN @state IS NOT NULL THEN @stateText ELSE [state] END	
				,district       = CASE WHEN @district IS NOT NULL THEN @districtText ELSE [district] END
				
				,city			= @city
				,email			= @email
				,purposeOfRemit = CASE WHEN @purpose IS NOT NULL THEN (SELECT sv.detailTitle FROM dbo.staticDataValue sv(NOLOCK) WHERE sv.valueId=@purpose)	
									   ELSE purposeOfRemit
									   END
				,mobile			= @mobile
				,relationship	= CASE WHEN @relation IS NOT NULL THEN (SELECT sv.detailTitle FROM dbo.staticDataValue sv(NOLOCK) WHERE sv.valueId=@relation)	
									   ELSE relationship
									   END
				,idType = @idType
				,idNumber = @idNumber
			WHERE receiverId = @recipientId

			SELECT TOP 1 errorCode	= '0'
				,recipientId	= receiverId
				,firstname		  
				,middlename		  
				,lastname		= ISNULL(lastName1,'')+ISNULL(' '+lastName2,'')
				,fullname       = firstname +ISNULL(' ' + middlename,'') + ISNULL(' ' + lastName1,'')
				,[address]		= [address]
				,city
				,[state]
				,[stateId]      = ISNULL(@state,@stateId)	
				,district
				,districtId     = ISNULL(@district,@districtId)	  
				,country	
				,countryId		= cm.countryId	  
				,relation		= relationship
				,relationId		= rel.valueId
				,mobile
				,email
				,transferReason = purposeOfRemit
				,reasonId		= rsn.valueId
				,dpUrl			= ''
				,userId			= @userId
				,countryCode	= cm.countryCode
				,idType			=  rec.idType
				,idNumber		= rec.idNumber
			FROM receiverInformation rec(NOLOCK)
			LEFT JOIN staticdatavalue rel (NOLOCK) ON rec.relationship=rel.detailTitle
			LEFT JOIN staticdatavalue rsn (NOLOCK) ON rec.purposeOfRemit=rsn.detailTitle
			LEFT JOIN countryMaster cm(NOLOCK) ON rec.country=cm.countryName
			WHERE receiverId =@recipientId
			RETURN
		END
		ELSE
		BEGIN
			SELECT '1' errorCode,'Receiver with '+@recipientId+' not found.' msg,id=@recipientId
		END
	END
	ELSE IF @flag='d'
	BEGIN
		--DELETE FROM receiverInformation WHERE receiverId=@recipientId
		
		UPDATE receiverInformation SET isActive = 0, DeletedBy = 'Customer:Mobile App', DeletedDate = GETDATE(), IsDeleted = 'Y' WHERE receiverId=@recipientId

		SELECT '0' errorCode,'Receiver Deleted Successfully.' msg,id=@recipientId
		RETURN
	END
	ELSE IF @flag='s_id'
	BEGIN

		SELECT @userId=ur.username,@countryId=cm.countryId,@stateName=ri.state,@districtName=ri.district
		FROM mobile_userRegistration ur(NOLOCK)
		INNER JOIN receiverInformation ri (NOLOCK) ON ur.customerId=ri.customerId
		INNER JOIN dbo.countryMaster cm(NOLOCK) ON UPPER(cm.countryName)=UPPER(ri.country)
		WHERE ri.receiverId=@recipientId AND ISNULL(ri.isActive,1) = 1

		SET @stateId  =CASE WHEN @countryId='151' then 
							(SELECT rcs.rowId 
							FROM dbo.countriesStates rcs WITH(NOLOCK) INNER JOIN dbo.countryMaster cm WITH(NOLOCK) ON cm.countryCode = rcs.countryCode 
							WHERE countryId = '151' AND UPPER(Replace(rcs.stateName,char(9),''))=UPPER(@stateName))	
							WHEN NOT EXISTS(SELECT 'A' FROM tblServicewiseLocation (NOLOCK) WHERE countryId = @countryId) THEN '0'
							ELSE (SELECT rowId FROM tblServicewiseLocation (NOLOCK) WHERE countryId = @countryId AND isActive = 1 AND location=@stateName)
							END;
		
		SET @districtId  =CASE WHEN @countryId='151' then 
								(SELECT rcs.rowId 
								FROM dbo.countriesStates rcs WITH(NOLOCK) INNER JOIN dbo.countryMaster cm WITH(NOLOCK) ON cm.countryCode = rcs.countryCode 
								WHERE countryId = '151' AND UPPER(Replace(rcs.stateName,char(9),''))=UPPER(@districtName))	
								WHEN NOT EXISTS(SELECT 'A' FROM tblSubLocation (NOLOCK) WHERE locationId = @stateId) THEN '0'
					ELSE (SELECT rowId FROM tblSubLocation (NOLOCK) WHERE locationId = @stateId AND subLocation=@districtName AND isActive = 1)
								END;	

		SELECT TOP 1 errorCode	= '0'
				,recipientId	= receiverId
				,firstname		  
				,middlename		  
				,lastname		= ISNULL(lastName1,'')+ISNULL(' '+lastName2,'')
				,fullname       = firstname +ISNULL(' ' + middlename,'') + ISNULL(' ' + lastName1,'')+ISNULL(' '+lastName2,'')
				,[address]		= [address]
				,city
				,[state]
				,[stateId]	    = @stateId
				,district
				,districtId		= @districtId
				,country	
				,countryId		= cm.countryId	  
				,relation		= relationship
				,relationId		= rel.valueId
				,mobile
				,email
				,transferReason = purposeOfRemit
				,reasonId		= rsn.valueId
				,dpUrl			= ''
				,userId			= rec.customerId
				,countryCode	= cm.countryCode
				,idType			= rec.idType
				,idNumber		= rec.idNumber
			FROM receiverInformation rec(NOLOCK)
			LEFT JOIN staticdatavalue rel (NOLOCK) ON rec.relationship=rel.detailTitle
			LEFT JOIN staticdatavalue rsn (NOLOCK) ON rec.purposeOfRemit=rsn.detailTitle
			LEFT JOIN countryMaster cm(NOLOCK) ON rec.country=cm.countryName
			WHERE receiverId =@recipientId AND ISNULL(rec.isActive,1) = 1
		RETURN
		
	END
	ELSE IF @flag='s_all'
	BEGIN
		SELECT @customerId=cm.customerId 
		FROM dbo.customerMaster(NOLOCK) cm
		WHERE cm.email = @userId 
		--OR cm.mobile=@userId

		IF @customerId IS NULL
			SET @customerId =  -1

		IF NULLIF(@size, 0) IS NULL
			SET @size =  -1

		IF NULLIF(@page, 0) IS NULL
			SET @page =  1
		ELSE
			SET @page += 1

		DECLARE	@sql VARCHAR(MAX)
		SET @sql = '
					SELECT recipientId	
							,firstname		
							,middlename		
							,lastname		
							,fullname       
							,[address]		
							,city
							,[state]
							,[stateId]
							,district	
							,districtId	
							,country	
							,countryId	
							,relation		
							,relationId		
							,mobile
							,email
							,transferReason 
							,reasonId		
							,dpUrl			
							,userId	
							,countryCode	
							,idType	
							,idNumber	
					FROM ( 
							SELECT ROW_NUMBER() OVER (ORDER BY receiverId  DESC) rowid_by_ROW_NUMBER
									,recipientId	= receiverId
									,firstname		  
									,middlename		  
									,lastname		= lastName1+ ISNULL('' '' + lastName2,'''')
									,fullname       =firstname +ISNULL('' '' + middlename,'''') + ISNULL('' '' + lastName1,'''')+ ISNULL('' '' + lastName2,'''')
									,[address]		= [address]
									,city
									,[state]
									,stateId        = CASE WHEN cm.countryId=''151'' THEN rcs.rowId
														   WHEN NOT EXISTS(SELECT ''A'' FROM tblServicewiseLocation (NOLOCK) WHERE countryId = cm.countryId) THEN ''0''  
														   ELSE (SELECT top 1 rowId FROM tblServicewiseLocation (NOLOCK) WHERE countryId = cm.countryId AND isActive = 1 AND location=rec.state)
													       END
									,district	
									,[districtId]   = CASE WHEN cm.countryId=''151'' THEN rcd.rowId
														   WHEN NOT EXISTS(SELECT ''A'' FROM tblSubLocation (NOLOCK) WHERE subLocation = rec.district) THEN ''0''
														   ELSE (SELECT top 1 rowId FROM tblSubLocation (NOLOCK) WHERE subLocation = rec.district AND locationId=swl.rowId AND isActive = 1)
				                                           END 
									,country	
									,countryId		= cm.countryId		  
									,relation		= relationship
									,relationId		= rel.valueId
									,mobile
									,email
									,transferReason = purposeOfRemit
									,reasonId		= rsn.valueId
									,dpUrl			=''''
									,userId			= '''+@userId+'''
									,countryCode	= cm.countryCode
									,idType			= rec.idType
									,idNumber		= rec.idNumber
							FROM receiverInformation rec(NOLOCK)
							LEFT JOIN staticdatavalue rel (NOLOCK) ON rec.relationship=rel.detailTitle and rel.IS_DELETE is null
							LEFT JOIN staticdatavalue rsn (NOLOCK) ON rec.purposeOfRemit=rsn.detailTitle and rsn.IS_DELETE is null and rsn.typeID = 3800
							LEFT JOIN countryMaster cm(NOLOCK) ON rec.country=cm.countryName
							LEFT JOIN countriesStates rcs(nolock) on UPPER(Replace(rcs.stateName,char(9),''''))=UPPER(rec.state)
							LEFT JOIN countriesStates rcd(nolock) on UPPER(Replace(rcd.stateName,char(9),''''))=UPPER(rec.district)
							LEFT JOIN tblServiceWiseLocation swl(nolock) on UPPER(swl.location)=UPPER(rec.state)
							WHERE customerId = '''+@customerId+''' and rec.isActive=1
					) x where 1=1 ' 
				+ CASE 
					WHEN @size <> -1 THEN '
						and rowid_by_ROW_NUMBER BETWEEN ' 
						+ CAST(((@page - 1) * @size + 1) AS VARCHAR(50)) 
						+ ' AND ' + CAST((@page * @size) AS VARCHAR(50))
					ELSE ''
					END

			IF	@search IS NOT NULL
			BEGIN
				SET @sql = @sql + '  AND (x.fullName LIKE ''%'+@search+'%'' OR x.mobile LIKE ''%'+@search+'%'' )'
			END
			SET @sql = @sql + ' ORDER BY x.recipientId DESC'
				
		--PRINT @sql
		EXEC (@sql)

		--SELECT '0' errorCode,'Success.' msg,id=@customerId

		----EXEC  mobile_proc_receiverSetup  @flag = 's_all',@userId = 'kamalbhusal2010@gmail.com' , @page = 0, @size =10,@search = 'K'
		
		RETURN
	END
END




GO
