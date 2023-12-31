USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[procTDSsearch]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec procTDSsearch 'v',null,'2011-2-13','2011-3-13'

create proc [dbo].[procTDSsearch]
	@flag char(1),
	@party varchar(15)=null,
	@trandate1 varchar(15),
	@trandate2 varchar(15),
	@Title varchar(50)=null
AS
set nocount on;

declare @sql varchar(max)
if @flag='v'
begin
		
	SET @Title = 'TDS Report'
	set @sql='SELECT 
				''542687145'' PAN,
				''kathmandu Money Transfer - Head Office '' as ''Party Name'',
				''500.00''  Amount,
				''50.00'' ''TDS Amount'',
				''2016-11-24'' as Date,
				'''' ''TDS Type'''
			--FROM 
			--( 
			--SELECT ref_num,party_pan_num,party_name,
			--SUM(CASE WHEN part_tran_type=''Cr'' THEN tran_amt ELSE 0 END) AS Amount, 
			--SUM(CASE WHEN part_tran_type=''Dr'' THEN tran_amt ELSE 0 END) AS TDS_amount , 
			--tran_date TDS_date, party_type_code 
			--FROM tran_master a WITH (NOLOCK), party b WITH (NOLOCK) 
			--WHERE a.acc_num=b.party_ac_num 
			--AND tran_type<>''y''
			--and tran_date between '''+@trandate1+''' and '''+@trandate2+' 00:00:00.000'''
	
	
	--if @party is not null
	--set @sql=@sql+ ' and party_ac_num='''+@party+''''
	
	
	--set @sql=@sql+ 'GROUP BY ref_num,tran_date,party_pan_num,party_name,party_type_code 
	--				) XY WHERE XY.Amount<>0 AND XY.TDS_amount<>0 '
		

	--print @sql
	exec (@sql)

		EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

	  SELECT 'From Date' head, CONVERT(VARCHAR(10), @trandate1, 101) value UNION
	  SELECT 'To Date' head, CONVERT(VARCHAR(10), @trandate2, 101) 
 
		SELECT title = @Title
end

GO
