USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_tempTran]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procEDURE [dbo].[proc_tempTran](
		 @flag char(1) 
		,@tempTran_id           INT			 = NULL
		,@sessionID				VARCHAR(100) = NULL
		,@entry_user_id			VARCHAR(100) = NULL
		,@acct_num				VARCHAR(100) = NULL
		,@gl_sub_head_code		VARCHAR(100) = NULL
		,@part_tran_type		VARCHAR(100) = NULL
		,@tran_amt              VARCHAR(100) = NULL
		,@isnew                 VARCHAR(100) = NULL
		,@refrence				VARCHAR(100) = NULL
		,@RunningBalance        VARCHAR(100) = NULL

)
AS 
		SET NOCOUNT ON 
		SET XACT_ABORT ON 
		
  BEGIN TRY 
  
   IF @flag = 'i'
   BEGIN
		 INSERT INTO temp_tran(
							sessionID
							,entry_user_id
							,acct_num
							,gl_sub_head_code
							,part_tran_type
							,tran_amt
							,tran_date
							,isnew
							,refrence
							,RunningBalance
						 )
					SELECT 
							@sessionID
						   ,@entry_user_id
						   ,@acct_num
						   ,@gl_sub_head_code
						   ,@part_tran_type
						   ,@tran_amt
						   ,GETDATE()
						   ,@isnew
						   ,@refrence
						   ,dbo.FNAGetRunningBalance(@acct_num,@tran_amt,@part_tran_type)
						   
						 SELECT @tempTran_id = SCOPE_IDENTITY()
						   
			   SELECT 1 ERROR_CODE,'DATA SAVE SUCCESSFULLY!' MSG , @tempTran_id ID
   
   
   END
   
	ELSE IF @flag = 'u'
	BEGIN
		  UPDATE temp_tran SET 
							tran_amt =@tran_amt
						   ,part_tran_type =@part_tran_type
		 WHERE tran_id = @tempTran_id
		 
		SELECT 'Data Update Successfully!' MSG 
	END
   
   ELSE IF @flag = 'a'
		BEGIN
			 SELECT 
					ROW_NUMBER()OVER(order by tran_id)[SN]
					,gl_sub_head_code[AC information]
					,dbo.ShowDecimal(tran_amt) [Amount]
					,part_tran_type [Type]
					,refrence
					,IsNew
				    ,'<img onclick = "EditGeneralVoucher(' + CAST(tran_id AS VARCHAR(50)) + ')" class = "showHand" border = "0" title = "Edit Voucher" src="../../../Images/edit.gif" />'+ CHAR(30) +'<img onclick = "DeleteNotification(' + CAST(tran_id AS VARCHAR(50)) + ')" class = "showHand" border = "0" title = "Delete Notification" src="../../../Images/delete.gif" />' [Edit/Delete]
					,dbo.[FNAGetRunningBalance](acct_num,tran_amt,part_tran_type) [Running Balance]
			FROM temp_tran 
			WHERE sessionID = @sessionID 
	   END
	   
	   ELSE IF @flag = 's'
	   BEGIN
			SELECT 	
					gl_sub_head_code[AC_information]
					,dbo.ShowDecimal(tran_amt) [Amount]
					,part_tran_type 
			FROM temp_tran 
			WHERE tran_id = @tempTran_id 
	   
	   
	   END
	   
	   
	   ELSE IF @flag = 'd'
	   BEGIN
	      DELETE FROM temp_tran WHERE tran_id = @tempTran_id
	      SELECT 'Data delete successfully' msg
	   
	   END
  
  
  END TRY 
  
  
 BEGIN CATCH
	  IF @@TRANCOUNT > 0
	  ROLLBACK TRANSACTION
	  SELECT '0' ERROR_CODE ,ERROR_MESSAGE() MSG 
 END CATCH


GO
