USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_ncellFreeSimCampaign]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[proc_ncellFreeSimCampaign]') AND TYPE IN (N'P', N'PC'))
	 DROP PROCEDURE [dbo].proc_ncellFreeSimCampaign

GO
*/
/*
	select * from ncellFreeSimCampaign
	truncate table ncellFreeSimCampaign
*/

CREATE proc [dbo].[proc_ncellFreeSimCampaign]
 	 @flag								VARCHAR(50)		= NULL
	,@user                              VARCHAR(30)		= NULL
	,@rowId								INT				= NULL
	,@controlNo							VARCHAR(50)		= NULL
	,@agentId		                    VARCHAR(50)		= NULL
	,@firstName							VARCHAR(200)	= NULL
	,@lastName							VARCHAR(200)	= NULL
	,@mobileNo							VARCHAR(50)		= NULL
	,@country							VARCHAR(50)		= NULL
	,@zone								VARCHAR(50)		= NULL
	,@district							VARCHAR(50)		= NULL
	,@idType							VARCHAR(100)	= NULL
	,@idNumber							VARCHAR(100)	= NULL
	,@idIssueDate						DATETIME		= NULL
	,@vdcMunicipality					VARCHAR(MAX)	= NULL
	,@contactNumber						VARCHAR(50)		= NULL
	,@agentName							VARCHAR(200)	= NULL	
	,@tranType							VARCHAR(10)		= NULL
	,@fromDate							VARCHAR(20)		= NULL
	,@fromTime							varchar(20)		= NULL
	,@toDate							VARCHAR(20)		= NULL
	,@toTime							VARCHAR(20)		= NULL
	,@filePath							VARCHAR(500)	= NULL
	,@sortBy                            VARCHAR(50)		= NULL
	,@sortOrder                         VARCHAR(5)		= NULL
	,@pageSize                          INT				= NULL
	,@pageNumber                        INT				= NULL

AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	CREATE TABLE #msg(errorCode INT, msg VARCHAR(100), id INT)
	DECLARE
		 @sql				VARCHAR(MAX)
		,@oldValue			VARCHAR(MAX)
		,@newValue			VARCHAR(MAX)
		,@module			VARCHAR(10)
		,@tableAlias		VARCHAR(100)
		,@logIdentifier		VARCHAR(50)
		,@logParamMod		VARCHAR(100)
		,@logParamMain		VARCHAR(100)
		,@table				VARCHAR(MAX)
		,@select_field_list	VARCHAR(MAX)
		,@extra_field_list	VARCHAR(MAX)
		,@sql_filter		VARCHAR(MAX)
		,@modType			VARCHAR(6)

		,@encryptControlNo	VARCHAR(100)
		,@tranId			INT
	SELECT
		 @logIdentifier = 'id'
		,@logParamMain = 'ncellFreeSimCampaign'
		,@logParamMod = 'ncellFreeSimCampaign'
		,@module = '40'
		,@tableAlias = 'Ncell Free Sim Campaign'	

	SET @controlNo = LTRIM(RTRIM(UPPER(@controlNo)))
	SELECT @encryptControlNo=dbo.FNAEncryptString(@controlNo)
		
	if @flag not in ('report','rptExport','rptSummary')
	begin
		IF @agentId IS NULL
			SELECT @agentId=agentId
				FROM applicationUsers WITH(NOLOCK) WHERE userName=@user
	end		
	
	IF @tranId IS NULL
		SELECT @tranId=id
			FROM remitTran WITH(NOLOCK) WHERE controlNo = @encryptControlNo
			
			--EXEC proc_ncellFreeSimCampaign @flag = 'c', @controlNo = '7167095679D', @agentId = '4616', @user = 'testagenta'
	IF @flag='c'
	BEGIN

		IF NOT EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE controlNo = @encryptControlNo)
		BEGIN
				EXEC proc_errorHandler 1, 'Transaction Not Found', @encryptControlNo
				RETURN
		END
		
		SELECT @encryptControlNo=dbo.FNAEncryptString(@controlNo)
		IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE sBranch = @agentId and controlNo = @encryptControlNo)
		BEGIN
				SET @tranType='Send'
		END
		IF EXISTS(SELECT 'X' FROM remitTran WITH(NOLOCK) WHERE pBranch = @agentId and controlNo = @encryptControlNo)
		BEGIN
				SET @tranType='Paid'
		END

		IF @tranType IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Transaction Not Found', @encryptControlNo
			RETURN
		END		
		IF EXISTS(SELECT 'X' FROM ncellFreeSimCampaign WITH(nolock) 
		where agentId=@agentId and tranType=@tranType and controlNo=@controlNo)
		BEGIN
			EXEC proc_errorHandler 1, 'Already Got Free SIM!', @encryptControlNo
			RETURN
		END	
		EXEC proc_errorHandler 0, 'Transaction Found!', @tranType
		RETURN
		
	END	

	IF @flag='LoadByTxn'
	BEGIN
		--EXEC proc_ncellFreeSimCampaign @flag = 'LoadByTxn', @controlNo = '7167095679D'
		DECLARE @fullname VARCHAR(150)='Ram', @pos INT, @stringB VARCHAR(100)
		IF @tranType='Send'
			SELECT @fullname=
			LTRIM(RTRIM(ISNULL(firstName,'')))+' '+LTRIM(RTRIM(ISNULL(middleName,'')))+ ' '+ LTRIM(RTRIM(ISNULL(lastName1,'')))+' '+LTRIM(RTRIM(ISNULL(lastName2,''))) 
			FROM tranSenders WITH(NOLOCK) WHERE tranId=@tranId
		ELSE
			SELECT @fullname=
			LTRIM(RTRIM(ISNULL(firstName,'')))+' '+LTRIM(RTRIM(ISNULL(middleName,'')))+ ' '+ LTRIM(RTRIM(ISNULL(lastName1,'')))+' '+LTRIM(RTRIM(ISNULL(lastName2,''))) 
			FROM tranReceivers WITH(NOLOCK) WHERE tranId=@tranId
		
		SELECT @fullname=UPPER(LTRIM(RTRIM(REPLACE(@fullname,'.',''))))
			
		IF CHARINDEX(' ',@fullname)=0
		BEGIN
			 SELECT @fullname  firstname , '' lastname1
		END
		ELSE 
		BEGIN
			SET @pos = LEN(@fullname) - CHARINDEX (' ',REVERSE(@fullname))
			SELECT  @stringB=	LTRIM(RTRIM(SUBSTRING(@fullname,@pos+2,50)))
			SELECT 	LTRIM(RTRIM(LEFT(@fullname,LEN(@fullname)-LEN(@stringB)))) firstName, @stringB lastName1
		END
					
	END
	
	IF @flag = 'i'
	BEGIN
		IF @user IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Your session has expired. Please try after a while', NULL
			RETURN
		END
		IF @agentId IS NULL
		BEGIN
			SELECT @agentId = agentId FROM applicationUsers WITH(NOLOCK) WHERE userName = @user
		END
		IF EXISTS(SELECT 'X' FROM ncellFreeSimCampaign WITH(NOLOCK) WHERE tranType = @tranType and controlNo = @controlNo)
		BEGIN
			EXEC proc_errorHandler 1, 'Already Got Free SIM!', @encryptControlNo
			RETURN
		END

		IF LEN(@mobileNo) <> 10
		BEGIN
			EXEC proc_errorHandler 1, 'Mobile Number must be of 10 digit', @encryptControlNo
			RETURN
		END
		IF EXISTS(SELECT 'X' FROM ncellFreeSimCampaign 
						WITH(NOLOCK) WHERE mobileNo=@mobileNo)
		BEGIN
			EXEC proc_errorHandler 1, 'Already Got This Mobile Number SIM!', @encryptControlNo
			RETURN
		END
		IF @idIssueDate IS NULL
		BEGIN
			EXEC proc_errorHandler 1, 'Id Issue Date missing', NULL
			RETURN
		END

		IF LEFT(@mobileNo,3) NOT IN ('980','981')
		BEGIN
			EXEC proc_errorHandler 1, 'Invalid Mobile (Sim) Number!', NULL
			RETURN
		END
		
		BEGIN TRANSACTION
			
			IF @contactNumber = '' OR @contactNumber IS NULL
			BEGIN 
				SELECT @contactNumber=LTRIM(RTRIM(a.agentPhone1)) 
					FROM agentMaster a WITH(NOLOCK) WHERE agentId=@agentId 
					
				IF @contactNumber IS NULL OR @contactNumber=''
					SELECT @contactNumber=LTRIM(RTRIM(a.agentMobile1)) 
						FROM agentMaster a WITH(NOLOCK) WHERE agentId=@agentId 
			END
			
			INSERT INTO ncellFreeSimCampaign (
				 controlNo
				,tranType
				,agentId
				,firstName
				,lastName
				,mobileNo
				,country
				,zone
				,district
				,idType
				,idNumber
				,idIssueDate
				,vdcMunicipality
				,contactNo
				,createdDate
				,createdBy
			)
			SELECT
				 @controlNo
				,@tranType
				,@agentId
				,@firstName
				,@lastName
				,@mobileNo
				,@country
				,@zone
				,@district
				,@idType
				,@idNumber
				,@idIssueDate
				,@vdcMunicipality
				,@contactNumber
				,dbo.FNAGetDateInNepalTZ()
				,@user			
					
			SET @modType = 'Insert'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId , @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to add new record.', @rowId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'SIM Detail has been added successfully.', @rowId
	END
	
	ELSE IF @flag = 'a'
	BEGIN
		SELECT 
		 a.id
		,a.firstName
		,a.lastName
		,a.controlNo
		,a.mobileNo
		,a.country
		,a.zone
		,a.district
		,a.idType
		,a.idNumber
		,CONVERT(VARCHAR,a.idIssueDate,101) idIssueDate
		,b.agentName agentName 
		,vdcMunicipality		
		FROM ncellFreeSimCampaign a WITH(NOLOCK) INNER JOIN agentMaster b WITH(NOLOCK) 
		ON a.agentId=b.agentId
		WHERE id=@rowId
	END

	ELSE IF @flag = 'u'
	BEGIN
		IF EXISTS(SELECT 'X' FROM ncellFreeSimCampaign WITH(NOLOCK) WHERE tranType = @tranType and controlNo = @controlNo)
		BEGIN
			EXEC proc_errorHandler 1, 'Already Got Free SIM!', @encryptControlNo
			RETURN
		END
		IF LEN(@mobileNo) <> 10
		BEGIN
			EXEC proc_errorHandler 1, 'Mobile Number must be of 10 digit', @encryptControlNo
			RETURN
		END
		BEGIN TRANSACTION
			UPDATE ncellFreeSimCampaign SET
				 firstName		= @firstName
				,lastName		= @lastName
				,mobileNo		= @mobileNo
				,country		= @country
				,zone			= @zone
				,district		= @district
				,idType			= @idType 
				,idNumber		= @idNumber
				,idIssueDate	= @idIssueDate
				,vdcMunicipality= @vdcMunicipality
				,modifiedBy		= @user
				,modifiedDate	= dbo.FNAGetDateInNepalTZ()
				
			WHERE id = @rowId
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier, @rowId, @newValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)			
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias, @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
				IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
				EXEC proc_errorHandler 1, 'Failed to update record.', @rowId
				RETURN
			END
		IF @@TRANCOUNT > 0
		COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'SIM Detail updated successfully.', @rowId
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		BEGIN TRANSACTION
			UPDATE ncellFreeSimCampaign SET
				 isDeleted = 'Y'
				,modifiedDate  = GETDATE()
				,modifiedBy = @user
			WHERE id = @rowId
			SET @modType = 'Delete'
			EXEC [dbo].proc_GetColumnToRow  @logParamMain, @logIdentifier,  @rowId, @oldValue OUTPUT
			INSERT INTO #msg(errorCode, msg, id)
			EXEC proc_applicationLogs 'i', NULL, @modType, @tableAlias,  @rowId, @user, @oldValue, @newValue
			IF EXISTS (SELECT 'x' FROM #msg WHERE errorCode <> '0')
			BEGIN
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
					EXEC proc_errorHandler 1, 'Failed to delete record.', @rowId
					RETURN
				END
			IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		EXEC proc_errorHandler 0, 'Record deleted successfully.', @rowId
	END
	
	ELSE IF @flag = 's'
	BEGIN
	
		IF @sortBy IS NULL
			SET @sortBy = 'id'

		IF @sortOrder IS NULL
			SET @sortOrder = 'ASC'

		SET @table = '(
			SELECT
				 main.id
				,main.controlNo
				,agMas.agentName
				,main.tranType
				,main.firstName 
				,main.lastName		
				,main.mobileNo			   
				,main.country
				,main.zone
				,main.district
				,main.idType
				,main.idNumber
				,main.idIssueDate
				,main.vdcMunicipality
				,main.contactNo
				,main.createdDate
				,main.createdBy
				FROM ncellFreeSimCampaign main WITH(NOLOCK) inner join agentMaster agMas with(nolock) on main.agentId=agMas.agentId
				WHERE ISNULL(main.isDeleted, '''')<>''Y''
					) x'

		SET @sql_filter = ''

		IF @controlNo IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND controlNo = ''' + @controlNo + ''''
		IF @mobileNo IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND mobileNo = ''' + @mobileNo + ''''
		IF @agentName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND agentName like ''%' + @agentName + '%'''			
		IF @firstName IS NOT NULL
			SET @sql_filter = @sql_filter + ' AND firstName like ''%' + @firstName + '%'''
			
		SET @select_field_list ='
				 id
				,controlNo
				,agentName
				,tranType
				,firstName 
				,lastName		
				,mobileNo			   
				,country
				,zone
				,district
				,idType
				,idNumber
				,idIssueDate
				,vdcMunicipality
				,contactNo
				,createdDate
				,createdBy
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

	ELSE IF @flag = 'eExport'
	BEGIN
			--exec [proc_ncellFreeSimCampaign] @flag='eExport',@fromDate='2013-02-11',@fromTime='00:00:00',@toDate='2013-02-11',@toTime='23:59:59'
			SET @fromDate=@fromDate+' '+@fromTime
			SET @toDate= @toDate+' '+@toTime 
			--MSISDN Issuing Country Region District Certificate Type Certificate No. Issue Date First Name Last Name contactNo Effective Date
			SELECT
				 agentName [Agent]
				,mobileNo [MSISDN]
				,country [Issuing Country]
				,zone [Region]
				,district [District]
				,idType [Certificate Type]
				,idNumber [Certificate No.]
				,convert(varchar,idIssueDate,101) [Issue Date]
				,firstName [First Name]
				,lastName [Last Name]				
				,contactNo [contactNo]
				,convert(varchar,a.createdDate,101) [Effective Date]
				 FROM ncellFreeSimCampaign a WITH(NOLOCK) LEFT JOIN agentMaster b WITH(NOLOCK) ON a.agentId=b.agentId				 
			WHERE a.createdDate BETWEEN @fromDate AND @toDate

			--> ### UPDATING DATA EXTRACT DATE 
			UPDATE ncellFreeSimCampaign SET 
					extractBy	=	@user,
					extractDate =	dbo.FNAGetDateInNepalTZ() 
			WHERE createdDate BETWEEN @fromDate AND @toDate 
			AND extractDate IS NULL  
		
	END
	
	ELSE IF @flag = 'report'
	BEGIN

			SET @toDate=@toDate + ' 23:59:59'			
			SELECT ROW_NUMBER()OVER(ORDER BY agentName) [S.N.] ,UPPER(agentName) [AgentName],SUM(SD) [SendDomestic] ,SUM(PD) [PaidDomestic] ,SUM(PIN)[PaidInternational]
			,SUM(MSD) [SimSendDomestic],SUM(MPD) [SimPaidDomestic],SUM(MPI) [SimPaidInterantional]
			,SUM(SD)+SUM(PD)+ SUM(PIN) [TotalTxn]
			,SUM(MSD)+SUM(MPD)+ SUM(MPI) [TotalSim]

			FROM(

					SELECT sBranch,COUNT(CONTROLNO) SD ,0 PD,0 PIN,0 MSD,0 MPD,0 MPI  FROM remitTran WITH (NOLOCK)
					WHERE  createdDate BETWEEN @fromDate AND @toDate 
					AND tranType='D'
					AND sBranch=ISNULL(@agentId,sBranch)
					GROUP BY sBranch

					UNION ALL

					SELECT pBranch,0,COUNT(CONTROLNO),0,0,0,0  FROM remitTran WITH (NOLOCK)
					WHERE  paidDate BETWEEN @fromDate AND @toDate 
					AND tranType='D'
					AND pBranch=ISNULL(@agentId,pBranch)
					GROUP BY pBranch

					UNION ALL

					SELECT pBranch,0,0,COUNT(CONTROLNO),0,0,0 TXN FROM remitTran WITH (NOLOCK)
					WHERE  paidDate BETWEEN @fromDate AND @toDate 
					AND tranType='I'
					AND pBranch=ISNULL(@agentId,pBranch)
					GROUP BY pBranch

					UNION ALL

					SELECT AGENTID,0,0,0,COUNT(MOBILENO),0,0 FROM NcellFreeSimCampaign WITH (NOLOCK)
					WHERE createdDate BETWEEN @fromDate AND @toDate 
					AND tranType='SEND'
					AND AGENTID=ISNULL(@agentId,AGENTID)
					GROUP BY AGENTID

					UNION ALL

					SELECT AGENTID,0,0,0,0,COUNT(MOBILENO),0 FROM NcellFreeSimCampaign WITH (NOLOCK)
					WHERE createdDate BETWEEN @fromDate AND @toDate 
					AND tranType='PAID'
					AND RIGHT(CONTROLNO,1)='D'
					AND AGENTID=ISNULL(@agentId,AGENTID)
					GROUP BY AGENTID

					UNION ALL

					SELECT AGENTID,0,0,0,0,0,COUNT(MOBILENO) FROM NcellFreeSimCampaign WITH (NOLOCK)
					WHERE createdDate BETWEEN @fromDate AND @toDate 
					AND tranType='PAID'
					AND RIGHT(CONTROLNO,1)<>'D'
					AND AGENTID=ISNULL(@agentId,AGENTID)
					GROUP BY AGENTID

			) X INNER JOIN  agentMaster Y WITH(NOLOCK) ON X.sBranch=Y.agentId
			INNER JOIN
			(
				SELECT DISTINCT agentid FROM NcellFreeSimCampaign 
			)mas ON mas.agentId=Y.agentId
			--AND (ISNULL(agentType,0) NOT IN ('2904','2905') OR parentId in (2054,4618,2293,2271,3067,2117))
			GROUP BY AGENTNAME
			ORDER BY AGENTNAME	
	EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
	
	SELECT 'Agent Name' head, case when @agentId Is null then 'All' else (select agentName from agentMaster with(nolock) where agentId=@agentId)end value

	UNION ALL
	
	SELECT 'From Date' head,@fromDate value

	UNION ALL
	
	SELECT 'To Date' head,@toDate value	

	SELECT 'Free Ncell Sim Registration Report' title	
	END
	
	ELSE IF @flag = 'rptExport'
	BEGIN

			SET @toDate=@toDate + ' 23:59:59'			
			SELECT ROW_NUMBER()OVER(ORDER BY agentName) [S.N.] ,UPPER(agentName) [AgentName],SUM(SD) [SendDomestic] ,SUM(PD) [PaidDomestic] ,SUM(PIN)[PaidInternational]
			,SUM(MSD) [SimSendDomestic],SUM(MPD) [SimPaidDomestic],SUM(MPI) [SimPaidInterantional]
			,SUM(SD)+SUM(PD)+ SUM(PIN) [TotalTxn]
			,SUM(MSD)+SUM(MPD)+ SUM(MPI) [TotalSim]

			FROM(

					SELECT sAgent,COUNT(CONTROLNO) SD ,0 PD,0 PIN,0 MSD,0 MPD,0 MPI  FROM remitTran WITH (NOLOCK)
					WHERE  createdDate BETWEEN @fromDate AND @toDate 
					AND tranType='D'
					AND sAgent=ISNULL(@agentId,sAgent)
					GROUP BY sAgent

					UNION ALL

					SELECT PAgent,0,COUNT(CONTROLNO),0,0,0,0  FROM remitTran WITH (NOLOCK)
					WHERE  paidDate BETWEEN @fromDate AND @toDate 
					AND tranType='D'
					AND pAgent=ISNULL(@agentId,pAgent)
					GROUP BY PAgent

					UNION ALL

					SELECT PAgent,0,0,COUNT(CONTROLNO),0,0,0 TXN FROM remitTran WITH (NOLOCK)
					WHERE  paidDate BETWEEN @fromDate AND @toDate 
					AND tranType='I'
					AND pAgent=ISNULL(@agentId,pAgent)
					GROUP BY PAgent

					UNION ALL

					SELECT AGENTID,0,0,0,COUNT(MOBILENO),0,0 FROM NcellFreeSimCampaign WITH (NOLOCK)
					WHERE createdDate BETWEEN @fromDate AND @toDate 
					AND tranType='SEND'
					AND AGENTID=ISNULL(@agentId,AGENTID)
					GROUP BY AGENTID

					UNION ALL

					SELECT AGENTID,0,0,0,0,COUNT(MOBILENO),0 FROM NcellFreeSimCampaign WITH (NOLOCK)
					WHERE createdDate BETWEEN @fromDate AND @toDate 
					AND tranType='PAID'
					AND RIGHT(CONTROLNO,1)='D'
					AND AGENTID=ISNULL(@agentId,AGENTID)
					GROUP BY AGENTID

					UNION ALL

					SELECT AGENTID,0,0,0,0,0,COUNT(MOBILENO) FROM NcellFreeSimCampaign WITH (NOLOCK)
					WHERE createdDate BETWEEN @fromDate AND @toDate 
					AND tranType='PAID'
					AND RIGHT(CONTROLNO,1)<>'D'
					AND AGENTID=ISNULL(@agentId,AGENTID)
					GROUP BY AGENTID

			) X INNER JOIN  agentMaster Y WITH(NOLOCK) ON X.sAgent=Y.agentId	
			INNER JOIN
			(
				SELECT DISTINCT agentid FROM NcellFreeSimCampaign 
			)mas ON mas.agentId=Y.agentId	
			--AND (ISNULL(agentType,0) NOT IN ('2904','2905') OR parentId in (2054,4618,2293,2271,3067,2117))
			GROUP BY AGENTNAME
			ORDER BY AGENTNAME
			
			--SELECT * FROM agentMaster WHERE agentId=2054
			--SELECT * FROM agentMaster WHERE agentName LIKE '%GRAN%' AND agentType=2903
	END
	
	ELSE IF @flag = 'rptSummary'
	BEGIN
	
		--SET @toDate=@toDate + ' 23:59:59'
		
		SELECT
			[SN]= ROW_NUMBER() over(order by B.agentName),
			[Agent Name] = B.agentName,
			SUM(IssuedQty) [Issued <br/> Qty],
			SUM([RecQty]) [Registered <br/> Qty],
			SUM(IssuedQty)-SUM([RecQty]) [Stock <br/> Agent],
			SUM([ActQty]) [Activated <br/> Qty],
			SUM([RecQty])-SUM([ActQty]) [Remain For <br/> Activation],
			SUM([DocRecQty]) [Doc Received<br/> Qty],
			SUM([DocSentQty]) [Doc Sent<br/> Qty],
			SUM([ActRejQty]) [Activation<br/> Rejected Qty],
			SUM([DocSentRejQty]) [Doc Sent<br/> Rejected Qty]
		FROM 
		(
			SELECT agentId,
				COUNT(mobile) IssuedQty,
				'' AS [RecQty],
				''[ActQty],
				'' [DocRecQty],
				'' [DocSentQty],
				'' [ActRejQty],
				'' [DocSentRejQty]
			FROM DistributionOfSIMToAgent WITH(NOLOCK) 
			WHERE agentId=ISNULL(@agentId,agentId)
			GROUP BY agentId

			UNION ALL
			
			SELECT agentId,
				'' IssuedQty,
				COUNT(agentId) [RecQty],
				'' [ActQty],
				'' [DocRecQty],
				'' [DocSentQty],
				'' [ActRejQty],
				'' [DocSentRejQty]
			FROM NcellFreeSimCampaign WITH(NOLOCK)
			WHERE createdDate BETWEEN @fromDate AND @toDate 
			AND agentId=ISNULL(@agentId,agentId)
			GROUP BY agentId

			UNION ALL
			
			SELECT agentId,
				'' [IssuedQty],
				'' [RecQty],
				COUNT(agentId) [ActQty],
				'' [DocRecQty],
				'' [DocSentQty],
				'' [ActRejQty],
				'' [DocSentRejQty]
			FROM NcellFreeSimCampaign WITH(NOLOCK)
			WHERE activatedDate IS NOT NULL 
			AND createdDate BETWEEN @fromDate AND @toDate 
			AND agentId=ISNULL(@agentId,agentId)
			GROUP BY agentId

			UNION ALL
			
			SELECT agentId,
				'' [IssuedQty],
				'' [RecQty],
				'' [ActQty],
				COUNT(agentId) [DocRecQty],
				'' [DocSentQty],
				'' [ActRejQty],
				'' [DocSentRejQty]
			FROM NcellFreeSimCampaign WITH(NOLOCK)
			WHERE docReceivedDate IS NOT NULL
			AND createdDate BETWEEN @fromDate AND @toDate 
			AND agentId=ISNULL(@agentId,agentId)
			GROUP BY agentId

			UNION ALL
			
			SELECT agentId,
				'' [IssuedQty],
				'' [RecQty],
				'' [ActQty],
				'' [DocRecQty],
				COUNT(agentId) [DocSentQty],
				'' [ActRejQty],
				'' [DocSentRejQty]
			FROM NcellFreeSimCampaign WITH(NOLOCK)
			WHERE docSendDate IS NOT NULL
			AND createdDate BETWEEN @fromDate AND @toDate 
			AND agentId=ISNULL(@agentId,agentId)
			GROUP BY agentId
			
					
			UNION ALL
			
			SELECT agentId,
				'' [IssuedQty],
				'' [RecQty],
				'' [ActQty],
				'' [DocRecQty],
				'' [DocSentQty],
				COUNT(agentId) [ActRejQty],
				'' [DocSentRejQty]
			FROM NcellFreeSimCampaign WITH(NOLOCK)
			WHERE activatedDate IS NOT NULL 
			AND docReceivedDate IS NULL 
			AND rejectedDate IS NOT NULL 
			AND createdDate BETWEEN @fromDate AND @toDate 
			AND agentId=ISNULL(@agentId,agentId)		
			GROUP BY agentId
			
			UNION ALL
			
			SELECT agentId,
				'' [IssuedQty],
				'' [RecQty],
				'' [ActQty],
				'' [DocRecQty],
				'' [DocSentQty],
				'' [ActRejQty],
				COUNT(agentId) [DocSentRejQty]
			FROM NcellFreeSimCampaign WITH(NOLOCK)
			WHERE docSendDate IS NOT NULL 
			AND docReceivedDate IS NOT NULL
			AND activatedDate IS NOT NULL
			AND rejectedDate IS NOT NULL 
			AND createdDate BETWEEN @fromDate AND @toDate 
			AND agentId=ISNULL(@agentId,agentId)		
			GROUP BY agentId
		)A INNER JOIN AGENTMASTER B WITH(NOLOCK) ON A.agentId=B.agentId
		GROUP BY B.agentName
		ORDER BY B.agentName
		
		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
		
		SELECT 'Agent Name' head, 
				CASE WHEN @agentId IS NULL THEN 'All' ELSE 
					(SELECT agentName FROM agentMaster WITH(NOLOCK) WHERE agentId=@agentId)END VALUE

		UNION ALL
		
		SELECT 'From Date' head,@fromDate VALUE

		UNION ALL
		
		SELECT 'To Date' head,@toDate VALUE	

		SELECT 'Ncell SIM Summary Report' title	
	END

	
END TRY
BEGIN CATCH
     IF @@TRANCOUNT > 0
     ROLLBACK TRANSACTION
     DECLARE @errorMessage VARCHAR(MAX)
     SET @errorMessage = ERROR_MESSAGE()
     EXEC proc_errorHandler 1, @errorMessage, @rowId
END CATCH



GO
