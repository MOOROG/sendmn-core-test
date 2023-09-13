SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER PROCEDURE [dbo].[proc_online_receiverSetup]
    (
      @flag						VARCHAR(50)		= NULL,
      @user						VARCHAR(30)		= NULL,
      @receiverId				VARCHAR(50)		= NULL,
      @customerId				VARCHAR(50)		= NULL,
      @membershipId				VARCHAR(50)		= NULL,
      @firstName				VARCHAR(100)	= NULL,
      @middleName				VARCHAR(100)	= NULL,
      @lastName1				VARCHAR(100)	= NULL,
      @lastName2				VARCHAR(100)	= NULL,
      @country					VARCHAR(200)	= NULL,
      @nativeCountry			VARCHAR(200)	= NULL,
      @address					VARCHAR(500)	= NULL,
      @state					VARCHAR(200)	= NULL,
      @zipCode					VARCHAR(50)		= NULL,
      @city						VARCHAR(100)	= NULL,
      @email					VARCHAR(150)	= NULL,
      @homePhone				VARCHAR(100)	= NULL,
      @workPhone				VARCHAR(100)	= NULL,
      @mobile					VARCHAR(100)	= NULL,
      @relationship				VARCHAR(100)	= NULL,
      @sortBy					VARCHAR(50)		= NULL,
      @sortOrder				VARCHAR(5)		= NULL,
      @pageSize					INT				= NULL,
      @pageNumber				INT				= NULL,
      @receiverType				INT				= NULL,
      @idType					INT				= NULL,
      @idNumber					VARCHAR(25)		= NULL,
      @placeOfIssue				VARCHAR(80)		= NULL,
      @paymentMode				INT				= NULL,
      @bankLocation				VARCHAR(100)	= NULL,
      @payOutPartner			INT				= NULL,
      @bankName					VARCHAR(150)	= NULL,
      @receiverAccountNo		VARCHAR(40)		= NULL,
      @remarks					NVARCHAR(800)	= NULL,
      @purposeOfRemit			VARCHAR(100)	= NULL,
      @fromDate					NVARCHAR(20)	= NULL,
      @toDate					NVARCHAR(20)	= NULL,
	  @otherRelationDesc		VARCHAR(20)		= NULL,
	  @loginBranchId			BIGINT			= NULL
    )
