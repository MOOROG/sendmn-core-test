SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE proc_online_sender_receiver
    @customerId BIGINT = NULL ,
	@receiverId  BIGINT=NULL,
    @user VARCHAR(25) = NULL ,
    @flag VARCHAR(50) = NULL ,
    @sortBy VARCHAR(50) = NULL ,
    @sortOrder VARCHAR(5) = NULL ,
    @fromDate NVARCHAR(20) = NULL ,
    @toDate NVARCHAR(20) = NULL ,
    @pageSize INT = NULL ,
    @pageNumber INT = NULL ,
    @customerName VARCHAR(100) = NULL ,
    @customerEmail VARCHAR(50) = NULL ,
    @receiverIds NVARCHAR(800) = NULL
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        DECLARE @table VARCHAR(MAX)= NULL ,
            @select_field_list VARCHAR(MAX)= NULL ,
            @sql_filter VARCHAR(MAX)= NULL ,
            @extra_field_list VARCHAR(MAX)= NULL;
        SET NOCOUNT ON;


        IF @flag = 's'
            BEGIN
                IF @sortBy = 'SN'
                    SET @sortBy = NULL;
                IF @sortBy IS NULL
                    OR @sortBy = ''
                    SET @sortBy = 'receiverId';
                
                SET @sortOrder = 'DESC';
                SET @sql_filter = '';

                IF @customerId IS NOT NULL
                    AND @customerId != ''
                    SET @sql_filter += ' AND customerId ='''
                        + CAST(@customerId AS VARCHAR) + '''';


				 IF @receiverId IS NOT NULL
                    AND @receiverId != ''
                    SET @sql_filter += ' AND receiverId ='''
                        + CAST(@receiverId AS VARCHAR) + '''';

                IF ISNULL(@fromDate, '') <> ''
                    AND ISNULL(@toDate, '') <> ''
                    SET @sql_filter += ' AND receiverCreatedDate BETWEEN '''
                        + @fromDate + ''' AND ''' + @toDate + ' 23:59:59''';


                SET @table = '(
				SELECT  ri.receiverId ,
						cm.customerId ,
						cm.membershipId,
						cm.fullName ,
						cm.address ,
						cm.mobile ,
						cm.isActive ,
						cm.isDeleted ,
						receiverName = ri.firstName + ISNULL('' ''+ri.middleName, '''')
						+ ISNULL('' ''+ri.lastName1, '''') ,
						ri.address receiverAddress ,
						ri.mobile  receiverMobile,
						cm.createdBy ,
						cm.createdDate,
						ri.createdBy receiverCreatedBy,
						CONVERT(varchar,ri.createdDate,23) receiverCreatedDate
				FROM    dbo.customerMaster cm ( NOLOCK )
						INNER JOIN dbo.receiverInformation ri ( NOLOCK ) ON cm.customerId = ri.customerId
				WHERE   ISNULL(cm.isActive, ''N'') = ''Y'' AND ISNULL(cm.isDeleted, ''N'') = ''N'') x';
                PRINT @table;
                SET @select_field_list = 'receiverId,customerId,membershipId,fullName,address,mobile,receiverName,receiverAddress,receiverMobile,createdBy,createdDate,receiverCreatedBy,receiverCreatedDate';
                EXEC dbo.proc_paging @table = @table, -- varchar(max)
                    @sqlFilter = @sql_filter, -- varchar(max)
                    @selectFieldList = @select_field_list, -- varchar(max)
                    @extraFieldList = @extra_field_list, -- varchar(max)
                    @sortBy = @sortBy, -- varchar(100)
                    @sortOrder = @sortOrder, -- varchar(5)
                    @pageSize = @pageSize, -- int
                    @pageNumber = @pageNumber, -- int
                    @noPaging = ''; -- char(1)
                RETURN;
            END;

        IF @flag = 'forPrint'
            BEGIN
			
                IF @receiverIds IS NOT NULL
                    BEGIN
                        SELECT  value
                        INTO    #tempReceiptId
                        FROM    dbo.Split(',', @receiverIds);
                    END;
                SELECT  ri.receiverId ,
                        cm.customerId ,
                        cm.membershipId ,
                        cm.fullName ,
                        cm.address ,
                        cm.mobile ,
                        cm.email ,
                        receiverName = ri.firstName + ISNULL(' '
                                                             + ri.middleName,
                                                             '''')
                        + ISNULL(' ' + ri.lastName1, '''') ,
                        ri.address receiverAddress ,
                        ri.mobile receiverMobile ,
                        cm.dob ,
                        ri.country ,
                        sTM.typeTitle paymentMode ,
                        SDV.DETAILTITLE relationship ,
                        SDV1.DETAILTITLE purposeOfRemit ,
                        ri.bankName ,
                        ri.receiverAccountNo ,
                        ri.createdDate ,
                        ri.remarks ,
                        [date] = GETDATE()
                FROM    dbo.customerMaster cm ( NOLOCK )
                        INNER JOIN dbo.receiverInformation ri ( NOLOCK ) ON cm.customerId = ri.customerId
                        LEFT JOIN dbo.serviceTypeMaster sTM ( NOLOCK ) ON sTM.serviceTypeId = ri.paymentMode
                        INNER JOIN #tempReceiptId t ON t.value = ri.receiverId
						LEFT JOIN STATICDATAVALUE SDV (NOLOCK) ON SDV.VALUEID = RI.RELATIONSHIP
						LEFT JOIN STATICDATAVALUE SDV1 (NOLOCK) ON SDV1.VALUEID = RI.PURPOSEOFREMIT
                WHERE   ISNULL(cm.isActive, 'N') = 'Y'
                        AND ISNULL(cm.isDeleted, 'N') = 'N'; 
                RETURN;
            END;
    END;
GO

