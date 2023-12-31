USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_bonusRpt]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_bonusRpt]
(	 
	 @flag				VARCHAR(50)
	,@fromDate			VARCHAR(50)		= NULL
	,@toDate			VARCHAR(50)		= NULL
	,@mFrom				varchar(50)		= null
	,@mTo				varchar(50)		= null
	,@customerId		VARCHAR(50)		= NULL
	,@branchId			VARCHAR(50)		= NULL	
	,@orderBy			VARCHAR(100)	= NULL	
	,@membershipId		VARCHAR(100)	= NULL	
	,@user				VARCHAR(100)	= NULL	
	,@prizeId			VARCHAR(20)		= NULL
	,@pageNumber			INT			= 1
	,@pageSize				INT			= 50	
) 
AS
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	declare @sql varchar(max)
		, @table as varchar(max)
		, @oldToDate varchar(50) = @toDate
	SET @toDate = @toDate+' 23:59:59'
	
	if @flag = 'bRpt'
	begin
		declare @subsql varchar(max) = 'select 
					sen.customerId	 
				   ,sen.membershipId
				   ,earnedBonus = sum(rt.bonusPoint) 
				from remitTran rt with(nolock) 
				inner join tranSenders sen with(nolock) on rt.id = sen.tranId
				where rt.approvedDateLocal between '''+@fromDate+''' and '''+@toDate+'''
					and rt.isBonusUpdated = ''Y'''
					
			if @membershipId is not null 
				set @subsql = @subsql+ ' and sen.membershipId = '''+@membershipId+''''
			set @subsql = @subsql+ 'group by sen.customerId,sen.membershipId'

		set @sql = '
			select
				 [S.N.]	= ROW_NUMBER() over(order by x.earnedBonus desc)
				,[Membership Id] = ''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=20167200&flag=bRptDrildown&fromDate='+@fromDate+'&toDate='+@oldToDate+'&membershipId=''+ x.membershipId +'''''')">''+ x.membershipId +''</a>'' 
				,[Customer Name] = cm.firstName+'' ''+isnull(cm.middleName,'''')+'' ''+ isnull(cm.lastName,'''')
				,[Earned Bonus] = x.earnedBonus
				,[Zone] = pZone
				,[District] = pDistrict
				,[VDC/Municipality] = pMunicipality
				,[Mobile] = mobile
				,[Email] = email
				,[Citizenship No] = citizenshipNo
			from 
			(
				'+@subsql+'
			)x 
			inner join customerMaster cm with(nolock) on x.customerId = cm.customerId
			where x.earnedBonus between '''+@mFrom+''' and '''+@mTo+''''

			EXEC(@sql)
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
			SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value 
			UNION ALL
			SELECT  'Bonus Range From ' head, @mFrom +' - '+ @mTo  value 
			UNION ALL
			SELECT 'Order By' head, @orderBy value
			UNION ALL
			SELECT 'Membership Id' head, @membershipId value

			SELECT 'Customer Bonus Report ' title
	end

	if @flag = 'bRptDrildown'
	begin
		select 
			 [S.N.] = row_number() over(order by rt.id)
			,[Tran Id] = rt.id
			,[Control No] = dbo.fnadecryptstring(rt.controlNo)
			,[Sender Name] = senderName
			,[Receiver Name] = receiverName
			,[Confirm Date] =  rt.approvedDateLocal
			,[Earned Bonus] = rt.bonusPoint		
			,[Coll. Amt] = cAmt
			,[Payout Amt] = pAmt
			,[Service Charge] = serviceCharge
			,[Payout Agent Comm.] = pAgentComm
			,[Sending Agent Comm.] = sAgentComm
			
		from remitTran rt with(nolock) 
		inner join tranSenders sen with(nolock) on rt.id = sen.tranId
		where rt.approvedDateLocal between @fromDate and @toDate and rt.isBonusUpdated = 'Y'
		and sen.membershipId = @membershipId
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Date Range From ' head, @fromDate +' - '+ @toDate  value 
		UNION ALL
		SELECT 'Order By' head, @orderBy value
		UNION ALL
		SELECT 'Membership Id' head, @membershipId value

		SELECT 'Customer Bonus Transaction Detail Report ' title
	end

	IF @flag='bonusPoint'
	BEGIN	
		if @orderBy = 'CustomerName'
			set @orderBy = '[Sender Name]'
		if @orderBy = 'BonusEarned'
			set @orderBy = '[Bonus Earned]'
		if @orderBy = 'Branch'
			set @orderBy = '[Branch Name]'
		
		IF ISNULL(@mFrom, 0) = 0
			SET @mFrom = 1
			
		set @table =
			'select 	
			      [Sender Name]			= ISNULL('' ''+ c.firstName,'''') + ISNULL('' '' + c.middleName, '''') + ISNULL('' '' + c.lastName, '''') 
				, [Sender Citizenship No]	= c.citizenshipNo
				, [Sender Mobile/Phone]	= c.mobile
				, [Bonus Pending]		= convert(int,round(isnull(bonusPointPending,0),0)) 
				, [Bonus Earned]		= convert(int,round((isnull(bonusPoint,0) + ISNULL(Redeemed, 0)),0)) 
				, [Available Bonus]		= convert(int,round((isnull(bonusPoint,0)),0)) 
			FROM customerMaster c with(nolock) 
			LEFT JOIN agentMaster am with(nolock) on c.agentId = am.agentId
			WHERE (isnull(bonusPointPending,0) between '''+@mFrom+''' and '''+@mTo+''' OR ISNULL(bonusPoint, 0) BETWEEN ''' + @mFrom + ''' AND ''' + @mTo + ''')'
			if @membershipId is not null
				set @table = @table+ ' and c.membershipId = '''+@membershipId+'''' 

			SET @sql = 'SELECT 
							COUNT(*) AS TXNCOUNT
							,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
							,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
						FROM (' + @table + ') x'
			PRINT @sql
			EXEC (@sql)

			SET @sql = '
				SELECT
					 *
				FROM (		
					SELECT 
						ROW_NUMBER() OVER (ORDER BY '+@orderBy+') AS [S.N],* 
					FROM (' + @table + ') x		
				) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
			
			PRINT @sql
			EXEC (@sql)		
	

	    EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		SELECT  'Bonus From ' head, @mFrom value 
		union all
		SELECT  'Bonus To ' head, @mTo value
		union all
		select 'Branch Name' head, case when @branchId is not null then (select agentName from agentMaster with(nolock) where agentId = @branchId)
		else 'All' end
		union all
		select 'Order By' head, @orderBy value
		union all
		select 'Membership Id' head, @membershipId value


		SELECT 'Customer Bonus Point Report ' title
	END
	/*
	if @flag = 'bonusRedeemed'
	begin
		if @orderBy = 'CustomerName'
			set @orderBy = '[Sender Name]'
		if @orderBy = 'RedeemedDate'
			set @orderBy = '[Redeemed_Date]'
		if @orderBy = 'Branch'
			set @orderBy = '[Branch Name]'
		if @orderBy = 'GiftItem'
			set @orderBy = '[Gift Item]'

		declare @tbl table (membershipId varchar(50),hoComm money, txnCount int)
		IF OBJECT_ID('tempdb..#tbl') IS NOT NULL
			DROP TABLE #tbl

		CREATE TABLE #tbl
		(
			membershipId varchar(50),
			hoComm money,
			txnCount varchar(50)
		)
	
		insert into #tbl
		select 
			membershipId = cm.customerCardNo,
			hoComm	= sum(isnull(serviceCharge,0)-isnull(sAgentComm,0)-isnull(pAgentComm,0)),
			txnCount = count('x')
		from remitTran rt with(nolock) 
		inner join tranSenders sen with(nolock) on rt.id = sen.tranId
		inner join customerMaster cm with(nolock) on cm.customerCardNo = sen.membershipId
		inner join bonusRedeemHistory red with(nolock) on red.customerId = cm.id
		where red.approvedDate between @fromDate and @toDate
		and cm.customerCardNo = isnull(@membershipId,cm.customerCardNo)
		and red.prizeId = isnull(@prizeId, red.prizeId)
		group by cm.customerCardNo

		set @table =
		'select 
				  [Ref. No]					= red.redeemId
				, [Membership Id]			= c.customerCardNo
				, [Agent]					= am.agentName
				, [Sender Name]				= ISNULL('' ''+ c.firstName,'''') + ISNULL('' '' + c.middleName, '''') + ISNULL('' '' + c.lastName, '''')  
				, [Sender (ID Type/No)]		= dbo.FNAGetDataValue(ci.idType)+'' - ''+ cast(ci.idNumber as varchar)
				, [Sender Contact]			= c.mobile
				, [No. of Txn]				= ''<a href = "#" onclick="OpenInNewWindow('''''+dbo.FNAGetURL()+'SwiftSystem/Reports/Reports.aspx?reportName=20167200&flag=txn-detail&branchId='+isnull(@branchId,'')+'&giftItem='+isnull(@prizeId,'')+'&from='+@fromDate+'&to='+@oldToDate+'&membershipId=''+ c.customerCardNo +'''''')">''+ txn.txnCount +''</a>'' 
				, [HO <br/>Commission]		= txn.hoComm
				, [Bonus Point_Total]		= cast(ISNULL(red.currentMilage, 0) as int)
				, [Bonus Point_Redeemed]	= convert(int,round(isnull(red.deductMilage,0),0)) 
				, [Bonus Point_Remaining]	= cast(ISNULL(red.currentMilage, 0) - isnull(red.deductMilage,0) as int)
				, [Gift Item]				= dbo.FNAGetDataValue(red.prizeId)
				, [Request_Date]			= red.createdDate
				, [Request_User]			= red.createdBy
				, [Approved_Date]			= red.approvedDate
				, [Approved_By]				= red.approvedBy
		from customerMaster c with(nolock) 
		inner join #tbl txn on c.customerCardNo = txn.membershipId
		inner join bonusRedeemHistory red with(nolock) on c.id = red.customerId
		left join customerIdentity ci with(nolock) on c.id = ci.customerId		
		left join agentMaster am with(nolock) on red.branchId = am.agentId
		where red.approvedDate between '''+@fromDate+''' and '''+@toDate+''''

		if @branchId is not null
			set @table = @table+ ' and red.branchId = '''+@branchId+'''' 

		if @membershipId is not null
			set @table = @table+ ' and c.customerCardNo = '''+@membershipId+'''' 

		if @prizeId is not null
			set @table = @table+ ' and red.prizeId = '''+@prizeId+'''' 

		SET @sql = 'SELECT 
							COUNT(*) AS TXNCOUNT
							,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
							,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
						FROM (' + @table + ') x'
		PRINT @sql
		EXEC (@sql)

		SET @sql = '
				SELECT
					 *
				FROM (		
					SELECT 
						ROW_NUMBER() OVER (ORDER BY '+@orderBy+') AS [S.N],* 
					FROM (' + @table + ') x		
				) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
		
		PRINT @sql
		EXEC (@sql)	
	
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
	   
		select 'Branch Name' head, case when @branchId is not null then (select agentName from agentMaster with(nolock) where agentId = @branchId)
												else 'All' end value
		union all
		SELECT  'From Date' head, @fromDate value 
		union all
		SELECT  'To Date' head, @toDate value
		union all
		select 'Gift Item' head,case when @prizeId is not null then (select dbo.FNAGetDataValue(@prizeId)) else 'All' end value
		union all
		select 'Order By' head, @orderBy value
		union all
		select 'Membership Id' head, @membershipId value
		SELECT 'Customer Bonus Redeemed Report ' title
	end

	if @flag ='txn-detail'
	begin
		SELECT 
			 [S.N.]					= row_number()over(order by rt.id)
			,[Control No]			='<a href = "#" onclick="OpenInNewWindow('''+dbo.FNAGetURL()+'Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId='+CAST(rt.id AS VARCHAR)+''')">'+dbo.FNADecryptString(controlNo)+'</a>'			 
			,[Sending_Country]		= sCountry
			,[Sending_Agent]		= sBranchName
			,[Sending_Amt]			= tAmt
			,[Sending_Currency]		= collCurr
			,[Receiving_Country]	= ISNULL(pCountry,'-')
			,[Receiving_Branch]		= case when rt.paymentMethod='Bank Deposit' then rt.pBankBranchName else ISNULL(rt.pBranchName,'-') end
			,[Receiving_Amt]		= pAmt
			,[Tran Type]			= rt.paymentMethod
			,[Sender Name]			= sen.firstName + ISNULL(' ' + sen.middleName, '') + ISNULL(' ' + sen.lastName1, '') + ISNULL(' ' + sen.lastName2,'')
			,[Receiver Name]		= rec.firstName + ISNULL(' ' + rec.middleName, '') + ISNULL(' ' + rec.lastName1, '') + ISNULL(' ' + rec.lastName2, '')
		FROM remitTran rt WITH(NOLOCK)  				
		inner join tranSenders sen WITH(NOLOCK) ON rt.id=sen.tranId 
		inner join tranReceivers rec WITH(NOLOCK) ON rt.id=rec.tranId
		inner join bonusRedeemHistory red with(nolock) on red.customerId = sen.customerId
		where sen.membershipId = @membershipId
		and red.approvedDate between @fromDate and @toDate
		and red.prizeId = isnull(@prizeId,red.prizeId)
		and red.branchId = isnull(@branchId,red.branchId)

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL	
	   
		select 'Branch Name' head, case when @branchId is not null then (select agentName from agentMaster with(nolock) where agentId = @branchId)
												else 'All' end value
		union all
		SELECT  'From Date' head, @fromDate value 
		union all
		SELECT  'To Date' head, @toDate value
		union all
		select 'Gift Item' head,case when @prizeId is not null then (select dbo.FNAGetDataValue(@prizeId)) else 'All' end value
		union all
		select 'Order By' head, @orderBy value
		union all
		select 'Membership Id' head, @membershipId value
		SELECT 'Customer Bonus - TXN Report ' title
	end

	if @flag = 'red-agent'
	begin
		if @orderBy = 'CustomerName'
			set @orderBy = '[Sender Name]'
		if @orderBy = 'RedeemedDate'
			set @orderBy = '[Redeemed_Date]'
		if @orderBy = 'Branch'
			set @orderBy = '[Branch Name]'
		if @orderBy = 'GiftItem'
			set @orderBy = '[Gift Item]'

		set @table =
		'select 
				  [Ref. No]					= red.redeemId
				, [Membership Id]			= c.customerCardNo
				, [Agent]					= am.agentName
				, [Sender Name]				= ISNULL('' ''+ c.firstName,'''') + ISNULL('' '' + c.middleName, '''') + ISNULL('' '' + c.lastName, '''')  
				, [Sender (ID Type/No)]		= dbo.FNAGetDataValue(ci.idType)+'' - ''+ cast(ci.idNumber as varchar)
				, [Sender Contact]			= c.mobile
				, [Bonus Point_Total]		= cast(ISNULL(red.currentMilage, 0) as int)
				, [Bonus Point_Redeemed]	= convert(int,round(isnull(red.deductMilage,0),0)) 
				, [Bonus Point_Remaining]	= cast(ISNULL(red.currentMilage, 0) - isnull(red.deductMilage,0) as int)
				, [Gift Item]				= dbo.FNAGetDataValue(red.prizeId)
				, [Request_Date]			= red.createdDate
				, [Request_User]			= red.createdBy
				, [Approved_Date]			= red.approvedDate
				, [Approved_By]				= red.approvedBy
		from customerMaster c with(nolock) 
		inner join bonusRedeemHistory red with(nolock) on c.id = red.customerId
		left join customerIdentity ci with(nolock) on c.id = ci.customerId		
		left join agentMaster am with(nolock) on red.branchId = am.agentId
		where red.approvedDate between '''+@fromDate+''' and '''+@toDate+''''

		if @branchId is not null
			set @table = @table+ ' and red.branchId = '''+@branchId+'''' 

		if @membershipId is not null
			set @table = @table+ ' and c.customerCardNo = '''+@membershipId+'''' 

		if @prizeId is not null
			set @table = @table+ ' and red.prizeId = '''+@prizeId+'''' 

		SET @sql = 'SELECT 
							COUNT(*) AS TXNCOUNT
							,' + CAST(@pageSize AS VARCHAR) + ' PAGESIZE
							,' + CAST(@pageNumber AS VARCHAR) + ' PAGENUMBER					
						FROM (' + @table + ') x'
		PRINT @sql
		EXEC (@sql)

		SET @sql = '
				SELECT
					 *
				FROM (		
					SELECT 
						ROW_NUMBER() OVER (ORDER BY '+@orderBy+') AS [S.N],* 
					FROM (' + @table + ') x		
				) AS tmp WHERE tmp.[S.N] BETWEEN ' + CAST(((@pageNumber - 1) * @pageSize + 1) AS VARCHAR) + ' AND ' +  CAST(@pageNumber * @pageSize AS VARCHAR)
		
		PRINT @sql
		EXEC (@sql)	
	
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
	   
		select 'Branch Name' head, case when @branchId is not null then (select agentName from agentMaster with(nolock) where agentId = @branchId)
												else 'All' end value
		union all
		SELECT  'From Date' head, @fromDate value 
		union all
		SELECT  'To Date' head, @toDate value
		union all
		select 'Gift Item' head,case when @prizeId is not null then (select dbo.FNAGetDataValue(@prizeId)) else 'All' end value
		union all
		select 'Order By' head, @orderBy value
		union all
		select 'Membership Id' head, @membershipId value
		SELECT 'Customer Bonus Redeemed Report ' title
	end


	*/



GO
