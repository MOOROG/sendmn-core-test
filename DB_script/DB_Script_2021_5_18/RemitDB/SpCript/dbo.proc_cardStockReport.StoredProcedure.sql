USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_cardStockReport]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_cardStockReport] (

 @flag			VARCHAR(10)
,@searchBy		VARCHAR(20)=NULL
,@cardBy		VARCHAR(20)=NULL
,@szone			VARCHAR(20)=NULL
,@user			VARCHAR(20)=NULL
,@sagent		VARCHAR(20)=NULL
,@remitCardNo	VARCHAR(20)=NULL

)
AS SET NOCOUNT ON;
BEGIN 
	
	DECLARE @FilterList TABLE(head VARCHAR(50), value VARCHAR(100))
		IF OBJECT_ID('tempdb..#TEMP_CARDSTOCK') IS NOT NULL 
			DROP TABLE TEMP_CARDSTOCK
						
		CREATE TABLE #TEMP_CARDSTOCK(remitcardNo VARCHAR(16), cardStatus CHAR(20),agentId VARCHAR(20))
		DECLARE 
				 @table			VARCHAR(MAX)	= NULL	
				,@gobalFilter	VARCHAR(MAX)	= ' WHERE icm.isDeleted IS NULL'
				,@sql			VARCHAR(MAX)	= NULL
				,@url			VARCHAR(MAX)	= NULL
							
	IF @sZone IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Sending Zone',@sZone 
		SET @gobalFilter=@gobalFilter+' AND am.agentState ='''+@sZone+''''
	END
		
	IF @sAgent IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Sending Agent',agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@sAgent 
		SET @gobalFilter=@gobalFilter+' AND am.agentId ='''+@sAgent+''''
	END			
	IF @remitCardNo IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Membership Id',@remitcardNo
		SET @gobalFilter=@gobalFilter+' AND cast(icm.remitcardNo as varchar) ='''+@remitcardNo+''''
	END
	IF @cardBy IS NOT NULL
	BEGIN
		INSERT INTO @FilterList 
		SELECT 'Card Type'
		,CASE WHEN @cardBy ='r' THEN 'IME Remit Card' ELSE
			CASE WHEN @cardBy ='c' THEN 'Customer Card' ELSE 
			'IME -Pin Remit Card' END  END
		SET @gobalFilter=@gobalFilter+' AND icm.cardType ='''+@cardBy+''''
	END
		
	INSERT INTO @FilterList 
	SELECT 'Report By',CASE WHEN @flag ='sz' THEN 'ZONE WISE' 
						WHEN @flag ='sa' THEN 'AGENT WISE' 						
						WHEN @flag ='s'  THEN 'DETAIL'
						END							
	SET @sql = 'insert into #TEMP_CARDSTOCK(remitcardNo,cardStatus,agentId)
		select icm.remitcardNo ,cardStatus,icm.agentId
		from imeremitcardmaster icm with(nolock) INNER JOIN agentMaster am WITH(NOLOCK) 
					ON icm.agentId=am.agentId ' 
		+@gobalFilter +'';
					
		IF @flag='sz'
		BEGIN
			SET @table='
					SELECT 
						 [S.N.]	= ROW_NUMBER() OVER(ORDER BY icm.zone)
						,[Zone]	= ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=getcardstockreport&searchBy=sa&sZone=''+icm.zone+''&cardBy='+@cardBy+'&searchText='+ISNULL(@remitCardNo,'')+'")>''+ icm.zone +''</a>''
						,[Transfered] = sum(tCount) 
						,[Enrolled] = sum(eCount) 
						,[Total] = sum(tCount) + sum(eCount) 
					FROM(
							SELECT 	
								 zone			= am.agentState 					   
								,tCount			= case when icm.cardStatus = ''Transfered'' then  count(''X'') else 0 end	
								,eCount			= case when icm.cardStatus = ''Enrolled'' then count(''X'') else 0 end
							FROM imeremitcardMaster  icm with(nolock)										
							INNER JOIN agentMaster am with(nolock) ON icm.agentId = am.agentId	
							'+@gobalFilter+'								
							GROUP BY am.agentState,icm.cardStatus			
						) icm GROUP BY icm.zone'				
			PRINT @table
			EXEC(@table)	
			
		END				
				
		IF @flag='sa'
		BEGIN			
			SET @table='
			SELECT 
				 [S.N.]	= ROW_NUMBER() OVER(ORDER BY am.agentState,am.agentName)
				,[Zone]	= am.agentState
				,[Agent Name] = ''<a href = "#" onclick=OpenInNewWindow("Reports.aspx?reportName=getcardstockreport&searchBy=detail&sAgent=''+ CAST(am.agentId AS VARCHAR)+''&cardBy='+@cardBy+'&searchText='+ISNULL(@remitCardNo,'')+'")>''+ am.agentName +''</a>''
				,[Transfered] = sum(tCount) 
				,[Enrolled] = sum(eCount) 
				,[Total] = sum(tCount) + sum(eCount) 
			FROM(
					SELECT 	
						 agentId		= am.agentId 					   
						,tCount			= case when icm.cardStatus = ''Transfered'' then  count(''X'') else 0 end	
						,eCount			= case when icm.cardStatus = ''Enrolled'' then count(''X'') else 0 end
					FROM imeremitcardMaster  icm with(nolock)										
					INNER JOIN agentMaster am with(nolock) ON icm.agentId = am.agentId	
					'+@gobalFilter+'								
					GROUP BY am.agentId,icm.cardStatus			
				) icm INNER JOIN dbo.agentMaster am WITH(NOLOCK) ON icm.agentId = am.agentId
				GROUP BY am.agentId,am.agentState, am.agentName'

			PRINT @table
			EXEC (@table)
		END	
	
		IF @flag='detail'
		BEGIN	
			SET @table='			
			SELECT
				 [S.N.]	= ROW_NUMBER() OVER(ORDER BY icm.cardStatus)
				,[Card Number] = remitcardNo
				,[Zone] = am.agentState  
				,[Agent Name] = am.agentName  
				,[Status] = CASE WHEN icm.cardStatus=''HO'' THEN ''Available'' else icm.cardStatus END  
				,[Uploaded By] = icm.createdBy
				,[Uploaded Date] = icm.createdDate
				,[Transfered By] = icm.transferedBy
				,[Transfered Date] = icm.transferedDate
				,[Enrolled By] = enrolledBy
				,[Enrolled Date] = 	enrolledDate											
			FROM imeremitcardmaster icm WITH(NOLOCK) 
			INNER JOIN agentMaster am WITH(NOLOCK) ON icm.agentId = am.agentId
			'+@gobalFilter

			PRINT @Table
			EXEC(@Table)
			
		END
		
		IF @flag='s'
		BEGIN
			SET @gobalFilter=@gobalFilter+' ORDER BY am.agentName ASC'
				SET @table='SELECT
				  	  	    icm.remitcardNo as [Card Number]				  	  	 
				  	  	   ,CASE WHEN icm.cardStatus=''HO'' THEN ''Available'' else icm.cardStatus END AS [Status]
				FROM imeremitcardmaster icm WITH(NOLOCK)
				INNER JOIN agentMaster am WITH(NOLOCK) on  isnull(icm.agentId,1001)=am.agentId'+ @gobalFilter
			
				
				print @table
				EXEC (@table)
		END					
				
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	
		SELECT * FROM @FilterList	
	
		SELECT 'CARD STOCK REPORT' title					
							
END

GO
