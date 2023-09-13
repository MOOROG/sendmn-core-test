SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
ALTER proc [dbo].[proc_approveOFACCompliance]
	 @flag                              VARCHAR(50)		= NULL
	,@user                              VARCHAR(200)	= NULL
	,@trnId								VARCHAR(30)		= NULL
	,@controlNo							VARCHAR(100)	= NULL
	,@sCountry							VARCHAR(50)		= NULL
	,@sAgentName						VARCHAR(50)     = NULL
	,@branchName						VARCHAR(50)		= NULL
	,@createdBy							VARCHAR(50)		= NULL
	,@createdDate						VARCHAR(20)     = NULL
	,@type								VARCHAR(10)		= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL
	,@Msg						 VARCHAR(20)		= NULL

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @controlNoEncrypted VARCHAR(20)
SELECT @controlNoEncrypted = dbo.FNAEncryptString(@controlNo)

BEGIN TRY

	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			  VARCHAR(10)
		,@tableAlias		  VARCHAR(100)
		,@logIdentifier	  VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)		
		,@id				VARCHAR(10)
		,@modType			VARCHAR(6)
		,@ApprovedFunctionId INT
		,@tranAmount		MONEY

	SELECT
		 @ApprovedFunctionId = 20123030
		,@logIdentifier = 'trnId'
		,@logParamMain = 'remitTranCompliance'
		,@logParamMod = 'remitTranOfac'
		,@module = '20'
		,@tableAlias = 'Approve OFAC Compliance'
	
	IF @flag='s'
	BEGIN

		SET @table = '(
		
					select 
						
						 tranId=ISNULL(b.holdTranId,b.id)
						,controlNo=dbo.FNADecryptString(b.controlNo) 
						,b.sCountry
						,b.sAgentName
						,branchName=b.sBranchName
						,b.createdBy 
						,b.createdDate
						,b.cAmt
						,type = ISNULL((SELECT dbo.FNAGetOfacComplianceReason(ISNULL(holdTranId, id))),''Cash Limit Hold'')
						,receiverName = receiverName
						,senderName = senderName
						,hasChanged = ''''
						from vwRemitTran b with(nolock)
						WHERE B.tranStatus IN (''Compliance Hold'', ''OFAC Hold'', ''OFAC/Compliance Hold'', ''Cash Limit Hold'', ''Cash Limit/OFAC/Compliance Hold'', ''Cash Limit/OFAC Hold'', ''Cash Limit/Compliance Hold'')
			) '

			
		IF @sortBy IS NULL
			SET @sortBy = 'tranId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		--print @table 
		--return;
		SET @table = '( 
			select tranId 
						--,controlNo= ''<a href="#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?controlNo='' + main.controlNo + '''''')">'' + main.controlNo + ''</a>''
						,controlNo= ''<a href="'+dbo.FNAGetURL()+'Remit/Compliance/ApproveOFACandComplaince/Manage.aspx?controlNo='' + main.controlNo + ''">'' + main.controlNo + ''</a>''
						,branchName
						,type 
						,receiverName
						,senderName 
						,hasChanged
						,sCountry
						,sAgentName
						,createdBy
						,createdDate
						,cAmt
					
				FROM ' + @table + ' main
				
				) x
	
				'
			
			print @table		
		SET @sql_filter = ''
		
		IF @controlNo IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND controlNo LIKE ''%' + @controlNo + '%'''
			
		IF @sCountry IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND sCountry = ''' + @sCountry + ''''
			
		IF @sAgentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND sAgentName = ''' + @sAgentName + ''''
		
		IF @branchName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND senderName = ''' + @branchName + ''''
			
		IF @createdBy IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND createdBy = ''' + @createdBy + ''''
			
		IF @createdDate IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND CAST(createdDate AS DATE) = ''' + @createdDate + ''''
			
		IF @type IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND type LIKE ''' + @type + '%'''
			
		SET @select_field_list ='
			 tranId
			,controlNo
			,branchName
			,type
			,receiverName
			,senderName
			,hasChanged
			,sCountry
			,sAgentName
			,createdBy
			,createdDate
			,cAmt
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


END TRY
BEGIN CATCH

     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @trnId

END CATCH
GO