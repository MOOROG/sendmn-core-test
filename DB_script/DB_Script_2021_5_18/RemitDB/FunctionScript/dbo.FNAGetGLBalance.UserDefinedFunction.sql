USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetGLBalance]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

SELECT [dbo].[FNAGetGLBalance] (327, default, default)

*/
--GO

CREATE FUNCTION [dbo].[FNAGetGLBalance] (
	 @gl_code INT
	,@from_date VARCHAR(10) = NULL 
	,@to_date VARCHAR(10) = NULL 
)  
RETURNS DECIMAL(38, 2)
BEGIN

	DECLARE @balance DECIMAL(38, 2)
	SELECT			
		 @balance = SUM(CASE WHEN part_tran_type = 'dr' THEN ISNULL(tran_amt, 0) * (-1) ELSE ISNULL(tran_amt, 0) END)		
	FROM (	
		SELECT 
			 gg.gl_code				
		FROM (
			SELECT					 		 
				 gg.tree_sape 
			FROM GL_GROUP gg WITH(NOLOCK) 
			WHERE gl_code = @gl_code
			
		) x
		INNER JOIN GL_GROUP gg WITH(NOLOCK) ON x.tree_sape = LEFT(gg.tree_sape, LEN(x.tree_sape))
	) x
	INNER JOIN ac_master am WITH(NOLOCK) ON x.gl_code = am.gl_code
	INNER JOIN tran_master tm WITH(NOLOCK) ON am.acct_num = tm.acc_num		
	WHERE tm.tran_date BETWEEN ISNULL(@from_date, '1900-01-01') AND ISNULL(@to_date, '2100-12-31') + ' 23:59:59'
	
	RETURN ISNULL(@balance, 0)
END
GO
