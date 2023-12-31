USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_RBAStatisticRpt]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- exec proc_RBAStatisticRpt @flag='rba-ec'

CREATE PROC [dbo].[proc_RBAStatisticRpt]
(
	 @flag				VARCHAR(10)	= NULL
	,@user				VARCHAR(50)	= NULL
	,@rptdl				VARCHAR(50)	= NULL
	
)
AS


SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY

	DECLARE 
	 @LOWrFrom		MONEY
	,@LOWrTo		MONEY
	,@MEDIUMrFrom	MONEY
	,@MEDIUMrTo		MONEY
	,@HIGHrFrom		MONEY
	,@HIGHrTo		MONEY
	,@highCount		MONEY
	,@mediumCount	MONEY
	,@lowCount		MONEY
	,@totalCount	BIGINT
	,@condition		varchar(max)
	,@sql			varchar(max)	

	SELECT @LOWrFrom=rFrom ,@LOWrTo=rTo  FROM RBAScoreMaster WHERE TYPE='LOW'
	SELECT @MEDIUMrFrom=rFrom ,@MEDIUMrTo=rTo  FROM RBAScoreMaster WHERE TYPE='MEDIUM'
	SELECT @HIGHrFrom=rFrom ,@HIGHrTo=rTo  FROM RBAScoreMaster WHERE TYPE='HIGH'
	
	IF(@flag='rba-s')
	 BEGIN
	 		
		SELECT 
		 @highCount			= SUM( CASE WHEN RBA BETWEEN @HIGHrFrom AND @HIGHrTo  THEN 1 ELSE 0 END ) 
		,@mediumCount		= SUM( CASE WHEN RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo  THEN 1 ELSE 0 END )
		,@lowCount			= SUM( CASE WHEN RBA BETWEEN @LOWrFrom AND @LOWrTo  THEN 1 ELSE 0 END )
		,@totalCount		= SUM( CASE WHEN RBA IS NOT NULL  THEN 1 ELSE 0 END)	  
		FROM CUSTOMERS WITH (NOLOCK) WHERE RBA IS NOT NULL
		
		SELECT (@highCount/@totalCount)*100 as HIGH, (@mediumCount/@totalCount)*100 as MEDIUM,(@lowCount/@totalCount)*100 as LOW,@totalCount as TOTAL		

	END
	
	IF(@flag='rba-dl')
	BEGIN
		
		--DECLARE @totalCount1 BIGINT
		--SELECT @totalCount = SUM(CASE WHEN RBA IS NOT NULL  THEN 1 ELSE 0 END) FROM CUSTOMERS WITH (NOLOCK) WHERE RBA IS NOT NULL
		--SELECT @totalCount1 = SUM(CASE WHEN RBA IS NOT NULL  THEN 1 ELSE 0 END) FROM tranSenders WITH (NOLOCK) WHERE RBA IS NOT NULL

		
		--SELECT country = X.countryName, x.CNT, per = (CAST(X.CNT as money)/@totalCount)*100 FROM(
		--		SELECT cm.countryName, [CNT] = COUNT(cm.countryName) FROM CUSTOMERS C WITH (NOLOCK)
		--		INNER JOIN countryMaster CM WITH(NOLOCK) ON C.nativeCountry = CM.countryId
		--		WHERE RBA IS NOT NULL GROUP BY cm.countryName
		--	)X			
		--	RETURN;
			
		IF @rptdl='HIGH'
		BEGIN
		 -- Native Country Wise --
			
			SELECT 
				@totalCount = SUM(X.CNT)
			FROM(
				SELECT cm.countryName, [CNT] = COUNT(cm.countryName) FROM CUSTOMERS C WITH (NOLOCK)
				INNER JOIN countryMaster CM WITH(NOLOCK) ON C.nativeCountry = CM.countryId
				WHERE RBA BETWEEN @HIGHrFrom AND @HIGHrTo GROUP BY cm.countryName
			)X


			SELECT 
				country = X.countryName
				,[percent] = (CAST(X.CNT as money)/@totalCount)*100 
			FROM(
				SELECT cm.countryName, [CNT] = COUNT(cm.countryName) FROM CUSTOMERS C WITH (NOLOCK)
				INNER JOIN countryMaster CM WITH(NOLOCK) ON C.nativeCountry = CM.countryId
				WHERE RBA BETWEEN @HIGHrFrom AND @HIGHrTo GROUP BY cm.countryName
			)X
			
			
			SELECT 
				@totalCount = SUM(Y.CNT)
			FROM(
				SELECT scountry,  CNT = count(scountry) FROM remitTran rt WITH(NOLOCK)
				INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
				WHERE ts.RBA BETWEEN @HIGHrFrom AND @HIGHrTo GROUP BY scountry
			)Y


			-- Sending Country wise --
			SELECT country = Y.scountry, [percent] = (CAST(Y.CNT as money)/@totalCount)*100  FROM (
				SELECT scountry,  CNT = count(scountry) FROM remitTran rt WITH(NOLOCK)
				INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
				WHERE ts.RBA BETWEEN @HIGHrFrom AND @HIGHrTo GROUP BY scountry
			) Y
		
		END
		ELSE IF @rptdl='MEDIUM'
		BEGIN
		 -- Native Country Wise --
		 
			SELECT @totalCount = SUM(X.CNT) FROM(
				SELECT cm.countryName, [CNT] = COUNT(cm.countryName) FROM CUSTOMERS C WITH (NOLOCK)
				INNER JOIN countryMaster CM WITH(NOLOCK) ON C.nativeCountry = CM.countryId
				WHERE RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo GROUP BY cm.countryName
			)X


			SELECT country = X.countryName, [percent] = (CAST(X.CNT as money)/@totalCount)*100 FROM(
				SELECT cm.countryName, [CNT] = COUNT(cm.countryName) FROM CUSTOMERS C WITH (NOLOCK)
				INNER JOIN countryMaster CM WITH(NOLOCK) ON C.nativeCountry = CM.countryId
				WHERE RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo GROUP BY cm.countryName
			)X
			
			-- Sending Country wise --				

			SELECT @totalCount = SUM(Y.CNT) FROM(
				SELECT scountry,  CNT = count(scountry) FROM remitTran rt WITH(NOLOCK)
				INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
				WHERE ts.RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo GROUP BY scountry
			) Y


			SELECT country = Y.scountry, [percent] = (CAST(Y.CNT as money)/@totalCount)*100  FROM (
				SELECT scountry,  CNT = count(scountry) FROM remitTran rt WITH(NOLOCK)
				INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
				WHERE ts.RBA BETWEEN @MEDIUMrFrom AND @MEDIUMrTo GROUP BY scountry
			) Y
			
		END
		ELSE IF @rptdl='LOW'
		BEGIN
			-- Native Country Wise --

			SELECT @totalCount = SUM(X.CNT) FROM(
				SELECT cm.countryName, [CNT] = COUNT(cm.countryName) FROM CUSTOMERS C WITH (NOLOCK)
				INNER JOIN countryMaster CM WITH(NOLOCK) ON C.nativeCountry = CM.countryId
				WHERE RBA BETWEEN @LOWrFrom AND @LOWrTo GROUP BY cm.countryName
			)X


			SELECT country = X.countryName, [percent] = (CAST(X.CNT as money)/@totalCount)*100 FROM(
				SELECT cm.countryName, [CNT] = COUNT(cm.countryName) FROM CUSTOMERS C WITH (NOLOCK)
				INNER JOIN countryMaster CM WITH(NOLOCK) ON C.nativeCountry = CM.countryId
				WHERE RBA BETWEEN @LOWrFrom AND @LOWrTo GROUP BY cm.countryName
			)X
			
			-- Sending Country wise --

			SELECT @totalCount = SUM(Y.CNT) FROM(
				SELECT scountry,  CNT = count(scountry) FROM remitTran rt WITH(NOLOCK)
				INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
				WHERE ts.RBA BETWEEN @LOWrFrom AND @LOWrTo GROUP BY scountry
			) Y

			SELECT country = Y.scountry, [percent] = (CAST(Y.CNT as money)/@totalCount)*100  FROM (
				SELECT scountry,  CNT = count(scountry) FROM remitTran rt WITH(NOLOCK)
				INNER JOIN tranSenders ts WITH(NOLOCK) ON rt.id = ts.tranId
				WHERE ts.RBA BETWEEN @LOWrFrom AND @LOWrTo GROUP BY scountry
			) Y
			
		END
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
