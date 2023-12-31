USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[procEntryBillByBill]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- Exec procEntryBillByBill 'session','date','acnum','refnum'

CREATE proc [dbo].[procEntryBillByBill]
	@sessionID varchar(50),
	@date varchar(20),
	@ac_num varchar(20),
	@ref_num varchar(20),
	@refrence varchar(50),
	@isnew varchar(2),
	@trntype varchar(2),
	@v_type varchar(2),
	@AMT money
	
as
begin
set nocount on;

	-- UPDATE BILL BY BILLL		
	--------------------------------------------------------------------	
		if(@isnew='y')
		begin
					
				INSERT INTO BILL_BY_BILL 
				(
					[TRN_DATE],[TRN_REFNO]
					,[ACC_NUM] ,[PART_TRN_TYPE],[VOUCHER_TYPE] ,
					[TRAN_AMT],[REMAIN_AMT],[BILL_REF],[OPENING_BAL]
				  )
				
				select @date,@ref_num,@ac_num,@trntype,@v_type,@AMT,@AMT,@refrence,@AMT
				return;	
		end

		DECLARE @newamt money
		select @newamt= REMAIN_AMT * (case when part_trn_type='dr' then -1 else 1 end )
		+ @AMT * (case when @trntype='dr' then -1 else 1 end )
		from BILL_BY_BILL
		where ACC_NUM=@ac_num and BILL_REF=@refrence
		
		update BILL_BY_BILL set REMAIN_AMT=ABS(@newamt), PART_TRN_TYPE=
		case when @newamt<0 then 'Dr' else 'Cr' end 
		where ACC_NUM=@ac_num and BILL_REF=@refrence

		
		--update BILL_BY_BILL set REMAIN_AMT=NEWAMT, PART_TRN_TYPE=TRN_TYPE
		--from BILL_BY_BILL u , (
			--select BILL_REF, acct_num,
			--case when PART_TRN_TYPE=part_tran_type then
			--	REMAIN_AMT+t.tran_amt
			--when PART_TRN_TYPE<>part_tran_type and REMAIN_AMT >= t.tran_amt then
			--	REMAIN_AMT-t.tran_amt
			--when PART_TRN_TYPE<>part_tran_type and REMAIN_AMT < t.tran_amt and PART_TRN_TYPE='dr' then
			--	t.tran_amt-REMAIN_AMT
			--when PART_TRN_TYPE<>part_tran_type and REMAIN_AMT < t.tran_amt and PART_TRN_TYPE='cr' then
			--	t.tran_amt-REMAIN_AMT
			--else
			--	t.tran_amt
			--end as NEWAMT,
			--case 
			--when PART_TRN_TYPE<>part_tran_type and REMAIN_AMT < t.tran_amt and PART_TRN_TYPE='dr' then
			--	'cr'
			--when PART_TRN_TYPE<>part_tran_type and REMAIN_AMT < t.tran_amt and PART_TRN_TYPE='cr' then
			--	'dr'
			--else
			--	PART_TRN_TYPE
			--end as TRN_TYPE
			--from BILL_BY_BILL b , temp_tran t 
			--where b.BILL_REF=t.refrence and t.acct_num=b.ACC_NUM
			--and t.acct_num = @ac_num
		--)a
		--where u.ACC_NUM=a.acct_num and u.BILL_REF=a.BILL_REF
		--and a.acct_num = @ac_num

end
-------------------------------------------------------------------------
	


GO
