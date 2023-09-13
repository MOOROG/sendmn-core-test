SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <12/27/2018>
-- Description:	<>
-- =============================================
ALTER PROCEDURE proc_customerDocumentType 
	-- Add the parameters for the stored procedure here
    @cdId INT = NULL ,
    @SN INT = NULL ,
    @fileName VARCHAR(80) = NULL ,
    @fileDescription VARCHAR(100) = NULL ,
    @fileType VARCHAR(20) = NULL ,
    @createdDate VARCHAR(30) = NULL ,
    @documentType INT = NULL ,
    @createdBy VARCHAR(30) = NULL ,
    @flag VARCHAR(20) ,
    @customerId INT = NULL ,
    @user VARCHAR(30) = NULL ,
    @agentId INT = NULL ,
    @branchId INT = NULL ,
    @sortBy VARCHAR(50) = NULL ,
    @sortOrder VARCHAR(5) = NULL ,
    @pageSize INT = NULL ,
    @pageNumber INT = NULL ,
    @searchCriteria VARCHAR(30) = NULL ,
    @searchValue VARCHAR(50) = NULL ,
    @approvedBy VARCHAR(30) = NULL,
	@membershipId varchar(30) = NULL
AS
    DECLARE @table NVARCHAR(MAX) ,
        @sql_filter VARCHAR(MAX) ,
        @extra_field_list VARCHAR(MAX) ,
        @select_field_list VARCHAR(MAX);
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT For Grid statements.
        SET NOCOUNT ON;
        IF @flag = 's'
            BEGIN
                IF @sortBy = 'SN'
                    SET @sortBy = NULL;
                IF @sortBy IS NULL
                    OR @sortBy = ''
                    SET @sortBy = 'createdDate';
                IF @sortOrder IS NULL
                    OR @sortOrder = ''
                    SET @sortOrder = 'DESC';
                SET @table = '
							(
								SELECT cdid,
								customerId,
								[fileName],
								fileDescription,
								CASE WHEN fileType = ''signature'' THEN ''image''
									ELSE fileType END fileType,
								documentType,
								CD.sessionId,
								cd.createdBy,
								cd.createdDate,
								ISNULL(sv.detailTitle,''signature'')  documentTypeName  
							FROM dbo.customerDocument cd (NOLOCK)
							LEFT JOIN dbo.staticDataValue sv (NOLOCK) ON sv.valueId=cd.documentType
							)x';
                SET @sql_filter = '';
		       
                IF @customerId IS NOT NULL
					BEGIN
					     SET @sql_filter += ' AND customerId='
                        + CAST(@customerId AS VARCHAR(10)) + '';
					END
                   
				
                IF @fileType IS NOT NULL AND @fileType !='0'
					BEGIN
						DECLARE @fileFilterName VARCHAR(150)=NULL
						SELECT @fileFilterName= LTRIM(RTRIM(detailTitle)) FROM dbo.staticDataValue WHERE valueId=@fileType 
							   SET @fileFilterName=REPLACE(@fileFilterName,' ','_');
						SET @sql_filter += ' AND fileName LIKE ''%' +@fileFilterName + '%''';
					END

                IF @fileDescription IS NOT NULL
					BEGIN
						SET @sql_filter += ' AND fileDescription='''+ @fileDescription + '''';
					END
					
                IF @createdDate IS NOT NULL
					BEGIN
					     SET @sql_filter += '  AND createdDate between '''
                        + CONVERT(VARCHAR, @createdDate, 101) + ''' AND '''
                        + CONVERT(VARCHAR, @createdDate, 101) + ' 23:59:59''';
					END
                   
				PRINT 'Filter Data:'+@sql_filter
                SET @select_field_list = 'cdId,customerId,sessionId,[fileName],fileDescription,fileType,documentType,createdBy,createdDate,documentTypeName';
                EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,
                    @extra_field_list, @sortBy, @sortOrder, @pageSize,
                    @pageNumber;
                RETURN;
            END;


		IF @flag='getDocByCustomerId'
		BEGIN
		    SELECT cm.fileName,cm.fileType,cm.documentType,Sv.detailTitle documentName
			FROM dbo.customerDocument (NOLOCK) cm
			LEFT JOIN dbo.staticDataValue (NOLOCK) Sv ON Sv.valueId=cm.documentType
			WHERE customerId=@customerId
		END

        IF @flag = 'getById'
            BEGIN
                IF @cdId IS NULL
                    BEGIN
                        EXEC proc_errorHandler 1,
                            'Customer Document Id Is Required.', NULL;
                        RETURN;
                    END;

                SELECT  CAST(cm.createdDate AS DATE) registerDate,*,cm.membershipId
					FROM    dbo.customerDocument cd
					INNER JOIN dbo.customerMaster cm ON cm.customerId=cd.customerId
                WHERE   cdId = @cdId;
                RETURN;
            END;
			-- Insert statements for procedure here
        IF @flag = 'i'
            BEGIN
                INSERT  INTO dbo.customerDocument
                        ( customerId ,
                          [fileName] ,
                          fileDescription ,
                          fileType ,
                          documentType ,
                          isDeleted ,
                          createdBy ,
                          createdDate ,
                          modifiedBy ,
                          modifiedDate ,
                          approvedBy ,
                          approvedDate ,
                          agentId ,
                          branchId
                        )
                VALUES  ( @customerId , -- customerId - int
                          @fileName , -- fileName - varchar(50)
                          @fileDescription , -- fileDescription - varchar(100)
                          @fileType , -- fileType - varchar(10)
                          @documentType ,
                          NULL , -- isDeleted - char(1)
                          @user , -- createdBy - varchar(30)
                          GETDATE() , -- createdDate - datetime
                          @user , -- modifiedBy - varchar(30)
                          GETDATE() , -- modifiedDate - datetime
                          '' , -- approvedBy - varchar(30)
                          GETDATE() , -- approvedDate - datetime
                          @agentId , -- agentId - int
                          @branchId  -- branchId - int
	                    );
				
				SET @cdId = @@IDENTITY
				UPDATE dbo.customerDocument SET sessionId = 'JME'+RIGHT('0000000' + CAST(@cdId AS VARCHAR), 6) WHERE cdId = @cdId
                EXEC proc_errorHandler 0, 'Record updated successfully.', NULL;
                RETURN;
            END;
		
        IF @flag = 'u'
            BEGIN
                IF @cdId IS NULL
                    BEGIN
                        EXEC proc_errorHandler 1,
                            'Customer Document Number Is Required.', NULL;
                        RETURN;
                    END;

                UPDATE  dbo.customerDocument
                SET     [fileName] = CASE WHEN @fileName IS NOT NULL
                                          THEN @fileName
                                          ELSE [fileName]
                                     END ,
                        fileDescription = CASE WHEN @fileDescription IS NOT NULL
                                               THEN @fileDescription
                                               ELSE fileDescription
                                          END ,
                        fileType = CASE WHEN @fileType IS NOT NULL
                                        THEN @fileType
                                        ELSE fileType
                                   END ,
                        documentType = CASE WHEN @documentType IS NOT NULL
                                            THEN @documentType
                                            ELSE documentType
                                       END ,
                        modifiedBy = CASE WHEN @user IS NOT NULL THEN @user
                                          ELSE modifiedBy
                                     END ,
                        approvedBy = CASE WHEN @approvedBy IS NOT NULL
                                          THEN @approvedBy
                                          ELSE approvedBy
                                     END ,
                        modifiedDate = GETDATE()
                WHERE   cdId = @cdId;
                EXEC proc_errorHandler 0, 'Record updated successfully.', NULL;
                RETURN;
            END;

		IF @flag='AddSignature'
		BEGIN
		    IF NOT EXISTS(SELECT 1 FROM dbo.customerDocument WHERE customerId =@customerId AND cdId=0)
			BEGIN
			IF @fileName IS NULL
				BEGIN
				    SET @fileName=@customerId+'_signature.png';
				END
			    
				INSERT INTO dbo.customerDocument
							(customerId,fileName,fileDescription,fileType,isDeleted,createdBy,createdDate,documentType)
					VALUES  (@customerId,@fileName,'Customer Signature','signature','N',@user,GETDATE(),'0')

				SET @cdId = @@IDENTITY

				EXEC proc_errorHandler 0, 'Record updated successfully.', @cdId;
                RETURN;
			END
		END
    END;

GO