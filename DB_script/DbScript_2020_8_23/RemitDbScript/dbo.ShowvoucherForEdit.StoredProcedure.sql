USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ShowvoucherForEdit]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Exec [ShowvoucherForEdit] @v_type='j',@voucher='37', @company_id='1', @sessionID ='aay11obioen1agy2g210id1q'

*/
CREATE proc [dbo].[ShowvoucherForEdit](
		 @flag					 VARCHAR(100)
		,@voucher				 VARCHAR(50) = NULL
		,@v_type				 VARCHAR(2)  = NULL
		,@company_id			 VARCHAR(20) = NULL
		,@sessionID				 VARCHAR(100)= NULL
		,@tran_amt				 VARCHAR(20) = NULL
		,@part_tran_type		 VARCHAR(20) = NULL
		,@acc_num				 VARCHAR(20) = NULL
		,@entry_user_id			 VARCHAR(20) = NULL
		,@ref_num			     VARCHAR(20) = NULL
		,@tran_type				 VARCHAR(20) = NULL
		,@usd_amt			     VARCHAR(20) = NULL
		,@tran_id				 VARCHAR(20) = NULL
)

AS
/*
flag info

s  -> delete then insert and with select 
a  -> select without delete 
t  -> select single data row for edit



*/


SET NOCOUNT ON;

BEGIN TRY

	IF @flag ='s'
	BEGIN
	     	DELETE FROM temp_voucher_edit WHERE sessionID=@sessionID

			INSERT INTO temp_voucher_edit (
									sessionID
									,entry_user_id
									,acc_num,gl_sub_head_code
									,part_tran_type
									,ref_num,rpt_code
									,tran_amt,tran_date
									,billno
									,part_tran_srl_num
									,tran_type
									,company_id
									,usd_amt
									,RunningBalance
									)
							SELECT 
									@sessionID
									,entry_user_id
									,acc_num
									,gl_sub_head_code
									,part_tran_type
									,ref_num
									,rpt_code
									,tran_amt
									,tran_date
									,billno
									,part_tran_srl_num
									,tran_type
									,company_id
									,usd_amt
									,RunningBalance
							FROM tran_master 
							WHERE ref_num=@voucher and tran_type=@v_type
					
						  SELECT
							       t.tran_id,t.ref_num,t.tran_type,t.billno, d.tran_particular
							      ,acc_num ,convert(varchar,tran_date,101)as tran_date
							     
						         ,ROW_NUMBER() OVER (ORDER BY tran_id) [Sn]
								 ,acct_name[ AC Num ],dbo.ShowDecimal(tran_amt)Amount,dbo.ShowDecimal(t.usd_amt) [USD] ,part_tran_type [Type]
								 ,dbo.ShowDecimal(RunningBalance)[R.Bal]
								 ,'<img onclick = "EditVoucher(' + CAST(t.tran_id AS VARCHAR(50)) + ')" class = "showHand" border = "0" title = "Edit Voucher" src="../../../Images/edit.gif" />'+ CHAR(30) +'<img onclick = "DeleteNotification(' + CAST(t.tran_id AS VARCHAR(50)) + ')" class = "showHand" border = "0" title = "Delete Notification" src="../../../Images/delete.gif" />' [Edit/Delete]
						 FROM temp_voucher_edit t 
						 WITH (NOLOCK) , ac_master a 
						 WITH(NOLOCK), tran_masterDetail d 
						 WITH(NOLOCK) 
						 WHERE t.ref_num=d.ref_num 
						 AND t.tran_type=d.tran_type 
						 AND t.company_id=d.company_id 
						 AND t.acc_num=a.acct_num 
						 AND SessionID=@sessionID
	END
	ELSE IF @flag = 'i'
	BEGIN
		
	   INSERT INTO temp_voucher_edit (
								 sessionID
								,tran_amt
								,part_tran_type
								,acc_num
								,entry_user_id
								,company_id
								,ref_num
								,tran_type
								,usd_amt
								,tran_date
							)
							SELECT  
							      @sessionID
							     ,@tran_amt
							     ,@part_tran_type
							     ,@acc_num
							     ,@entry_user_id
							     ,@company_id
							     ,@ref_num
							     ,@tran_type
							     ,@usd_amt
							     ,(SELECT TOP 1 tran_date FROM temp_voucher_edit WHERE tran_date IS NOT NULL AND sessionID = @sessionID)
					SELECT @tran_id = SCOPE_IDENTITY()
				    SELECT 0 ERROR_CODE, 'Data Save Successfully' MSG ,@tran_id ID 
	END
	
    ELSE IF @flag = 'u'
	BEGIN
			UPDATE temp_voucher_edit SET 
					 tran_amt		= @tran_amt
					,usd_amt		=  @usd_amt
					,part_tran_type = @part_tran_type
					,acc_num		= @acc_num
				WHERE  tran_id = @ref_num -- ref_num is a tran_id number
		 SELECT 0 ERROR_CODE, 'Data Save Successfully' MSG ,@tran_id ID 
	END
	
	ELSE IF @flag = 'd'
	BEGIN
		 DELETE 
			 temp_voucher_edit 
		 WHERE tran_id = @tran_id
		 
		 SELECT 'Data Delete Successfully' msg
	
	END
	
	ELSE IF @flag = 'a'
	BEGIN
			SELECT
					  tran_id,t.ref_num,t.tran_type,t.billno, d.tran_particular
					  ,acc_num ,convert(varchar,tran_date,101)as tran_date
				     
					 ,ROW_NUMBER() OVER (ORDER BY tran_id) [Sn]
					 ,acct_name[ AC Num ],dbo.ShowDecimal(tran_amt)Amount,dbo.ShowDecimal(t.usd_amt) [USD] ,part_tran_type [Type]
					 ,dbo.ShowDecimal(RunningBalance)[R.Bal]
					 ,'<img onclick = "EditVoucher(' + CAST(t.tran_id AS VARCHAR(50)) + ')" class = "showHand" border = "0" title = "Edit Voucher" src="../../../Images/edit.png" />'+ space(300) +'<img onclick = "DeleteNotification(' + CAST(t.tran_id AS VARCHAR(50)) + ')" class = "showHand" border = "0" title = "Delete Notification" src="../../../Images/delete.gif" />' [Edit/Delete]
			 FROM temp_voucher_edit t 
			 WITH (NOLOCK) , ac_master a 
			 WITH(NOLOCK), tran_masterDetail d 
			 WITH(NOLOCK) 
			 WHERE t.ref_num=d.ref_num 
			 AND t.tran_type=d.tran_type 
			 AND t.company_id=d.company_id 
			 AND t.acc_num=a.acct_num 
			 AND SessionID=@sessionID
	END
	
	IF @flag = 't'
	BEGIN
	       SELECT  
			a.acct_name +'|'+ a.acct_num [acc_name]
			,dbo.ShowDecimal(tran_amt) tran_amt
			,dbo.ShowDecimal(t.usd_amt)	usd_amt	
			,part_tran_type 
		 FROM temp_voucher_edit t 
		 INNER JOIN ac_master a 
		 ON t.acc_num = a.acct_num where t.tran_id = @tran_id

	END
		
	
	

END TRY

BEGIN CATCH
  IF @@TRANCOUNT > 0
  ROLLBACK TRANSACTION
  SELECT 1 ERROR_CODE , ERROR_MESSAGE() MSG ,@tran_id ID

END CATCH


GO
