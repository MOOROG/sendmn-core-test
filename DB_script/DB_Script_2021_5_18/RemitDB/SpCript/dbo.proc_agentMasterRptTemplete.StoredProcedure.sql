USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentMasterRptTemplete]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_agentMasterRptTemplete]
	 @flag								VARCHAR(50)		=	NULL
	,@rowId								VARCHAR(50)		=	NULL
	,@user								VARCHAR(50)		=	NULL
	,@templateName						VARCHAR(200)	=	NULL
	,@pageNumber						VARCHAR(100)	=	NULL
	,@pageSize							VARCHAR(100)	=	NULL     
	,@sortBy							VARCHAR(50)		=	NULL
	,@sortOrder							VARCHAR(5)		=	NULL	
	,@agentInfo							VARCHAR(MAX)	=	NULL
	,@agentInfoAlias 					VARCHAR(MAX)	=	NULL


AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@tableName			VARCHAR(50)
		,@logIdentifier		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@tableAlias		VARCHAR(100)
		,@modType			VARCHAR(6)
		,@module			INT	
		,@select_field_list VARCHAR(MAX)
		,@extra_field_list  VARCHAR(MAX)
		,@table             VARCHAR(MAX)
		,@fields			VARCHAR(MAX)	
		,@fieldsAlias		VARCHAR(MAX)

	IF @flag='ddl'
	BEGIN
		SELECT 'all-dom' VALUE,'All Agents- Domestic' TEST UNION ALL
		SELECT 'all-int' VALUE,'All Agents- International' TEST UNION ALL
		SELECT 'all-sending-dom' VALUE,'All Sending Agents- Domestic' TEST UNION ALL
		SELECT 'all-sending-int' VALUE,'All Sending Agents- International' TEST UNION ALL
		SELECT 'all-sending' VALUE,'All Sending Agents' TEST UNION ALL
		SELECT 'all-paying' VALUE, 'All Paying Agents' TEST UNION   ALL		
		SELECT 'private-agent','IME private agents'   UNION ALL
		SELECT 'bank-finance', 'Bank & Finance'      UNION ALL
		SELECT 'college','School & Colleges'    
	END
	if @flag='ddl-status'
	BEGIN
		SELECT 'Unblock'  VALUE, 'Unblock' TEST UNION ALL
		SELECT 'Block' VALUE, 'Block' TEST UNION   ALL		
		SELECT 'Active', 'Active'  UNION ALL
		SELECT 'Inactive','Inactive'
	END
	IF @flag = 'a'
	BEGIN
		SELECT id,templateName FROM ReportTemplate	WITH(NOLOCK) 
		WHERE ISNULL(isDeleted,'N')='N' AND ISNULL(isActive,'Y')='Y' AND createdBy=@user
		and temType = 'a'		
	END

	--ALTER TABLE ReportTemplate ADD temType CHAR(1)
	
	IF @flag='b'
	BEGIN
		SELECT @fields=REPLACE(REPLACE(REPLACE(fields,'[',''),']',''),',',', ') FROM ReportTemplate WITH(NOLOCK) WHERE id=@rowId
		SELECT @fields AS value		
	END
	
    IF @flag = 'i'
    BEGIN		
		
			SET @fields=''
			SET @fieldsAlias=''
			IF @agentInfo IS NOT NULL AND @fields<>''
			BEGIN
				SET @fields=@fields+','+@agentInfo
				SET @fieldsAlias=@fieldsAlias+','+@agentInfoAlias
			END
			IF @agentInfo IS NOT NULL AND @fields=''
			BEGIN
				SET @fields=@agentInfo
				SET @fieldsAlias=@agentInfoAlias
			END	
			
			IF @fields=''
			BEGIN
				EXEC proc_errorHandler 1, 'Please select fields for report template!.', @rowId	
				RETURN;
			END
			
			BEGIN TRANSACTION					
			INSERT INTO ReportTemplate(
				 templateName
				,fields
				,fieldsAlias
				,createdBy
				,createdDate
				,temType
			)
			SELECT
				 @templateName
				,@fields
				,@fieldsAlias
				,@user
				,GETDATE()
				,'a'
			SET @rowId=@@IDENTITY		
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
			EXEC proc_errorHandler 0, 'Record has been added successfully.', @rowId
    END
    
    IF @flag='d'
    BEGIN
		UPDATE ReportTemplate SET 
			isDeleted='Y', 
			modfiedDate=GETDATE(),
			modifiedBy=@user
		WHERE id=@rowId
		SELECT 0 errorCode, 'Record has been deleted successfully.' msg, @rowId id	
    END
    
    IF @flag='AGENT_INFO'
    BEGIN
			SELECT '[Agent Id]' VALUE,'Agent Id'  FIELD
			UNION ALL
			SELECT '[Agent Name]',	'Agent Name'
			UNION ALL
			SELECT '[Agent Code]',	'Agent Code'
			UNION ALL
			SELECT '[Agent Address]',	'Agent Address'		
			UNION ALL
			SELECT '[Agent City]',	'Agent City'	
			UNION ALL
			SELECT '[Agent Country]',	'Agent Country'	
			UNION ALL
			SELECT '[Agent State/Zone]',	'Agent State/Zone'	
			UNION ALL
			SELECT '[Agent District]',	'Agent District'	
			UNION ALL
			SELECT '[Agent Location]',	'Agent Location'
			UNION ALL	
			SELECT '[Zip]',	'Zip'	
			UNION ALL	
			SELECT '[Phone]',	'Phone'		
			UNION ALL	
			SELECT '[Fax]',	'Fax'
			UNION ALL	
			SELECT '[Mobile]',	'Mobile'	
			UNION ALL	
			SELECT '[Email]',	'Email'	
			UNION ALL	
			SELECT '[Organization Type]',	'Organization Type'	
			UNION ALL	
			SELECT '[Business Type]',	'Business Type'	
			UNION ALL	
			SELECT '[Agent Role]',	'Agent Role'	
			UNION ALL	
			SELECT '[Agent Type]',	'Agent Type'	
			UNION ALL	
			SELECT '[Allow A/C Deposit]',	'Allow A/C Deposit'	
			UNION ALL	
			SELECT '[Act As Branch]',	'Act As Branch'	
			UNION ALL	
			SELECT '[Contact Expiry Date]',	'Contact Expiry Date'
			UNION ALL	
			SELECT '[Renewall Follow Up]',	'Renewall Follow Up'
			UNION ALL	
			SELECT '[Is Settling Agent]',	'Is Settling Agent'
			UNION ALL	
			SELECT '[Agent Group]',	'Agent Group'
			UNION ALL	
			SELECT '[Business License]',	'Business License'
			UNION ALL	
			SELECT '[Agent Block]',	'Agent Block'
			UNION ALL
			SELECT '[Contact Person]','Contact Person'
			UNION ALL	
			SELECT '[Agent Company Name]',	'Agent Company Name'
			UNION ALL	
			SELECT '[Company Address]',	'Company Address'
			UNION ALL	
			SELECT '[Company City]',	'Company City'
			UNION ALL	
			SELECT '[Company Country]',	'Company Country'
			UNION ALL	
			SELECT '[Company State]',	'Company State'
			UNION ALL	
			SELECT '[Company District]',	'Company District'
			UNION ALL	
			SELECT '[Company Zip]',	'Company Zip'
			UNION ALL	
			SELECT '[Company Phone]',	'Company Phone'
			UNION ALL	
			SELECT '[Company Fax]',	'Company Fax'
			UNION ALL	
			SELECT '[Company Email]',	'Company Email'
			UNION ALL	
			SELECT '[Local Time]',	'Local Time'
			UNION ALL	
			SELECT '[Local Currency]',	'Local Currency'
			UNION ALL	
			SELECT '[Agent Details]',	'Agent Details'
			UNION ALL	
			SELECT '[Is Active]',	'Is Active'
			UNION ALL	
			SELECT '[Created Date]',	'Created Date'
			UNION ALL	
			SELECT '[Created By]',	'Created By'
			UNION ALL	
			SELECT '[Modified Date]',	'Modified Date'
			UNION ALL	
			SELECT '[Modified By]',	'Modified By'
			UNION ALL	
			SELECT '[Approved Date]',	'Approved Date'
			UNION ALL	
			SELECT '[Approved By]',	'Approved By'
			UNION ALL
			SELECT '[Map Code International]',	'Map Code International'
			UNION ALL	
			SELECT '[Map Code Domestic]',	'Map Code Domestic'
			UNION ALL	
			SELECT '[Commission Code Int]',	'Commission Code Int'
			UNION ALL	
			SELECT '[Commission Code Dom]',	'Commission Code Dom'
			UNION ALL	
			SELECT '[Joined Date]',	'Joined Date'
			UNION ALL	
			SELECT '[Map Code Int A/C]',	'Map Code Int A/C'
			UNION ALL	
			SELECT '[Map Code Domestic A/C]',	'Map Code Domestic A/C'
			UNION ALL	
			SELECT '[Pay Option]',	'Pay Option'
			UNION ALL	
			SELECT '[Is Head Office]',	'Is Head Office'		
			UNION ALL	
			SELECT '[Settlement Currency]',	'Settlement Currency'  
			
			END

END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id
END CATCH



GO
