USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_online_payoutLocation]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_online_payoutLocation]
(
	@flag			VARCHAR(10)			= NULL
   ,@country		VARCHAR(50)			=NULL
   ,@agentId		VARCHAR(50)			=NULL
   ,@agentCity		VARCHAR(50)			=NULL
   ,@agentAddress	VARCHAR(50)			=NULL
   ,@user			varchar(50)			=NULL
   ,@payType		VARCHAR(50)			=NULL
   ,@sortBy			VARCHAR(50)		    =NULL
   ,@sortOrder		VARCHAR(5)		    =NULL
   ,@agentState		VARCHAR(25)			=NULL
   ,@pageSize		INT				    =NULL
   ,@pageNumber		INT				    =NULL
)	
	
AS SET NOCOUNT ON;
BEGIN TRY

	DECLARE
		 @table				VARCHAR(MAX)
		,@selectfieldlist	VARCHAR(MAX)
		,@extrafieldlist	VARCHAR(MAX)
		,@sqlfilter        VARCHAR(MAX)


	IF @flag='sc'
		BEGIN
			SELECT DISTINCT cm.countryName, cm.countryId FROM payoutLocation pl  
			WITH (NOLOCK) JOIN dbo.countryMaster cm  
			WITH (NOLOCK) 
			ON pl.Country=cm.countryName 
		END

	IF @flag='sp'
		BEGIN		
			SELECT 'Cash Payment'  paymentMode, 'c'	payMode UNION ALL
			SELECT 'Bank Deposit'  paymentMode, 'b'	payMode			
		END

	IF @flag='af'
		BEGIN

		IF @sortBy IS NULL
		   SET @sortBy = 'Branch'
		IF @sortOrder IS NULL
		   SET @sortOrder = 'ASC'
		   
			SET @table='		
							SELECT id
							,Country
							,Branch
							,City
							,Address 
							,isnull(Contact,'''') contact
							,CASE WHEN paymode=''c'' THEN ''Cash Payment'' 
								WHEN paymode=''b'' THEN ''Bank Deposit'' 
								ELSE ''Both'' END paymode
							from payoutLocation where 1=1
							 '						
			SET @sqlfilter = '' 

				IF @country IS NOT NULL
					SET @table = @table + ' AND country='''+@country+''''	
						
				IF @agentState IS NOT NULL
					SET @table = @table + ' AND City = '''+@agentState+''''

				IF @agentAddress IS NOT NULL 
					SET @table = @table + ' AND (address like '''+@agentAddress+'%'' OR Branch like '''+@agentAddress+ '%'')'-- or id Like '''+@agentAddress+ '%''' 
					
		
			EXEC (@table)
			PRINT @table
	END
	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     SELECT 1 error_code, ERROR_MESSAGE() mes, NULL id
END CATCH


	
GO
