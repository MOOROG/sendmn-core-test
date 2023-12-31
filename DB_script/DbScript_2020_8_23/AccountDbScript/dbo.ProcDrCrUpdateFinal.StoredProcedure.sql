USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[ProcDrCrUpdateFinal]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Exec ProcDrCrUpdateFinal 'CR',4500,'2405021112154'
CREATE Proc [dbo].[ProcDrCrUpdateFinal]
	@TRN_TYPE		AS VARCHAR(5),
	@AC_NUM			AS VARCHAR(30),
	@TRN_AMT		AS MONEY,
	@TRN_AMT_USD	AS MONEY=null

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
				UPDATE ac_master SET 
						USD_AMT=CASE WHEN @TRN_TYPE='DR' 
						THEN ISNULL(USD_AMT,0) - ISNULL(@TRN_AMT_USD,0)
						ELSE ISNULL(USD_AMT,0) -  ISNULL(-@TRN_AMT_USD,0) 
						END,
						CLR_BAL_AMT=CASE WHEN @TRN_TYPE='DR' 
						THEN ISNULL(CLR_BAL_AMT,0) - ISNULL(@TRN_AMT,0)
						ELSE ISNULL(CLR_BAL_AMT,0) +  ISNULL(@TRN_AMT,0) 
						END
						WHERE acct_num=@AC_NUM
		
				-- ###############Update AVAILABLE_AMT	
				UPDATE ac_master 
					SET AVAILABLE_AMT= ISNULL(DR_BAL_LIM,0) +  ISNULL(CLR_BAL_AMT,0) -  ISNULL(SYSTEM_RESERVED_AMT,0) -  ISNULL(LIEN_AMT,0)
					WHERE acct_num=@AC_NUM
	 

		-- select  'SUCCESS' as Remarks

END





GO
