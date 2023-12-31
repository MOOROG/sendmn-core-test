USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_drillTrialBalance]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_drillTrialBalance] (
	 @fromDate VARCHAR(10) = '2000-01-01'
	,@toDate VARCHAR(10) = '2020-01-01'
	,@glCode VARCHAR(10) = NULL
	,@drill INT = 0
)
AS	
SET NOCOUNT ON


IF @glCode IS NULL
BEGIN
	SELECT 
		 Code = rf.reportid 
		,Name = rf.lable		
		,dr = ABS(CASE WHEN x.Total < 0 THEN x.Total  ELSE 0 END)
		,cr = ABS(CASE WHEN x.Total > 0 THEN x.Total  ELSE 0 END)
		,drill = 1
	FROM report_format rf WITH(NOLOCK)
	LEFT JOIN (
		SELECT
			 gg.bal_grp
			,SUM(CASE WHEN part_tran_type = 'dr' THEN ISNULL(tran_amt, 0) * (-1) ELSE ISNULL(tran_amt, 0) END) Total
		FROM tran_master tm WITH(NOLOCK)
		INNER JOIN ac_master am WITH(NOLOCK) ON tm.acc_num = am.acct_num
		INNER JOIN GL_GROUP gg WITH(NOLOCK) ON am.gl_code = gg.gl_code				
		WHERE tran_date BETWEEN ISNULL(@fromDate, '1900-01-01') AND ISNULL(@toDate, '2100-12-31') + ' 23:59:59'						 
		GROUP BY gg.bal_grp
	) x ON x.bal_grp = rf.reportid
	WHERE rf.reportid NOT IN (24)
	ORDER BY rf.grp_main
	RETURN
END

IF @drill = 1
BEGIN
	SELECT 
		 Code
		,Name	
		,dr = ABS(CASE WHEN x.Total < 0 THEN x.Total  ELSE 0 END)
		,cr = ABS(CASE WHEN x.Total > 0 THEN x.Total  ELSE 0 END)
		,drill = 0
	FROM (
		SELECT 
			 Code = gg.gl_code
			,Name = gg.gl_name		
			,Total = SUM(ISNULL(x.Total, 0))
		FROM GL_GROUP gg WITH(NOLOCK)
		LEFT JOIN (
			SELECT 
				 gg.gl_code
				,gg.gl_name 
				,gg.bal_grp
				,gg.p_id
				,gg.tree_sape
				,SUM(CASE WHEN part_tran_type = 'dr' THEN ISNULL(tran_amt, 0) * (-1) ELSE ISNULL(tran_amt, 0) END) Total
			FROM tran_master tm WITH(NOLOCK)
			INNER JOIN ac_master am WITH(NOLOCK) ON tm.acc_num = am.acct_num
			INNER JOIN GL_GROUP gg WITH(NOLOCK) ON am.gl_code = gg.gl_code				
			WHERE tran_date BETWEEN ISNULL(@fromDate, '1900-01-01') AND ISNULL(@toDate, '2100-12-31') + ' 23:59:59'							 
			AND gg.bal_grp = @glCode
			GROUP BY gg.gl_code, gg.bal_grp,gg.gl_name,gg.p_id, gg.tree_sape
			
		) x ON gg.tree_sape = LEFT(x.tree_sape, LEN(gg.tree_sape))
		WHERE gg.bal_grp = @glCode		
		--AND ISNUMERIC(gg.p_id) = 0
		GROUP BY gg.gl_name	, gg.gl_code		
	) x
	ORDER BY Name

END

IF EXISTS(SELECT 'x' FROM ac_master WITH(NOLOCK) WHERE gl_code = @glCode) --Accounts
BEGIN
	SELECT
		 Code = am.acct_num
		,Name = am.acct_name 
		,dr = ABS(CASE WHEN x.Total < 0 THEN x.Total  ELSE 0 END)
		,cr = ABS(CASE WHEN x.Total > 0 THEN x.Total  ELSE 0 END)
		,drill = -1
	FROM ac_master am WITH(NOLOCK)
	LEFT JOIN (
		SELECT
			 tm.acc_num
			,SUM(CASE WHEN part_tran_type = 'dr' THEN ISNULL(tran_amt, 0) * (-1) ELSE ISNULL(tran_amt, 0) END) Total
		FROM tran_master tm WITH(NOLOCK)
		INNER JOIN ac_master am WITH(NOLOCK) ON tm.acc_num = am.acct_num
		WHERE tran_date BETWEEN ISNULL(@fromDate, '1900-01-01') AND ISNULL(@toDate, '2100-12-31') + ' 23:59:59'
			AND am.gl_code = @glCode		 
		GROUP BY tm.acc_num
	) x ON x.acc_num = am.acct_num
	WHERE gl_code = @glCode
	ORDER BY am.acct_name ASC	
END
ELSE IF EXISTS(SELECT 'x' FROM GL_GROUP WITH(NOLOCK) WHERE p_id = @glCode)
BEGIN
	SELECT 
		 Code = gg.gl_code
		,Name = gg.gl_name		
		,dr = ABS(SUM(CASE WHEN x.Total < 0 THEN x.Total  ELSE 0 END))
		,cr = ABS(SUM(CASE WHEN x.Total > 0 THEN x.Total  ELSE 0 END))
		,drill = 0
	FROM GL_GROUP gg WITH(NOLOCK)
	LEFT JOIN (
		SELECT 
			 gg.gl_code
			,gg.gl_name 
			,gg.bal_grp
			,gg.p_id
			,gg.tree_sape
			,SUM(CASE WHEN part_tran_type = 'dr' THEN ISNULL(tran_amt, 0) * (-1) ELSE ISNULL(tran_amt, 0) END) Total
		FROM tran_master tm WITH(NOLOCK)
		INNER JOIN ac_master am WITH(NOLOCK) ON tm.acc_num = am.acct_num
		INNER JOIN GL_GROUP gg WITH(NOLOCK) ON am.gl_code = gg.gl_code				
		WHERE tran_date BETWEEN ISNULL(@fromDate, '1900-01-01') AND ISNULL(@toDate, '2100-12-31') + ' 23:59:59'							 
		GROUP BY gg.gl_code, gg.bal_grp,gg.gl_name,gg.p_id, gg.tree_sape
	) x ON gg.tree_sape = LEFT(x.tree_sape, LEN(gg.tree_sape))
	WHERE gg.p_id = @glCode	
	GROUP BY gg.gl_name	, gg.gl_code
	ORDER BY gg.gl_name
END

	
	 

	

	
	

GO
