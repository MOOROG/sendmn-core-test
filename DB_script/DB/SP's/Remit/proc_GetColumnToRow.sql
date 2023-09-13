SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
  
ALTER PROC [dbo].[proc_GetColumnToRow](  
  @tableName  VARCHAR(100)  
 ,@fieldName  VARCHAR(50)  
 ,@dataId  VARCHAR(50)  
 ,@dataList  NVARCHAR(MAX) = NULL OUTPUT  
 ,@returnTable CHAR(1)   = NULL   
)  
AS  
BEGIN  
 SET NOCOUNT ON  
 DECLARE @separator VARCHAR(10)  
 SET @separator = '-:::-'  
 IF @tableName IN ('applicationUserRoles')  
 BEGIN  
  SELECT  
   @dataList = ISNULL(@dataList + ',', '') + CAST(aur.roleId AS VARCHAR(50))     
  FROM applicationUserRoles aur WHERE aur.[userId] = @dataId  
    
  IF @returnTable = 'Y'  
  SELECT @dataList  
  RETURN   
 END  
 ELSE IF @tableName IN ('applicationUserRolesMod')  
 BEGIN  
  SELECT  
   @dataList = ISNULL(@dataList + ',', '') + CAST(aur.roleId AS VARCHAR(50))     
  FROM applicationUserRolesMod aur WHERE aur.[userId] = @dataId  
    
  IF @returnTable = 'Y'  
  SELECT @dataList  
    
  RETURN   
 END   
 ELSE IF @tableName IN ('applicationRoleFunctions')  
 BEGIN  
  SELECT  
   @dataList = ISNULL(@dataList + ',', '') + arf.functionId   
  FROM applicationRoleFunctions arf WHERE arf.roleId = @dataId  
    
  IF @returnTable = 'Y'  
  SELECT @dataList  
  RETURN  
 END  
 ELSE IF @tableName IN ('applicationRoleFunctionsMod')  
 BEGIN  
  SELECT  
   @dataList = ISNULL(@dataList + ',', '') + arf.functionId   
  FROM applicationRoleFunctionsMod arf WHERE arf.roleId = @dataId  
    
  IF @returnTable = 'Y'  
   SELECT @dataList  
     
  RETURN  
 END   
 ELSE IF @tableName IN ('applicationUserFunctions')  
 BEGIN   
  SELECT  
   @dataList = ISNULL(@dataList + ',', '') + auf.functionId   
  FROM applicationUserFunctions auf WHERE auf.[userId] = @dataId  
    
  IF @returnTable = 'Y'  
   SELECT @dataList  
     
  RETURN  
 END   
 ELSE IF @tableName IN ('applicationUserFunctionsMod')  
 BEGIN  
  SELECT  
   @dataList = ISNULL(@dataList + ',', '') + auf.functionId   
  FROM applicationUserFunctionsMod auf WHERE auf.[userId] = @dataId  
    
  IF @returnTable = 'Y'  
   SELECT @dataList  
     
  RETURN  
 END   
 ELSE IF @tableName IN ('commissionPackage', 'commissionPackageHistory')  
 BEGIN  
  IF @returnTable = 'Y'  
   SELECT @dataId  
  RETURN  
 END  
 ELSE IF @tableName IN ('agentGroup')  
 BEGIN  
  SELECT  
   @dataList = ISNULL(@dataList + ',', '') + CAST(ag.agentId AS VARCHAR(50))   
  FROM agentGroup ag WHERE ag.groupId = @dataId  
    
  IF @returnTable = 'Y'  
  SELECT @dataList  
  RETURN  
 END  
 ELSE IF @tableName IN ('agentGroupMod')  
 BEGIN  
  SELECT  
   @dataList = ISNULL(@dataList + ',', '') + CAST(agm.agentId AS VARCHAR(50))   
  FROM agentGroupMod agm WHERE agm.groupId = @dataId  
    
  IF @returnTable = 'Y'  
   SELECT @dataList  
     
  RETURN  
 END   
 ELSE IF @tableName IN ('csCriteria')  
 BEGIN  
  SELECT  
   @dataList = ISNULL(@dataList + ',', '') + CAST(csc.criteriaId AS VARCHAR(50))  
  FROM csCriteria csc WHERE csc.csDetailId = @dataId  
    
  IF @returnTable = 'Y'  
  SELECT @dataList  
  RETURN  
 END  
 ELSE IF @tableName IN ('csCriteriaHistory')  
 BEGIN  
  SELECT  
   @dataList = ISNULL(@dataList + ',', '') + CAST(csch.criteriaId AS VARCHAR(50))  
  FROM csCriteriaHistory csch WHERE csch.csDetailId = @dataId AND csch.approvedBy IS NULL  
    
  IF @returnTable = 'Y'  
  SELECT @dataList  
  RETURN  
 END  
 ELSE IF @tableName IN ('cisCriteria')  
 BEGIN  
  SELECT  
   @dataList = ISNULL(@dataList + ',', '') + CAST(csc.criteriaId AS VARCHAR(50))  
  FROM cisCriteria csc WHERE csc.cisDetailId = @dataId  
    
  IF @returnTable = 'Y'  
  SELECT @dataList  
  RETURN  
 END  
 ELSE IF @tableName IN ('cisCriteriaHistory')  
 BEGIN  
  SELECT  
   @dataList = ISNULL(@dataList + ',', '') + CAST(csch.criteriaId AS VARCHAR(50))  
  FROM cisCriteriaHistory csch WHERE csch.cisDetailId = @dataId AND csch.approvedBy IS NULL  
    
  IF @returnTable = 'Y'  
  SELECT @dataList  
  RETURN  
 END  
 DECLARE @columnList TABLE(columnName NVARCHAR(500))  
 DECLARE @table NVARCHAR(MAX)   
   
 --Application Role   
 IF @tableName = 'applicationRoles'  
 BEGIN  
  INSERT @columnList(columnName)  
  SELECT 'Name'  
   
      SET @table='(  
                   SELECT TOP 1  
        roleName [Name]  
                   FROM applicationRoles ar WITH(NOLOCK)  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''   
                        ORDER BY ar.createdDate DESC  
                  )x '   
 END  
   
 --IP Blacklist  
 IF @tableName IN ('IPBlacklist', 'IPBlacklistMod')  
 BEGIN  
  INSERT @columnList(columnName)  
  SELECT 'IP Address' UNION ALL  
  SELECT 'Message' UNION ALL  
  SELECT 'Reason' UNION ALL  
  SELECT 'Is Enable'  
      
     SET @table='(  
                   SELECT TOP 1  
                          [IP Address]    = IPAddress   
                         ,[Message]     = msg  
                         ,[Reason]     = reason  
       ,[Is Enable]    = CASE WHEN isEnable = ''Y'' THEN ''Yes'' ELSE ''No'' END               
                   FROM ' + @tableName + ' WITH(NOLOCK)  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''    
                  )x '   
 END  
   
 --Maintenance Plan  
 IF @tableName IN ('maintenancePlan', 'maintenancePlanMod')  
 BEGIN  
  INSERT @columnList(columnName)  
  SELECT 'From Date' UNION ALL  
  SELECT 'To Date' UNION ALL  
  SELECT 'Message' UNION ALL  
  SELECT 'Reason' UNION ALL  
  SELECT 'Is Enable'  
      
     SET @table='(  
                   SELECT TOP 1  
                          [From Date]    = fromDate   
                         ,[To Date]     = toDate  
                         ,[Message]     = msg  
                         ,[Reason]     = reason  
       ,[Is Enable]    = CASE WHEN isEnable = ''Y'' THEN ''Yes'' ELSE ''No'' END               
                   FROM ' + @tableName + ' WITH(NOLOCK)  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''    
                  )x '   
 END  
   
 --Agent Master  
 IF @tableName IN ('agentMaster', 'agentMasterMod')  
 BEGIN  
  INSERT @columnList(columnName)  
  SELECT 'Name' UNION ALL  
  SELECT 'Code' UNION ALL  
  SELECT 'Address' UNION ALL  
  SELECT 'City' UNION ALL  
  SELECT 'Country' UNION ALL  
  SELECT 'State' UNION ALL  
  SELECT 'District' UNION ALL  
  SELECT 'Location' UNION ALL  
  SELECT 'Zip' UNION ALL  
  SELECT 'Phone1' UNION ALL  
  SELECT 'Phone2' UNION ALL  
  SELECT 'Fax1' UNION ALL  
  SELECT 'Fax2' UNION ALL  
  SELECT 'Mobile1' UNION ALL  
  SELECT 'Mobile2' UNION ALL  
  SELECT 'Email1' UNION ALL  
  SELECT 'Email2' UNION ALL  
  SELECT 'Bank Code' UNION ALL  
  SELECT 'Bank Branch' UNION ALL  
  SELECT 'Bank Account Number' UNION ALL  
  SELECT 'Account Holders Name' UNION ALL  
  SELECT 'Registration Type' UNION ALL  
  SELECT 'Business Type' UNION ALL  
  SELECT 'Agent Role' UNION ALL  
  SELECT 'Agent Type' UNION ALL  
  SELECT 'Allow Account Deposit' UNION ALL  
  SELECT 'Contract Expiry Date' UNION ALL  
  SELECT 'Renewal Follow-up Date' UNION ALL  
  SELECT 'Is Settling Agent' UNION ALL  
  SELECT 'Agent Group' UNION ALL  
  SELECT 'Business License' UNION ALL  
  SELECT 'Agent Block' UNION ALL  
  SELECT 'Company Name' UNION ALL  
  SELECT 'Company Address' UNION ALL  
  SELECT 'Company City' UNION ALL  
  SELECT 'Company Country' UNION ALL  
  SELECT 'Company State' UNION ALL  
  SELECT 'Company District' UNION ALL  
  SELECT 'Company Zip' UNION ALL  
  SELECT 'Company Phone1' UNION ALL  
  SELECT 'Company Phone2' UNION ALL  
  SELECT 'Company Fax1' UNION ALL  
  SELECT 'Company Fax2' UNION ALL  
  SELECT 'Company Email1' UNION ALL  
  SELECT 'Company Email2' UNION ALL  
  SELECT 'Local Time' UNION ALL  
  SELECT 'isActive' UNION ALL  
  SELECT 'Agent Details' UNION ALL  
  SELECT 'Head Message' UNION ALL  
  SELECT 'Mapcode International' UNION ALL  
  SELECT 'Mapcode Domestic' UNION ALL  
  SELECT 'Commcode International' UNION ALL  
  SELECT 'Commcode Domestic'   
      
     SET @table='(  
                   SELECT TOP 1  
                          [Name]     = agentName   
                         ,[Code]     = agentCode         
       ,Address    = agentAddress  
       ,City     = agentCity  
       ,Country    = agentCountry  
       ,State     = agentState  
       ,District    = agentDistrict  
       ,Location    = loc.districtName  
       ,Zip     = agentZip  
       ,Phone1     = agentPhone1  
       ,Phone2     = agentPhone2  
       ,Fax1     = agentFax1  
       ,Fax2     = agentFax2  
       ,Mobile1    = agentMobile1  
       ,Mobile2    = agentMobile2   
       ,Email1     = agentEmail1  
       ,Email2     = agentEmail2   
       ,[Bank Code]   = bankcode  
       ,[Bank Branch]   = bankbranch  
       ,[Bank Account Number] = bankaccountnumber  
       ,[Account Holders Name] = accountholdername  
       ,[Registration Type] = bot.detailTitle  
       ,[Business Type]  = bt.detailTitle  
       ,[Agent Role]   = CASE  WHEN agentRole = ''S'' THEN ''Send''  
               WHEN agentRole = ''R'' THEN ''Receive''  
               ELSE ''Both'' END  
       ,[Agent Type]   = sdv.detailTitle  
       ,[Allow Account Deposit]= CASE WHEN allowAccountDeposit = ''Y'' THEN ''Yes''  
                 ELSE ''No'' END   
       ,[Contract Expiry Date] = am.contractExpiryDate  
       ,[Renewal Follow-up Date] = am.renewalFollowupDate  
       ,[Is Settling Agent] = CASE WHEN am.isSettlingAgent = ''Y'' THEN ''Yes''   
               WHEN am.isSettlingAgent = ''N'' THEN ''No'' ELSE ''NC'' END  
       ,[Agent Group]   = ag.detailTitle  
       ,[Business License]     = businessLicense    
       ,[Agent Block]   = CASE  WHEN agentBlock = ''U'' THEN ''Unblock''   
               WHEN agentBlock = ''B'' THEN ''Block''  
               ELSE ''N/A'' END  
       ,[Company Name]    = agentCompanyName  
       ,[Company Address]   = companyAddress  
       ,[Company City]    = companyCity  
       ,[Company Country]   = companyCountry  
       ,[Company State]   = companyState  
       ,[Company District]   = companyDistrict  
       ,[Company Zip]    = companyZip  
       ,[Company Phone1]   = companyPhone1  
       ,[Company Phone2]   = companyPhone2  
       ,[Company Fax1]    = companyFax1  
       ,[Company Fax2]    = companyFax2  
       ,[Company Email1]   = companyEmail1  
       ,[Company Email2]   = companyEmail2  
       ,[Local Time]    = tz.name  
       ,[isActive]     = am.isActive  
       ,[Agent Details]   = agentDetails    
       ,[Head Message]       = am.headMessage  
       ,[Mapcode International] = am.mapcodeInt  
       ,[Mapcode Domestic]   = am.mapCodeDom  
       ,[Commcode International] = am.commCodeInt  
       ,[Commcode Domestic]  = am.commCodeDom               
                   FROM ' + @tableName + ' am WITH(NOLOCK)  
                   LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON am.agentType = sdv.valueId  
                   LEFT JOIN staticDataValue bt WITH(NOLOCK) ON am.businessType = bt.valueId  
                   LEFT JOIN staticDataValue ag WITH(NOLOCK) ON am.agentGrp = ag.valueId  
                   LEFT JOIN staticDataValue bot WITH(NOLOCK) ON am.businessOrgType = bot.valueId  
                   LEFT JOIN timeZones tz WITH(NOLOCK) ON am.localTime = tz.ROWID  
                   LEFT JOIN api_districtList loc WITH(NOLOCK) ON am.agentLocation = loc.districtCode  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''   
                         
                  )x '   
 END  
   
 --Application Users  
 IF @tableName IN ('applicationUsers', 'applicationUsersMod')  
 BEGIN   
  BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Salutation' UNION ALL  
   SELECT 'First Name' UNION ALL  
   SELECT 'Middle Name' UNION ALL  
   SELECT 'Last Name' UNION ALL  
   SELECT 'Gender' UNION ALL  
   SELECT 'Branch/Agent' UNION ALL  
   SELECT 'Country' UNION ALL  
   SELECT 'State' UNION ALL  
   SELECT 'District' UNION ALL  
   SELECT 'Zip' UNION ALL  
   SELECT 'City' UNION ALL  
   SELECT 'Address' UNION ALL  
   SELECT 'Phone' UNION ALL  
   SELECT 'Mobile' UNION ALL  
   SELECT 'Email' UNION ALL  
   SELECT 'Password Change Days' UNION ALL  
   SELECT 'Password Change Warning Days' UNION ALL  
   SELECT 'User Access Level' UNION ALL  
   SELECT 'Session Time out Period' UNION ALL  
   SELECT 'Login Time' UNION ALL  
   SELECT 'Logout Time' UNION ALL  
   SELECT 'Max Report View Days' UNION ALL  
   SELECT 'Send Tran From Time' UNION ALL  
   SELECT 'Send Tran To Time'  UNION ALL   
   SELECT 'Pay Tran From Time'  UNION ALL       
   SELECT 'Pay Tran To Time'  UNION ALL  
   SELECT 'Report View From Time' UNION ALL  
   SELECT 'Report View To Time' UNION ALL  
   SELECT 'User Type'   UNION ALL  
   SELECT 'Is Active'     
       
   SET @table='(  
        SELECT TOP 1  
         Salutation         = sdv1.detailTitle  
        ,[First Name]        = firstName   
        ,[Middle Name]        = middleName         
        ,[Last Name]        = lastName  
        ,Gender          = sdv2.detailTitle  
        ,[Branch/Agent]        = am.agentName  
        ,Country         = country.countryName  
        ,State          = st.stateName  
        ,District         = dist.districtName  
        ,Zip          = zip  
        ,City          = city  
        ,Address         = address  
        ,Phone          = telephoneNo   
        ,Mobile          = mobileNo  
        ,Email          = email   
        ,[isLocked]         = isLocked  
        ,[Agent Code]        = main.agentCode  
        ,[Password Change Days]      = pwdChangeDays  
        ,[Password Change Warning Days]    = pwdChangeWarningDays  
        ,[User Access Level]      = userAccessLevel  
        ,[Session Time out Period]     = sessionTimeOutPeriod  
        ,[Login Time]        = loginTime  
        ,[Logout Time]        = logoutTime       
        ,[Max Report View Days]              = maxReportViewDays   
        ,[Send Tran From Time]      = fromSendTrnTime   
        ,[Send Tran To Time]      = toSendTrnTime   
        ,[Pay Tran From Time]      = fromPayTrnTime       
        ,[Pay Tran To Time]       = toPayTrnTime   
        ,[Report View From Time]     = fromRptViewTime   
        ,[Report View To Time]      = toRptViewTime    
        ,[User Type]        = sdv3.detailDesc  
        ,[Is Active]        = case when isnull(main.isActive,''Y'') = ''Y'' then ''Yes'' else ''No'' end  
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster country WITH(NOLOCK) ON main.countryId = country.countryId  
        LEFT JOIN staticDataValue sdv1 WITH(NOLOCK) ON main.salutation = sdv1.valueId  
        LEFT JOIN staticDataValue sdv2 WITH(NOLOCK) ON main.gender = sdv2.valueId  
        LEFT JOIN countryStateMaster st WITH(NOLOCK) ON main.state = st.stateId  
        LEFT JOIN zoneDistrictMap dist WITH(NOLOCK) ON main.district = dist.districtId  
        LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agentId = am.agentId  
        LEFT JOIN staticDataValue sdv3 WITH(NOLOCK) ON main.userType = sdv3.detailTitle  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''   
                          
       )x '   
  END  
 END  
   
 --Country Currency Master  
 IF @tableName IN ('userLimit', 'userLimitMod')  
 BEGIN  
  INSERT @columnList(columnName)  
  SELECT 'Send Limit' UNION ALL  
  SELECT 'Pay Limit' UNION ALL  
  SELECT 'Currency' UNION ALL  
  SELECT 'Is Enable'  
      
     SET @table='(  
                   SELECT TOP 1  
        [Send Limit]        = main.sendLimit  
                         ,[Pay Limit]        = main.payLimit  
                         ,[Currency]         = cm.currencyCode         
       ,[Is Enable]        = CASE WHEN main.isEnable = ''Y'' THEN ''Yes'' ELSE ''No'' END               
                   FROM ' + @tableName + ' main WITH(NOLOCK)  
                   LEFT JOIN currencyMaster cm WITH(NOLOCK) ON main.currencyId = cm.currencyId  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''   
                         
                  )x '   
 END  
   
 --Country Currency Master  
 IF @tableName IN ('countryCurrencyMaster', 'countryCurrencyMasterMod')  
 BEGIN  
  INSERT @columnList(columnName)  
  SELECT 'Country Name' UNION ALL  
  SELECT 'Country Code' UNION ALL  
  SELECT 'Currency Name' UNION ALL  
  SELECT 'Currency Code' UNION ALL  
  SELECT 'Currency Description' UNION ALL  
  SELECT 'Currency Decimal Name' UNION ALL  
  SELECT 'After Decimal Count' UNION ALL  
  SELECT 'Decimal Digit Round' UNION ALL  
  SELECT 'Time Zone' UNION ALL  
  SELECT 'isActive'  
      
     SET @table='(  
                   SELECT TOP 1  
        [Country Name]        = countryName  
                         ,[Country Code]        = countryCode  
                         ,[Currency Name]       = currName         
       ,[Currency Code]       = currCode  
       ,[Currency Description]      = currDesc  
       ,[Currency Decimal Name]     = currDecimalName  
       ,[After Decimal Count]      = countAfterDecimal  
       ,[Decimal Digit Round]      = roundNoDecimal  
       ,[Time Zone]        = tz.name  
       ,[isActive]         = main.isActive               
                   FROM ' + @tableName + ' main WITH(NOLOCK)  
                   LEFT JOIN timezones tz WITH(NOLOCK) ON main.timeZone = tz.ROWID  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''   
                         
                  )x '   
 END  
   
 --Admin Master  
 IF @tableName IN ('adminMaster', 'adminMasterMod')  
 BEGIN  
  INSERT @columnList(columnName)  
  SELECT 'User Name' UNION ALL  
  SELECT 'User Code' UNION ALL  
  SELECT 'Password' UNION ALL  
  SELECT 'Address' UNION ALL  
  SELECT 'City' UNION ALL  
  SELECT 'Country' UNION ALL  
  SELECT 'Phone1' UNION ALL  
  SELECT 'Phone2' UNION ALL  
  SELECT 'Fax1' UNION ALL  
  SELECT 'Fax2' UNION ALL  
  SELECT 'Mobile1' UNION ALL  
  SELECT 'Mobile2' UNION ALL  
  SELECT 'Email1' UNION ALL  
  SELECT 'Email2' UNION ALL  
  SELECT 'Post' UNION ALL  
  SELECT 'User Type' UNION ALL  
  SELECT 'isActive'  
      
     SET @table='(  
                   SELECT TOP 1  
        [User Name]        = userName  
                         ,[User Code]        = userCode  
                         ,[Password]         = userPassword         
       ,[Address]         = userAddress  
       ,[City]          = userCity  
       ,[Country]         = ccm.countryName  
       ,[Phone1]         = userPhone1  
       ,[Phone2]         = userPhone2  
       ,[Fax1]          = userFax1  
       ,[Fax2]          = userFax2  
       ,[Mobile1]         = userMobile1  
       ,[Mobile2]         = userMobile2  
       ,[Email1]         = userEmail1  
       ,[Email2]         = userEmail2  
       ,[Post]          = userPost  
       ,[User Type]        = userType  
       ,[isActive]         = main.isActive               
                   FROM ' + @tableName + ' main WITH(NOLOCK)  
                   LEFT JOIN countryMaster ccm WITH(NOLOCK) ON main.userCountry = ccm.countryId  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''   
                         
                  )x '   
 END  
   
 --Default Service Charge Master  
 IF @tableName IN ('dscMaster', 'dscMasterHistory')  
 BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = sccm.countryName        
        ,[Receiving Country]      = rccm.countryName  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'dscMasterHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END     
 --Special Service Charge Master  
 IF @tableName IN ('sscMaster', 'sscMasterHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Sending Super Agent' UNION ALL  
   SELECT 'Sending Agent' UNION ALL  
   SELECT 'Sending Branch' UNION ALL  
   SELECT 'Sending State' UNION ALL  
   SELECT 'Sending Zip Code' UNION ALL  
   SELECT 'Sending Agent Group' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Receiving Super Agent' UNION ALL  
   SELECT 'Receiving Agent' UNION ALL  
   SELECT 'Receiving Branch' UNION ALL  
   SELECT 'Receiving State' UNION ALL  
   SELECT 'Receiving Zip Code' UNION ALL  
   SELECT 'Receiving Agent Group' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Discount(ve)' UNION ALL  
   SELECT 'VE Type' UNION ALL  
   SELECT 'Discount(ne)' UNION ALL  
   SELECT 'NE Type' UNION ALL  
   SELECT 'Effective From' UNION ALL  
   SELECT 'Effective To' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = sccm.countryName  
        ,[Sending Super Agent]      = ISNULL(ssa.agentName, ''All'')  
        ,[Sending Agent]       = ISNULL(sa.agentName, ''All'')  
        ,[Sending Branch]       = ISNULL(sb.agentName, ''All'')  
        ,[Sending State]       = ISNULL(csm.stateName, ''All'')  
        ,[Sending Zip Code]       = zip  
        ,[Sending Agent Group]      = ISNULL(ag.detailTitle, ''All'')        
        ,[Receiving Country]      = rccm.countryName  
        ,[Receiving Super Agent]     = ISNULL(rsa.agentName, ''All'')  
        ,[Receiving Agent]       = ISNULL(ra.agentName, ''All'')  
        ,[Receiving Branch]       = ISNULL(rb.agentName, ''All'')  
        ,[Receiving State]       = ISNULL(csm2.stateName, ''All'')  
        ,[Receiving Zip Code]      = rZip  
        ,[Receiving Agent Group]     = ISNULL(ag2.detailTitle, ''All'')  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Discount(ve)]        = CAST(ve AS VARCHAR)  
        ,[VE Type]         = sdv1.detailTitle  
        ,[Discount(ne)]        = CAST(ne AS VARCHAR)  
        ,[NE Type]         = sdv2.detailTitle  
        ,[Effective From]       = effectiveFrom  
        ,[Effective To]        = effectiveTo  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN agentMaster ssa WITH(NOLOCK) ON main.ssAgent = ssa.agentId  
        LEFT JOIN agentMaster sa WITH(NOLOCK) ON main.sAgent = sa.agentId  
        LEFT JOIN agentMaster sb WITH(NOLOCK) ON main.sBranch = sb.agentId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN agentMaster rsa WITH(NOLOCK) ON main.rsAgent = rsa.agentId  
        LEFT JOIN agentMaster ra WITH(NOLOCK) ON main.rAgent = ra.agentId  
        LEFT JOIN agentMaster rb WITH(NOLOCK) ON main.rBranch = rb.agentId  
        LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON main.state = csm.stateId  
        LEFT JOIN countryStateMaster csm2 WITH(NOLOCK) ON main.rState = csm2.stateId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue ag WITH(NOLOCK) ON main.agentGroup = ag.valueId  
        LEFT JOIN staticDataValue ag2 WITH(NOLOCK) ON main.rAgentGroup = ag2.valueId  
        LEFT JOIN staticDataValue sdv1 WITH(NOLOCK) ON main.veType = sdv1.valueId  
        LEFT JOIN staticDataValue sdv2 WITH(NOLOCK) ON main.neType = sdv2.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'sscMasterHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END   
   
 --Default/Special Service Charge Detail,Default/Custom Send/Pay Commission Detail  
 IF @tableName IN ('dscDetail', 'dscDetailHistory', 'sscDetail', 'sscDetailHistory', 'dcSendDetail', 'dcSendDetailHistory', 'scSendDetail', 'scSendDetailHistory', 'dcPayDetail', 'dcPayDetailHistory', 'scPayDetail', 'scPayDetailHistory')  
 BEGIN    
  INSERT @columnList(columnName)  
  SELECT 'Amount From' UNION ALL  
  SELECT 'Amount To' UNION ALL  
  SELECT 'Percent' UNION ALL  
  SELECT 'Min Amount' UNION ALL  
  SELECT 'Max Amount'  
      
     SET @table='(  
                   SELECT TOP 1  
        [Amount From]        = fromAmt  
                         ,[Amount To]        = toAmt  
                         ,[Percent]         = pcnt         
       ,[Min Amount]        = minAmt  
       ,[Max Amount]        = maxAmt          
                   FROM ' + @tableName + ' main WITH(NOLOCK)  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
                        CASE WHEN @tableName IN ('dscDetailHistory','sscDetailHistory','dcSendDetailHistory','scSendDetailHistory','dcPayDetailHistory','scPayDetailHistory') THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
                   + '  
                         
                  )x '   
 END  
   
 --Default/Custom Send/Pay Commission Detail for SuperAgent  
 IF @tableName IN ('dcSendDetailSA', 'dcSendDetailSAHistory', 'scSendDetailSA', 'scSendDetailSAHistory', 'dcPayDetailSA', 'dcPayDetailSAHistory', 'scPayDetailSA', 'scPayDetailSAHistory')  
 BEGIN    
  INSERT @columnList(columnName)  
  SELECT 'Amount From' UNION ALL  
  SELECT 'Amount To' UNION ALL  
  SELECT 'Percent' UNION ALL  
  SELECT 'Min Amount' UNION ALL  
  SELECT 'Max Amount'  
      
     SET @table='(  
                   SELECT TOP 1  
        [Amount From]        = fromAmt  
                         ,[Amount To]        = toAmt  
                         ,[Percent]         = pcnt         
       ,[Min Amount]        = minAmt  
       ,[Max Amount]        = maxAmt          
                   FROM ' + @tableName + ' main WITH(NOLOCK)  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
                        CASE WHEN @tableName IN ('dcSendDetailSAHistory','scSendDetailSAHistory','dcPayDetailSAHistory','scPayDetailSAHistory') THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
                   + '  
                         
                  )x '   
 END  
   
 --Default/Custom Send/Pay Commission Detail For Hub  
 IF @tableName IN ('dcSendDetailHub', 'dcSendDetailHubHistory', 'scSendDetailHub', 'scSendDetailHubHistory', 'dcPayDetailHub', 'dcPayDetailHubHistory', 'scPayDetailHub', 'scPayDetailHubHistory')  
 BEGIN    
  INSERT @columnList(columnName)  
  SELECT 'Amount From' UNION ALL  
  SELECT 'Amount To' UNION ALL  
  SELECT 'Percent' UNION ALL  
  SELECT 'Min Amount' UNION ALL  
  SELECT 'Max Amount'  
      
     SET @table='(  
                   SELECT TOP 1  
        [Amount From]        = fromAmt  
                         ,[Amount To]        = toAmt  
                         ,[Percent]         = pcnt         
       ,[Min Amount]        = minAmt  
       ,[Max Amount]        = maxAmt          
                   FROM ' + @tableName + ' main WITH(NOLOCK)  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
                        CASE WHEN @tableName IN ('dcSendDetailHubHistory','scSendDetailHubHistory','dcPayDetailHubHistory','scPayDetailHubHistory') THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
                   + '  
                         
                  )x '   
 END  
   
 --Default Domestic Commission Detail  
 IF @tableName IN ('dcDetail', 'dcDetailHistory', 'scDetail', 'scDetailHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
  SELECT 'Amount From' UNION ALL  
  SELECT 'Amount To' UNION ALL  
  SELECT 'Service Charge Percent' UNION ALL  
  SELECT 'Service Charge Min Amount' UNION ALL  
  SELECT 'Service Charge Max Amount' UNION ALL  
  SELECT 'Sending Agent Comm. Percent' UNION ALL  
  SELECT 'Sending Agent Comm. Min Amount' UNION ALL  
  SELECT 'Sending Agent Comm. Max Amount' UNION ALL  
  SELECT 'Sending Sup Agent Comm. Percent' UNION ALL  
  SELECT 'Sending Sup Agent Comm. Min Amount' UNION ALL  
  SELECT 'Sending Sup Agent Comm. Max Amount' UNION ALL  
  SELECT 'Paying Agent Comm. Percent' UNION ALL  
  SELECT 'Paying Agent Comm. Min Amount' UNION ALL  
  SELECT 'Paying Agent Comm. Max Amount' UNION ALL  
  SELECT 'Paying Sup Agent Comm. Percent' UNION ALL  
  SELECT 'Paying Sup Agent Comm. Min Amount' UNION ALL  
  SELECT 'Paying Sup Agent Comm. Max Amount' UNION ALL  
  SELECT 'Bank Commission Percent' UNION ALL  
  SELECT 'Bank Commission Min Amount' UNION ALL  
  SELECT 'Bank Commission Max Amount'  
    
  SET @table='(  
                   SELECT TOP 1  
        [Amount From]        = fromAmt  
                         ,[Amount To]        = toAmt  
                         ,[Service Charge Percent]     = serviceChargePcnt         
       ,[Service Charge Min Amount]    = serviceChargeMinAmt  
       ,[Service Charge Max Amount]    = serviceChargeMaxAmt  
       ,[Sending Agent Comm. Percent]    = sAgentCommPcnt  
       ,[Sending Agent Comm. Min Amount]   = sAgentCommMinAmt  
       ,[Sending Agent Comm. Max Amount]   = sAgentCommMaxAmt  
       ,[Sending Sup Agent Comm. Percent]   = ssAgentCommPcnt  
       ,[Sending Sup Agent Comm. Min Amount]  = ssAgentCommMinAmt  
       ,[Sending Sup Agent Comm. Max Amount]  = ssAgentCommMaxAmt   
       ,[Paying Agent Comm. Percent]    = pAgentCommPcnt  
       ,[Paying Agent Comm. Min Amount]   = pAgentCommMinAmt  
       ,[Paying Agent Comm. Max Amount]   = pAgentCommMaxAmt  
       ,[Paying Sup Agent Comm. Percent]   = psAgentCommPcnt  
       ,[Paying Sup Agent Comm. Min Amount]  = psAgentCommMinAmt  
       ,[Paying Sup Agent Comm. Max Amount]  = psAgentCommMaxAmt  
       ,[Bank Commission Percent]     = bankCommPcnt  
       ,[Bank Commission Min Amount]    = bankCommMinAmt  
       ,[Bank Commission Max Amount]    = bankCommMaxAmt  
                   FROM ' + @tableName + ' main WITH(NOLOCK)  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
                        CASE WHEN @tableName IN ('dcDetailHistory', 'scDetailHistory') THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
                   + '  
                         
                  )x '   
 END  
   
 --Default Domestic Commission Master  
 IF @tableName IN ('dcMaster', 'dcMasterHistory')  
 BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Group' UNION ALL  
   SELECT 'Receiving Group' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Group]       = sg.detailTitle  
        ,[Receiving Group]       = rg.detailTitle         
        ,[Transaction Type]       = stm.typeTitle  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN staticDataValue sg WITH(NOLOCK) ON main.sGroup = sg.valueId  
        LEFT JOIN staticDataValue rg WITH(NOLOCK) ON main.rGroup = rg.valueId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'dcMasterHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 --Custom Domestic Commission Master  
 IF @tableName IN ('scMaster', 'scMasterHistory')  
 BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Agent' UNION ALL  
   SELECT 'Sending Branch' UNION ALL  
   SELECT 'Sending State' UNION ALL  
   SELECT 'Sending Group' UNION ALL  
   SELECT 'Receiving Agent' UNION ALL  
   SELECT 'Receiving Branch' UNION ALL  
   SELECT 'Receiving State' UNION ALL  
   SELECT 'Receiving Group' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Effective From' UNION ALL  
   SELECT 'Effective To' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Agent]       = ISNULL(sa.agentName, ''All'')  
        ,[Sending Branch]       = ISNULL(sb.agentName, ''All'')  
        ,[Sending State]       = ISNULL(ss.stateName, ''All'')  
        ,[Sending Group]       = ISNULL(sg.detailTitle, ''All'')  
        ,[Receiving Agent]       = ISNULL(ra.agentName, ''All'')  
        ,[Receiving Branch]       = ISNULL(rb.agentName, ''All'')  
        ,[Receiving State]       = ISNULL(rs.stateName, ''All'')  
        ,[Receiving Group]       = ISNULL(rg.detailTitle, ''All'')         
        ,[Transaction Type]       = stm.typeTitle  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Effective From]       = effectiveFrom  
        ,[Effective To]        = effectiveTo  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN agentMaster sa WITH(NOLOCK) ON main.sAgent = sa.agentId  
        LEFT JOIN agentMaster sb WITH(NOLOCK) ON main.sBranch = sb.agentId  
        LEFT JOIN countryStateMaster ss WITH(NOLOCK) ON main.sState = ss.stateId  
        LEFT JOIN staticDataValue sg WITH(NOLOCK) ON main.sGroup = sg.valueId  
        LEFT JOIN agentMaster ra WITH(NOLOCK) ON main.rAgent = ra.agentId  
        LEFT JOIN agentMaster rb WITH(NOLOCK) ON main.rBranch = rb.agentId  
        LEFT JOIN countryStateMaster rs WITH(NOLOCK) ON main.rState = rs.stateId  
        LEFT JOIN staticDataValue rg WITH(NOLOCK) ON main.rGroup = rg.valueId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'scMasterHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 --Default Sending Commission Master  
 IF @tableName IN ('dcSendMaster', 'dcSendMasterHistory')  
 BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = sccm.countryName        
        ,[Receiving Country]      = rccm.countryName  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'dcSendMasterHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 --Custom Sending Commission Master  
 IF @tableName IN ('scSendMaster', 'scSendMasterHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Sending Super Agent' UNION ALL  
   SELECT 'Sending Agent' UNION ALL  
   SELECT 'Sending Branch' UNION ALL  
   SELECT 'Sending State' UNION ALL  
   SELECT 'Sending Zip' UNION ALL  
   SELECT 'Sending Agent Group' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Receiving Super Agent' UNION ALL  
   SELECT 'Receiving Agent' UNION ALL  
   SELECT 'Receiving Branch' UNION ALL  
   SELECT 'Receiving State' UNION ALL  
   SELECT 'Receiving Zip' UNION ALL  
   SELECT 'Receiving Agent Group' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Effective From' UNION ALL  
   SELECT 'Effective To' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = sccm.countryName  
        ,[Sending Super Agent]      = ISNULL(ssa.agentName, ''All'')  
        ,[Sending Agent]       = ISNULL(sa.agentName, ''All'')  
        ,[Sending Branch]       = ISNULL(sb.agentName, ''All'')  
        ,[Sending State]       = ISNULL(csm.stateName, ''All'')  
        ,[Sending Zip]        = zip  
        ,[Sending Agent Group]      = ISNULL(ag.detailTitle, ''All'')        
        ,[Receiving Country]      = ISNULL(rccm.countryName, ''All'')  
        ,[Receiving Super Agent]     = ISNULL(rsa.agentName, ''All'')  
        ,[Receiving Agent]       = ISNULL(ra.agentName, ''All'')  
        ,[Receiving Branch]       = ISNULL(rb.agentName, ''All'')  
        ,[Receiving State]       = ISNULL(csm2.stateName, ''All'')  
        ,[Receiving Zip]       = zip  
        ,[Receiving Agent Group]     = ISNULL(ag2.detailTitle, ''All'')  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Effective From]       = effectiveFrom  
        ,[Effective To]        = effectiveTo  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN agentMaster ssa WITH(NOLOCK) ON main.ssAgent = ssa.agentId  
        LEFT JOIN agentMaster sa WITH(NOLOCK) ON main.sAgent = sa.agentId  
        LEFT JOIN agentMaster sb WITH(NOLOCK) ON main.sBranch = sb.agentId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN agentMaster rsa WITH(NOLOCK) ON main.rsAgent = rsa.agentId  
        LEFT JOIN agentMaster ra WITH(NOLOCK) ON main.rAgent = ra.agentId  
        LEFT JOIN agentMaster rb WITH(NOLOCK) ON main.rBranch = rb.agentId  
        LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON main.state = csm.stateId  
        LEFT JOIN countryStateMaster csm2 WITH(NOLOCK) ON main.rState = csm2.stateId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
        LEFT JOIN staticDataValue ag WITH(NOLOCK) ON main.agentGroup = ag.valueId  
        LEFT JOIN staticDataValue ag2 WITH(NOLOCK) ON main.rAgentGroup = ag2.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'scSendMasterHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END   
   
 --Default Paying Commission Master  
 IF @tableName IN ('dcPayMaster', 'dcPayMasterHistory')  
 BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = sccm.countryName        
        ,[Receiving Country]      = rccm.countryName  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'dcPayMasterHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 --Custom Paying Commission Master  
 IF @tableName IN ('scPayMaster', 'scPayMasterHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Sending Super Agent' UNION ALL  
   SELECT 'Sending Agent' UNION ALL  
   SELECT 'Sending Branch' UNION ALL  
   SELECT 'Sending State' UNION ALL  
   SELECT 'Sending Zip' UNION ALL  
   SELECT 'Sending Agent Group' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Receiving Super Agent' UNION ALL  
   SELECT 'Receiving Agent' UNION ALL  
   SELECT 'Receiving Branch' UNION ALL  
   SELECT 'Receiving State' UNION ALL  
   SELECT 'Receiving Zip' UNION ALL  
   SELECT 'Receiving Agent Group' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Effective From' UNION ALL  
   SELECT 'Effective To' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = ISNULL(sccm.countryName, ''All'')  
        ,[Sending Super Agent]      = ISNULL(ssa.agentName, ''All'')  
        ,[Sending Agent]       = ISNULL(sa.agentName, ''All'')  
        ,[Sending Branch]       = ISNULL(sb.agentName, ''All'')  
        ,[Sending State]       = ISNULL(csm.stateName, ''All'')  
        ,[Sending Zip]        = zip  
        ,[Sending Agent Group]      = ISNULL(ag.detailTitle, ''All'')        
        ,[Receiving Country]      = rccm.countryName  
        ,[Receiving Super Agent]     = ISNULL(rsa.agentName, ''All'')  
        ,[Receiving Agent]       = ISNULL(ra.agentName, ''All'')  
        ,[Receiving Branch]       = ISNULL(rb.agentName, ''All'')  
        ,[Receiving State]       = ISNULL(csm2.stateName, ''All'')  
        ,[Receiving Zip]       = zip  
        ,[Receiving Agent Group]     = ISNULL(ag2.detailTitle, ''All'')  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Effective From]       = effectiveFrom  
        ,[Effective To]        = effectiveTo  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN agentMaster ssa WITH(NOLOCK) ON main.ssAgent = ssa.agentId  
        LEFT JOIN agentMaster sa WITH(NOLOCK) ON main.sAgent = sa.agentId  
        LEFT JOIN agentMaster sb WITH(NOLOCK) ON main.sBranch = sb.agentId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN agentMaster rsa WITH(NOLOCK) ON main.rsAgent = rsa.agentId  
        LEFT JOIN agentMaster ra WITH(NOLOCK) ON main.rAgent = ra.agentId  
        LEFT JOIN agentMaster rb WITH(NOLOCK) ON main.rBranch = rb.agentId  
        LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON main.state = csm.stateId  
        LEFT JOIN countryStateMaster csm2 WITH(NOLOCK) ON main.rState = csm2.stateId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
        LEFT JOIN staticDataValue ag WITH(NOLOCK) ON main.agentGroup = ag.valueId  
        LEFT JOIN staticDataValue ag2 WITH(NOLOCK) ON main.rAgentGroup = ag2.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'scPayMasterHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END   
   
   
 ----------------------------------  
   
 --Default Sending Commission Master For SuperAgent  
 IF @tableName IN ('dcSendMasterSA', 'dcSendMasterSAHistory')  
 BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = sccm.countryName        
        ,[Receiving Country]      = rccm.countryName  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'dcSendMasterSAHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 --Custom Sending Commission Master For SuperAgent  
 IF @tableName IN ('scSendMasterSA', 'scSendMasterSAHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Sending Super Agent' UNION ALL  
   SELECT 'Sending Agent' UNION ALL  
   SELECT 'Sending Branch' UNION ALL  
   SELECT 'Sending State' UNION ALL  
   SELECT 'Sending Zip' UNION ALL  
   SELECT 'Sending Agent Group' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Receiving Super Agent' UNION ALL  
   SELECT 'Receiving Agent' UNION ALL  
   SELECT 'Receiving Branch' UNION ALL  
   SELECT 'Receiving State' UNION ALL  
   SELECT 'Receiving Zip' UNION ALL  
   SELECT 'Receiving Agent Group' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Effective From' UNION ALL  
   SELECT 'Effective To' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = sccm.countryName  
        ,[Sending Super Agent]      = ISNULL(ssa.agentName, ''All'')  
        ,[Sending Agent]       = ISNULL(sa.agentName, ''All'')  
        ,[Sending Branch]       = ISNULL(sb.agentName, ''All'')  
        ,[Sending State]       = ISNULL(csm.stateName, ''All'')  
        ,[Sending Zip]        = zip  
        ,[Sending Agent Group]      = ISNULL(ag.detailTitle, ''All'')        
        ,[Receiving Country]      = ISNULL(rccm.countryName, ''All'')  
        ,[Receiving Super Agent]     = ISNULL(rsa.agentName, ''All'')  
        ,[Receiving Agent]       = ISNULL(ra.agentName, ''All'')  
        ,[Receiving Branch]       = ISNULL(rb.agentName, ''All'')  
        ,[Receiving State]       = ISNULL(csm2.stateName, ''All'')  
        ,[Receiving Zip]       = zip  
        ,[Receiving Agent Group]     = ISNULL(ag2.detailTitle, ''All'')  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Effective From]       = effectiveFrom  
        ,[Effective To]        = effectiveTo  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN agentMaster ssa WITH(NOLOCK) ON main.ssAgent = ssa.agentId  
        LEFT JOIN agentMaster sa WITH(NOLOCK) ON main.sAgent = sa.agentId  
        LEFT JOIN agentMaster sb WITH(NOLOCK) ON main.sBranch = sb.agentId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN agentMaster rsa WITH(NOLOCK) ON main.rsAgent = rsa.agentId  
        LEFT JOIN agentMaster ra WITH(NOLOCK) ON main.rAgent = ra.agentId  
        LEFT JOIN agentMaster rb WITH(NOLOCK) ON main.rBranch = rb.agentId  
        LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON main.state = csm.stateId  
        LEFT JOIN countryStateMaster csm2 WITH(NOLOCK) ON main.rState = csm2.stateId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
        LEFT JOIN staticDataValue ag WITH(NOLOCK) ON main.agentGroup = ag.valueId  
        LEFT JOIN staticDataValue ag2 WITH(NOLOCK) ON main.rAgentGroup = ag2.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'scSendMasterSAHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END   
   
 --Default Paying Commission Master For SuperAgent  
 IF @tableName IN ('dcPayMasterSA', 'dcPayMasterSAHistory')  
 BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = sccm.countryName         
        ,[Receiving Country]      = rccm.countryName  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'dcPayMasterSAHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 --Custom Paying Commission Master For Super Agent  
 IF @tableName IN ('scPayMasterSA', 'scPayMasterSAHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Sending Super Agent' UNION ALL  
   SELECT 'Sending Agent' UNION ALL  
   SELECT 'Sending Branch' UNION ALL  
   SELECT 'Sending State' UNION ALL  
   SELECT 'Sending Zip' UNION ALL  
   SELECT 'Sending Agent Group' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Receiving Super Agent' UNION ALL  
   SELECT 'Receiving Agent' UNION ALL  
   SELECT 'Receiving Branch' UNION ALL  
   SELECT 'Receiving State' UNION ALL  
   SELECT 'Receiving Zip' UNION ALL  
   SELECT 'Receiving Agent Group' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Effective From' UNION ALL  
   SELECT 'Effective To' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = ISNULL(sccm.countryName, ''All'')  
        ,[Sending Super Agent]      = ISNULL(ssa.agentName, ''All'')  
        ,[Sending Agent]       = ISNULL(sa.agentName, ''All'')  
        ,[Sending Branch]       = ISNULL(sb.agentName, ''All'')  
        ,[Sending State]       = ISNULL(csm.stateName, ''All'')  
        ,[Sending Zip]        = zip  
        ,[Sending Agent Group]      = ISNULL(ag.detailTitle, ''All'')        
        ,[Receiving Country]      = ISNULL(rccm.countryName  
        ,[Receiving Super Agent]     = ISNULL(rsa.agentName, ''All'')  
        ,[Receiving Agent]       = ISNULL(ra.agentName, ''All'')  
        ,[Receiving Branch]       = ISNULL(rb.agentName, ''All'')  
        ,[Receiving State]       = ISNULL(csm2.stateName, ''All'')  
        ,[Receiving Zip]       = zip  
        ,[Receiving Agent Group]     = ISNULL(ag2.detailTitle, ''All'')  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Effective From]       = effectiveFrom  
        ,[Effective To]        = effectiveTo  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN agentMaster ssa WITH(NOLOCK) ON main.ssAgent = ssa.agentId  
        LEFT JOIN agentMaster sa WITH(NOLOCK) ON main.sAgent = sa.agentId  
        LEFT JOIN agentMaster sb WITH(NOLOCK) ON main.sBranch = sb.agentId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN agentMaster rsa WITH(NOLOCK) ON main.rsAgent = rsa.agentId  
        LEFT JOIN agentMaster ra WITH(NOLOCK) ON main.rAgent = ra.agentId  
        LEFT JOIN agentMaster rb WITH(NOLOCK) ON main.rBranch = rb.agentId  
        LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON main.state = csm.stateId  
        LEFT JOIN countryStateMaster csm2 WITH(NOLOCK) ON main.rState = csm2.stateId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
        LEFT JOIN staticDataValue ag WITH(NOLOCK) ON main.agentGroup = ag.valueId  
        LEFT JOIN staticDataValue ag2 WITH(NOLOCK) ON main.rAgentGroup = ag2.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'scPayMasterSAHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END   
   
 ---------------------------------------  
   
 --Default Sending Commission Master for Hub  
 IF @tableName IN ('dcSendMasterHub', 'dcSendMasterHubHistory')  
 BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = sccm.countryName        
        ,[Receiving Country]      = rccm.countryName  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'dcSendMasterHubHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 --Custom Sending Commission Master for Hub  
 IF @tableName IN ('scSendMasterHub', 'scSendMasterHubHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Sending Super Agent' UNION ALL  
   SELECT 'Sending Agent' UNION ALL  
   SELECT 'Sending Branch' UNION ALL  
   SELECT 'Sending State' UNION ALL  
   SELECT 'Sending Zip' UNION ALL  
   SELECT 'Sending Agent Group' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Receiving Super Agent' UNION ALL  
   SELECT 'Receiving Agent' UNION ALL  
   SELECT 'Receiving Branch' UNION ALL  
   SELECT 'Receiving State' UNION ALL  
   SELECT 'Receiving Zip' UNION ALL  
   SELECT 'Receiving Agent Group' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Effective From' UNION ALL  
   SELECT 'Effective To' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = sccm.countryName  
        ,[Sending Super Agent]      = ssa.agentName  
        ,[Sending Agent]       = sa.agentName  
        ,[Sending Branch]       = sb.agentName  
        ,[Sending State]       = csm.stateName  
        ,[Sending Zip]        = zip  
        ,[Sending Agent Group]      = ag.detailTitle        
        ,[Receiving Country]      = rccm.countryName  
        ,[Receiving Super Agent]     = rsa.agentName  
        ,[Receiving Agent]       = ra.agentName  
        ,[Receiving Branch]       = rb.agentName  
        ,[Receiving State]       = csm2.stateName  
        ,[Receiving Zip]       = zip  
        ,[Receiving Agent Group]     = ag2.detailTitle  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Effective From]       = effectiveFrom  
        ,[Effective To]        = effectiveTo  
        ,[Active]         = main.isEnable  
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN agentMaster ssa WITH(NOLOCK) ON main.ssAgent = ssa.agentId  
        LEFT JOIN agentMaster sa WITH(NOLOCK) ON main.sAgent = sa.agentId  
        LEFT JOIN agentMaster sb WITH(NOLOCK) ON main.sBranch = sb.agentId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN agentMaster rsa WITH(NOLOCK) ON main.rsAgent = rsa.agentId  
        LEFT JOIN agentMaster ra WITH(NOLOCK) ON main.rAgent = ra.agentId  
        LEFT JOIN agentMaster rb WITH(NOLOCK) ON main.rBranch = rb.agentId  
        LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON main.state = csm.stateId  
        LEFT JOIN countryStateMaster csm2 WITH(NOLOCK) ON main.rState = csm2.stateId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
        LEFT JOIN staticDataValue ag WITH(NOLOCK) ON main.agentGroup = ag.valueId  
        LEFT JOIN staticDataValue ag2 WITH(NOLOCK) ON main.rAgentGroup = ag2.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'scSendMasterHubHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END   
   
 --Default Paying Commission Master for Hub  
 IF @tableName IN ('dcPayMasterHub', 'dcPayMasterHubHistory')  
 BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = sccm.countryName        
        ,[Receiving Country]      = rccm.countryName  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'dcPayMasterHubHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 --Custom Paying Commission Master for Hub  
 IF @tableName IN ('scPayMasterHub', 'scPayMasterHubHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Code' UNION ALL  
   SELECT 'Description' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Sending Super Agent' UNION ALL  
   SELECT 'Sending Agent' UNION ALL  
   SELECT 'Sending Branch' UNION ALL  
   SELECT 'Sending State' UNION ALL  
   SELECT 'Sending Zip' UNION ALL  
   SELECT 'Sending Agent Group' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Receiving Super Agent' UNION ALL  
   SELECT 'Receiving Agent' UNION ALL  
   SELECT 'Receiving Branch' UNION ALL  
   SELECT 'Receiving State' UNION ALL  
   SELECT 'Receiving Zip' UNION ALL  
   SELECT 'Receiving Agent Group' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Commission Base' UNION ALL  
   SELECT 'Effective From' UNION ALL  
   SELECT 'Effective To' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Code]          = code  
        ,[Description]        = description  
        ,[Sending Country]       = sccm.countryName  
        ,[Sending Super Agent]      = ssa.agentName  
        ,[Sending Agent]       = sa.agentName  
        ,[Sending Branch]       = sb.agentName  
        ,[Sending State]       = csm.stateName  
        ,[Sending Zip]        = zip  
        ,[Sending Agent Group]      = ag.detailTitle        
        ,[Receiving Country]      = rccm.countryName  
        ,[Receiving Super Agent]     = rsa.agentName  
        ,[Receiving Agent]       = ra.agentName  
        ,[Receiving Branch]       = rb.agentName  
        ,[Receiving State]       = csm2.stateName  
        ,[Receiving Zip]       = zip  
        ,[Receiving Agent Group]     = ag2.detailTitle  
        ,[Transaction Type]       = stm.typeTitle  
        ,[Base Currency]       = baseCurrency  
        ,[Commission Base]       = sdv.detailTitle  
        ,[Effective From]       = effectiveFrom  
        ,[Effective To]        = effectiveTo  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN agentMaster ssa WITH(NOLOCK) ON main.ssAgent = ssa.agentId  
        LEFT JOIN agentMaster sa WITH(NOLOCK) ON main.sAgent = sa.agentId  
        LEFT JOIN agentMaster sb WITH(NOLOCK) ON main.sBranch = sb.agentId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN agentMaster rsa WITH(NOLOCK) ON main.rsAgent = rsa.agentId  
        LEFT JOIN agentMaster ra WITH(NOLOCK) ON main.rAgent = ra.agentId  
        LEFT JOIN agentMaster rb WITH(NOLOCK) ON main.rBranch = rb.agentId  
        LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON main.state = csm.stateId  
        LEFT JOIN countryStateMaster csm2 WITH(NOLOCK) ON main.rState = csm2.stateId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN staticDataValue sdv WITH(NOLOCK) ON main.commissionBase = sdv.valueId  
        LEFT JOIN staticDataValue ag WITH(NOLOCK) ON main.agentGroup = ag.valueId  
        LEFT JOIN staticDataValue ag2 WITH(NOLOCK) ON main.rAgentGroup = ag2.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'scPayMasterHubHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END   
 --------------------------------  
   
 --Compliance Rule Setup Master for Hub  
 IF @tableName IN ('csMaster', 'csMasterHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Sending Agent' UNION ALL  
   SELECT 'Sending State' UNION ALL  
   SELECT 'Sending Zip' UNION ALL  
   SELECT 'Sending Group' UNION ALL  
   SELECT 'Sending Customer Type' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Receiving Agent' UNION ALL  
   SELECT 'Receiving State' UNION ALL  
   SELECT 'Receiving Zip' UNION ALL  
   SELECT 'Receiving Group' UNION ALL  
   SELECT 'Receiving Customer Type' UNION ALL  
   SELECT 'Currency'  
       
   SET @table='(  
        SELECT TOP 1  
         [Sending Country]       = ISNULL(sccm.countryName, ''All'')  
        ,[Sending Agent]       = ISNULL(sa.agentName, ''All'')  
        ,[Sending State]       = ISNULL(ss.stateName, ''All'')  
        ,[Sending Zip]        = sZip  
        ,[Sending Group]       = sg.detailTitle  
        ,[Sending Customer Type]     = ISNULL(sct.detailTitle, ''All'')  
               
        ,[Receiving Country]      = ISNULL(rccm.countryName, ''All'')  
        ,[Receiving Agent]       = ISNULL(ra.agentName, ''All'')  
        ,[Receiving State]       = ISNULL(rs.stateName, ''All'')  
        ,[Receiving Zip]       = rZip  
        ,[Receiving Group]       = rg.detailTitle  
        ,[Receiving Customer Type]     = ISNULL(rct.detailTitle, ''All'')  
        ,[Currency]         = curr.currencyCode             
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN agentMaster sa WITH(NOLOCK) ON main.sAgent = sa.agentId  
        LEFT JOIN countryStateMaster ss WITH(NOLOCK) ON main.sState = ss.stateId  
        LEFT JOIN staticDataValue sg WITH(NOLOCK) ON main.sGroup = sg.valueId  
        LEFT JOIN staticDataValue sct WITH(NOLOCK) ON main.sCustType = sct.valueId  
          
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN agentMaster ra WITH(NOLOCK) ON main.rAgent = ra.agentId  
        LEFT JOIN countryStateMaster rs WITH(NOLOCK) ON main.rState = rs.stateId  
        LEFT JOIN staticDataValue rg WITH(NOLOCK) ON main.rGroup = rg.valueId  
        LEFT JOIN staticDataValue rct WITH(NOLOCK) ON main.rCustType = rct.valueId  
        LEFT JOIN currencyMaster curr WITH(NOLOCK) ON main.currency = curr.currencyId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'csMasterHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END   
   
 --Compliance Setup Detail  
 IF @tableName IN ('csDetail', 'csDetailHistory')  
 BEGIN    
  INSERT @columnList(columnName)  
  SELECT 'Condition' UNION ALL  
  SELECT 'Collection Mode' UNION ALL  
  SELECT 'Payment Mode' UNION ALL  
  SELECT '#Txn' UNION ALL  
  SELECT 'Amount' UNION ALL  
  SELECT 'Period' UNION ALL  
  SELECT 'Action'  
      
     SET @table='(  
                   SELECT TOP 1  
        [Condition]       = ISNULL(con.detailTitle, ''All'')  
                         ,[Collection Mode]      = ISNULL(cm.detailTitle, ''All'')  
                         ,[Payment Mode]       = ISNULL(pm.typeTitle, ''All'')        
       ,[#Txn]         = tranCount  
       ,[Amount]        = amount   
       ,[Period]        = period  
       ,[Action]        = CASE WHEN main.nextAction = ''P'' THEN ''Pending''  
                   WHEN main.nextAction = ''H'' THEN ''Hold''  
                   WHEN main.nextAction = ''B'' THEN ''Block''  
                   WHEN main.nextAction = ''M'' THEN ''Mark as Compliance'' END         
                   FROM ' + @tableName + ' main WITH(NOLOCK)  
                   LEFT JOIN staticDataValue con ON main.condition = con.valueId  
                   LEFT JOIN staticDataValue cm ON main.collMode = cm.valueId  
                   LEFT JOIN serviceTypeMaster pm ON main.paymentMode = pm.serviceTypeId  
                   --LEFT JOIN staticDataValue act ON main.nextAction = act.valueId  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
                        CASE WHEN @tableName IN ('csDetailHistory') THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
                   + '  
                         
                  )x '   
 END  
   
 --Compliance ID Setup Master  
 IF @tableName IN ('cisMaster', 'cisMasterHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Sending Agent' UNION ALL  
   SELECT 'Sending State' UNION ALL  
   SELECT 'Sending Zip' UNION ALL  
   SELECT 'Sending Group' UNION ALL  
   SELECT 'Sending Customer Type' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Receiving Agent' UNION ALL  
   SELECT 'Receiving State' UNION ALL  
   SELECT 'Receiving Zip' UNION ALL  
   SELECT 'Receiving Group' UNION ALL  
   SELECT 'Receiving Customer Type'  
       
   SET @table='(  
        SELECT TOP 1  
         [Sending Country]       = ISNULL(sccm.countryName, ''All'')  
        ,[Sending Agent]       = ISNULL(sa.agentName, ''All'')  
        ,[Sending State]       = ISNULL(ss.stateName, ''All'')  
        ,[Sending Zip]        = sZip  
        ,[Sending Group]       = sg.detailTitle  
        ,[Sending Customer Type]     = ISNULL(sct.detailTitle, ''All'')  
                
        ,[Receiving Country]      = ISNULL(rccm.countryName, ''All'')  
        ,[Receiving Agent]       = ISNULL(ra.agentName, ''All'')  
        ,[Receiving State]       = ISNULL(rs.stateName, ''All'')  
        ,[Receiving Zip]       = rZip  
        ,[Receiving Group]       = rg.detailTitle  
        ,[Receiving Customer Type]     = ISNULL(rct.detailTitle, ''All'')             
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN agentMaster sa WITH(NOLOCK) ON main.sAgent = sa.agentId  
        LEFT JOIN countryStateMaster ss WITH(NOLOCK) ON main.sState = ss.stateId  
        LEFT JOIN staticDataValue sg WITH(NOLOCK) ON main.sGroup = sg.valueId  
        LEFT JOIN staticDataValue sct WITH(NOLOCK) ON main.sCustType = sct.valueId  
          
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN agentMaster ra WITH(NOLOCK) ON main.rAgent = ra.agentId  
        LEFT JOIN countryStateMaster rs WITH(NOLOCK) ON main.rState = rs.stateId  
        LEFT JOIN staticDataValue rg WITH(NOLOCK) ON main.rGroup = rg.valueId  
        LEFT JOIN staticDataValue rct WITH(NOLOCK) ON main.rCustType = rct.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'csMasterHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END   
   
 --Compliance ID Setup Detail  
 IF @tableName IN ('cisDetail', 'cisDetailHistory')  
 BEGIN    
  INSERT @columnList(columnName)  
  SELECT 'Condition' UNION ALL  
  SELECT 'Collection Mode' UNION ALL  
  SELECT 'Payment Mode' UNION ALL  
  SELECT '#Txn' UNION ALL  
  SELECT 'Amount' UNION ALL  
  SELECT 'Period' UNION ALL  
  SELECT 'isEnable'  
      
     SET @table='(  
                   SELECT TOP 1  
        [Condition]       = ISNULL(con.detailTitle, ''All'')  
                         ,[Collection Mode]      = ISNULL(cm.detailTitle, ''All'')  
                         ,[Payment Mode]       = ISNULL(pm.typeTitle, ''All'')        
       ,[#Txn]         = tranCount  
       ,[Amount]        = amount   
       ,[Period]        = period  
       ,[isEnable]        = isEnable       
                   FROM ' + @tableName + ' main WITH(NOLOCK)  
                   LEFT JOIN staticDataValue con ON main.condition = con.valueId  
                   LEFT JOIN staticDataValue cm ON main.collMode = cm.valueId  
                   LEFT JOIN serviceTypeMaster pm ON main.paymentMode = pm.serviceTypeId  
                        WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
                        CASE WHEN @tableName IN ('cisDetailHistory') THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
                   + '  
                         
                  )x '   
 END  
   
 --Exchange Rate Default Setup  
 IF @tableName IN ('deRate', 'deRateHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Hub' UNION ALL  
   SELECT 'Country' UNION ALL  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Local Currency' UNION ALL  
   SELECT 'Cost' UNION ALL  
   SELECT 'Margin' UNION ALL  
   SELECT 'Max(+)' UNION ALL  
   SELECT 'Min(-)' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Hub]          = h.agentName  
        ,[Country]         = ccm.countryName  
        ,[Base Currency]       = bccm.currencyCode  
        ,[Local Currency]       = lccm.currencyCode  
        ,[Cost]          = cost  
        ,[Margin]         = margin  
        ,[Max(+)]         = ve  
        ,[Min(-)]         = ne  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN agentMaster h WITH(NOLOCK) ON main.hub = h.agentId  
        LEFT JOIN countryMaster ccm WITH(NOLOCK) ON main.country = ccm.countryId  
        LEFT JOIN currencyMaster bccm WITH(NOLOCK) ON main.baseCurrency = bccm.currencyId  
        LEFT JOIN currencyMaster lccm WITH(NOLOCK) ON main.localCurrency = lccm.currencyId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'seRateHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END   
   
 --Exchange Rate Custom Setup  
 IF @tableName IN ('seRate', 'seRateHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Local Currency' UNION ALL  
   SELECT 'Sending Hub' UNION ALL  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Sending Super Agent' UNION ALL  
   SELECT 'Sending Agent' UNION ALL  
   SELECT 'Sending Branch' UNION ALL  
   SELECT 'Receiving Hub' UNION ALL  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Receiving Super Agent' UNION ALL  
   SELECT 'Receiving Agent' UNION ALL  
   SELECT 'Receiving Branch' UNION ALL  
   SELECT 'State' UNION ALL  
   SELECT 'Zip Code' UNION ALL  
   SELECT 'Agent Group' UNION ALL  
   SELECT 'Cost' UNION ALL  
   SELECT 'Margin' UNION ALL  
   SELECT 'Max(+)' UNION ALL  
   SELECT 'Min(-)' UNION ALL  
   SELECT 'Agent Margin' UNION ALL  
   SELECT 'Effective From' UNION ALL  
   SELECT 'Effective To' UNION ALL  
   SELECT 'Active'  
       
   SET @table='(  
        SELECT TOP 1  
         [Base Currency]       = bccm.currencyCode  
        ,[Local Currency]       = lccm.currencyCode  
        ,[Sending Hub]        = sh.agentName  
        ,[Sending Country]       = sccm.countryName  
        ,[Sending Super Agent]      = ssa.agentName  
        ,[Sending Agent]       = sa.agentName  
        ,[Sending Branch]       = sb.agentName  
        ,[Receiving Hub]       = rh.agentName         
        ,[Receiving Country]      = rccm.countryName  
        ,[Receiving Super Agent]     = rsa.agentName  
        ,[Receiving Agent]       = ra.agentName  
        ,[Receiving Branch]       = rb.agentName  
        ,[State]         = csm.stateName  
        ,[Zip Code]         = zip  
        ,[Agent Group]        = ag.detailTitle  
        ,[Cost]          = cost  
        ,[Margin]         = margin  
        ,[Max(+)]         = ve  
        ,[Min(-)]         = ne  
        ,[Agent Margin]        = agentMargin  
        ,[Effective From]       = effectiveFrom  
        ,[Effective To]        = effectiveTo  
        ,[Active]         = main.isEnable               
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN agentMaster sh WITH(NOLOCK) ON main.sHub = sh.agentId  
        LEFT JOIN agentMaster rh WITH(NOLOCK) ON main.rHub = rh.agentId  
        LEFT JOIN currencyMaster lccm WITH(NOLOCK) ON main.localCurrency = lccm.currencyId  
        LEFT JOIN countryMaster sccm WITH(NOLOCK) ON main.sCountry = sccm.countryId  
        LEFT JOIN agentMaster ssa WITH(NOLOCK) ON main.ssAgent = ssa.agentId  
        LEFT JOIN agentMaster sa WITH(NOLOCK) ON main.sAgent = sa.agentId  
        LEFT JOIN agentMaster sb WITH(NOLOCK) ON main.sBranch = sb.agentId  
        LEFT JOIN countryMaster rccm WITH(NOLOCK) ON main.rCountry = rccm.countryId  
        LEFT JOIN agentMaster rsa WITH(NOLOCK) ON main.rsAgent = rsa.agentId  
        LEFT JOIN agentMaster ra WITH(NOLOCK) ON main.rAgent = ra.agentId  
        LEFT JOIN agentMaster rb WITH(NOLOCK) ON main.rBranch = rb.agentId  
        LEFT JOIN countryStateMaster csm WITH(NOLOCK) ON main.state = csm.stateId  
        LEFT JOIN currencyMaster bccm WITH(NOLOCK) ON main.baseCurrency = bccm.currencyId  
        LEFT JOIN staticDataValue ag WITH(NOLOCK) ON main.agentGroup = ag.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'seRateHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END   
   
 --Transaction Limit  
 IF @tableName IN ('sendTranLimit', 'sendTranLimitMod')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Receiving Country' UNION ALL  
   SELECT 'Collection Type' UNION ALL  
   SELECT 'Min Limit' UNION ALL  
   SELECT 'Max Limit' UNION ALL  
   SELECT 'Currency' UNION ALL  
   SELECT 'Customer Type'  
       
   SET @table='(  
        SELECT TOP 1  
         [Receiving Country]      = ISNULL(receivingCountry, ''Any'')  
        ,[Collection Type]       = ISNULL(tranType, ''Any'')  
        ,[Min Limit]        = minLimitAmt  
        ,[Max Limit]        = maxLimitAmt  
        ,[Currency]         = currency  
        ,[Customer Type]       = ISNULL(ct.detailTitle, ''Any'')              
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN staticDataValue ct WITH(NOLOCK) ON main.customerType = ct.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''  
                          
       )x '  
 END   
   
 IF @tableName IN ('receiveTranLimit', 'receiveTranLimitMod')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Sending Country' UNION ALL  
   SELECT 'Payout Type' UNION ALL  
   SELECT 'Max Limit' UNION ALL  
   SELECT 'Agent Max Limit' UNION ALL  
   SELECT 'Currency' UNION ALL  
   SELECT 'Customer Type'  
       
   SET @table='(  
        SELECT TOP 1  
         [Sending Country]       = ISNULL(sendingCountry, ''Any'')  
        ,[Payout Type]        = ISNULL(tranType, ''Any'')  
        ,[Max Limit]        = maxLimitAmt  
        ,[Agent Max Limit]       = agMaxLimitAmt  
        ,[Currency]         = currency  
        ,[Customer Type]       = ISNULL(ct.detailTitle, ''Any'')              
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN staticDataValue ct WITH(NOLOCK) ON main.customerType = ct.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''  
                          
       )x '  
 END  
   
 IF @tableName IN ('creditLimit', 'creditLimitHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Currency' UNION ALL  
   SELECT 'Limit' UNION ALL  
   SELECT 'Max Limit' UNION ALL  
   --SELECT 'Todays Added Max Limit' UNION ALL  
   SELECT 'Per Topup Limit' UNION ALL  
   --SELECT 'Expiry Date' UNION ALL  
   SELECT 'Per Topup Request' UNION ALL  
   SELECT 'Max Toup Request'   
       
   SET @table='(  
        SELECT TOP 1  
         [Currency]        = curr.currencyCode  
        ,[Limit]        = limitAmt  
        ,[Max Limit]       = maxLimitAmt  
        --,[Todays Added Max Limit]    = todaysAddedMaxLimit  
        ,[Per Topup Limit]      = perTopUpAmt  
        --,[Expiry Date]       = expiryDate   
        ,[Per Topup Request]     = perToupRequest  
        ,[Max Toup Request]      = maxTopupRequest                     
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN currencyMaster curr WITH(NOLOCK) ON main.currency = curr.currencyId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'creditLimitHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 IF @tableName IN ('creditLimitInt', 'creditLimitIntHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Currency' UNION ALL  
   SELECT 'Limit' UNION ALL  
   SELECT 'Max Limit' UNION ALL     
   SELECT 'Per Topup Limit' UNION ALL  
   SELECT 'Expiry Date'  
       
   SET @table='(  
        SELECT TOP 1  
         [Currency]        = main.currency  
        ,[Limit]        = limitAmt  
        ,[Max Limit]       = maxLimitAmt          
        ,[Per Topup Limit]      = perTopUpAmt  
        ,[Expiry Date]       = convert(varchar,expiryDate,101)  
                     
        FROM ' + @tableName + ' main WITH(NOLOCK)  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'creditLimitIntHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 IF @tableName IN ('topUpLimit', 'topUpLimitMod')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Currency' UNION ALL  
   SELECT 'Limit Per Day' UNION ALL  
   SELECT 'Per Topup Limit' UNION ALL  
   SELECT 'Max Credit Limit For Agent'  
       
   SET @table='(  
        SELECT TOP 1  
         [Currency]        = curr.currencyCode  
        ,[Limit Per Day]      = limitPerDay  
        ,[Per Topup Limit]      = perTopUpLimit     
        ,[Max Credit Limit For Agent]   = maxCreditLimitForAgent        
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN currencyMaster curr WITH(NOLOCK) ON main.currency = curr.currencyId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''  
                          
       )x '  
 END  
   
 IF @tableName IN ('topUpLimitInt', 'topUpLimitIntMod')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Currency' UNION ALL  
   SELECT 'Limit Per Day' UNION ALL  
   SELECT 'Per Topup Limit'  
       
   SET @table='(  
        SELECT TOP 1  
         [Currency]        = curr.currencyCode  
        ,[Limit Per Day]      = limitPerDay  
        ,[Per Topup Limit]      = perTopUpLimit            
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN currencyMaster curr WITH(NOLOCK) ON main.currency = curr.currencyId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''  
                          
       )x '  
 END  
   
 IF @tableName IN ('fundDeposit', 'fundDepositMod')  
 BEGIN  
  
  INSERT @columnList(columnName)  
   SELECT 'Req Id'   UNION ALL  
   SELECT 'Agent Name'  UNION ALL  
   SELECT 'Bank Name'  UNION ALL  
   SELECT 'Amount'   UNION ALL  
   SELECT 'Deposited Date'   UNION ALL  
   SELECT 'Remarks'  UNION ALL  
   SELECT 'Created By'  UNION ALL  
   SELECT 'Created Date' UNION ALL  
   SELECT 'Modified By' UNION ALL  
   SELECT 'Modified Date'   
       
   SET @table='(  
        SELECT TOP 1  
         [Req Id]        = rowId  
        ,[Agent Name]       = dbo.GetAgentNameFromId(agentId)  
        ,[Bank Name]       = dbo.FNAGetAccName(bankId)   
        ,[Amount]        = dbo.ShowDecimal(amount)    
        ,[Deposited Date]      = CONVERT(VARCHAR,depositedDate,107)   
        ,[Remarks]        = remarks    
        ,[Created By]       = createdBy     
        ,[Created Date]       = convert(varchar,createdDate ,107)  
        ,[Modified By]       = modifiedBy   
        ,[Modified Date]         = convert(varchar,modifiedDate ,107)         
        FROM ' + @tableName + ' main WITH(NOLOCK)  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'fundDepositMod' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 IF @tableName IN ('fundTransfer', 'fundTransferMod')  
 BEGIN  
  
  INSERT @columnList(columnName)  
   SELECT 'Req Id'   UNION ALL  
   SELECT 'Super Agent Name'  UNION ALL  
   SELECT 'Agent Name'  UNION ALL  
   SELECT 'Amount'   UNION ALL  
   SELECT 'Date'   UNION ALL  
   SELECT 'Transfer Type' UNION ALL  
   SELECT 'Remarks'  UNION ALL  
   SELECT 'Created By'  UNION ALL  
   SELECT 'Created Date' UNION ALL  
   SELECT 'Modified By' UNION ALL  
   SELECT 'Modified Date'   
  
   SET @table='(  
        SELECT TOP 1  
         [Req Id]        = fundTrxId  
        ,[Super Agent Name]       = dbo.GetAgentNameFromId(Sagent)  
        ,[Agent Name]       = dbo.GetAgentNameFromId(agent)  
        ,[Amount]        = dbo.ShowDecimal(trnAmt)    
        ,[Date]         = CONVERT(VARCHAR,trnDate,107)   
        ,[Transfer Type]      = case when trnType=''T'' then ''Transfer'' else ''Receipt'' end   
        ,[Remarks]        = remarks    
        ,[Created By]       = createdBy     
        ,[Created Date]       = convert(varchar,createdDate ,107)  
        ,[Modified By]       = modifiedBy   
        ,[Modified Date]         = convert(varchar,modifiedDate ,107)         
        FROM ' + @tableName + ' main WITH(NOLOCK)  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'fundTransferMod' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 IF @tableName IN ('moneyGram', 'moneyGramMod')  
 BEGIN  
  --select * from moneyGram  
  INSERT @columnList(columnName)  
   SELECT 'Agent'        UNION ALL  
   SELECT 'Control No'       UNION ALL  
   SELECT 'Receiver Full Name'     UNION ALL  
   SELECT 'Sender Full Name'     UNION ALL  
   SELECT 'Receiver Contact Number'   UNION ALL  
   SELECT 'Tran Amount'      UNION ALL  
   SELECT 'Tran Date'       UNION ALL  
   SELECT 'Location'       UNION ALL  
   SELECT 'Address'       UNION ALL  
   SELECT 'Created By'       UNION ALL  
   SELECT 'Created Date'   
  
   SET @table='(  
        SELECT TOP 1  
         [Agent]        = main.agent  
        ,[Control No]       = main.controlNo  
        ,[Receiver Full Name]     = main.recFullName  
        ,[Sender Full Name]      = main.sendFullName  
        ,[Receiver Contact Number]    = main.recContactNo  
        ,[Tran Amount]       = dbo.ShowDecimal(main.amount)    
        ,[Tran Date]       = convert(varchar,main.tranDate ,107)    
        ,[Location]        = dbo.GetAgentNameFromId(main.location)  
        ,[Address]        = address    
        ,[Created By]       = main.createdBy     
        ,[Created Date]       = convert(varchar,main.createdDate ,107)  
             
        FROM ' + @tableName + ' main WITH(NOLOCK)  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'moneyGramMod' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 --Default Exchange Rate  
 IF @tableName IN ('defExRate', 'defExRateHistory')  
 BEGIN  
  DECLARE @setupType CHAR(2)  
  SELECT @setupType = setupType FROM defExRate WITH(NOLOCK) WHERE defExRateId = @dataId  
    
  IF(@setupType = 'CU')  
  BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Currency' UNION ALL  
   SELECT 'Factor' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Collection Rate' UNION ALL  
   SELECT 'Collection Notional Margin' UNION ALL  
   SELECT 'Collection Max Rate' UNION ALL  
   SELECT 'Collection Min Rate' UNION ALL  
   SELECT 'Payment Rate' UNION ALL  
   SELECT 'Payment Notional Margin' UNION ALL  
   SELECT 'Payment Max Rate' UNION ALL  
   SELECT 'Payment Min Rate'  
       
   SET @table='(  
        SELECT TOP 1  
         [Base Currency]        = main.baseCurrency  
        ,[Currency]          = main.currency  
        ,[Transaction Type]        = stm.typeTitle         
        ,[Factor]          = main.factor  
        ,[Collection Rate]        = main.cRate  
        ,[Collection Notional Margin]     = main.cMargin  
        ,[Collection Max Rate]       = main.cMax  
        ,[Collection Min Rate]       = main.cMin  
        ,[Payment Rate]         = main.pRate  
        ,[Payment Notional Margin]      = main.pMargin  
        ,[Payment Max Rate]        = main.pMax  
        ,[Payment Min Rate]                 = main.pMin  
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'defExRateHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
  END  
    
  IF(@setupType = 'CO')  
  BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Currency' UNION ALL  
   SELECT 'Country' UNION ALL  
   SELECT 'Factor' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Collection Rate' UNION ALL  
   SELECT 'Collection Notional Margin' UNION ALL  
   SELECT 'Payment Rate' UNION ALL  
   SELECT 'Payment Notional Margin'  
       
   SET @table='(  
        SELECT TOP 1  
         [Base Currency]        = main.baseCurrency  
        ,[Currency]          = main.currency  
        ,[Country]          = cm.countryName  
        ,[Transaction Type]        = stm.typeTitle         
        ,[Factor]          = main.factor  
        ,[Collection Rate]        = main.cRate  
        ,[Collection Notional Margin]     = main.cMargin  
        ,[Payment Rate]         = main.pRate  
        ,[Payment Notional Margin]      = main.pMargin  
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster cm WITH(NOLOCK) ON main.country = cm.countryId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'defExRateHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                      + '  
                          
       )x '  
  END  
    
  IF(@setupType = 'AG')  
  BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Base Currency' UNION ALL  
   SELECT 'Currency' UNION ALL  
   SELECT 'Country' UNION ALL  
   SELECT 'Agent' UNION ALL  
   SELECT 'Factor' UNION ALL  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Collection Rate' UNION ALL  
   SELECT 'Collection Notional Margin' UNION ALL  
   SELECT 'Payment Rate' UNION ALL  
   SELECT 'Payment Notional Margin'  
       
   SET @table='(  
        SELECT TOP 1  
         [Base Currency]        = main.baseCurrency  
        ,[Currency]          = main.currency  
        ,[Country]          = cm.countryName  
        ,[Agent]          = am.agentName  
        ,[Transaction Type]        = stm.typeTitle         
        ,[Factor]          = main.factor  
        ,[Collection Rate]        = main.cRate  
        ,[Collection Notional Margin]     = main.cMargin  
        ,[Payment Rate]         = main.pRate  
        ,[Payment Notional Margin]      = main.pMargin  
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN countryMaster cm WITH(NOLOCK) ON main.country = cm.countryId  
        LEFT JOIN agentMaster am WITH(NOLOCK) ON main.agent = am.agentId  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'defExRateHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
  END  
 END  
   
 IF @tableName IN ('spExRate', 'spExRateHistory')  
 BEGIN  
   INSERT @columnList(columnName)  
   SELECT 'Transaction Type' UNION ALL  
   SELECT 'Coll. Country' UNION ALL  
   SELECT 'Coll. Agent' UNION ALL  
   SELECT 'Coll. Agent Group' UNION ALL  
   SELECT 'Coll. Branch' UNION ALL  
   SELECT 'Coll. Branch Group' UNION ALL  
   SELECT 'Coll. Currency' UNION ALL  
   SELECT 'Coll. Rate Factor' UNION ALL  
   SELECT 'Coll. Rate' UNION ALL  
   SELECT 'Coll. Curr HO Margin' UNION ALL  
   SELECT 'Coll. Curr Agent Margin' UNION ALL  
   SELECT 'Coll. HO Tolerance Max' UNION ALL  
   SELECT 'Coll. HO Tolerance Min' UNION ALL  
   SELECT 'Coll. Agent Tolerance Max' UNION ALL  
   SELECT 'Coll. Agent Tolerance Min' UNION ALL  
   SELECT 'Payment Country' UNION ALL  
   SELECT 'Payment Agent' UNION ALL  
   SELECT 'Payment Agent Group' UNION ALL  
   SELECT 'Payment Branch' UNION ALL  
   SELECT 'Payment Branch Group' UNION ALL  
   SELECT 'Payment Currency' UNION ALL  
   SELECT 'Payment Rate Factor' UNION ALL  
   SELECT 'Payment Rate' UNION ALL  
   SELECT 'Payment Curr HO Margin' UNION ALL  
   SELECT 'Payment Curr Agent Margin' UNION ALL  
   SELECT 'Payment HO Tolerance Max' UNION ALL  
   SELECT 'Payment HO Tolerance Min' UNION ALL  
   SELECT 'Payment Agent Tolerance Max' UNION ALL  
   SELECT 'Payment Agent Tolerance Min'   
       
   SET @table='(  
        SELECT TOP 1  
         [Transaction Type]        = stm.typeTitle         
        ,[Coll. Country]        = ccm.countryName  
        ,[Coll. Agent]         = ISNULL(cam.agentName, ''All'')  
        ,[Coll. Agent Group]       = ISNULL(cag.detailTitle, ''All'')  
        ,[Coll. Branch]         = ISNULL(cbm.agentName, ''All'')  
        ,[Coll. Branch Group]       = ISNULL(cbg.detailTitle, ''All'')  
        ,[Coll. Currency]        = main.cCurrency  
        ,[Coll. Rate Factor]       = main.cRateFactor  
        ,[Coll. Rate]         = main.cRate  
        ,[Coll. Curr HO Margin]       = main.cCurrHOMargin  
        ,[Coll. Curr Agent Margin]      = main.cCurrAgentMargin  
        ,[Coll. HO Tolerance Max]      = main.cHOTolMax  
        ,[Coll. HO Tolerance Min]      = main.cHOTolMin  
        ,[Coll. Agent Tolerance Max]     = main.cAgentTolMax  
        ,[Coll. Agent Tolerance Min]     = main.cAgentTolMin  
        ,[Payment Country]        = pcm.countryName  
        ,[Payment Agent]        = ISNULL(pam.agentName, ''All'')  
        ,[Payment Agent Group]       = ISNULL(pag.detailTitle, ''All'')  
        ,[Payment Branch]        = ISNULL(pbm.agentName, ''All'')  
        ,[Payment Branch Group]       = ISNULL(pbg.detailTitle, ''All'')  
        ,[Payment Currency]        = main.pCurrency  
        ,[Payment Rate Factor]       = main.pRateFactor  
        ,[Payment Rate]         = main.pRate  
        ,[Payment Curr HO Margin]      = main.pCurrHOMargin  
        ,[Payment Curr Agent Margin]     = main.pCurrAgentMargin  
        ,[Payment HO Tolerance Max]      = main.pHOTolMax  
        ,[Payment HO Tolerance Min]      = main.pHOTolMin  
        ,[Payment Agent Tolerance Max]     = main.pAgentTolMax  
        ,[Payment Agent Tolerance Min]     = main.pAgentTolMin  
  
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN serviceTypeMaster stm WITH(NOLOCK) ON main.tranType = stm.serviceTypeId  
        LEFT JOIN countryMaster ccm WITH(NOLOCK) ON main.cCountry = ccm.countryId  
        LEFT JOIN agentMaster cam WITH(NOLOCK) ON main.cAgent = cam.agentId  
        LEFT JOIN staticDataValue cag WITH(NOLOCK) ON main.cAgentGroup = cag.valueId  
        LEFT JOIN agentMaster cbm WITH(NOLOCK) ON main.cBranch = cbm.agentId  
        LEFT JOIN staticDataValue cbg WITH(NOLOCK) ON main.cBranchGroup = cbg.valueId  
        LEFT JOIN countryMaster pcm WITH(NOLOCK) ON main.pCountry = pcm.countryId  
        LEFT JOIN agentMaster pam WITH(NOLOCK) ON main.pAgent = pam.agentId  
        LEFT JOIN staticDataValue pag WITH(NOLOCK) ON main.pAgentGroup = pag.valueId  
        LEFT JOIN agentMaster pbm WITH(NOLOCK) ON main.pBranch = pbm.agentId  
        LEFT JOIN staticDataValue pbg WITH(NOLOCK) ON main.pBranchGroup = pbg.valueId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'spExRateHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 IF @tableName IN ('rateMask', 'rateMaskHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Rate Mask Id'       UNION ALL  
   SELECT 'Currency'        UNION ALL  
   SELECT 'Rate Mask MUL- Before Decimal'   UNION ALL  
   SELECT 'Rate Mask MUL- After Decimal'   UNION ALL  
   SELECT 'Rate Mask DIV- Before Decimal'   UNION ALL  
   SELECT 'Rate Mask DIV- After Decimal'   UNION ALL  
   SELECT 'Created By'        UNION ALL  
   SELECT 'Created Date'       UNION ALL  
   SELECT 'Modified By'       UNION ALL  
   SELECT 'Modified Date'   
  
   SET @table='(  
        SELECT TOP 1  
         [Rate Mask Id]       = rmId  
        ,[Currency]        = currency  
        ,[Rate Mask MUL- Before Decimal]  = rateMaskMulBd  
        ,[Rate Mask MUL- After Decimal]   = rateMaskMulAd    
        ,[Rate Mask DIV- Before Decimal]  = rateMaskDivBd  
        ,[Rate Mask DIV- After Decimal]   = rateMaskDivAd  
        ,[Created By]       = createdBy     
        ,[Created Date]       = convert(varchar,createdDate ,107)  
        ,[Modified By]       = modifiedBy   
        ,[Modified Date]         = convert(varchar,modifiedDate ,107)         
        FROM ' + @tableName + ' main WITH(NOLOCK)  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'rateMaskHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
 IF @tableName IN ('errPaidTran', 'errPaidTranHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Tran Id' UNION ALL  
   SELECT 'Control No' UNION ALL  
   SELECT 'New Payout Agent' UNION ALL  
   SELECT 'Old Payout Agent' UNION ALL  
   SELECT 'Old Paid Date' UNION ALL  
   SELECT 'Message' UNION ALL  
   SELECT 'Tran Amount' UNION ALL  
   SELECT 'Created By' UNION ALL  
   SELECT 'Created Date'   
  
       
   SET @table='(  
        SELECT TOP 1  
         [Tran Id]        = tranId  
        ,[Control No]       = dbo.FNADecryptString(controlNo)  
        ,[New Payout Agent]      = newPBranchName   
        ,[Old Payout Agent]      = oldPBranchName    
        ,[Old Paid Date]      = CONVERT(VARCHAR,OLDPAIDDATE,101)  
        ,[Message]        = narration    
        ,[Tran Amount]       = payoutAmt  
        ,[Created By]       = main.createdBy   
        ,[Created Date]       = main.createdDate   
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        INNER JOIN remitTran TXN WITH(NOLOCK) ON TXN.id = main.tranId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +    
          CASE WHEN @tableName = 'errPaidTranHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END  
          + '  
                          
       )x '  
   
 END  
  
 IF @tableName ='balanceTopUp'  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'ID' UNION ALL  
   SELECT 'AGENT NAME' UNION ALL  
   SELECT 'TOP UP AMOUNT' UNION ALL  
   SELECT 'CREATED BY' UNION ALL  
   SELECT 'CREATED DATE'  
       
   SET @table='(  
        SELECT TOP 1  
         [ID]        = MAIN.BTID  
        ,[AGENT NAME]      = TXN.AGENTNAME  
        ,[TOP UP AMOUNT]     = MAIN.AMOUNT  
        ,[CREATED BY]      = MAIN.CREATEDBY    
        ,[CREATED DATE]      = CONVERT(VARCHAR,MAIN.CREATEDDATE,101)  
        FROM ' + @tableName + ' MAIN WITH(NOLOCK)  
        INNER JOIN AGENTMASTER TXN WITH(NOLOCK) ON TXN.AGENTID = MAIN.AGENTID  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''    
           
                          
       )x '  
   
 END  
  
 IF @tableName in ('imeRemitCardReIssueRequest')  
 BEGIN    
    INSERT @columnList(columnName)    
    SELECT 'Requesting For' UNION ALL   
    SELECT 'IME Remit Card Number' UNION ALL    
    SELECT 'New IME Remit Card Number' UNION ALL     
    SELECT 'Customer Name' UNION ALL    
    SELECT 'Request Remarks' UNION ALL    
    SELECT 'Created By' UNION ALL   
    SELECT 'Created Date'   
         
    SET @table='(    
   SELECT TOP 1   
    [Requesting For]     = CASE main.requestFor WHEN ''C'' THEN ''IME Remit Card Loss'' ELSE ''PIN Number Loss'' END  
   ,[IME Remit Card Number]   = main.oldRemitCardNo   
   ,[New IME Remit Card Number]  = main.newRemitCardNo   
   ,[Customer Name]     = ISNULL(km.firstName, '''') + ISNULL( '' '' + km.middleName, '''')+ ISNULL( '' '' + km.lastName, '''')  
   ,[Request Remarks]     = main.requestRemarks  
   ,[Created By]      = main.createdBy  
   ,[Created Date]      = main.createdDate  
   FROM ' + @tableName + ' main WITH(NOLOCK)    
   INNER JOIN kycMaster km WITH(NOLOCK) ON main.oldRemitCardNo = km.remitCardNo  
     WHERE main.' + @fieldName + ' = ''' + @dataId + '''      
                            
     )x '    
     
 END   
   
 IF @tableName IN ('userWiseTxnLimit', 'userWiseTxnLimitHISTORY')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'User Name' UNION ALL  
   SELECT 'User Full Name' UNION ALL  
   SELECT 'Send Per Day' UNION ALL  
   SELECT 'Send Per Txn' UNION ALL  
   SELECT 'Send Todays' UNION ALL  
   SELECT 'Pay Per Day' UNION ALL  
   SELECT 'Pay Per Txn' UNION ALL  
   SELECT 'Pay Todays' UNION ALL  
   SELECT 'Cancel Per Day' UNION ALL  
   SELECT 'Cancel Per Txn' UNION ALL  
   SELECT 'Cancel Todays' UNION ALL  
   SELECT 'Created By' UNION ALL  
   SELECT 'Created Date'   
       
   SET @table='(  
        SELECT TOP 1  
         [User Name]       = a.userName  
        ,[User Full Name]      = ISNULL(a.firstName, '''') + ISNULL( '' '' + a.middleName, '''')+ ISNULL( '' '' + a.lastName, '''')   
        ,[Send Per Day]       = main.sendPerDay   
        ,[Send Per Txn]       = main.sendPerTxn    
        ,[Send Todays]       = main.sendTodays    
        ,[Pay Per Day]       = main.payPerDay  
        ,[Pay Per Txn]       = main.payPerTxn    
        ,[Pay Todays]       = main.payTodays  
        ,[Cancel Per Day]      = main.cancelPerDay  
        ,[Cancel Per Txn]      = main.cancelPerTxn    
        ,[Cancel Todays]      = main.cancelTodays   
        ,[Created By]       = main.createdBy   
        ,[Created Date]       = main.createdDate   
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        INNER JOIN applicationUsers a WITH(NOLOCK) ON a.userId = main.userId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +    
          CASE WHEN @tableName = 'userWiseTxnLimitHISTORY' THEN ' AND main.approvedBy IS NULL ' ELSE '' END  
          + '  
                          
       )x '  
   
 END  
   
    
 IF @tableName IN ('customerMaster', 'customerMasterEditedDataMod')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Customer Id'     UNION ALL  
   SELECT 'First Name'      UNION ALL  
   SELECT 'Middle Name'     UNION ALL  
   SELECT 'Last Name'       UNION ALL  
   SELECT 'Country'      UNION ALL  
   SELECT 'State'       UNION ALL  
   SELECT 'Zip Code'      UNION ALL  
   SELECT 'City'       UNION ALL  
   SELECT 'City Unicode'     UNION ALL  
   SELECT 'Street'       UNION ALL  
   SELECT 'Street Unicode'     UNION ALL  
   SELECT 'Email Address'     UNION ALL  
   SELECT 'Phone no'      UNION ALL  
   SELECT 'Mobile No'      UNION ALL  
   SELECT 'Native CountryId'    UNION ALL  
   SELECT 'Date of birth'     UNION ALL  
   SELECT 'Occupation'      UNION ALL  
   SELECT 'Id ExpiryDate'     UNION ALL  
   SELECT 'Id Type'      UNION ALL  
   SELECT 'Id Number'      UNION ALL  
   SELECT 'Gender'       UNION ALL  
   SELECT 'Id Issued Date'     UNION ALL  
   SELECT 'Is Online User'     UNION ALL  
   SELECT 'Source of Fund'     UNION ALL  
   SELECT 'Visa Status'      UNION ALL  
   SELECT 'Employee Business Type'   UNION ALL  
   SELECT 'Remittance Allowed'    UNION ALL  
   SELECT 'Remarks'      UNION ALL  
   SELECT 'Organization Type'    UNION ALL  
   SELECT 'Date of Incorporation'    UNION ALL  
   SELECT 'Nature Of Company'     UNION ALL  
   SELECT 'Position'       UNION ALL  
   SELECT 'Name Of Authorized Person'  UNION ALL  
   SELECT 'Monthly Income'     UNION ALL  
   SELECT 'Telephone No'     UNION ALL  
   SELECT 'Company Registration No'    
     
       
   SET @table='(  
         SELECT  TOP 1   
        [Customer Type] = sd.detailTitle ,      
        [Customer Id] = customerId ,   
        [First Name] = firstName,  
        [Middle Name] = middleName,  
        [Last Name] = lastName1,  
        [Country]=CM.countryName,  
        [State]=CSM.stateName,  
        [Zip Code]=zipCode,  
        [City]=city,  
        [City Unicode]=cityUnicode,  
        [Street]=main.street,  
        [Street Unicode]=main.streetUnicode,  
        [Email Address]=email,  
        [Phone no]=homePhone,  
        [Mobile No]=mobile,  
        [Native CountryId]=main.nativeCountry,  
        [Date of birth]=dob,  
        [Occupation]=sdv.detailTitle,  
        [Id ExpiryDate]=main.idExpiryDate,  
        [Id Type]=sdv1.detailTitle,  
        [Id Number]=main.idNumber,  
        [Telephone No]=main.telNo,  
        [Gender]=sdv2.detailTitle,  
        [Id Issued Date]=main.idIssueDate,  
        [Is Online User]= CASE WHEN main.onlineUser = ''Y'' THEN ''Yes'' ELSE ''NO'' end ,  
        [Source of Fund]=sdv3.detailTitle,  
        [Visa Status] = sdv4.detailTitle,  
        [Employee Business Type] =sdv5.detailTitle,  
        [Remittance Allowed] = CASE WHEN ISNULL(main.remittanceAllowed,0)=0 THEN ''Yes'' ELSE ''NO'' END,  
        [Remarks]=main.remarks,  
        [Organization Type]=sdv6.detailTitle,  
        [Date of Incorporation] = main.dateofIncorporation,  
        [Nature Of Company]  =sdv7.detailTitle,  
        [Position] = sdv8.detailTitle,  
        [Name Of Authorized Person] = main.nameOfAuthorizedPerson,  
        [Monthly Income] = main.monthlyIncome,  
        [Company Registration No] = main.registerationNo  
        FROM '+@tableName+' main WITH(NOLOCK)  
        LEFT join agentMaster am with(nolock) on main.agentId = am.agentId  
        LEFT JOIN dbo.staticDataValue sd WITH(NOLOCK) ON sd.valueId = main.customerType  
        LEFT JOIN dbo.staticDataValue sdv WITH(NOLOCK) ON sdv.valueId = main.occupation  
        INNER JOIN dbo.staticDataValue sdv1 WITH(NOLOCK) ON sdv1.valueId = main.idType  
        left JOIN dbo.staticDataValue sdv2 WITH(NOLOCK) ON sdv2.valueId = main.gender  
        LEFT JOIN dbo.staticDataValue sdv3 WITH(NOLOCK) ON sdv3.valueId = main.sourceOfFund  
        LEFT JOIN dbo.staticDataValue sdv4 WITH(NOLOCK) ON sdv4.valueId = main.visaStatus  
        LEFT JOIN dbo.staticDataValue sdv5 WITH(NOLOCK) ON sdv5.valueId = main.employeeBusinessType  
        LEFT JOIN dbo.staticDataValue sdv6 WITH(NOLOCK) ON sdv6.valueId = main.organizationType  
        LEFT JOIN dbo.staticDataValue sdv7 WITH(NOLOCK) ON sdv7.valueId = main.natureOfCompany  
        LEFT JOIN dbo.staticDataValue sdv8 WITH(NOLOCK) ON sdv8.valueId = main.position  
        INNER JOIN dbo.countryMaster CM WITH(NOLOCK) ON CM.countryId = main.country   
        LEFT JOIN dbo.countryStateMaster CSM WITH(NOLOCK) ON CSM.STATEID = MAIN.state  
        
      WHERE [' + @fieldName + '] = ''' + @dataId + '''                         
  
       )x '  
       PRINT @table  
   
 END  
  
 IF @tableName IN ('customerMemIdReIssue')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Customer Id' UNION ALL  
   SELECT 'Old Membership Id' UNION ALL  
   SELECT 'New Membership Id' UNION ALL    
   SELECT 'Request Remarks' UNION ALL    
   SELECT 'Requested By' UNION ALL  
   SELECT 'Requested Date'  
       
   SET @table='(  
        SELECT TOP 1            
        [Customer Id] = customerId ,   
        [Old Membership Id] = oldMemId,  
        [New Membership Id] = newMemId,  
        [Request Remarks] = remarks,          
        [Requested By] = main.createdBy,  
        [Requested Date] = main.createdDate       
        FROM ' + @tableName + ' main WITH(NOLOCK)  
          WHERE [' + @fieldName + '] = ''' + @dataId + ''' AND approvedBy IS NULL  
      )x '  
  
  --PRINT(@table)  
  --RETURN  
   
 END  
  
  
 IF @tableName IN('agentBlock','agentBlockMod')  
 BEGIN  
  INSERT @columnList(columnName)  
   select 'Agent' UNION ALL  
   select 'Status' UNION ALL  
   select 'Remark'  
  
  SET @table='(  
        SELECT TOP 1            
        [Agent] = am.agentName,   
        [Status] = agentStatus,  
        [Remark] = remarks              
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        LEFT JOIN agentMaster am with(nolock) on am.agentId=main.agentId   
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +    
            
          CASE WHEN @tableName = 'agentBlock' THEN ' AND main.approvedBy IS NULL ' ELSE '' END  
          + '                          
  
      )x '  
    
  --PRINT(@table)  
  --RETURN  
 END  
   
 IF @tableName IN ('agentGroupMaping', 'agentGroupMapingHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Agent' UNION ALL  
   SELECT 'Group' UNION ALL  
   SELECT 'Group Detail' UNION ALL     
   SELECT 'Requested By' UNION ALL  
   SELECT 'Requested Date'  
       
   SET @table='(  
        SELECT TOP 1  
          [Agent]    = am.agentName  
         ,[Group]    = sdt.typeTitle  
         ,[Group Detail]  = sdv.detailTitle  
         ,[Requested By]  = main.createdBy      
         ,[Requested Date]  = convert(varchar,main.createdDate,101)  
           
        FROM ' + @tableName + ' main WITH(NOLOCK)  
        INNER JOIN staticDataType sdt on sdt.typeId = main.groupCat  
        INNER JOIN staticDataValue sdv on sdv.valueId =  main.groupDetail  
        INNER JOIN agentMaster am on am.agentId = main.agentId  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'agentGroupMapingHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
   
  
 IF @tableName IN ('bankGuarantee', 'bankGuaranteeHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'Guarantee No' UNION ALL  
   SELECT 'Amount' UNION ALL  
   SELECT 'Currency' UNION ALL     
   SELECT 'Bank Name' UNION ALL  
   SELECT 'Issued Date' UNION ALL  
   SELECT 'Expiry Date' UNION ALL  
   SELECT 'Follow UpDate'  
  
   SET @table='(  
        SELECT TOP 1  
          [Guarantee No]  = main.guaranteeNo  
         ,[Amount]   = main.amount  
         ,[Currency]  = main.currency  
         ,[Bank Name]  = main.bankName      
         ,[Issued Date]  = convert(varchar, main.issuedDate, 101)  
         ,[Expiry Date]  = convert(varchar, main.expiryDate, 101)  
         ,[Follow UpDate] = convert(varchar, main.followUpDate, 101)  
           
        FROM ' + @tableName + ' main WITH(NOLOCK)      
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'bankGuaranteeHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
  
 IF @tableName IN ('cashSecurity', 'cashSecurityHistory')  
 BEGIN  
  INSERT @columnList(columnName)  
   SELECT 'RowId' UNION ALL  
   SELECT 'depositAcNo' UNION ALL     
   SELECT 'cashDeposit' UNION ALL  
   SELECT 'currency' UNION ALL  
   SELECT 'depositedDate' UNION ALL  
   SELECT 'bankName'  
  
   SET @table='(  
        SELECT TOP 1  
          [RowId]   = main.csId  
         ,[depositAcNo]  = main.depositAcNo  
         ,[cashDeposit]  = main.cashDeposit      
         ,[currency]  = main.currency  
         ,[depositedDate] = main.depositedDate  
         ,[bankName] = main.bankName  
           
        FROM ' + @tableName + ' main WITH(NOLOCK)   
        INNER JOIN agentMaster am WITH(NOLOCK) ON main.agentid = am.agentId     
          WHERE [' + @fieldName + '] = ''' + @dataId + '''' +  
          CASE WHEN @tableName = 'cashSecurityHistory' THEN ' AND main.approvedBy IS NULL ' ELSE '' END                          
        + '  
                          
       )x '  
 END  
 IF @tableName IN ('tblpartnerwiseCountry','tblpartnerwiseCountryMod')  
 BEGIN  
      
  INSERT @columnList(columnName)  
     
   SELECT 'AGENT NAME' UNION ALL  
   SELECT 'COUNTRY NAME' UNION ALL  
   SELECT 'PAYOUT METHOD' UNION ALL  
   SELECT 'IS REAL TIME' UNION ALL  
   SELECT 'IS ACTIVE' UNION ALL 
   SELECT 'MINIMUM LIMIT' UNION ALL  
   SELECT 'MAXIMUM LIMIT' UNION ALL  
   SELECT 'LIMIT CURRENCY' UNION ALL  
   SELECT 'EX RATE CALCULATE BY PARTNER'  UNION ALL 
   SELECT 'IS ACCOUNT VALIDATION SUPPORTED'   
       
   SET @table='(  
        SELECT TOP 1  
           
         [AGENT NAME]      = TXN.AGENTNAME  
        ,[COUNTRY NAME]      = CM.CountryName  
        ,[PAYOUT METHOD]     = ISNULL(S.typeTitle, ''All'')  
        ,[IS REAL TIME]      = CASE WHEN ISNULL(MAIN.isRealTime,''0'') = 0 THEN ''FALSE'' ELSE ''TRUE'' END  
		,[IS ACTIVE]      = CASE WHEN ISNULL(MAIN.isActive,''0'') = 0 THEN ''FALSE'' ELSE ''TRUE'' END  
        ,[MINIMUM LIMIT]     = MAIN.minTxnLimit  
        ,[MAXIMUM LIMIT]     = MAIN.maxTxnLimit  
        ,[LIMIT CURRENCY]     = MAIN.LimitCurrency    
        ,[EX RATE CALCULATE BY PARTNER]  = CASE WHEN ISNULL(MAIN.exRateCalByPartner,''0'') = 0 THEN ''FALSE'' ELSE ''TRUE'' END  
        ,[IS ACCOUNT VALIDATION SUPPORTED]  = CASE WHEN ISNULL(MAIN.isACValidateSupport,''0'') = 0 THEN ''FALSE'' ELSE ''TRUE'' END  
        FROM ' + @tableName + ' MAIN WITH(NOLOCK)  
        LEFT JOIN AGENTMASTER TXN WITH(NOLOCK) ON TXN.AGENTID = MAIN.AGENTID  
        LEFT JOIN COUNTRYMASTER CM WITH(NOLOCK) ON CM.COUNTRYID = MAIN.COUNTRYID  
        LEFT JOIN SERVICETYPEMASTER S WITH(NOLOCK) ON S.serviceTypeId = MAIN.PAYMENTMETHOD  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''    
           
                          
       )x '  
   
 END  
 IF @tableName IN ('sendingAmtThreshold','sendingAmtThresholdHistory')  
 BEGIN  
      
  INSERT @columnList(columnName)  
     
   SELECT 'SENDING COUNTRY NAME' UNION ALL  
   SELECT 'RECEIVING COUNTRY NAME' UNION ALL  
   SELECT 'SENDING AGENT' UNION ALL  
   SELECT 'AMOUNT' UNION ALL  
   SELECT 'MESSAGE' UNION ALL  
   SELECT 'IS ACTIVE' UNION ALL  
   SELECT 'CREATED BY' UNION ALL  
   SELECT 'CREATED DATE'  
       
   SET @table='(  
        SELECT TOP 1  
           
         [SENDING COUNTRY NAME]    = MAIN.sCountryName  
        ,[RECEIVING COUNTRY NAME]   = MAIN.rCountryName  
        ,[SENDING AGENT]     = ISNULL(TXN.agentName,''All'')  
        ,[AMOUNT]       = MAIN.Amount  
        ,[MESSAGE]       = MAIN.MessageTxt  
        ,[IS ACTIVE]      = MAIN.IsActive  
        ,[CREATED BY]      = MAIN.CREATEDBY    
        ,[CREATED DATE]      = CONVERT(VARCHAR,MAIN.CREATEDDATE,101)  
        FROM ' + @tableName + ' MAIN WITH(NOLOCK)  
        LEFT JOIN AGENTMASTER TXN WITH(NOLOCK) ON TXN.AGENTID = MAIN.sAgent  
          WHERE [' + @fieldName + '] = ''' + @dataId + '''    
           
                          
       )x '  
   
 END  
  
 DECLARE   
   @fieldList   NVARCHAR(MAX)  
  ,@fieldList2  NVARCHAR(MAX)    
  ,@sql    NVARCHAR(MAX)  
  
  
 SELECT   
   @fieldList = ISNULL(@fieldList + ', ', '') + + '[' + columnName + ']'  
  ,@fieldList2 = ISNULL(@fieldList2 + ', ', '') + 'CAST (ISNULL(' + '[' +  columnName + '] , '''') AS NVARCHAR(MAX)) [' + columnName + ']'  
 FROM @columnList  
   
   
 IF @fieldList IS NULL  
 BEGIN  
  SELECT   
   @fieldList = ISNULL(@fieldList + ', ', '') + + '[' + column_name + ']'  
    ,@fieldList2 = ISNULL(@fieldList2 + ', ', '') + 'CAST (ISNULL(' + '[' +  column_name + '] , '''') AS NVARCHAR(MAX)) [' + column_name + ']'  
  FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME =  @tableName  
   AND COLUMN_NAME NOT IN (   
           'isDeleted', 'isActive', 'createdBy'  
          ,'createdDate', 'modifiedBy', 'modifiedDate'  
          ,'approvedBy', 'approvedDate', 'modType'  
          ,'msrepl_tran_version'  
         )  
  SET @table = @tableName  
  SET @sql = '  
   SELECT field, data  
   FROM   
    (  
     SELECT '  + @fieldList2 + ' FROM ' + @table + '    
      WHERE [' + @fieldName + '] = ''' + @dataId + '''                   
    ) p  
   UNPIVOT (Data FOR Field IN   
      ( '  + @fieldList + ' )  
     
   )AS unpvt;'   
 END  
 ELSE  
 BEGIN  
  SET @sql = '  
    SELECT field, data  
    FROM   
     (  
      SELECT '  + @fieldList2 + ' FROM ' + @table + '  
     ) p  
    UNPIVOT (Data FOR Field IN   
       ( '  + @fieldList + ' )  
      
    )AS unpvt;'   
 END  
  
--PRINT @sql  
  
 DECLARE @temp_table TABLE(Field NVARCHAR(100), Data NVARCHAR(MAX))  
 INSERT @temp_table (Field, data)  
 EXEC (@sql)  
   
 SET @fieldList = NULL  
 --print @table  
 SELECT   
   @fieldList = ISNULL(@fieldList +  @separator, '') + Field + ' = ' + Data   
 FROM @temp_table  
 SET @dataList = @fieldList  

 IF @returnTable = 'Y'  
  SELECT @dataList  
END
GO