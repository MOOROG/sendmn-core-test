USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ProcDrCrUpdateFinal]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[ProcDrCrUpdateFinal]
	@TRN_TYPE as Varchar(5),
	@AC_NUM as Varchar(30),
	@TRN_AMT as money,
	@TRN_AMT_USD as money=null

AS
BEGIN 

SET NOCOUNT ON;

		DECLARE @AVAILABLE_AMT as varchar(20)
		DECLARE @acct_ownership as varchar(5)

			select @acct_ownership=acct_ownership,@AVAILABLE_AMT=isnull(AVAILABLE_AMT,0) 
			from ac_master 
			where acct_num=@AC_NUM

			-- ############### AVAILABLE_AMT Checking
				--if @acct_ownership='c' and @TRN_TYPE='DR' and @AVAILABLE_AMT < @TRN_AMT	
				--begin
				--	select 'Insufficient Account Balance AcNo:'+ cast(@ac_num as varchar) +' AVAILABLE_AMT: '+ cast(@AVAILABLE_AMT as varchar) as remarks
				--	return 
				--end

				-- ############### Update CLR_BAL_AMT
				update ac_master set 
						USD_AMT=case when @TRN_TYPE='DR' 
						then isnull(USD_AMT,0) - isnull(@TRN_AMT_USD,0)
						else isnull(USD_AMT,0) -  isnull(-@TRN_AMT_USD,0) 
						end,
						CLR_BAL_AMT=case when @TRN_TYPE='DR' 
						then isnull(CLR_BAL_AMT,0) - isnull(@TRN_AMT,0)
						else isnull(CLR_BAL_AMT,0) -  isnull(-@TRN_AMT,0) 
						end
						where acct_num=@AC_NUM
		
				-- ###############Update AVAILABLE_AMT	
				update ac_master 
					set AVAILABLE_AMT= isnull(DR_BAL_LIM,0) +  isnull(CLR_BAL_AMT,0) -  isnull(SYSTEM_RESERVED_AMT,0) -  isnull(LIEN_AMT,0)
					where acct_num=@AC_NUM
	 

		-- select  'SUCCESS' as Remarks

end




GO
