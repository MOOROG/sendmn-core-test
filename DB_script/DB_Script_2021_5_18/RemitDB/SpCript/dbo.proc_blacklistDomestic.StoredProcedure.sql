USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_blacklistDomestic]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[proc_blacklistDomestic](
	 @flag				varchar(10)		= NULL
	,@user				varchar(30)		= NULL
	,@rowId				int				= NULL 
	,@customerCardNo	varchar(40)		= NULL
	,@membershipId		varchar(40)		= NULL
	,@Name				varchar(100)	= NULL
	,@Address			varchar(100)	= NULL
	,@country			varchar(30)		= NULL
	,@district			varchar(30)		= NULL
	,@zone				varchar(30)		= NULL
	,@IdType			varchar(30)		= NULL
	,@IdNumber			varchar(30)		= NULL
	,@Dob				varchar(30)		= NULL
	,@FatherName		varchar(60)		= NULL
	,@Remarks			varchar(500)	= NULL
	,@isActive			varchar(2)		= NULL
	,@sortBy            VARCHAR(50)		= NULL
	,@sortOrder         VARCHAR(5)		= NULL
	,@pageSize          INT				= NULL
	,@pageNumber        INT				= NULL
	,@ofacKey			VARCHAR(50)		= NULL
	,@contact			VARCHAR(50)		= NULL
	,@idPlaceIssue		VARCHAR(50)		= NULL
	,@entNum			VARCHAR(50)		= NULL
	,@vesselType		VARCHAR(50)		= NULL
	,@dataSource		VARCHAR(50)		= NULL
)AS
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE  @table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)

BEGIN
	If @flag='i'
	BEGIN
		/*
			SELECT TOP 1 * FROM dbo.blacklist
			ALTER TABLE blacklist ADD membershipId VARCHAR(16),district VARCHAR(100),idType VARCHAR(100),idNumber VARCHAR(50),
				dob VARCHAR(30),FatherName VARCHAR(200),isActive CHAR(1)
			ALTER TABLE blacklistHistory ADD membershipId VARCHAR(16),district VARCHAR(100),idType VARCHAR(100),idNumber VARCHAR(50),
				dob VARCHAR(30),FatherName VARCHAR(200),isActive CHAR(1)
		*/
		INSERT INTO blacklist( 
			  membershipId	
			 ,Name			
			 ,Address		
			 ,country		
			 ,district		
			 ,state			
			 ,IdType			
			 ,IdNumber		
			 ,Dob			
			 ,FatherName		
			 ,Remarks		
			 ,isActive		
			 ,createdBy		
			 ,createdDate
			 ,isManual
			 ,dataSource
			 ,vesselType
			 ,idPlaceIssue
			 ,contact
		)SELECT 
			 @customerCardNo	
			,@Name				
			,@Address			
			,@country			
			,@district			
			,@zone				
			,@IdType			
			,@IdNumber			
			,@Dob				
			,@FatherName		
			,@Remarks			
			,@isActive	
			,@user
			,GETDATE()
			,'d'
			,'Manual'
			,'sdn'
			,@idPlaceIssue
			,@contact
		SET @rowId =  SCOPE_IDENTITY()	
		UPDATE dbo.blacklist 
			SET entNum = @rowId, 
				ofacKey = 'Manual'+CAST(@rowId AS VARCHAR) 
		WHERE rowId = @rowId

		INSERT INTO blacklistHistory
						(
						     blackListId
							,ofacKey
							,entNum
							,name
							,vesselType
							,address
							,state
							,country
							,remarks
							,dataSource
							,createdDate
							,createdBy
							,isManual
							,membershipId
							,district
							,IdType			
							,IdNumber		
							,Dob			
							,FatherName
							,isActive	
							)
					VALUES(
							 @rowId
							,'Manual'+CAST(@rowId AS VARCHAR)
							,@rowId
							,@name
							,'sdn'
							,@address
							,@zone
							,@country
							,@remarks
							,'Manual'
							,GETDATE()
							,@user
							,'d'
							,@customerCardNo
							,@district
							,@IdType			
							,@IdNumber		
							,@Dob			
							,@FatherName
							,'Y')

		SELECT '0' errorCode,'Compliance Successfully added' msg,null
		RETURN

	END
	IF @flag='u'
	BEGIN
		UPDATE blacklist SET
			  membershipId= @customerCardNo
			 ,Name			= @Name
			 ,Address		= @Address
			 ,country		= @country
			 ,district		= @district
			 ,state			= @zone
			 ,IdType		= @IdType
			 ,IdNumber		= @IdNumber
			 ,Dob			= @Dob
			 ,FatherName	= @FatherName
			 ,Remarks		= @Remarks	
			 ,isActive		= @isActive	
			 ,modifiedBy	= @user
			 ,modifiedDate	= GETDATE()
		WHERE rowId=@rowId 

		UPDATE blacklistHistory SET
			  membershipId	= @customerCardNo
			 ,Name			= @Name
			 ,Address		= @Address
			 ,country		= @country
			 ,district		= @district
			 ,state			= @zone
			 ,IdType		= @IdType
			 ,IdNumber		= @IdNumber
			 ,Dob			= @Dob
			 ,FatherName	= @FatherName
			 ,Remarks		= @Remarks	
			 ,isActive		= @isActive	
			 ,modifiedBy	= @user
			 ,modifiedDate	= GETDATE()
		WHERE blackListId = @rowId	

		SELECT '0' errorCode,'Compliance Successfully updated' msg,null
		RETURN

	END	

	IF @flag='a'
	BEGIN
		IF @sortBy IS NULL
			SET @sortBy = 'rowId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'DESC'
		SET @table = '(
				SELECT  rowId			
					   ,membershipId	
					   ,Name			
					   ,Address		
					   ,country			  		
					   ,IdType			
					   ,IdNumber		
					   ,Dob
					   ,isActive=case when isnull(isActive,''Y'')=''Y'' then ''Yes'' ELSE ''No'' END 				 	
					   ,createdBy		
					   ,createdDate
					   ,state
					   ,district
					   ,ofacKey
				FROM dbo.blacklist with(nolock) where isManual = ''d''
			) x'
					
		SET @sql_filter = ''
		
		IF @customerCardNo IS NOT NULL
			SET @sql_filter=@sql_filter+'AND customerCardNo='+@customerCardNo
		IF @Name IS NOT NULL
			SET @sql_filter=@sql_filter+'AND Name like ''%'+@Name+'%'''

		IF @ofacKey IS NOT NULL
			SET @sql_filter=@sql_filter+'AND ofacKey  = '''+@ofacKey+''''		
							
		SET @select_field_list ='
			 rowId			
			,membershipId	
			,Name			
			,Address		
			,country			  		
			,IdType			
			,IdNumber		
			,Dob
			,isActive				 	
			,createdBy		
			,createdDate
			,state
			,district
			,ofacKey
			'

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
	IF @flag='s'
	BEGIN
		SELECT membershipId	
			 ,Name			
			 ,Address		
			 ,country		
			 ,district		
			 ,state			
			 ,IdType			
			 ,IdNumber		
			 ,Dob			
			 ,FatherName		
			 ,Remarks		
			 ,isActive		
			 ,createdBy		
			 ,createdDate 
		FROM dbo.blacklist WITH(NOLOCK) WHERE rowId=@rowId
	END
END


GO
