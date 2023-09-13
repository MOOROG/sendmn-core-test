SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROC PROC_CUSTOMERMODIFYLOG  
(  
		@flag					VARCHAR(30),  
		@user					VARCHAR(100)	= NULL,  
		@customerId				BIGINT			= NULL,  
		@customerType			VARCHAR(30)		= NULL,  
		@fullName				NVARCHAR(200)	= NULL,  
		@firstName				VARCHAR(50)		= NULL,  
		@middleName				VARCHAR(50)		= NULL,  
		@lastName1				VARCHAR(50)		= NULL,  
		@country				VARCHAR(30)		= NULL,  
		@zipCode				VARCHAR(30)		= NULL,  
		@state					VARCHAR(30)		= NULL,  
		@street					VARCHAR(80)		= NULL,  
		@custCity				VARCHAR(100)	= NULL,  
		@district				VARCHAR(100)	=	NULL,
		@cityUnicode			NVARCHAR(100)	= NULL,  
		@streetUnicode			NVARCHAR(100)	= NULL,  
		@custGender				VARCHAR(30)		= NULL,  
		@custNativecountry		VARCHAR(30)		= NULL,  
		@dob					varchar(40)		= null,    
		@email					VARCHAR(100)	= NULL,  
		@custTelNo				VARCHAR(30)		= NULL,  
		@mobileNumber			varchar(20)		= NULL,  
		@visaStatus				INT				= NULL,  
	    @employeeBusinessType	INT				= NULL,  
	    @nameOfEmployeer		VARCHAR(80)		= NULL,  
	    @SSNNO					VARCHAR(20)		= NULL,  
	    @occupation				VARCHAR(30)		= NULL,  
	    @sourceOfFound			VARCHAR(100)	= NULL,  
		@monthlyIncome			VARCHAR(50)		= NULL,  
		@idType					varchar(40)		= null,  --new added by dhan  
		@idNumber				VARCHAR(20)		= NULL,  
		@issueDate				varchar(40)		= null,  
		@expiryDate				varchar(40)		= NULL,  --new added by dhan  
		@remittanceAllowed		BIT				= NULL,  
		@onlineUser				VARCHAR(50)		= NULL,  
		@remarks				VARCHAR(1000)	= NULL,  
		@placeofissue			INT     = NULL,   --new added by gunn  
   
  
	 --used for customer type organisation  
	    @companyName			VARCHAR(100)	= NULL,  
	    @registerationNo		VARCHAR(30)		= NULL,  
	    @organizationType		INT				= NULL,  
	    @dateofIncorporation	DATETIME		= NULL,  
	    @natureOfCompany		INT				= NULL,  
	    @nameOfAuthorizedPerson VARCHAR(80)		= NULL,  
	    @position				INT				= NULL,  
	  
	 -- old Data  
		@bank					VARCHAR(5)		= NULL,  
		@accNumber				VARCHAR(30)		= NULL,  
		@bankId						VARCHAR(100)		=	NULL,
		@accountNumber				VARCHAR(100)		=	NULL,
		--- for Select List  
		@fromDate				VARCHAR(20)		= NULL,  
		@toDate					VARCHAR(20)		= NULL,  
		@sortBy					VARCHAR(50)		= NULL,  
		@sortOrder				VARCHAR(5)		= NULL,  
		@pageSize				INT				= NULL,  
		@pageNumber				INT				= NULL,  
		@searchCriteria			VARCHAR(30)		= NULL ,  
		@searchValue			VARCHAR(50)		= NULL ,  
		@sourceOfFund			VARCHAR(30)		= NULL ,
		@additionalAddress		VARCHAR(50)		= NULL
		 
)  
AS  
SET NOCOUNT ON;  
SET XACT_ABORT ON;  
BEGIN  
 IF @flag = 'i'  
  BEGIN  
   DECLARE @oldcustomerType   VARCHAR(30)   = NULL,  
     @oldfullName    NVARCHAR(200)  = NULL,  
     @oldfirstName    VARCHAR(30)   = NULL,  
     @oldmiddleName    VARCHAR(30)   = NULL,  
     @oldlastName1    VARCHAR(30)   = NULL,  
     @oldcountry     VARCHAR(30)   = NULL,  
     @oldzipCode     VARCHAR(30)   = NULL,  
     @oldstate     VARCHAR(30)   = NULL,  
     @oldstreet     VARCHAR(80)   = NULL,  
     @oldcustCity    VARCHAR(100)  = NULL,  
	 @olddistrict    VARCHAR(100)  = NULL, 
     @oldcityUnicode    NVARCHAR(100)  = NULL ,  
     @oldstreetUnicode   NVARCHAR(100)  = NULL ,  
     @oldcustGender    VARCHAR(30)   = NULL ,  
     @oldcustNativecountry  VARCHAR(30)   = NULL ,  
     @olddob      VARCHAR(40)   = null,    
     @oldemail     VARCHAR(100)  = NULL,  
     @oldcustTelNo    VARCHAR(30)   = NULL ,  
     @oldmobileNumber   varchar(20)   = NULL,  
     @oldvisaStatus    INT     = NULL ,  
     @oldemployeeBusinessType INT     = NULL ,  
     @oldnameOfEmployeer   VARCHAR(80)   = NULL ,  
     @oldSSNNO     VARCHAR(20)   = NULL ,  
     @oldoccupation    VARCHAR(30)   = NULL ,  
     @oldplaceofissue   INT     = NULL ,  
     @oldsourceOfFound   VARCHAR(100)  = NULL ,  
     @oldmonthlyIncome   VARCHAR(50)   = NULL,  
     @oldidType     varchar(40)   = null,  --new added by dhan  
     @oldidNumber    VARCHAR(20)   = NULL,  
     @oldissueDate    varchar(40)   = null,  
     @oldexpiryDate    varchar(40)   = NULL,  --new added by dhan  
     @oldremittanceAllowed  BIT     = NULL ,  
     @oldonlineUser    VARCHAR(50)   = NULL ,  
     @oldremarks     VARCHAR(1000)  = NULL ,  
	 @oldAddress	VARCHAR(50)		= NULL,
  
     --used for customer type organisation  
     @oldcompanyName    VARCHAR(100)  = NULL ,  
     @oldregisterationNo   VARCHAR(30)   = NULL ,  
     @oldorganizationType  INT     = NULL ,  
     @olddateofIncorporation  DATETIME   = NULL ,  
     @oldnatureOfCompany   INT     = NULL ,  
     @oldnameOfAuthorizedPerson VARCHAR(80)   = NULL ,  
     @oldposition    INT     = NULL ,  
       
     -- old Data  
     @oldbank     VARCHAR(5)   = NULL,  
     @oldaccNumber    VARCHAR(30)   = NULL,  
     @amendmentId    VARCHAR(MAX)    
     
   SET @amendmentId = NEWID()  
   SELECT @oldcustomerType   = customerType,  
     @oldfullName    = fullName,  
     @oldfirstName    = firstName,  
     @oldmiddleName    = middleName,  
     @oldlastName1    = lastName1,  
     @oldcountry     = country,  
     @oldzipCode     = zipCode,  
     @oldstate     = state,  
     @oldstreet     = street,  
     @oldcustCity    = city,  
	 @olddistrict    = district,  
     @oldcityUnicode    = cityUnicode,  
     @oldstreetUnicode   = streetUnicode,  
     @oldcustGender    = gender,  
     @oldcustNativecountry  = nativeCountry,  
     @olddob      = CONVERT(VARCHAR(10),dob,121),  
     @oldemail     = email,  
     @oldcustTelNo    = telNo,  
     @oldmobileNumber   = mobile,  
     @oldvisaStatus    = visaStatus,  
     @oldemployeeBusinessType = employeeBusinessType,   
     @oldnameOfEmployeer   = nameOfEmployeer,  
     @oldSSNNO     = SSNNO,  
     @oldoccupation    = occupation,  
     @oldplaceofissue   = placeofissue,  
     @oldsourceOfFound   = sourceOfFund,  
     @oldmonthlyIncome   = monthlyIncome,  
     @oldidType     = idType,  
     @oldidNumber    = idNumber,   
     @oldissueDate    = CONVERT(VARCHAR(10),idIssueDate,121),   
     @oldexpiryDate    = CONVERT(VARCHAR(10),idExpiryDate,121),  
     @oldremittanceAllowed  = remittanceAllowed,  
     @oldonlineUser    = onlineUser,  
     @oldremarks     = remarks,  
     --used for customer type organisation  
     @oldcompanyName    = companyName,  
     @oldregisterationNo   = registerationNo,  
     @oldorganizationType  = organizationType,  
     @olddateofIncorporation  = CONVERT(VARCHAR,dateofIncorporation,111),  
     @oldnatureOfCompany   = natureOfCompany,  
     @oldnameOfAuthorizedPerson = nameOfAuthorizedPerson,   
     @oldposition    = position,  
     -- old Data  
     @oldbank     = bankName,  
     @oldaccNumber    = bankAccountNo,
	 @oldAddress		= address
  FROM customerMaster (NOLOCK)   
  WHERE customerId = @customerId  
    
  PRINT 'New Mobile No ='+@mobileNumber;  
  PRINT 'Old Mobile No='+@oldmobileNumber ;  
   IF ISNULL(@oldcustomerType,'') != ISNULL(@customerType,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'customerType', @oldcustomerType, @user, GETDATE(), @customerType,@amendmentId  
    END  
   IF ISNULL(@oldfirstName,'') != ISNULL(@firstName,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'firstName', @oldfirstName, @user, GETDATE(), @firstName,@amendmentId  
    END  
   IF ISNULL(@oldmiddleName,'') != ISNULL(@middleName,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'middleName', @oldmiddleName, @user, GETDATE(), @middleName,@amendmentId  
    END  
   IF ISNULL(@oldlastName1,'') != ISNULL(@lastName1,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'lastName1', @oldlastName1, @user, GETDATE(), @lastName1,@amendmentId  
    END  
   IF ISNULL(@oldfullName,'') !=ISNULL(@fullName,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'fullName', @oldfullName, @user, GETDATE(), @fullName,@amendmentId  
    END  
   IF ISNULL(@oldcountry,'') != ISNULL(@country,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'country', @oldcountry, @user, GETDATE(), @country,@amendmentId  
    END  
   IF ISNULL(@oldzipCode,'') != ISNULL(@zipCode,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'zipCode', @oldzipCode, @user, GETDATE(), @zipCode,@amendmentId  
    END  
   IF ISNULL(@oldstate,'') != ISNULL(@state,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'state', @oldstate, @user, GETDATE(), @state,@amendmentId  
    END  
   IF ISNULL(@oldstreet,'') !=ISNULL(@street,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'street', @oldstreet, @user, GETDATE(), @street,@amendmentId  
    END  
   IF ISNULL(@oldcustCity,'') !=ISNULL(@custCity,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'city', @oldcustCity, @user, GETDATE(), @custCity,@amendmentId  
    END  
	IF ISNULL(@olddistrict,'') !=ISNULL(@district,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'district', @olddistrict, @user, GETDATE(), @district,@amendmentId  
    END  
   IF ISNULL(@oldcityUnicode,'') !=ISNULL(@cityUnicode,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'cityUnicode', @oldcityUnicode, @user, GETDATE(), @cityUnicode,@amendmentId  
    END  
   IF ISNULL(@oldstreetUnicode,'') !=ISNULL(@streetUnicode,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'streetUnicode', @oldstreetUnicode, @user, GETDATE(), @streetUnicode,@amendmentId  
    END  
   IF ISNULL(@oldcustGender,'') !=ISNULL(@custGender,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'gender', @oldcustGender, @user, GETDATE(), @custGender,@amendmentId  
    END  
   IF ISNULL(@oldcustNativecountry,'') !=ISNULL(@custNativecountry,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'nativeCountry', @oldcustNativecountry, @user, GETDATE(), @custNativecountry,@amendmentId  
    END  
   IF ISNULL(@olddob,'') != ISNULL(@dob,'') 
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'dob', ISNULL(@olddob,''), @user, GETDATE(), ISNULL(@dob,''),@amendmentId  
    END  
   IF ISNULL(@oldemail,'') !=ISNULL(@email,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'email', @oldemail, @user, GETDATE(), @email,@amendmentId  
    END  
   IF ISNULL(@oldcustTelNo,'') !=ISNULL(@custTelNo,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'telNo', @oldcustTelNo, @user, GETDATE(), @custTelNo,@amendmentId  
    END  
   IF ISNULL(@oldmobileNumber,'') !=ISNULL(@mobileNumber,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'mobile', @oldmobileNumber, @user, GETDATE(), @mobileNumber,@amendmentId  
    END  
   IF ISNULL(@oldvisaStatus,'') != ISNULL(@visaStatus,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'visaStatus', @oldvisaStatus, @user, GETDATE(), @visaStatus,@amendmentId  
    END  
   IF ISNULL(@oldemployeeBusinessType,'') != ISNULL(@employeeBusinessType,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'employeeBusinessType', @oldemployeeBusinessType, @user, GETDATE(), @employeeBusinessType,@amendmentId  
    END  
   IF ISNULL(@oldnameOfEmployeer,'') !=ISNULL(@nameOfEmployeer,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'nameOfEmployeer', @oldnameOfEmployeer, @user, GETDATE(), @nameOfEmployeer,@amendmentId  
    END  
   IF ISNULL(@oldSSNNO,'') != ISNULL(@SSNNO,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'SSNNO', @oldSSNNO, @user, GETDATE(), @SSNNO,@amendmentId  
    END 
   IF ISNULL(@oldoccupation,'') != ISNULL(@occupation,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'occupation', @oldoccupation, @user, GETDATE(), @occupation,@amendmentId  
    END  
   IF ISNULL(@oldplaceofissue,'') != ISNULL(@placeofissue,'')   
   BEGIN  
    INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
    SELECT @customerId, 'placeofissue', @oldplaceofissue, @user, GETDATE(), @placeofissue,@amendmentId  
   END  
     
   IF ISNULL(@oldsourceOfFound,'') !=ISNULL(@sourceOfFound,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'sourceOfFund', @oldsourceOfFound, @user, GETDATE(), @sourceOfFound,@amendmentId  
    END  
   IF ISNULL(@oldmonthlyIncome,'') != ISNULL(@monthlyIncome,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'monthlyIncome', @oldmonthlyIncome, @user, GETDATE(), @monthlyIncome,@amendmentId  
    END  
   IF ISNULL(@oldidType,'') != ISNULL(@idType,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'idType', @oldidType, @user, GETDATE(), @idType,@amendmentId  
    END  
   IF ISNULL(@oldidNumber,'') != ISNULL(@idNumber,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'idNumber', @oldidNumber, @user, GETDATE(), @idNumber,@amendmentId  
    END  
   IF ISNULL(@oldissueDate,'') != ISNULL(@issueDate,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'idIssueDate', @oldissueDate, @user, GETDATE(), @issueDate,@amendmentId  
    END  
   IF ISNULL(@oldexpiryDate,'') != ISNULL(@expiryDate,'')
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'idExpiryDate', @oldexpiryDate, @user, GETDATE(), @expiryDate,@amendmentId  
    END  
   IF ISNULL(@oldremittanceAllowed,'') !=ISNULL(@remittanceAllowed,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'remittanceAllowed', @oldremittanceAllowed, @user, GETDATE(), @remittanceAllowed,@amendmentId  
    END  
   --IF ISNULL(@oldonlineUser,'N') !=  ISNULL(@onlineUser,'')  
   -- BEGIN  
   --  INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
   --  SELECT @customerId, 'onlineUser', @oldonlineUser, @user, GETDATE(), @onlineUser,@amendmentId  
   -- END  
   IF ISNULL(@oldremarks,'') != ISNULL(@remarks,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'remarks', @oldremarks, @user, GETDATE(), @remarks,@amendmentId  
    END  
   IF ISNULL(@oldcompanyName,'') != ISNULL(@companyName,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'companyName', @oldcompanyName, @user, GETDATE(), @companyName,@amendmentId  
    END  
   IF ISNULL(@oldregisterationNo,'') != ISNULL(@registerationNo,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'registerationNo', @oldregisterationNo, @user, GETDATE(), @registerationNo,@amendmentId  
    END  
   IF ISNULL(@oldorganizationType,'') != ISNULL(@organizationType,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'organizationType', @oldorganizationType, @user, GETDATE(), @organizationType,@amendmentId  
    END  
   IF CONVERT(VARCHAR,ISNULL(@olddateofIncorporation,''),111) != CONVERT(VARCHAR,ISNULL(@dateofIncorporation,''),111)    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'dateofIncorporation', CONVERT(VARCHAR,@olddateofIncorporation,111), @user, GETDATE(), CONVERT(VARCHAR,@dateofIncorporation,111),@amendmentId  
    END  
   IF ISNULL(@oldnatureOfCompany,'') != ISNULL(@natureOfCompany,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'natureOfCompany', @oldnatureOfCompany, @user, GETDATE(), @natureOfCompany,@amendmentId  
    END  
   IF ISNULL(@oldnameOfAuthorizedPerson,'') != ISNULL(@nameOfAuthorizedPerson,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'nameOfAuthorizedPerson', @oldnameOfAuthorizedPerson, @user, GETDATE(), @nameOfAuthorizedPerson,@amendmentId  
    END  
   IF ISNULL(@oldposition,'') != ISNULL(@position,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'position', @oldposition, @user, GETDATE(), @position,@amendmentId  
    END  
   ----- old  
  
   IF ISNULL(@oldbank,'') != ISNULL(@bank,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'bank', @oldbank, @user, GETDATE(), @bank,@amendmentId  
    END  
   IF ISNULL(@oldaccNumber,'') !=ISNULL(@accNumber,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'bankAccountNo', @oldaccNumber, @user, GETDATE(), @accNumber,@amendmentId  
    END  
   --IF ISNULL(@oldbank,'') != ISNULL(@bankId,'')   
   -- BEGIN  
   --  INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
   --  SELECT @customerId, 'bank', @oldbank, @user, GETDATE(), @bankId,@amendmentId  
   -- END  
   --IF ISNULL(@oldaccNumber,'') !=ISNULL(@accountNumber,'')    
   -- BEGIN  
   --  INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
   --  SELECT @customerId, 'bankAccountNo', @oldaccNumber, @user, GETDATE(), @accountNumber,@amendmentId  
   -- END 
  END  
   
 IF @flag ='s'  
  BEGIN  
   DECLARE @table VARCHAR(MAX)  
   SET @table ='SELECT  ISNULL(firstname,'''') + ISNULL('' '' +middlename,'''') + ISNULL('' '' + lastname1,'''') [Customer Name]
						,columnName [Column Name],oldValue [Old Value]
						,newValue [New Value],tcl.modifiedBy [Modified By],tcl.modifiedDate [Modified Date]
				 FROM TBLCUSTOMERMODIFYLOGS tcl (nolock)
				 INNER JOIN CUSTOMERMASTER CM (NOLOCK) ON CM.CUSTOMERID = TCL.CUSTOMERID
				 WHERE 1=1 ';  
  
   IF @customerId <> '0'
    BEGIN  
     SET @table=@table+ ' AND tcl.customerId='+CONVERT(VARCHAR, @customerId)+'';  
    END  
   IF @fromDate IS NOT NULL AND @toDate IS NOT NULL  
    BEGIN  
    SET @table +=  ' AND tcl.modifiedDate BETWEEN ''' +@fromDate+''' AND ''' +@toDate +' 23:59:59'''  
     --SET @sql_filter=@sql_filter+ ' AND modifiedDate BETWEEN '+@fromDate+' AND '+@fromDate+ ' 23:59:59'  
    END  
   EXEC (@table)  
   SELECT @fullName= fullName FROM dbo.customerMaster WHERE customerId=@customerId  
   EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL  
   SELECT  'Customer Name' head, @fullName UNION ALL  
   SELECT  'From Date' head, @fromDate VALUE UNION ALL  
   SELECT  'To Date' head, @toDate VALUE    
   SELECT  'Customer Modified Log' title  
      RETURN;  
  END  
 IF @flag ='i-fromSendPage'  
 BEGIN  
    SET @amendmentId = NEWID()  
    SELECT   
     @oldmobileNumber   = mobile,  
     @oldoccupation    = occupation,  
     @oldplaceofissue   = placeofissue,  
     @oldmonthlyIncome   = monthlyIncome,  
     @oldemail     = email  
  FROM customerMaster (NOLOCK)   
  WHERE customerId = @customerId  
  
  IF ISNULL(@oldmobileNumber,'') !=ISNULL(@mobileNumber,'')    
   BEGIN  
    INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
    SELECT @customerId, 'mobile', @oldmobileNumber, @user, GETDATE(), @mobileNumber,@amendmentId  
   END  
  IF ISNULL(@oldoccupation,'') != ISNULL(@occupation,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'occupation', @oldoccupation, @user, GETDATE(), @occupation,@amendmentId  
    END  
  IF ISNULL(@oldplaceofissue,'') != ISNULL(@placeofissue,'')   
   BEGIN  
    INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
    SELECT @customerId, 'placeofissue', @oldplaceofissue, @user, GETDATE(), @placeofissue,@amendmentId  
   END  
  IF ISNULL(@oldmonthlyIncome,'') != ISNULL(@monthlyIncome,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'monthlyIncome', @oldmonthlyIncome, @user, GETDATE(), @monthlyIncome,@amendmentId  
    END  
  IF ISNULL(@oldemail,'') !=ISNULL(@email,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'email', @oldemail, @user, GETDATE(), @email,@amendmentId  
    END  
  
  IF ISNULL(@oldsourceOfFound,'') != ISNULL(@sourceOfFound,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'sourceOfFound', @oldsourceOfFound, @user, GETDATE(), @sourceOfFound,@amendmentId  
    END  
  IF ISNULL(@oldAddress,'') != ISNULL(@additionalAddress,'')  
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'Address', @oldAddress, @user, GETDATE(),@additionalAddress,@amendmentId  
    END 

 END  
 IF @flag = 'i-new'  
  BEGIN  
   DECLARE  
     @oldStateName			VARCHAR(50)		= NULL,  
     @newAddressName		VARCHAR(300)	= NULL 
     
   SET @amendmentId = NEWID()  
   SELECT @oldcustomerType   = customerType,  
     @oldfullName    = fullName,  
     @oldfirstName    = firstName,  
     @oldmiddleName    = middleName,  
     @oldlastName1    = lastName1,  
     @oldcountry     = country,  
     @oldzipCode     = zipCode,  
     @oldstate     = state,  
     @oldstreet     = street,  
     @oldcustCity    = city,  
     @oldcityUnicode    = cityUnicode,  
     @oldstreetUnicode   = streetUnicode,  
     @oldcustGender    = gender,  
     @oldcustNativecountry  = nativeCountry,  
     @olddob      = CONVERT(VARCHAR(10),dob,121),  
     @oldemail     = email,  
     @oldcustTelNo    = telNo,  
     @oldmobileNumber   = mobile,  
     @oldvisaStatus    = visaStatus,  
     @oldemployeeBusinessType = employeeBusinessType,   
     @oldnameOfEmployeer   = nameOfEmployeer,  
     @oldSSNNO     = SSNNO,  
     @oldoccupation    = occupation,  
     @oldplaceofissue   = placeofissue,  
     @oldsourceOfFound   = sourceOfFund,  
     @oldmonthlyIncome   = monthlyIncome,  
     @oldidType     = idType,  
     @oldidNumber    = idNumber,   
     @oldissueDate    = CONVERT(VARCHAR(10),idIssueDate,121),   
     @oldexpiryDate    = CONVERT(VARCHAR(10),idExpiryDate,121),  
     @oldremittanceAllowed  = remittanceAllowed,  
     @oldonlineUser    = onlineUser,  
     @oldremarks     = remarks,  
     --used for customer type organisation  
     @oldcompanyName    = companyName,  
     @oldregisterationNo   = registerationNo,  
     @oldorganizationType  = organizationType,  
     @olddateofIncorporation  = CONVERT(VARCHAR,dateofIncorporation,111),  
     @oldnatureOfCompany   = natureOfCompany,  
     @oldnameOfAuthorizedPerson = nameOfAuthorizedPerson,   
     @oldposition    = position,  
     -- old Data  
     @oldbank     = bankName,  
     @oldaccNumber    = bankAccountNo,  
     @oldStateName    =   CSM.stateName,
	 @oldAddress = CM.address
  FROM customerMaster (NOLOCK) CM  
  LEFT JOIN dbo.countryStateMaster (NOLOCK) CSM ON CSM.stateId = CM.state  
  WHERE customerId = @customerId  
    
  PRINT 'New Mobile No ='+@mobileNumber;  
  PRINT 'Old Mobile No='+@oldmobileNumber ;  
     
   IF ISNULL(@oldstate,'') != ISNULL(@state,'') OR ISNULL(@oldcustCity,'') !=ISNULL(@custCity,'') OR ISNULL(@oldstreet,'') !=ISNULL(@street,'')   
   BEGIN  
    SELECT @newAddressName = stateName + ISNULL(', ' + @custCity, '')+ISNULL(', '+@street, '')  
    FROM dbo.countryStateMaster (NOLOCK) WHERE stateId = @state  
  
    INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
    SELECT @customerId, 'address', @oldStateName + ISNULL(', ' + @oldcustCity, '')+ISNULL(', '+@oldstreet, '') , @user, GETDATE(), @newAddressName,@amendmentId  
   END   
   IF ISNULL(@oldcustomerType,'') != ISNULL(@customerType,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'customerType', @oldcustomerType, @user, GETDATE(), @customerType,@amendmentId  
    END  
   IF ISNULL(@oldfirstName,'') != ISNULL(@firstName,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'firstName', @oldfirstName, @user, GETDATE(), @firstName,@amendmentId  
    END  
   IF ISNULL(@oldmiddleName,'') != ISNULL(@middleName,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'middleName', @oldmiddleName, @user, GETDATE(), @middleName,@amendmentId  
    END  
   IF ISNULL(@oldlastName1,'') != ISNULL(@lastName1,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'lastName1', @oldlastName1, @user, GETDATE(), @lastName1,@amendmentId  
    END  
   IF ISNULL(@oldfullName,'') !=ISNULL(@fullName,'')  
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'fullName', @oldfullName, @user, GETDATE(), @fullName,@amendmentId  
    END  
   IF ISNULL(@oldcountry,'') != ISNULL(@country,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'country', @oldcountry, @user, GETDATE(), @country,@amendmentId  
    END  
   IF ISNULL(@oldzipCode,'') != ISNULL(@zipCode,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'zipCode', @oldzipCode, @user, GETDATE(), @zipCode,@amendmentId  
    END  
   IF ISNULL(@oldcustGender,'') !=ISNULL(@custGender,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'gender', @oldcustGender, @user, GETDATE(), @custGender,@amendmentId  
    END  
   IF ISNULL(@oldcustNativecountry,'') !=ISNULL(@custNativecountry,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'nativeCountry', @oldcustNativecountry, @user, GETDATE(), @custNativecountry,@amendmentId  
    END  
   IF ISNULL(@oldAddress,'') != ISNULL(@additionalAddress,'')  
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'Address', @oldAddress, @user, GETDATE(),@additionalAddress,@amendmentId  
    END  
	IF @dob IS NOT NULL
	BEGIN
		IF ISNULL(@olddob,'') != ISNULL(@dob,'')  
		BEGIN  
		 INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
		 SELECT @customerId, 'dob', ISNULL(@olddob,''), @user, GETDATE(), ISNULL(@dob,''),@amendmentId  
		END  
	END
   IF ISNULL(@oldemail,'') !=ISNULL(@email,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'email', @oldemail, @user, GETDATE(), @email,@amendmentId  
    END  
   IF ISNULL(@oldcustTelNo,'') !=ISNULL(@custTelNo,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'telNo', @oldcustTelNo, @user, GETDATE(), @custTelNo,@amendmentId  
    END  
   IF ISNULL(@oldmobileNumber,'') !=ISNULL(@mobileNumber,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'mobile', @oldmobileNumber, @user, GETDATE(), @mobileNumber,@amendmentId  
    END  
   IF ISNULL(@oldvisaStatus,'') != ISNULL(@visaStatus,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'visaStatus', @oldvisaStatus, @user, GETDATE(), @visaStatus,@amendmentId  
    END  
   IF ISNULL(@oldemployeeBusinessType,'') != ISNULL(@employeeBusinessType,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'employeeBusinessType', @oldemployeeBusinessType, @user, GETDATE(), @employeeBusinessType,@amendmentId  
    END  
   IF ISNULL(@oldnameOfEmployeer,'') !=ISNULL(@nameOfEmployeer,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'nameOfEmployeer', @oldnameOfEmployeer, @user, GETDATE(), @nameOfEmployeer,@amendmentId  
    END  
   IF ISNULL(@oldSSNNO,'') != ISNULL(@SSNNO,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'SSNNO', @oldSSNNO, @user, GETDATE(), @SSNNO,@amendmentId  
    END  
   IF ISNULL(@oldoccupation,'') != ISNULL(@occupation,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'occupation', @oldoccupation, @user, GETDATE(), @occupation,@amendmentId  
    END  
   IF ISNULL(@oldplaceofissue,'') != ISNULL(@placeofissue,'')   
   BEGIN  
    INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
    SELECT @customerId, 'placeofissue', @oldplaceofissue, @user, GETDATE(), @placeofissue,@amendmentId  
   END  
     
   IF ISNULL(@oldsourceOfFound,'') !=ISNULL(@sourceOfFound,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'sourceOfFund', @oldsourceOfFound, @user, GETDATE(), @sourceOfFound,@amendmentId  
    END  
   IF ISNULL(@oldmonthlyIncome,'') != ISNULL(@monthlyIncome,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'monthlyIncome', @oldmonthlyIncome, @user, GETDATE(), @monthlyIncome,@amendmentId  
    END  
   IF ISNULL(@oldidType,'') != ISNULL(@idType,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'idType', @oldidType, @user, GETDATE(), @idType,@amendmentId  
    END  
   IF ISNULL(@oldidNumber,'') != ISNULL(@idNumber,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'idNumber', @oldidNumber, @user, GETDATE(), @idNumber,@amendmentId  
    END  
   IF ISNULL(@oldissueDate,'') != ISNULL(@issueDate,'')
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'idIssueDate', CONVERT(VARCHAR,@oldissueDate,111), @user, GETDATE(), CONVERT(VARCHAR,@issueDate,111),@amendmentId  
    END  
   IF ISNULL(@oldexpiryDate,'') != ISNULL(@expiryDate,'')
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'idExpiryDate', @oldexpiryDate, @user, GETDATE(), @expiryDate,@amendmentId  
    END  
   IF ISNULL(@oldremittanceAllowed,'') !=ISNULL(@remittanceAllowed,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'remittanceAllowed', @oldremittanceAllowed, @user, GETDATE(), @remittanceAllowed,@amendmentId  
    END  
   --IF ISNULL(@oldonlineUser,'N') != ISNULL(@onlineUser,'')
   -- BEGIN  
   --  INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
   --  SELECT @customerId, 'onlineUser', @oldonlineUser, @user, GETDATE(), @onlineUser,@amendmentId  
   -- END  
   IF ISNULL(@oldremarks,'') != ISNULL(@remarks,'')   
  BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'remarks', @oldremarks, @user, GETDATE(), @remarks,@amendmentId  
    END  
   IF ISNULL(@oldcompanyName,'') != ISNULL(@companyName,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'companyName', @oldcompanyName, @user, GETDATE(), @companyName,@amendmentId  
    END  
   IF ISNULL(@oldregisterationNo,'') != ISNULL(@registerationNo,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'registerationNo', @oldregisterationNo, @user, GETDATE(), @registerationNo,@amendmentId  
    END  
   IF ISNULL(@oldorganizationType,'') != ISNULL(@organizationType,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'organizationType', @oldorganizationType, @user, GETDATE(), @organizationType,@amendmentId  
    END  
   IF CONVERT(VARCHAR,ISNULL(@olddateofIncorporation,''),111) != CONVERT(VARCHAR,ISNULL(@dateofIncorporation,''),111)    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'dateofIncorporation', CONVERT(VARCHAR,@olddateofIncorporation,111), @user, GETDATE(), CONVERT(VARCHAR,@dateofIncorporation,111),@amendmentId  
    END  
   IF ISNULL(@oldnatureOfCompany,'') != ISNULL(@natureOfCompany,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'natureOfCompany', @oldnatureOfCompany, @user, GETDATE(), @natureOfCompany,@amendmentId  
    END  
   IF ISNULL(@oldnameOfAuthorizedPerson,'') != ISNULL(@nameOfAuthorizedPerson,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'nameOfAuthorizedPerson', @oldnameOfAuthorizedPerson, @user, GETDATE(), @nameOfAuthorizedPerson,@amendmentId  
    END  
   IF ISNULL(@oldposition,'') != ISNULL(@position,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'position', @oldposition, @user, GETDATE(), @position,@amendmentId  
    END  
   ----- old  
  
   IF ISNULL(@oldbank,'') != ISNULL(@bank,'')   
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'bank', @oldbank, @user, GETDATE(), @bank,@amendmentId  
    END  
   IF ISNULL(@oldaccNumber,'') !=ISNULL(@accNumber,'')    
    BEGIN  
     INSERT INTO TBLCUSTOMERMODIFYLOGS(customerId, columnName, oldValue, modifiedBy, modifiedDate,newValue,amendmentId)  
     SELECT @customerId, 'bankAccountNo', @oldaccNumber, @user, GETDATE(), @accNumber,@amendmentId  
    END  
  END  
END
GO