-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Gagan>
-- Create date: <2019/04/30,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE PROC_API_STATE_SETUP
		@FLAG				VARCHAR(30)
	--grid parameters
	,@user				VARCHAR(50)		= NULL
	,@pageSize			VARCHAR(50)		= NULL
	,@pageNumber		VARCHAR(50)		= NULL
	,@sortBy			VARCHAR(50)		= NULL
	,@sortOrder			VARCHAR(50)		= NULL
	,@API_PARTNER		INT				= NULL
	,@PAYMENT_TYPE		INT				= NULL
	,@stateId			NVARCHAR(30)	= NULL 
	,@cityId			VARCHAR(30)		= NULL 
	,@CITY_NAME			VARCHAR(30)		= NULL 
	,@TOWN_NAME			VARCHAR(30)		= NULL 
	,@isActive			VARCHAR(5)		= NULL
	,@rowId				VARCHAR(10)		= NULL
	,@XML				NVARCHAR(MAX)	= NULL
	,@BANK_COUNTRY		VARCHAR(50) 	= NULL 
	,@API_PARTNER_ID	INT				= NULL 
	,@STATE_COUNTRY		VARCHAR(50)		= NULL 
	,@CITY_COUNTRY		VARCHAR(50)		= NULL 
	,@TOWN_COUNTRY		VARCHAR(50)		= NULL
	,@COUNTRY_ID		VARCHAR(50)		= NULL
	
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
		DECLARE  @table				VARCHAR(MAX)
			,@select_field_list	VARCHAR(MAX)
			,@extra_field_list	VARCHAR(MAX)
			,@sql_filter		VARCHAR(MAX)
			,@_stateId			BIGINT
			,@_cityId			BIGINT
			DECLARE @NEW_RECORD INT, @MSG VARCHAR(200)
	IF @FLAG = 'S'
	BEGIN
		SET @sortBy = 'STATE_ID'
		SET @sortOrder = 'desc'

		SET @table = '( SELECT STATE_ID,
								API_PARTNER = AM.AGENTNAME,
								API_PARTNER_ID,
								STATE_NAME,
								STATE_CODE,
								STATE_COUNTRY,
								PAYMENT_TYPE =CASE WHEN ISNULL(typeTitle,'''')='''' THEN ''All'' ELSE SM.typeTitle END,
								PAYMENT_TYPE_ID,
								IS_ACTIVE = CASE WHEN IS_ACTIVE = 1 THEN ''YES'' ELSE ''NO'' END
			 			FROM dbo.API_STATE_LIST AB(NOLOCK)
						INNER JOIN AGENTMASTER AM(NOLOCK) ON AM.AGENTID = AB.API_PARTNER_ID AND AM.PARENTID = 0
						LEFT JOIN SERVICETYPEMASTER SM(NOLOCK) ON SM.serviceTypeId = AB.PAYMENT_TYPE_ID '

		SET @sql_filter = ''
		SET @table = @table + ')x'
		
		IF @API_PARTNER <> 0
			SET @sql_filter = @sql_filter+' AND API_PARTNER_ID =  '''+CAST(@API_PARTNER AS VARCHAR)+''''

		IF @PAYMENT_TYPE <> 0
			SET @sql_filter = @sql_filter+' AND PAYMENT_TYPE_ID =  '''+CAST(@PAYMENT_TYPE AS VARCHAR)+''''

		SET @select_field_list  = '
				STATE_ID,API_PARTNER,STATE_NAME,STATE_CODE,STATE_COUNTRY,IS_ACTIVE,PAYMENT_TYPE,API_PARTNER_ID'
				 	
		EXEC dbo.proc_paging @table, @sql_filter, @select_field_list, @extra_field_list
				, @sortBy, @sortOrder, @pageSize, @pageNumber
	END
	ELSE IF @FLAG = 'S-City'
	BEGIN
		SET @sortBy = 'CITY_ID'
		SET @sortOrder = 'desc'

		SET @table = '( SELECT  CITY_ID,
								SL.STATE_NAME,
								CITY_NAME,
								CITY_CODE,
								CITY_COUNTRY,
								PAYMENT_TYPE =CASE WHEN ISNULL(typeTitle,'''')='''' THEN ''All'' ELSE SM.typeTitle END,
								CL.PAYMENT_TYPE_ID,
								IS_ACTIVE = CASE WHEN CL.IS_ACTIVE = 1 THEN ''YES'' ELSE ''NO'' END
			 			FROM dbo.API_CITY_LIST CL(NOLOCK)
						LEFT JOIN SERVICETYPEMASTER SM(NOLOCK) ON SM.serviceTypeId = CL.PAYMENT_TYPE_ID
						INNER JOIN dbo.API_STATE_LIST SL(NOLOCK) ON SL.STATE_ID = CL.STATE_ID
						WHERE CL.STATE_ID = '''+@stateId +''''

		SET @sql_filter = ''
		SET @table = @table + ')x'
		
		IF @CITY_NAME <> ''
			SET @sql_filter = @sql_filter+' AND CITY_NAME =  ''%'+CAST(@CITY_NAME AS VARCHAR)+'%'''

		--IF @PAYMENT_TYPE <> 0
		--	SET @sql_filter = @sql_filter+' AND PAYMENT_TYPE_ID =  '''+CAST(@PAYMENT_TYPE AS VARCHAR)+''''

		SET @select_field_list  = '
				CITY_ID,STATE_NAME,CITY_NAME,CITY_CODE,CITY_COUNTRY,IS_ACTIVE,PAYMENT_TYPE'
				 	
		EXEC dbo.proc_paging @table, @sql_filter, @select_field_list, @extra_field_list
				, @sortBy, @sortOrder, @pageSize, @pageNumber
	END
	ELSE IF @FLAG = 'S-Town'
	BEGIN
		SET @sortBy = 'TOWN_ID'
		SET @sortOrder = 'desc'

		SET @table = '( SELECT  TOWN_ID,
								TOWN_NAME,
								TOWN_CODE,
								TOWN_COUNTRY,
								PAYMENT_TYPE = CASE WHEN ISNULL(typeTitle,'''')='''' THEN ''All'' ELSE SM.typeTitle END,
								IS_ACTIVE = CASE WHEN TL.IS_ACTIVE = 1 THEN ''YES'' ELSE ''NO'' END
			 			FROM dbo.API_TOWN_LIST TL(NOLOCK)
						INNER JOIN dbo.API_CITY_LIST CL(NOLOCK) ON CL.CITY_ID = TL.CITY_ID
						INNER JOIN SERVICETYPEMASTER SM(NOLOCK) ON SM.serviceTypeId = TL.PAYMENT_TYPE_ID
						WHERE TL.CITY_ID = '''+@cityId+''''

		SET @sql_filter = ''
		SET @table = @table + ')x'
		
		IF @TOWN_NAME <> ''
			SET @sql_filter = @sql_filter+' AND TOWN_NAME LIKE  ''%'+CAST(@TOWN_NAME AS VARCHAR)+'%'''

		--IF @PAYMENT_TYPE <> 0
		--	SET @sql_filter = @sql_filter+' AND PAYMENT_TYPE_ID =  '''+CAST(@PAYMENT_TYPE AS VARCHAR)+''''

		SET @select_field_list  = '
				 TOWN_ID,TOWN_NAME,TOWN_CODE,TOWN_COUNTRY,IS_ACTIVE,PAYMENT_TYPE'
				 	
		EXEC dbo.proc_paging @table, @sql_filter, @select_field_list, @extra_field_list
				, @sortBy, @sortOrder, @pageSize, @pageNumber
	END
	ELSE IF @FLAG = 'enable-disable-state'
	BEGIN
		IF @isActive = 'YES'
		BEGIN
			update dbo.API_STATE_LIST set  IS_ACTIVE = 0 where STATE_ID = @rowId
			SELECT '0' ErrorCode , 'Record has been disabled successfully.' Msg , @rowId id	 
		END
		ELSE
		BEGIN
			update dbo.API_STATE_LIST set  IS_ACTIVE = 1 where STATE_ID = @rowId

			SELECT '0' ErrorCode , 'Record has been enabled successfully.' Msg , @rowId id	 
		END
	END
	ELSE IF @FLAG = 'enable-disable-city'
	BEGIN
		IF @isActive = 'YES'
		BEGIN
			update dbo.API_CITY_LIST set  IS_ACTIVE = 0 where CITY_ID = @rowId
			SELECT '0' ErrorCode , 'Record has been disabled successfully.' Msg , @rowId id	 
		END
		ELSE
		BEGIN
			update dbo.API_CITY_LIST set  IS_ACTIVE = 1 where CITY_ID = @rowId

			SELECT '0' ErrorCode , 'Record has been enabled successfully.' Msg , @rowId id	 
		END
	END
	ELSE IF @FLAG = 'enable-disable-town'
	BEGIN
		IF @isActive = 'YES'
		BEGIN
			update dbo.API_TOWN_LIST set  IS_ACTIVE = 0 where TOWN_ID = @rowId
			SELECT '0' ErrorCode , 'Record has been disabled successfully.' Msg , @rowId id	 
		END
		ELSE
		BEGIN
			update dbo.API_TOWN_LIST set  IS_ACTIVE = 1 where TOWN_ID = @rowId

			SELECT '0' ErrorCode , 'Record has been enabled successfully.' Msg , @rowId id	 
		END
	END
	ELSE IF @FLAG = 'syncState'
	BEGIN
		IF OBJECT_ID('tempdb..#apiStates') IS NOT NULL DROP TABLE #txnDetails
		
		DECLARE @XMLDATA XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('(Id)[1]','VARCHAR(20)') AS 'Id'
					,p.value('(Name)[1]','VARCHAR(150)') AS 'Name'
		INTO #apiStates
		FROM @XMLDATA.nodes('/ArrayOfStateResponse/StateResponse') AS apiStates(p)

		--DELETE EXISTING DATA FROM TEMP TABLE
		DELETE TMP 
		FROM #apiStates TMP
		INNER JOIN dbo.API_STATE_LIST ASL(NOLOCK) ON ASL.STATE_CODE = TMP.Id
		WHERE STATE_COUNTRY = @STATE_COUNTRY
		AND API_PARTNER_ID = @API_PARTNER_ID

		--INSERT NEW DATA INTO MAIN TABLE
		INSERT INTO API_STATE_LIST (API_PARTNER_ID,STATE_NAME,STATE_CODE,STATE_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE)
		SELECT @API_PARTNER_ID,Name,Id,@STATE_COUNTRY,0,1 
		FROM #apiStates

		SELECT @NEW_RECORD = COUNT(1) FROM #apiStates
		SET @MSG ='State synced successfully.' + CAST(@NEW_RECORD AS VARCHAR) + ' new records inserted in system.'

		EXEC proc_errorHandler 0, @MSG, NULL
	END
	ELSE IF @FLAG = 'syncCity'
	BEGIN
		IF OBJECT_ID('tempdb..#apiCities') IS NOT NULL DROP TABLE #txnDetails
		
		DECLARE @XMLDATA1 XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('(Id)[1]','VARCHAR(20)') AS 'Id'
					,p.value('(Name)[1]','VARCHAR(150)') AS 'Name'
		INTO #apiCities
		FROM @XMLDATA1.nodes('/ArrayOfCityResponse/CityResponse') AS apiCities(p)

		--DELETE EXISTING DATA FROM TEMP TABLE
		DELETE TMP 
		FROM #apiCities TMP
		INNER JOIN dbo.API_CITY_LIST ACL(NOLOCK) ON ACL.CITY_CODE = TMP.Id
		WHERE CITY_COUNTRY = @CITY_COUNTRY
		AND ACL.STATE_ID = @stateId

		--INSERT NEW DATA INTO MAIN TABLE
		INSERT INTO API_CITY_LIST (STATE_ID,CITY_NAME,CITY_CODE,CITY_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE)
		SELECT @stateId,Name,Id,@CITY_COUNTRY,0,1 
		FROM #apiCities

		SELECT @NEW_RECORD = COUNT(1) FROM #apiCities
		SET @MSG ='State cities successfully.' + CAST(@NEW_RECORD AS VARCHAR) + ' new records inserted in system.'

		EXEC proc_errorHandler 0, @MSG, NULL
	END
	ELSE IF @FLAG = 'syncTown'
	BEGIN
		IF OBJECT_ID('tempdb..#apiTowns') IS NOT NULL DROP TABLE #txnDetails
		
		DECLARE @XMLDATA2 XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('(Id)[1]','VARCHAR(20)') AS 'Id'
					,p.value('(Name)[1]','VARCHAR(150)') AS 'Name'
		INTO #apiTowns
		FROM @XMLDATA2.nodes('/ArrayOfTownResponse/TownResponse') AS apiTowns(p)

		--DELETE EXISTING DATA FROM TEMP TABLE
		DELETE TMP 
		FROM #apiTowns TMP
		INNER JOIN dbo.API_TOWN_LIST ATL(NOLOCK) ON ATL.TOWN_CODE = TMP.Id
		WHERE TOWN_COUNTRY = @TOWN_COUNTRY
		AND ATL.CITY_ID = @cityId
		AND ATL.STATE_ID = @stateId
		--HERE cityId and stateId are our primary keys of city and state table

		--INSERT NEW DATA INTO MAIN TABLE
		INSERT INTO API_TOWN_LIST (STATE_ID,CITY_ID,TOWN_NAME,TOWN_CODE,TOWN_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE)
		SELECT @stateId,@cityId,Name,Id,@TOWN_COUNTRY,0,1 
		FROM #apiTowns

		SELECT @NEW_RECORD = COUNT(1) FROM #apiTowns
		SET @MSG ='State towns successfully.' + CAST(@NEW_RECORD AS VARCHAR) + ' new records inserted in system.'

		EXEC proc_errorHandler 0, @MSG, NULL
	END
	
	IF @FLAG = 'syncCityByscheduler'
	BEGIN
		IF OBJECT_ID('tempdb..#apiCitiesscheduler') IS NOT NULL DROP TABLE #txnDetails
		
		DECLARE @XMLDATAscheduler XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('(Id)[1]','VARCHAR(20)') AS 'Id'
					,p.value('(Name)[1]','VARCHAR(150)') AS 'Name'
		INTO #apiCitiesscheduler
		FROM @XMLDATAscheduler.nodes('/ArrayOfCity/City') AS apiCities(p)

		--DELETE EXISTING DATA FROM TEMP TABLE
		DELETE TMP 
		FROM #apiCitiesscheduler TMP
		INNER JOIN dbo.API_CITY_LIST ACL(NOLOCK) ON ACL.CITY_CODE = TMP.Id
		WHERE CITY_COUNTRY = @CITY_COUNTRY
		--AND ACL.STATE_ID = @stateId
		SELECT @_stateId=STATE_ID FROM dbo.API_STATE_LIST WHERE STATE_CODE=@stateId
		IF @_stateId IS NOT NULL
		BEGIN
			INSERT INTO API_CITY_LIST (STATE_ID,CITY_NAME,CITY_CODE,CITY_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE)
			SELECT @_stateId,[Name],Id,@CITY_COUNTRY,0,1 
			FROM #apiCitiesscheduler

			SELECT @NEW_RECORD = COUNT(1) FROM #apiCitiesscheduler
			SET @MSG ='Cities successfully.' + CAST(@NEW_RECORD AS VARCHAR) + ' new records inserted in system.'
			EXEC proc_errorHandler 0, @MSG, NULL
			RETURN;
		END
		ELSE
		BEGIN
		    SET @MSG ='State information not found ! at state code : ' + @stateId
		END
		--INSERT NEW DATA INTO MAIN TABLE

		EXEC proc_errorHandler 0, @MSG, NULL
	END
	IF @FLAG = 'syncTownscheduler'
	BEGIN
		IF OBJECT_ID('tempdb..#apiTownsscheduler') IS NOT NULL DROP TABLE #txnDetails
		
		DECLARE @XMLDATATownscheduler XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('(Id)[1]','VARCHAR(20)') AS 'Id'
					,p.value('(Name)[1]','VARCHAR(150)') AS 'Name'
		INTO #apiTownsscheduler
		FROM @XMLDATATownscheduler.nodes('/ArrayOfTownResponse/TownResponse') AS apiTowns(p)

		--DELETE EXISTING DATA FROM TEMP TABLE
		DELETE TMP 
		FROM #apiTownsscheduler TMP
		INNER JOIN dbo.API_TOWN_LIST ATL(NOLOCK) ON ATL.TOWN_CODE = TMP.Id
		WHERE TOWN_COUNTRY = @TOWN_COUNTRY
		--HERE cityId and stateId are our primary keys of city and state table
		SELECT @_stateId=STATE_ID FROM dbo.API_STATE_LIST WHERE STATE_CODE=@stateId
		IF @_stateId IS NULL
		BEGIN
		    SET @MSG ='State information not found ! at state code : ' + @stateId
			EXEC proc_errorHandler 1, @MSG, NULL
			RETURN;
		END
		SELECT @_cityId=CITY_ID FROM dbo.API_CITY_LIST WHERE CITY_CODE=@cityId
		IF @_cityId IS NULL
		BEGIN
		    SET @MSG ='City information not found ! at city code : ' + @cityId
			EXEC proc_errorHandler 1, @MSG, NULL
			RETURN;
		END
		--INSERT NEW DATA INTO MAIN TABLE
		INSERT INTO API_TOWN_LIST (STATE_ID,CITY_ID,TOWN_NAME,TOWN_CODE,TOWN_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE)
		SELECT @_stateId,@_cityId,Name,Id,@TOWN_COUNTRY,0,1 
		FROM #apiTownsscheduler

		SELECT @NEW_RECORD = COUNT(1) FROM #apiTownsscheduler
		SET @MSG ='Towns successfully.' + CAST(@NEW_RECORD AS VARCHAR) + ' new records inserted in system.'

		EXEC proc_errorHandler 0, @MSG, NULL
	END


	ELSE IF @flag= 'getDetailsOfState'
	BEGIN 
		SELECT CM.countryCode,cm.countryName,ASL.STATE_CODE,ASL.API_PARTNER_ID,ASL.STATE_ID FROM dbo.API_STATE_LIST ASL(NOLOCK)
		INNER JOIN dbo.countryMaster CM(NOLOCK) ON ASL.STATE_COUNTRY = CM.countryName
		WHERE ASL.STATE_ID = @rowId

	END
	ELSE IF @flag= 'getDetailsOfCity'
	BEGIN 
		SELECT CM.countryCode,cm.countryName,ACL.CITY_CODE,ACL.CITY_ID,ASL.API_PARTNER_ID,ASL.STATE_CODE,AM.agentName,ASL.STATE_ID FROM dbo.API_CITY_LIST ACL(NOLOCK)
		INNER JOIN dbo.API_STATE_LIST ASL(NOLOCK) ON ASL.STATE_ID = ACL.STATE_ID
		INNER JOIN dbo.countryMaster CM(NOLOCK) ON ACL.CITY_COUNTRY = CM.countryName
		INNER JOIN dbo.agentMaster AM(NOLOCK) ON AM.agentId = ASL.API_PARTNER_ID
		WHERE ACL.CITY_ID = @rowId

	END

	IF @FLAG='getCityByCountryId'
	BEGIN
	    SELECT 
			APL.CITY_ID			CITY_ID,
			APL.CITY_NAME		CITY_NAME,
			APL.CITY_CODE		CITY_CODE
			FROM dbo.API_CITY_LIST APL(NOLOCK)
			INNER JOIN dbo.countryMaster CM(NOLOCK) ON CM.countryName=APL.CITY_COUNTRY 
			AND APL.IS_ACTIVE=1 AND CM.countryId=@COUNTRY_ID
	END
END
GO
