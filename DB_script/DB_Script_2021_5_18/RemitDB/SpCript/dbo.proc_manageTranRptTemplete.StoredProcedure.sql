USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_manageTranRptTemplete]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROC [dbo].[proc_manageTranRptTemplete]
	 @flag								VARCHAR(50)		=	NULL
	,@rowId								VARCHAR(50)		=	NULL
	,@user								VARCHAR(50)		=	NULL
	,@tranInfo							VARCHAR(MAX)	=	NULL
	,@senAgentInfo						VARCHAR(MAX)	=	NULL
	,@senInfo 							VARCHAR(MAX)	=	NULL
	,@recAgentInfo	                    VARCHAR(MAX)    =	NULL
	,@recInfo							VARCHAR(MAX)	=	NULL
	,@templateName						VARCHAR(200)	=	NULL
	,@pageNumber						VARCHAR(100)	=	NULL
	,@pageSize							VARCHAR(100)	=	NULL     
	,@sortBy							VARCHAR(50)		=	NULL
	,@sortOrder							VARCHAR(5)		=	NULL	
	,@tranInfoAlias						VARCHAR(MAX)	=	NULL
	,@senAgentInfoAlias 				VARCHAR(MAX)	=	NULL
	,@senInfoAlias 						VARCHAR(MAX)	=	NULL
	,@recAgentInfoAlias 				VARCHAR(MAX)	=	NULL
	,@recInfoAlias 						VARCHAR(MAX)	=	NULL


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

	IF @flag = 'a'
	BEGIN
		SELECT id,templateName FROM ReportTemplate	WITH(NOLOCK) 
		WHERE ISNULL(isDeleted,'N')='N' 
			AND ISNULL(isActive,'Y')='Y' 
			--AND createdBy=@user 	
			AND temType IS NULL
	END
	
	IF @flag='b'
	BEGIN

		SELECT @fields=REPLACE(REPLACE(REPLACE(fields,'[',''),']',''),',',', ') FROM ReportTemplate WHERE id=@rowId
		SELECT @fields AS value
		
	END
	
    IF @flag = 'i'
    BEGIN		
		
			SET @fields=''
			SET @fieldsAlias=''
			IF @tranInfo IS NOT NULL AND @fields<>''
			BEGIN
				SET @fields=@fields+','+@tranInfo
				SET @fieldsAlias=@fieldsAlias+','+@tranInfoAlias
				--SET @fieldsAlias=@fieldsAlias+','+@tranInfo
			END
			IF @tranInfo IS NOT NULL AND @fields=''
			BEGIN
				SET @fields=@tranInfo
				SET @fieldsAlias=@tranInfoAlias
				--SET @fieldsAlias=@tranInfo
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
			)
			SELECT
				 @templateName
				,@fields
				,@fieldsAlias
				,@user
				,GETDATE()
			
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
    
    IF @flag='TRANINFO'
    BEGIN
			SELECT '[TranNo]' VALUE,'TranNo'  FIELD
			UNION ALL
			SELECT '[ICN]',	'ICN'
			UNION ALL
			SELECT '[Confirm Date]',	'Confirm Date'
			UNION ALL
			SELECT '[TRN Date]',	'TRN Date'
			UNION ALL
			SELECT '[Payment Type]',	'Payment Type'
			UNION ALL
			SELECT '[Collected Amount]',	'Collected Amount'
			UNION ALL
			SELECT '[Sevice Charge]',	'Sevice Charge'
			UNION ALL
			SELECT '[Exchange Rate]',	'Exchange Rate'
			UNION ALL
			SELECT '[Purpose of Remittance]',	'Purpose of Remittance'
			UNION ALL
			SELECT '[Remarks]',	'Remarks'
			UNION ALL
			SELECT '[TRN Status]',	'TRN Status'
			UNION ALL
			SELECT '[Paid Date]',	'Paid Date'
			UNION ALL
			SELECT '[Cancelled Date]',	'Cancelled Date'
			UNION ALL
			SELECT '[Receiving Currency]','Receiving Currency'
			UNION ALL
			SELECT '[Receiving Amount]','Receiving Amount'
			UNION ALL
			SELECT '[sCurrCostRate]','Usd vs Sending Rate'
			UNION ALL
			SELECT '[pCurrCostRate]','Usd vs Receiving Rate'
			UNION ALL
			SELECT '[Settlement Rate]','Settlement Rate'
			UNION ALL
			SELECT '[Exchange Rate Premium]','Exchange Rate Premium'
			UNION ALL
			SELECT '[Service Charge Discount]','Service Charge Discount'
    END
        
    IF @flag='SENDING_AGENT_INFO'
    BEGIN
			SELECT '[Sending Agent Name]' VALUE,	'Sending Agent Name' FIELD
			UNION ALL
			SELECT '[Sending Agent Code]',	'Sending Agent Code'
			UNION ALL
			SELECT '[Sending Branch Name]',	'Sending Branch Name'
			UNION ALL
			SELECT '[Sending Branch Code]',	'Sending Branch Code'
			UNION ALL
			SELECT '[Sending User]'	,'Sending User'
			UNION ALL
			SELECT '[Sending Currency]',	'Sending Currency'
			UNION ALL
			SELECT '[Sending Amount]',	'Sending Amount'
			UNION ALL
			SELECT '[Sender Commission]',	'Sender Commission'
			UNION ALL
			SELECT '[Sending Country]',	'Sending Country'
    END
    
    IF @flag='SENDER_INFO'
    BEGIN
			SELECT '[Sender Name]' VALUE,'Sender Name' [FIELD]
			UNION ALL
			SELECT '[Sender Address]','Sender Address'
			UNION ALL
			SELECT '[Sender City]','Sender City'
			UNION ALL
			SELECT '[Sender Member ID]','Sender Member ID'
			UNION ALL
			SELECT '[Sender Id Type]','Sender Id Type'
			UNION ALL
			SELECT '[Sender Id Number]','Sender Id Number'
			UNION ALL
			SELECT '[Sender Mobile]','Sender Mobile'
			UNION ALL
			SELECT '[Visa Expiry Date]','Visa Expiry Date'
			UNION ALL
			SELECT '[Sender Native Country]','Sender Native Country'
    END
    
    IF @flag='REC_AGENT_INFO'
    BEGIN

			SELECT '[Receiving Agent Name]' VALUE,'Receiving Agent Name' FIELD
			UNION ALL
			SELECT '[Receiving Agent Code]','Receiving Agent Code'
			UNION ALL
			SELECT '[Receiving Branch Name]','Receiving Branch Name'
			UNION ALL
			SELECT '[Receiving Branch Code]','Receiving Branch Code'
			UNION ALL
			SELECT '[Receiving User]','Receiving User'
			UNION ALL
			SELECT '[Receiving Country]','Receiving Country'
			UNION ALL
			SELECT '[Receiver Commission]',	'Receiver Commission'

    END
    
    IF @flag='REC_INFO'
    BEGIN

			SELECT '[Receiver Name]' VALUE,'Receiver Name' FIELD
			UNION ALL
			SELECT '[Receiver Address]','Receiver Address'
			UNION ALL
			SELECT '[Receiver City]','Receiver City'
			UNION ALL
			SELECT '[Receiver Member ID]','Receiver Member ID'
			UNION ALL
			SELECT '[Receiver Id Type]','Receiver Id Type'
			UNION ALL
			SELECT '[Receiver Id Number]','Receiver Id Number'
			UNION ALL
			SELECT '[Receiver Mobile]','Receiver Mobile'
			UNION ALL
			SELECT '[Receiver Bank]','Receiver Bank'
			UNION ALL
			SELECT '[Receiver Bank Branch]','Receiver Bank Branch'
			UNION ALL
			SELECT '[Receiver A/C No]','Receiver A/C No'
			UNION ALL
			SELECT '[Receiver Country]','Receiver Country'
			UNION ALL
			SELECT '[External Bank Code]','External Bank Code'
			UNION ALL
			SELECT '[External Branch Code]','External Branch Code'
			UNION ALL
			SELECT '[ID Issue District]','ID Issue District'


    END
			
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id
END CATCH



GO
