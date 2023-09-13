ALTER PROC PROC_NEWCUSTOMERREGISTRATION
	@flag					VARCHAR(50)
	,@user				    VARCHAR(50)			= NULL
	,@pageNumber		    INT					= NULL
	,@pageSize			    INT					= NULL
	,@sBranch			    VARCHAR(10)			= NULL
	,@fromDate				VARCHAR(10)			= NULL
	,@toDate				VARCHAR(10)			= NULL
	,@sortBy                VARCHAR(50)			= NULL    
	,@sortOrder             VARCHAR(5)			= NULL    
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
IF @flag = 'st'
BEGIN
	DECLARE 
		 @select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@sql_filter        VARCHAR(MAX)
		,@sAgent			INT

		SET @toDate = @toDate + ' 23:59:59'

          IF @sortBy = 'SN'
              SET @sortBy = NULL;
          IF @sortBy IS NULL
              SET @sortBy = 'customerId';
          IF @sortOrder IS NULL
              SET @sortOrder = 'ASC';
          SET @table = '
			 (
			SELECT  cm.customerId
					,cm.firstName+ '' '' + COALESCE(cm.middleName + '' '','''') + COALESCE(cm.lastName1 + '' '','''') + ISNULL(cm.lastName2,'''') [CustomerName]
					,cm.mobile
					,cm.zipCode
					,isnull(csm.stateName, '''') + '',''+ ISNULL(cm.city,'''') + '','' + ISNULL(cm.street,'''') address
					,com.countryName NativeCountry 
					,sdv.detailTitle Occupation
					,cm.dob 
					,sdv1.detailTitle IdType
					,cm.idNumber
					,Gender = CASE WHEN ISNULL(cm.gender,'''') = ''98'' THEN ''Female'' ELSE ''Male'' END
					,cm.createdDate CustomerCreatedDate
					,cm.createdBy
					,cm.approvedBy
					,sdv2.detailTitle CustomerType
					,kyc.kycMethod
					,kyc.kycStatus
					,kyc.createdDate KycCreatedDate
					FROM dbo.customerMaster cm
					LEFT JOIN dbo.TBL_CUSTOMER_KYC kyc ON kyc.customerId = cm.customerId
					LEFT JOIN dbo.countryStateMaster csm ON csm.stateId = cm.state
					LEFT JOIN dbo.countryMaster com ON com.countryId = cm.country
					LEFT JOIN dbo.staticDataValue sdv ON sdv.valueId = cm.occupation
					LEFT JOIN dbo.staticDataValue sdv1 ON sdv1.valueId = cm.idType
					LEFT JOIN dbo.staticDataValue sdv2 ON sdv2.valueId = cm.customerType
					where cm.createddate between '''+@fromDate+''' and '''+@toDate+'''
			 '; 
          SET @sql_filter = ''; 
    --      IF @customerId IS NOT NULL and @customerId <> ''
    --          SET @table = @table + ' where ri.customerId = '''+@customerId+'''';	
		  --SET @table = @table + ')tb on trl.customerId =tb.receiverid';
          SET @table = @table + ' )x';
		
          PRINT @table;
         SET @select_field_list = 'customerId,CustomerName,mobile,zipCode,address,NativeCountry,Occupation,dob,IdType,idNumber,Gender,CustomerCreatedDate,createdBy,approvedBy,CustomerType,kycMethod,kycStatus,KycCreatedDate';
	    --SELECT @table, @sql_filter, @select_field_list,@extra_field_list, @sortBy, @sortOrder, @pageSize,@pageNumber
          EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,@extra_field_list, @sortBy, @sortOrder, @pageSize,@pageNumber;
		  --SELECT 2
END
IF @flag = 's'
BEGIN
	SELECT  cm.customerId
					,cm.firstName+ ' ' + COALESCE(cm.middleName + ' ','') + COALESCE(cm.lastName1 + ' ','') + ISNULL(cm.lastName2,'') [CustomerName]
					,cm.mobile
					,cm.zipCode
					,isnull(csm.stateName, '') + ','+ ISNULL(cm.city,'') + ',' + ISNULL(cm.street,'') address
					,com.countryName NativeCountry 
					,sdv.detailTitle Occupation
					,cm.dob 
					,sdv1.detailTitle IdType
					,cm.idNumber
					,Gender = CASE WHEN ISNULL(cm.gender,'') = '98' THEN 'Female' ELSE 'Male' END
					,cm.createdDate CustomerCreatedDate
					,cm.createdBy
					,cm.approvedBy
					,sdv2.detailTitle CustomerType
					,sdv3.detailTitle kycMethod
					,sdv4.detailTitle kycStatus
					,kyc.createdDate KycCreatedDate
					FROM dbo.customerMaster cm
					LEFT JOIN dbo.TBL_CUSTOMER_KYC kyc ON kyc.customerId = cm.customerId
					LEFT JOIN dbo.countryStateMaster csm ON csm.stateId = cm.state
					LEFT JOIN dbo.countryMaster com ON com.countryId = cm.country
					LEFT JOIN dbo.staticDataValue sdv ON sdv.valueId = cm.occupation
					LEFT JOIN dbo.staticDataValue sdv1 ON sdv1.valueId = cm.idType
					LEFT JOIN dbo.staticDataValue sdv2 ON sdv2.valueId = cm.customerType
					LEFT JOIN dbo.staticDataValue sdv3 ON sdv3.valueId = kyc.kycMethod
					LEFT JOIN dbo.staticDataValue sdv4 ON sdv4.valueId = kyc.kycStatus
					INNER JOIN dbo.applicationUsers au ON au.firstName = cm.createdBy
					INNER JOIN dbo.agentMaster am ON am.agentId = au.agentId
					where cm.createddate between @fromDate and @toDate
					AND am.agentId = @sBranch

	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL    
	DECLARE @sBranchName VARCHAR(50)
	SELECT @sBranchName = agentName FROM dbo.agentMaster WHERE agentId = @sBranch
	SELECT 'Sending Branch' head,isnull(@sBranchName,'All') value  
	UNION ALL    
	SELECT 'From Date' head,@fromDate VALUE    
	UNION ALL    
	SELECT 'To Date' head,@toDate VALUE     

	SELECT 'New Customer Registration Report(New Customer Registration Report)' title    
END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	BEGIN
		SELECT '1' ErrorCode,'Error in new customer registration report' Msg,NULL id
	END
END CATCH