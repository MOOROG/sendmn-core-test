USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[proc_DealStockSummary]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[proc_DealStockSummary](
	 @flag			VARCHAR	(50)	=NULL
	,@user			VARCHAR (30)	=NULL
	,@bankId		VARCHAR	(50)	=NULL
	,@sortBy        VARCHAR(50)		= NULL
	,@sortOrder     VARCHAR(5)		= NULL
	,@pageSize      INT				= NULL
	,@pageNumber    INT				= NULL		
)
AS 

DECLARE 
		 @table					VARCHAR(MAX)		
		,@select_field_list		VARCHAR(MAX)
		,@extra_field_list		VARCHAR(MAX)
		,@sql_filter			VARCHAR(MAX)

IF @flag = 'dealSummary'
BEGIN
	IF @sortBy IS NULL
		SET @sortBy = 'DealDate'
	IF @sortOrder IS NULL
		SET @sortOrder = 'ASC'
	IF @pageSize IS NULL
		SET @pageSize = 20
	SET @table='(
			SELECT dbs.BankName,dbf.BankId,dbf.RowId,DealDate,LcyAmt,UsdAmt,Rate,dbf.RemainingAmt FROM DealBookingHistory dbf (NOLOCK) 
			INNER JOIN DealBankSetting dbs (NOLOCK) ON dbf.BankId = dbs.RowId 
			WHERE 1=1 AND RemainingAmt > 0 )x'

		SET @sql_filter = '' 

		IF @bankId IS NOT NULL
			SET @sql_filter = @sql_filter + 'and  x.BankId='''+@bankId+''''	
	
		SET @select_field_list ='BankName,BankId,RowId,DealDate,LcyAmt,UsdAmt,Rate,RemainingAmt'   
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
ELSE IF @flag='s'
BEGIN
		SELECT bs.BankName,bs.RowId AS BankId,usd_amt*-1 AS RemainingtoTransfer
		FROM  dbo.DealBankSetting bs WITH (NOLOCK)
		--INNER JOIN dbo.DealBookingHistory bh WITH (NOLOCK) ON bs.RowId=bh.BankId
		INNER JOIN ac_master A(NOLOCK) ON A.acct_num = bs.BuyAcNo
		where 1=1 and bs.RowId = isnull(@bankId,bs.RowId)
END

GO
