USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_sscReportAgent]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC proc_sscReportAgent @flag = 'a', @agentId = '3885',@pCountry='151',@pCurrency='MYR'
EXEC proc_sscReportAgent @flag = 'a', @agentId = '3885',@pCountry='113',@pCurrency='MYR'
*/
CREATE proc [dbo].[proc_sscReportAgent]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@agentId							INT				= NULL
	,@pCountry							VARCHAR(30)		= NULL	
	,@pCurrency							VARCHAR(30)		= NULL

AS

SET NOCOUNT ON;
SET XACT_ABORT ON;


BEGIN TRY
	

	IF @flag = 'a'
	BEGIN	
			IF OBJECT_ID('tempdb..#TEMP_TABLE') IS NOT NULL
			DROP TABLE #TEMP_TABLE
			
			IF OBJECT_ID('tempdb..#RESULT') IS NOT NULL
			DROP TABLE #RESULT
			
			CREATE TABLE #TEMP_TABLE
			(
				serviceTypeId INT				
			)
			CREATE TABLE #RESULT
			(
				TRAN_TYPE VARCHAR(50),
				FROM_AMOUNT MONEY,
				TO_AMOUNT MONEY,
				PERCENTAGE FLOAT,
				MIN_AMOUNT MONEY,
				MAX_AMOUNT MONEY			
								
			)
			DECLARE @MasterId AS INT,@masterType AS VARCHAR(1),@intPartId AS INT,@intTotalRows AS INT,@tranType AS INT
			
			INSERT INTO #TEMP_TABLE
			SELECT serviceTypeId
			FROM serviceTypeMaster	
			WHERE isActive='Y' AND isDeleted IS NULL
			
			INSERT INTO #TEMP_TABLE
			SELECT NULL

			
			ALTER TABLE #TEMP_TABLE ADD RowID INT IDENTITY(1,1)
			SELECT @intPartId=MAX(RowID) FROM #TEMP_TABLE	

			SET @intTotalRows=1
			WHILE @intPartId >=  @intTotalRows
			BEGIN
			
				SELECT @tranType=serviceTypeId FROM #TEMP_TABLE WHERE RowID=@intTotalRows
				
				SELECT @MasterId=masterId,@masterType=masterType FROM [dbo].FNAGetSC(@agentId, NULL, @pCountry, NULL, NULL,@tranType,1, @pCurrency)
						
				IF @masterType='D'
				BEGIN
					INSERT INTO #RESULT					
					SELECT	
							 @tranType
							,dbo.ShowDecimal(fromAmt) [From Amount]
							,dbo.ShowDecimal(toAmt) [To Amount]
							,pcnt [Percentage]
							,dbo.ShowDecimal(minAmt) [Min Amount]
							,dbo.ShowDecimal(maxAmt) [Max Amount] 						
					FROM dscDetail a WITH(NOLOCK) WHERE dscMasterId=@MasterId
				END
				IF @masterType='S'
				BEGIN
					INSERT INTO #RESULT	
					SELECT  
							 @tranType 
							,fromAmt [From Amount]
							,toAmt [To Amount]
							,pcnt [Percentage]
							,minAmt [Min Amount]
							,maxAmt [Max Amount]
					FROM sscDetail a WITH(NOLOCK) WHERE sscMasterId=@MasterId
				END

				SET @intTotalRows=@intTotalRows+1
			END
			SELECT CASE WHEN TRAN_TYPE IS NULL THEN 'All' ELSE B.typeTitle END [Tran Type]
			,dbo.ShowDecimal(A.FROM_AMOUNT) [From Amount]
			,dbo.ShowDecimal(A.TO_AMOUNT) [To Amount]
			,dbo.ShowDecimal(A.PERCENTAGE) [Percentage]
			,dbo.ShowDecimal(A.MIN_AMOUNT) [Min Amount]
			,dbo.ShowDecimal(A.MAX_AMOUNT) [Max Amount] FROM #RESULT A WITH(NOLOCK) LEFT JOIN serviceTypeMaster B WITH(NOLOCK)
			ON A.TRAN_TYPE=B.serviceTypeId
	END


END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH


GO
