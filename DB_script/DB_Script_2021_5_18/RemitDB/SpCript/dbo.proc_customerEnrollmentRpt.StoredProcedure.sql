USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_customerEnrollmentRpt]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXEC [proc_customerEnrollmentRpt] @flag = 'main', @user = 'admin', @fromDate = '2013-11-01',
 @toDate = '2013-11-17', @memId = null, @pageNumber = '1', @pageSize = '100'

*/
CREATE procEDURE [dbo].[proc_customerEnrollmentRpt]
	@flag				VARCHAR(20),
	@fromDate			VARCHAR(20)	= NULL,
	@toDate				VARCHAR(30) = NULL,
	@memId				VARCHAR(50)	= NULL,
	@agentId			VARCHAR(30)	= NULL,
	@branchId			VARCHAR(30)	= NULL,
	@pageNumber			INT			= NULL,
	@pageSize			INT			= NULL,
	@user				VARCHAR(50)	= NULL
AS 
SET NOCOUNT ON;
SET ANSI_NULLS ON;

	declare @sql varchar(max),@url varchar(max)
	IF @flag='main'
	BEGIN
			SET @url='"Reports.aspx?reportName=20164400&flag=main-customer&fromDate='+@fromDate+'&toDate='+@toDate+'&agent=''+ISNULL(cast(a.agentId as varchar),'''')+''&memId='+ISNULL(@memId,'')+'"'
			
			set @sql = 'select 
				[SN] = row_number() over(order by b.agentName) 
			   ,[Agent] = ''<span class = "link" onclick = ViewAMLDDLReport('+@url+');>'' + b.agentName	+ ''</span>''  		   
			   ,[No of Customer] = count(''x'') 
			from customerMaster a with(nolock) 
			inner join agentMaster b with(nolock) on a.agentId = b.agentId'
			
			set @sql = @sql+ ' where a.createdDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59'''

			if @agentId is not null and @branchId is null
				set @sql = @sql+ ' and a.agentId = '''+@agentId+''''

			if @branchId is not null
				set @sql = @sql+ ' and a.agentId = '''+@branchId+''''

			if @memId is not null
				set @sql = @sql+ ' and a.membershipId = '''+@memId+''''

			set @sql = @sql+ ' group by b.agentName,a.agentId' 

			print(@sql)
			exec(@sql)

			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'Agent' head, case when @agentId is null then 'All' else (select agentName from agentMaster with(nolock) where agentId = @agentId) end value
			union all
			SELECT 'Branch' head, case when @branchId is null then 'All' else (select agentName from agentMaster with(nolock) where agentId = @branchId) end value
			union all
			SELECT 'From Date' head, @fromDate value
			union all
			SELECT 'To Date' head, @toDate value
			union all
			SELECT 'Membeship ID' head, @memId  value

			SELECT 'Customer Enrollment Report' title
	END

	IF @flag='main-customer'
	BEGIN
			SET @url='"Reports.aspx?reportName=customerrpt&fromDate='+@fromDate+'&toDate='+@toDate+'&memId=''+ISNULL(cast(a.membershipId as varchar),'''')+''"'
			set @sql  = 'select 
				[Membership Id] = ''<span class = "link" onclick = ViewAMLDDLReport('+@url+');>'' + a.membershipId	+ ''</span>''  
			   ,[Customer Name] = ISNULL('' '' + a.firstName, '''') + ISNULL('' '' + a.middleName, '''') + ISNULL('' '' + a.lastName, '''') 
			   ,[County] = pCountry
			   ,[Zone] = pZone
			   ,[District] = pDistrict
			   ,[VDC/MNC] = pMunicipality
			   ,[Mobile] = mobile
			   ,[Email] = email
			   ,[Occupation] = occupation
			   ,[Date Of Birth] = dobEng
			   ,[Created By] = createdBy
			   ,[Created Date] = createdDate
			   ,[Approved By] = approvedBy
			   ,[Approved Date] = approvedDate 
			 from customerMaster a with(nolock)'
			 
			set @sql = @sql+ ' where a.createdDate between '''+@fromDate+''' and '''+@toDate+' 23:59:59'''

			if @agentId is not null and @branchId is null
				set @sql = @sql+ ' and a.agentId = '''+@agentId+''''

			if @branchId is not null
				set @sql = @sql+ ' and a.agentId = '''+@branchId+''''

			if @memId is not null
				set @sql = @sql+ ' and a.membershipId = '''+@memId+''''
			
			set @sql = @sql+ ' order by a.createdDate desc'
			exec(@sql)
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'Agent' head, case when @agentId is null then 'All' else (select agentName from agentMaster with(nolock) where agentId = @agentId) end value
			union all
			SELECT 'Branch' head, case when @branchId is null then 'All' else (select agentName from agentMaster with(nolock) where agentId = @branchId) end value
			union all
			SELECT 'From Date' head, @fromDate value
			union all
			SELECT 'To Date' head, @toDate value
			union all
			SELECT 'Membeship ID' head, @memId  value

			SELECT 'Customer Enrollment Report' title
	END

	IF @FLAG='main-detail'
	BEGIN
			--send transaction
			select 
				 [S.N.]    =  row_number()over(order by rt.id) 
				,[Control No]	= dbo.fnadecryptstring(rt.controlNo)
				,[Agent]		= sBranchName
				,[Payment Method] = paymentMethod
				,[Payout Amount] = pAmt
				,[Tran Status] = tranStatus
				,[TXN Date] = createdDate
				,[Paid Date] = paidDate
				,[Rec. Agent] = pAgentName
				,[Sender_Name] = isnull(sen.firstName,'')+' '+isnull(sen.middleName,'')+' '+isnull(sen.lastname1,'')+' '+isnull(sen.lastname2,'')
				,[Sender_Id Type] = sen.idType
				,[Sender_Id Number] = sen.idNUmber
				,[Receiver_Name] = isnull(rec.firstName,'')+' '+isnull(rec.middleName,'')+' '+isnull(rec.lastname1,'')+' '+isnull(rec.lastname2,'')
				,[Receiver_Id Type] = sen.idType
				,[Receiver_Id Number] = sen.idNUmber
				,[Transaction Type] = 'Send'
			from remitTran rt with(nolock) 
			inner join tranSenders sen with(nolock) on rt.id = sen.tranId
			inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
			where sen.membershipId = @memId 
			and rt.createddate between @fromDate and @toDate+' 23:59:59'

			union all

			--receiver transaction
			select
				 [S.N.]    =  row_number()over(order by rt.id) 
				 ,[Control No]		= dbo.fnadecryptstring(rt.controlNo)
				,[Agent]			= sBranchName
				,[Payment Type]		= paymentMethod
				,[Payout Amount]	= pAmt
				,[Tran Status]		= tranStatus
				,[TXN Date]			= createdDate
				,[Paid Date]		= paidDate
				,[Rec. Agent]		= pAgentName
				,[Sender_Name]		= isnull(sen.firstName,'')+' '+isnull(sen.middleName,'')+' '+isnull(sen.lastname1,'')+' '+isnull(sen.lastname2,'')
				,[Sender_Id Type]	= sen.idType
				,[Sender_Id Number] = sen.idNUmber
				,[Receiver_Name]	= isnull(rec.firstName,'')+' '+isnull(rec.middleName,'')+' '+isnull(rec.lastname1,'')+' '+isnull(rec.lastname2,'')
				,[Receiver_Id Type] = sen.idType
				,[Receiver_Id Number] = sen.idNUmber
				,[Transaction Type]		= 'Receive'
			 from remitTran rt with(nolock) 
			inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
			inner join tranSenders sen with(nolock) on rt.id = sen.tranId
			where sen.membershipId = @memId 
			and rt.paidDate between @fromDate and @toDate+' 23:59:59'
			
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'From Date' head,@FROMDATE value
			UNION ALL
			SELECT 'To Date' head,@TODATE value
			UNION ALL
			SELECT 'Membeship ID' head,@memId  value


			SELECT 'Customer Enrollment Report' title
	END

	IF @FLAG='detail'
	BEGIN
			--send transaction
			select 
				 [S.N.]    =  row_number()over(order by rt.id) 
				,[Control No]	= dbo.fnadecryptstring(rt.controlNo)
				,[Agent]		= sBranchName
				,[Payment Method] = paymentMethod
				,[Payout Amount] = pAmt
				,[Tran Status] = tranStatus
				,[TXN Date] = createdDate
				,[Paid Date] = paidDate
				,[Rec. Agent] = pAgentName
				,[Sender_Name] = isnull(sen.firstName,'')+' '+isnull(sen.middleName,'')+' '+isnull(sen.lastname1,'')+' '+isnull(sen.lastname2,'')
				,[Sender_Id Type] = sen.idType
				,[Sender_Id Number] = sen.idNUmber
				,[Receiver_Name] = isnull(rec.firstName,'')+' '+isnull(rec.middleName,'')+' '+isnull(rec.lastname1,'')+' '+isnull(rec.lastname2,'')
				,[Receiver_Id Type] = sen.idType
				,[Receiver_Id Number] = sen.idNUmber
				,[Transaction Type] = 'Send'
			from remitTran rt with(nolock) 
			inner join tranSenders sen with(nolock) on rt.id = sen.tranId
			inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
			where sen.membershipId = @memId 
			and rt.createddate between @fromDate and @toDate+' 23:59:59'

			union all

			--receiver transaction
			select
				 [S.N.]    =  row_number()over(order by rt.id) 
				 ,[Control No]		= dbo.fnadecryptstring(rt.controlNo)
				,[Agent]			= sBranchName
				,[Payment Type]		= paymentMethod
				,[Payout Amount]	= pAmt
				,[Tran Status]		= tranStatus
				,[TXN Date]			= createdDate
				,[Paid Date]		= paidDate
				,[Rec. Agent]		= pAgentName
				,[Sender_Name]		= isnull(sen.firstName,'')+' '+isnull(sen.middleName,'')+' '+isnull(sen.lastname1,'')+' '+isnull(sen.lastname2,'')
				,[Sender_Id Type]	= sen.idType
				,[Sender_Id Number] = sen.idNUmber
				,[Receiver_Name]	= isnull(rec.firstName,'')+' '+isnull(rec.middleName,'')+' '+isnull(rec.lastname1,'')+' '+isnull(rec.lastname2,'')
				,[Receiver_Id Type] = sen.idType
				,[Receiver_Id Number] = sen.idNUmber
				,[Transaction Type]		= 'Receive'
			 from remitTran rt with(nolock) 
			inner join tranReceivers rec with(nolock) on rt.id = rec.tranId
			inner join tranSenders sen with(nolock) on rt.id = sen.tranId
			where sen.membershipId = @memId 
			and rt.paidDate between @fromDate and @toDate+' 23:59:59'
			
			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'From Date' head,@FROMDATE value
			UNION ALL
			SELECT 'To Date' head,@TODATE value
			UNION ALL
			SELECT 'Membeship ID' head,@memId  value


			SELECT 'Customer Enrollment Report' title
	END


GO
