USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentTarget]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_agentTarget]
 		 @flag							 VARCHAR(50)	= NULL
		,@id							 INT			= NULL 
		,@agentId						 INT			= NULL
		,@agentName						 VARCHAR(50)	= Null
	    ,@year							 varchar(20)    = null
	    ,@month							 varchar(50)    = null 
		,@branchId						 VARCHAR(50)	= NULL	
		,@countryId						 VARCHAR(50)	= NULL	
		,@userType						 VARCHAR(2)		= NULL
		,@xml							 XML			= NULL
		,@user							 VARCHAR(50)	= NULL
		,@createdBy						 varchar(50)	= NULl
		,@targetTxn						 varchar(50)	= NULl
		,@targetEduPay					 varchar(50)	= NULl
		,@targetTopup					 varchar(50)	= NULl
		,@sortBy						 VARCHAR(50)	= NULL
		,@sortOrder						 VARCHAR(5)		= NULL
		,@pageSize						 INT			= NULL
		,@pageNumber					 INT			= NULL	


	AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN
	DECLARE 
		 @table							VARCHAR(MAX)
		,@select_field_list				VARCHAR(MAX)
		,@extra_field_list				VARCHAR(MAX)
		,@sql_filter					VARCHAR(MAX)
		,@sql							varchar(max)	
		,@StartDate						VARCHAR(20)
		,@previousMonthDate				VARCHAR(20)
		,@previousMonth					VARCHAR(20)
		,@previousYr					VARCHAR(20)
		,@totBonus						VARCHAR(10)
		,@totPoint						MONEY
		,@bonusPrize					VARCHAR(500)
		,@cashPrize						VARCHAR(500)
		,@head							VARCHAR(MAX)

	IF @flag='s'
	BEGIN	
		DECLARE 
			 @tblTemp TABLE (
				particulars VARCHAR(200),
				targentTxn VARCHAR(50),				
				actualTxn VARCHAR(50),
				remarks VARCHAR(500)				
			)

		SELECT @month = 'Ashad'
	    SELECT @year = '2073'
		SELECT @previousMonth = 'Jestha' 
	    SELECT @previousYr = '2073'
		
		-- No Result case
		SELECT targentTxn head FROM @tblTemp WHERE 1=2
		SELECT [Bonus Point]=targentTxn,[Gifts]=targentTxn FROM @tblTemp WHERE 1=2

		SELECT 'Domestic Target for the month : <b>'+@month+'</b>' head
		INSERT INTO @tblTemp(particulars, targentTxn,actualTxn,remarks)
		SELECT   
			 Particular = 'Minimum Target' 
			,Target = minTarget
			,Achived = actualTxn
			,Remarks = 'Achieve your minimum target & get extra Rs 15/txn for extra txn.'
		FROM RemittanceLogData.dbo.agentTarget WITH(NOLOCK) 
			WHERE (agentId = @branchId or agentId = @agentId) 
				AND yr =  @year  
				AND yrMonth =  @month 
				AND userName IS NULL
		UNION ALL
		SELECT   
				 Particular = 'Final Target' 
				,Target = targentTxn
				,Achived = actualTxn
				,Remarks = 'Achieve your final target & get Flat incentive.'
		FROM RemittanceLogData.dbo.agentTarget WITH(NOLOCK) 
			WHERE (agentId = @branchId or agentId = @agentId) 
				AND yr =  @year  
				AND yrMonth =  @month 
				AND userName IS NULL          
 
		SELECT 
			'Particular' = particulars
			,[Target] = targentTxn
			,[Actual] = ISNULL(actualTxn,0)
			,[Remaining] =	CASE 
								WHEN CAST(CAST(ISNULL(targentTxn,0) AS INT) - CAST(ISNULL(actualTxn, 0) AS INT) AS VARCHAR) > 0 THEN CAST(CAST(ISNULL(targentTxn, 0) AS INT) - CAST(ISNULL(actualTxn, 0) AS INT) AS VARCHAR)
								ELSE 'Target Achieved' 
							END
			,Remarks
		FROM @tblTemp
		RETURN;		
	END
	ELSE IF @flag='s-intl'
	BEGIN			
		DECLARE 
			@tblTempIntl TABLE (
				particulars VARCHAR(200),
				targentTxn VARCHAR(50),
				remarks VARCHAR(500)			
			)

		SELECT @month = 'Jestha'
	    SELECT @year = '2073'
		SELECT @previousMonth = 'Baisakh' 
	    SELECT @previousYr = '2072'
		
		-- No Result case
		SELECT targentTxn head FROM @tblTempIntl WHERE 1=2
		SELECT [Bonus Point]=targentTxn,[Gifts]=targentTxn FROM @tblTempIntl WHERE 1=2

		SELECT 'International Target for the month : <b>'+@month+'</b>' head
		INSERT INTO @tblTempIntl(particulars, targentTxn,remarks)
		SELECT   
				 Particular = 'Target' 
				,Target = targentTxn				
				,Remarks = 'Achieved at least Max. Txn on <b>'+@month+'</b> & get Rs 10/txn for total International Txn.'
		FROM RemittanceLogData.dbo.agentTargetIntl WITH(NOLOCK) 
			WHERE (agentId = @branchId or agentId = @agentId) 
				AND yr =  @year  
				AND yrMonth =  @month 				
		          
 
		SELECT 
			'Particular' = particulars
			, [Target] = targentTxn			
			,Remarks
		FROM @tblTempIntl
		RETURN	
	END	
	IF @flag='i'
	BEGIN
		INSERT INTO RemittanceLogData.dbo.agentTarget (		                
				agentId
			,yr
			,yrMonth
			,targentTxn			
			,targetEduPay		
			,targetTopup
			,createdBy
			,createdDate
		    )
		SELECT
				@agentId
			,@year
			,@month
			,@targetTxn
			,@targetEduPay
			,@targetTopup
			,@user
			,GETDATE()
		         
		SELECT 0, 'Target has been added successfully.', @agentId
		RETURN        
	END

	IF @flag='u'
	BEGIN		   
		UPDATE RemittanceLogData.dbo.agentTarget SET		    
			 agentId			= @agentId
			,yr					= @year
			,yrMonth			= @month
			,targentTxn			= @targetTxn		
			,targetEduPay		= @targetEduPay		
			,targetTopup		= @targetTopup
			,modifiedBy			= @user
			,modifiedDate		= getdate()
		WHERE id= @id
		SELECT 0, 'Target has been updated successfully.', @id	
		RETURN
	END

	IF @flag='sl'
    BEGIN
        IF @sortBy IS NULL
			SET @sortBy = 'agentId'
		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'
		
		SET @table = '(
				SELECT 
					 at.id
					,am.agentName
					,at.agentId
                    ,yr
                    ,yrMonth
					,targentTxn
					,targetEduPay
					,targetTopup
					,actualTxn
					,actualEduPay
					,actualTopup
					,at.createdBy
					,at.createdDate					
				FROM RemittanceLogData.dbo.agentTarget at with(nolock)	
				inner join agentMaster am with(nolock) on at.agentId = am.agentId
				and userName is null
							
				)x '
				
		SET @sql_filter = ''
			
		IF @agentId IS NOT NULL 
			SET @sql_filter=@sql_filter+' AND agentId = '''+@agentId+''''
		IF @agentName IS NOT NULL 
			SET @sql_filter=@sql_filter+' AND agentName like ''%'+@agentName+'%'''
		IF @year IS NOT NULL 
			SET @sql_filter=@sql_filter+' AND yr = '''+@year+''''
		IF @month IS NOT NULL 
			SET @sql_filter=@sql_filter+' AND yrMonth = '''+@month+''''
									
		SET @select_field_list ='			 
					  id
					 ,agentName
					 ,agentId
					 ,yr
					 ,yrMonth
					 ,targentTxn
					 ,targetEduPay
					 ,targetTopup
					 ,actualTxn
					 ,actualEduPay
					 ,actualTopup
					 ,createdBy
					 ,createdDate					
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
		RETURN        
    END

    IF @flag = 'd'
    BEGIN
        DELETE FROM RemittanceLogData.dbo.agentTarget WHERE id=@id
		SELECT 0, 'Target has been deleted successfully.', @id
		RETURN
    END
		      
    ELSE IF @flag ='a'
    BEGIN
		SELECT 
			at.*,am.agentName 
		FROM RemittanceLogData.dbo.agentTarget at WITH(NOLOCK) 
		INNER JOIN agentMaster am WITH(NOLOCK) ON at.agentId = am.agentId
		WHERE id = @id
		RETURN
	END

	ELSE IF @flag ='upload'
    BEGIN		
		declare @agentTarget table(agentId varchar(50),yr varchar(50),yrMonth varchar(50),targentTxn varchar(50),targetEduPay varchar(50),targetTopup varchar(50))
		INSERT @agentTarget(agentId,yr,yrMonth,targentTxn,targetEduPay,targetTopup)
		SELECT
			p.value('@agentId','VARCHAR(50)'),
			p.value('@yr','VARCHAR(50)'),
			p.value('@yrMonth','VARCHAR(50)'),
			p.value('@txn','VARCHAR(50)'),
			p.value('@eduPay','VARCHAR(50)'),
			p.value('@topup','VARCHAR(50)')
		FROM @xml.nodes('/root/row') as tmp(p)
		
		insert into RemittanceLogData.dbo.agentTarget (agentId ,yr ,yrMonth ,targentTxn ,cashPrize,targetTopup,createdBy,createdDate,sAgent)

		select am.agentId ,yr ,yrMonth ,targentTxn ,targetEduPay,targetTopup,@user,getdate(),
		case when (am.agentType = '2903' and am.actAsBranch = 'Y') then am.agentId else am.parentId end from @agentTarget at
		inner join agentMaster am with(nolock) on at.agentId = am.agentId

		SELECT 'Agent Target Uploaded Sucessfully.' msg
	END
	
	ELSE IF @flag ='uploadPrize'
    BEGIN

		if not exists(select 'x' from RemittanceLogData.dbo.agentTarget with(nolock) where yr = @year and yrMonth = @month)
		begin
			select 'No Data Found.' msg
			return;
		end
		declare @prizeUpload table(agentId varchar(50),bonusPrize varchar(500),cashPrize varchar(500))
		INSERT @prizeUpload(agentId,bonusPrize,cashPrize)
		SELECT
			p.value('@agentId','VARCHAR(50)'),
			p.value('@bonusPrize','VARCHAR(50)'),
			p.value('@cashPrize','VARCHAR(50)')
		FROM @xml.nodes('/root/row') as tmp(p)
		
		update RemittanceLogData.dbo.agentTarget 
			set bonusPrize = b.bonusPrize
		       ,cashPrize = b.cashPrize 
			   ,prizeUploadBy = @user
			   ,prizeUploadDate =  getdate()
		from RemittanceLogData.dbo.agentTarget a,
		(
			select pu.bonusPrize,pu.cashPrize,am.agentId from @prizeUpload pu inner join agentMaster am with(nolock) on am.mapCodeInt = pu.agentId
		)b where a.agentId = b.agentId and a.yr = @year and a.yrMonth = @month
		

		SELECT 'Agent Target Prize Uploaded Sucessfully.' msg

	END

	ELSE IF @flag ='uploadZoneWise'
    BEGIN
		DECLARE @zoneTarget table(zoneName varchar(50),yr varchar(50),targentTxn varchar(50),targetEduPay varchar(50),targetTopup varchar(50),targetRemitCard varchar(50))
		INSERT @zoneTarget(zoneName,yr,targentTxn,targetEduPay,targetTopup,targetRemitCard)
		SELECT
			p.value('@Zone','VARCHAR(50)'),
			p.value('@Year','VARCHAR(50)'),
			p.value('@Domestic','VARCHAR(50)'),
			p.value('@EduPay','VARCHAR(50)'),
			p.value('@Topup','VARCHAR(50)'),
			p.value('@Card','VARCHAR(50)')
		FROM @xml.nodes('/root/row') as tmp(p)
		
		/*Update Matching Data*/
		UPDATE
			z
		SET
			 z.targetDomTxn = t.targentTxn 
			,z.targetEduPay = t.targetEduPay 
			,z.targetTopup = t.targetTopup
			,z.targetRemitCard = t.targetRemitCard
		FROM
			RemittanceLogData.dbo.zoneWiseTargetSetup z 
			INNER JOIN @zoneTarget t on z.zoneName = t.zoneName AND z.yr = t.yr 
			
		
		/*Delete Matching Data After Update*/
		DELETE FROM t
		FROM
			RemittanceLogData.dbo.zoneWiseTargetSetup z 
			INNER JOIN @zoneTarget t on z.zoneName = t.zoneName AND z.yr = t.yr
		
		/* New Insert */
		INSERT INTO RemittanceLogData.dbo.zoneWiseTargetSetup(zoneName,yr,targetDomTxn,targetEduPay,targetTopup,targetRemitCard,createdby,createdDate)
		SELECT zoneName,yr,targentTxn,targetEduPay,targetTopup,targetRemitCard,@user,GETDATE() FROM @zoneTarget
		
		SELECT 'Zone Wise Target Uploaded Sucessfully.' msg
	END
END






GO