AS
    BEGIN
        DECLARE @table VARCHAR(MAX) ,
            @select_field_list VARCHAR(MAX) ,
            @extra_field_list VARCHAR(MAX) ,
            @sql_filter VARCHAR(MAX);
		--,@customerId1			VARCHAR(50)
		DECLARE @PURPOSEID INT = NULL, @RELATION INT = NULL

		SELECT @PURPOSEID = valueId
		FROM STATICDATAVALUE (NOLOCK)
		WHERE detailTitle = @purposeOfRemit
		AND typeID = '3800'

		IF @PURPOSEID IS NULL
			SET @PURPOSEID = @purposeOfRemit

		SELECT @RELATION = valueId
		FROM STATICDATAVALUE (NOLOCK)
		WHERE detailTitle = @relationship
		AND typeID = '2100'

		IF @RELATION IS NULL
			SET @RELATION = @relationship
        IF @flag = 'i'
            BEGIN
                INSERT  INTO receiverInformation
                        (fullname
						 ,membershipId ,customerId ,firstName ,middleName ,lastName1 ,lastName2 ,country ,NativeCountry,[address] ,[state] ,zipCode ,city ,email ,
                          homePhone ,workPhone ,mobile ,relationship ,receiverType ,idType ,idNumber ,placeOfIssue ,paymentMode ,bankLocation ,payOutPartner ,
                          bankName ,receiverAccountNo ,remarks ,purposeOfRemit ,createdBy ,createdDate,otherRelationDesc,agentId				
		                )
                        SELECT    ISNULL(@firstName,'') + ISNULL(' ' + @middleName,'') +ISNULL(' ' + @lastName1,''),
								@membershipId ,@customerId ,@firstName ,@middleName ,@lastName1 ,@lastName2 ,@country ,@nativeCountry,@address ,@state ,@zipCode ,@city ,@email ,
                                @homePhone ,@workPhone ,@mobile ,@RELATION ,@receiverType ,@idType ,@idNumber ,@placeOfIssue ,@paymentMode ,@bankLocation ,@payOutPartner ,
                                @bankName ,@receiverAccountNo ,@remarks ,@PURPOSEID ,@user ,GETDATE(),@otherRelationDesc,@loginBranchId	
				
				SET @receiverId=SCOPE_IDENTITY();						
                SELECT  '0' errorCode ,'Receiver Successfully added.' msg ,id = @receiverId,extra = @customerId;
                RETURN; 			
            END;
	
        IF @flag = 'u'
            BEGIN	
		
		DECLARE @fullName VARCHAR(100)
		SET @fullName = @firstName + ISNULL(' ' + @middleName,'') + ISNULL(' ' + @lastName1,'') + ISNULL(' ' + @lastName2,'')
		

		EXEC PROC_RECEIVERMODIFYLOGS	@FLAG = 'i'
										,@user = @user
										,@receiverId		= @receiverId
										,@customerId		= @customerId
										,@firstName			= @firstName			
										,@middleName		= @middleName		
										,@lastName1			= @lastName1			
										,@lastName2			= @lastName2
										,@fullName			= @fullName			
										,@country			= @country			
										,@nativeCountry		= @nativeCountry		
										,@address			= @address			
										,@state				= @state				
										,@zipCode			= @zipCode			
										,@city				= @city				
										,@email				= @email				
										,@homePhone			= @homePhone			
										,@workPhone			= @workPhone			
										,@mobile			= @mobile			
										,@relationship		= @RELATION		
										,@receiverType		= @receiverType		
										,@idType			= @idType			
										,@idNumber			= @idNumber			
										,@placeOfIssue		= @placeOfIssue		
										,@paymentMode		= @paymentMode		
										,@bankLocation		= @bankLocation		
										,@payOutPartner		= @payOutPartner		
										,@bankName			= @bankName			
										,@receiverAccountNo	= @receiverAccountNo
										,@remarks			= @remarks			
										,@purposeOfRemit	= @PURPOSEID	
										,@otherRelationDesc	= @otherRelationDesc

                UPDATE  receiverInformation
                SET     firstName = @firstName ,
                        middleName = @middleName ,
                        lastName1 = @lastName1 ,
                        lastName2 = @lastName2 ,
                        country = @country ,
                        NativeCountry = @nativeCountry ,
                        address = @address ,
                        state = @state ,
                        zipCode = @zipCode ,
                        city = @city ,
                        email = @email ,
                        homePhone = @homePhone ,
                        workPhone = @workPhone ,
                        mobile = @mobile ,
                        relationship = @RELATION ,
                        receiverType = @receiverType ,
                        idType = @idType ,
                        idNumber = @idNumber ,
                        placeOfIssue = @placeOfIssue ,
                        paymentMode = @paymentMode ,
                        bankLocation = @bankLocation ,
                        payOutPartner = @payOutPartner ,
                        bankName = @bankName ,
                        receiverAccountNo = @receiverAccountNo ,
                        remarks = @remarks ,
                        purposeOfRemit = @PURPOSEID ,
                        modifiedBy = @user ,
                        modifiedDate = GETDATE(),
						otherRelationDesc = @otherRelationDesc
                WHERE   receiverId = @receiverId;

                SELECT  '0' errorCode ,'Receiver Information has been updated' msg ,id = null,extra = @customerId; 
            END;
	
        IF @flag = 'd'
            BEGIN

				UPDATE receiverInformation SET isdeleted = 1
												,deletedby = @user
												,deleteddate = cast(Getdate() as date)
										  WHERE receiverId = @receiverId;


                SELECT  '0' errorCode ,'Receiver Deleted Successfully.' msg ,id = @receiverId;
            END;
	
        IF @flag = 's'
            BEGIN
                IF @sortBy = 'SN'
                    SET @sortBy = NULL;
                IF @sortBy IS NULL
                    SET @sortBy = 'firstName';
                IF @sortOrder IS NULL
                    SET @sortOrder = 'ASC';
                SET @table = '
						 (
					SELECT   
						 ri.receiverId
						,ri.firstName , ISNULL('' '' + ri.middleName,'''') middleName,	ISNULL('' '' + ri.lastName1,'''') lastName1,	ISNULL('' '' + ri.lastName2,'''') lastName2	
						,ri.firstName + ISNULL('' '' + ri.middleName,'''') + ISNULL('' '' + ri.lastName1,'''') + ISNULL('' '' + ri.lastName2,'''') FullName
						,ri.customerId
						,country  
						,Cm.countryName nativeCountry
						,ri.address		
						,ri.state			
						,ri.zipCode		
						,ri.city			
						,ri.email			
						,ri.homePhone		
						,ri.workPhone		
						,(Select coalesce(ri.mobile,ri.homePhone)) as Mobile
						,relationship,
						otherRelationDesc,
						ri.receiverType ,
						ri.idType ,
						ri.idNumber ,
						ri.placeOfIssue ,
						ri.paymentMode ,
						ri.bankLocation ,
						ri.payOutPartner ,
						ri.bankName ,
						ri.receiverAccountNo ,
						ri.remarks,
						ri.purposeOfRemit,
						ri.createdDate,
						ri.membershipId,
						ri.createdBy receiverCreatedBy,
						ri.createdDate receiverCreatedDate,
						hasChanged = CASE WHEN (ri.approvedBy IS NULL) THEN ''Y'' ELSE ''N'' END,
						modifiedBy = CASE WHEN ri.approvedBy IS NULL THEN ri.createdBy ELSE Cm.createdBy END  
					FROM receiverInformation  ri WITH (NOLOCK)
					LEFT JOIN CountryMaster  (NOLOCK) Cm ON Cm.countryId=ri.NativeCountry
					WHERE customerId = ''' + @customerId + '''
					and isnull(ri.isdeleted,0) <> 1'; 
					

                SET @sql_filter = ''; 
                IF @country IS NOT NULL
                    SET @table = @table + ' and country=''' + @country + '''';	
                IF @address IS NOT NULL
                    SET @table = @table + ' AND address like ''' + @address
                        + '%'' or city like ''' + @city + '%''';-- or id Like '''+@agentAddress+ '%''' 
                SET @table = @table + ' )x';
                PRINT @table;
                IF @receiverId IS NOT NULL
                    SET @sql_filter += ' AND receiverId=' + @receiverId;
                IF ISNULL(@fromDate, '') <> '' AND ISNULL(@toDate, '') <> ''
                    SET @sql_filter += ' AND receiverCreatedDate BETWEEN '''
                        + @fromDate + ''' AND ''' + @toDate + ' 23:59:59''';
                SET @select_field_list = 'receiverId,customerId,FullName=firstName + middleName + lastName1 + lastName2,firstName,middleName
			   ,lastName1,lastName2,country,address,state,zipCode,city,email,homePhone,workPhone,Mobile,relationship,receiverType ,idType ,
			   idNumber ,placeOfIssue ,paymentMode ,bankLocation ,payOutPartner ,bankName ,receiverAccountNo ,remarks,purposeOfRemit,
			   createdDate,membershipId,receiverCreatedBy,receiverCreatedDate';
			      
                EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,@extra_field_list, @sortBy, @sortOrder, @pageSize,@pageNumber;
            END;

        IF @flag = 'a'
            BEGIN
                SELECT  [receiverId] ,
                        [customerId] ,
                        [membershipId] ,
                        [firstName] ,
                        [middleName] ,
                        [lastName1] ,
                        [lastName2] ,
                        [country] ,
                        [NativeCountry] ,
                        [address] ,
                        [state] ,
                        [zipCode] ,
                        [city] ,
                        [email] ,
                        [homePhone] ,
                        [workPhone] ,
                        [mobile] ,
                        [relationship] ,
                        [receiverType] ,
                        [idType] ,
                        [idNumber] ,
                        [placeOfIssue] ,
                        [paymentMode] ,
                        [bankLocation] ,
                        [payOutPartner] ,
                        [bankName] ,
                        [receiverAccountNo] ,
                        [remarks] ,
                        [purposeOfRemit]
                FROM    receiverInformation WITH ( NOLOCK )
                WHERE   receiverId = @receiverId;
            END;	
    
	    IF @flag = 'sDetail'
            BEGIN
	
                SELECT  ri.receiverId ,
                        ri.customerId ,
                        ri.firstName ,
                        ri.membershipId ,
                        ri.middleName ,
                        ri.lastName1 ,
                        ri.lastName2 ,
                        ri.country ,
                        ri.NativeCountry ,
						NM.countryName,
                        ri.address ,
                        ri.state ,
                        ri.zipCode ,
                        cm.countryId ,
                        ri.city ,
                        ri.email ,
                        ri.homePhone ,
                        ri.workPhone ,
                        ri.mobile ,
                        ri.relationship ,
                        ri.receiverType ,
                        ri.idType ,
                        ri.idNumber ,
                        ri.placeOfIssue ,
                        ri.paymentMode ,
                        ri.bankLocation ,
                        ri.payOutPartner ,
                        ri.bankName ,
                        ri.receiverAccountNo ,
                        ri.remarks ,
                        ri.purposeOfRemit
                FROM    receiverInformation ri WITH ( NOLOCK )
                        INNER JOIN countryMaster cm WITH ( NOLOCK ) ON ri.country = cm.countryName
                        INNER JOIN countryMaster NM WITH ( NOLOCK ) ON NM.countryId = ri.NativeCountry
                WHERE   customerId = @customerId
                        AND receiverId = @receiverId;
				
				

			
            END;

        IF @flag = 'sDetailByCusId'
            BEGIN
	
                SELECT  ri.receiverId ,
                        ri.customerId ,
                        ri.firstName ,
                        ri.membershipId ,
                        ri.middleName ,
                        ri.lastName1 ,
                        ri.lastName2 ,
                        ri.country ,
                        Ncm.countryName nativeCountry ,
                        ri.address ,
                        ri.state ,
                        ri.zipCode ,
                        cm.countryId ,
                        ri.city ,
                        ri.email ,
                        ri.homePhone ,
                        ri.workPhone ,
                        ri.mobile ,
                        ri.relationship ,
                        ri.receiverType ,
                        ri.idType ,
                        ri.idNumber ,
                        ri.placeOfIssue ,
                        ri.paymentMode ,
                        ri.bankLocation ,
                        ri.payOutPartner ,
                        ri.bankName ,
                        ri.receiverAccountNo ,
                        ri.remarks ,
                        ri.purposeOfRemit
                FROM    receiverInformation ri WITH ( NOLOCK )
                        INNER JOIN countryMaster cm WITH ( NOLOCK ) ON ri.country = cm.countryName
                        INNER JOIN countryMaster Ncm WITH ( NOLOCK ) ON ri.NativeCountry = Ncm.countryId
                WHERE   customerId = @customerId;
				
            END;
        IF @flag = 'sDetailByReceiverId'
            BEGIN
	
                SELECT  ri.receiverId ,
                        ri.customerId ,
                        ri.firstName ,
                        com.membershipId ,
                        ri.middleName ,
                        ri.lastName1 ,
                        ri.lastName2 ,
                        ri.country ,
                        ri.address ,
                        ri.state ,
                        ri.zipCode ,
                        cm.countryId ,
                        ri.NativeCountry ,
                        ri.city ,
                        ri.email ,
                        ri.homePhone ,
                        ri.workPhone ,
                        ri.mobile ,
                        ri.relationship ,
						ri.otherRelationDesc,
                        ri.purposeOfRemit ,
                        ri.receiverType ,
                        ri.idType ,
                        ri.idNumber ,
                        ri.placeOfIssue ,
                        ri.paymentMode ,
                        ri.bankLocation ,
                        ISNULL(ri.bank, ri.payOutPartner) payOutPartner,
                        ri.bankName ,
                        ri.receiverAccountNo ,
                        ri.remarks ,
                        ri.createdDate
                FROM    receiverInformation ri WITH ( NOLOCK )
                        INNER JOIN countryMaster cm WITH ( NOLOCK ) ON ri.country = cm.countryName
						INNER JOIN dbo.customerMaster COM(NOLOCK) ON com.customerId=ri.customerId
                WHERE   receiverId = @receiverId;
                RETURN;
            END;
		If @flag = 'sDetailByReceiverIdForPrint'
		BEGIN
			SELECT TOP 10  ri.receiverId ,
			cmm.fullName customerName,
                   ri.customerId ,
                   ri.firstName ,
                   COM.membershipId ,
                   ri.middleName ,
                   ri.lastName1 ,
                   ri.lastName2 ,
                   ri.country ,
                   ri.address ,
                   ri.state ,
                   ri.zipCode ,
                   cm.countryId ,
				   cm1.countryname [NativeCountry],
                   ri.city ,
                   ri.email ,
                   ri.homePhone ,
                   ri.workPhone ,
                   ri.mobile ,
				   SDV.detailTitle relationship,
				   ri.otherRelationDesc,
				  
				   SDV1.detailTitle purposeOfRemit,
				   SDV2.detailTitle receiverType,
                   SDV3.detailTitle idType ,
                   ri.idNumber ,
                   ri.placeOfIssue ,
                   CASE WHEN ri.paymentmode = '1' THEN 'Cash Payment' ELSE 'Bank Deposit' END paymentMode ,
                   ISNULL(ABBL.BRANCH_NAME ,'')  bankBranchName ,
                   CASE WHEN ri.country = 'NEPAL' THEN ISNULL(ABL.BANK_NAME,'ANY WHERE') ELSE  ISNULL(ABL.BANK_NAME ,'') END payOutPartner ,
                   ri.bankName ,
                   ri.receiverAccountNo ,
                   ri.remarks ,
                   ri.createdDate
           FROM    receiverInformation ri WITH ( NOLOCK )
                   INNER JOIN countryMaster cm WITH ( NOLOCK ) ON ri.country = cm.countryName
		   INNER JOIN dbo.customerMaster COM(NOLOCK) ON com.customerId=ri.customerId
		   LEFT JOIN countrymaster CM1 (NOLOCK) ON CM1.COUNTRYID = ri.nativecountry
		   LEFT JOIN STATICDATAVALUE SDV (NOLOCK) ON SDV.VALUEID = RI.RELATIONSHIP
		   LEFT JOIN STATICDATAVALUE SDV1 (NOLOCK) ON SDV1.VALUEID = RI.PURPOSEOFREMIT
		   LEFT JOIN STATICDATAVALUE SDV2 (NOLOCK) ON SDV2.VALUEID = RI.RECEIVERTYPE
		   LEFT JOIN STATICDATAVALUE SDV3 (NOLOCK) ON SDV3.VALUEID = RI.idtype
		   LEFT JOIN API_BANK_BRANCH_LIST ABBL (NOLOCK) ON ABBL.BRANCH_ID = RI.BANKLOCATION
		   LEFT JOIN API_BANK_LIST ABL (NOLOCK) ON ABL.BANK_ID = RI.PAYOUTPARTNER
		   LEFT JOIN dbo.customerMaster (NOLOCK) cmm ON cmm.customerId = ri.customerId
           WHERE   receiverId = @receiverId ;
           RETURN;
		END
        IF @flag = 'getTtranDetail'
            BEGIN
                SELECT  ri.receiverId ,
                        ri.customerId ,
                        receiverName = ISNULL(ri.firstName, '') + ' '
                        + ISNULL(ri.middleName, '') + ' '
                        + ISNULL(ri.lastName1, '') + ' ' + ISNULL(ri.lastName2,
                                                              ''),		
                        countryId = ri.country ,
                        ri.address ,
                        ri.state ,
                        ri.zipCode ,
                        ri.city ,
                        ri.email ,
                        phone = ri.homePhone ,
                        ri.workPhone ,
                        ri.mobile ,
                        ri.relationship
                FROM    receiverInformation ri WITH ( NOLOCK )
                        INNER JOIN countryMaster cm WITH ( NOLOCK ) ON ri.country = cm.countryName
                WHERE   customerId = @customerId
                        AND receiverId = @receiverId;

            END;
	
        IF @flag = 'recProfile'
            BEGIN	 	
	
                SELECT DISTINCT
                        ISNULL(TS.tranid, '')
                FROM    receiverInformation ri WITH ( NOLOCK )
                        LEFT JOIN ( SELECT  tranid = rt.id ,
                                            TS.customerId
                                    FROM    tranSenders TS
                                            INNER JOIN remitTran rt WITH ( NOLOCK ) ON TS.tranid = rt.id
                                                              AND TS.customerId = @customerId
                                  ) TS ON ri.customerId = TS.customerId
                        INNER JOIN tranReceivers tR WITH ( NOLOCK ) ON tR.fullName = ISNULL(ri.firstName,
                                                              '') + ''
                                                              + ISNULL(ri.middleName,
                                                              '') + ''
                                                              + ISNULL(ri.lastName1,
                                                              '') + ''
                                                              + ISNULL(ri.lastName2,
                                                              '')
                                                              AND tR.mobile = ri.mobile
                WHERE   ri.receiverId = @receiverId
                        AND ri.customerId = @customerId; 
            END;
    END;

GO