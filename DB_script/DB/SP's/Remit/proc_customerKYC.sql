--EXEC [proc_customerKYC] @flag = 's', @customerId ='39470'  ,@pageNumber='1', @pageSize='10', @sortBy='rowId', @sortOrder='ASC', @user = 'admin'
USE FastMoneyPro_Remit
GO
 
ALTER PROC [dbo].[proc_customerKYC]
	@flag				VARCHAR(50),			
	@user				VARCHAR(30)			=	NULL,
	@customerId			INT					=	NULL,
	@kycMethod			VARCHAR(30)			=	NULL,
	@kycStatus			VARCHAR(30)			=	NULL,
	@selecteddate		VARCHAR(30)			=	null,
	@remarkstext		NVARCHAR(200)		=	NULL,
	@pageSize			INT					=	NULL,
	@pageNumber			INT					=	NULL,
	@sortBy				VARCHAR(50)			=	NULL,
	@sortOrder			VARCHAR(5)			=	NULL,  
	@trackingNo			VARCHAR(20)			=	NULL,
	@rowId				VARCHAR(20)			=	NULL
AS
SET NOCOUNT ON;  
SET XACT_ABORT ON;
BEGIN TRY 
	DECLARE @errorMessage VARCHAR(MAX),
	   @sql    VARCHAR(MAX)  
	  ,@table    VARCHAR(MAX)  
	  ,@select_field_list VARCHAR(MAX)  
	  ,@extra_field_list VARCHAR(MAX)  
	  ,@sql_filter  VARCHAR(MAX)
	  ,@isExists BIT 


	IF @flag = 'i'
	BEGIN
		IF @kycStatus!='11044' AND EXISTS(SELECT 1
					FROM dbo.TBL_CUSTOMER_KYC (NOLOCK) 
					WHERE customerId = @customerId 
					AND kycMethod = @kycMethod 
					AND kycStatus = @kycStatus
					AND isDeleted = 0)
		BEGIN
			SET @isExists=1
			
		END
		IF @kycStatus='11044' AND EXISTS(SELECT 1 FROM dbo.TBL_CUSTOMER_KYC WHERE customerId=@customerId AND kycStatus='11044' AND isDeleted <> '1')
		BEGIN
		    SET @isExists=1
		END
		IF @isExists=1
		BEGIN
		    EXEC dbo.proc_errorHandler '1', 'Data already exist', NULL 
			RETURN
		END
		INSERT INTO TBL_CUSTOMER_KYC (customerId,kycmethod,kycStatus,remarks,createdBy,createdDate,trackingNo,KYC_DATE)
							  VALUES (@customerId,@kycmethod,@kycstatus,@remarkstext,@user,GETDATE(),@trackingNo,@selecteddate);
		EXEC dbo.proc_errorHandler '0', 'Customer KYC inserted successfully', NULL 
		RETURN
	END
	ELSE IF @Flag='dropdownListMethod'
	BEGIN
		SELECT valueId [value],detailTitle [text] from staticdatavalue(NOLOCK) where typeid=7007  AND ISNULL(ISActive,'Y')='Y'
		RETURN
	END
	ELSE IF @Flag='dropdownListStatus'
	BEGIN
		SELECT valueId [value],detailTitle [text] from staticdatavalue(NOLOCK) where typeid=7008  AND ISNULL(ISActive,'Y')='Y'
		RETURN
	END
	IF @flag = 'd'
	BEGIN	
		UPDATE TBL_CUSTOMER_KYC SET isDeleted = 1, deletedBy = @user, deletedDate = GETDATE() 
		WHERE rowId = @rowId
		
		--DELETE FROM dbo.TBL_CUSTOMER_KYC WHERE rowId = @rowId
		EXEC dbo.proc_errorHandler '0', 'Customer KYC deleted successfully', NULL 
		RETURN
	END
	IF @flag = 's'
	BEGIN	
		IF @sortBy IS NULL
		   SET @sortBy = 'createdDate'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'DESC'
		 SET @table = '(
		SELECT C.detailTitle kycMethod,rowId,B.detailTitle kycStatus,
				A.remarks,A.createdBy,A.createdDate
				,trackingNo = ''<a href="javascript:void(0);" onclick="OpenInNewWindow(''''/Common/JPPostKYCInquiry.aspx?tranckingNumber=''+A.trackingNo+''&membershipId=''+CM.membershipId+''&dt=''+CONVERT(VARCHAR(10), CM.CREATEDDATE, 120)+'''''')">''+A.trackingNo+''</a>''
		FROM dbo.TBL_CUSTOMER_KYC  A (nolock) 
		INNER JOIN CUSTOMERMASTER CM(NOLOCK) ON CM.CUSTOMERID = A.CUSTOMERID
		INNER JOIN STATICDATAVALUE B (NOLOCK) ON A.kycStatus = B.valueId
		INNER JOIN STATICDATAVALUE C (NOLOCK) ON A.kycMethod = C.valueId 
		WHERE A.CustomerId = '''+CAST(@customerId AS VARCHAR)+'''
		AND ISNULL(A.isDeleted, 0) = 0
		)x'
	
		SET @sql_filter = ''

		--IF @kycMethod='11048'
		--BEGIN
		--		SET @sql_Filter=@sql_Filter + ' AND kycmethod like ''' +@kycMethod+'%'''
	
		--END

		SET @select_field_list ='kycMethod,rowId,kycStatus,remarks,createdBy,createdDate,trackingNo'
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
END TRY 
BEGIN CATCH	
	IF @@TRANCOUNT > 0  
     ROLLBACK TRANSACTION  
     SET @errorMessage = ERROR_MESSAGE() 
	 EXEC dbo.proc_errorHandler 1, @errorMessage, NULL
END CATCH
