USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_voucherApprove]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
 EXEC [proc_voucherApprove] @flag = 's'
Exec [proc_voucherApprove] @flag='d',@TempId='12'
exec [proc_voucherApprove] @flag = 's'  ,@pageNumber='1', @pageSize='10', @sortBy=null, @sortOrder=null
Exec [proc_voucherApprove] @flag='u',@sessionID='1'
SELECT * FROM tempTrnToApprove
*/

CREATE proc [dbo].[proc_voucherApprove]
	 @flag						VARCHAR(10)
	,@tempTran_id				INT                 = NULL
	,@TempId					VARCHAR(20)			= NULL
	,@voucher_type				VARCHAR(20)			= NULL
	,@TranDate					VARCHAR(20)			= NULL
	,@sortBy					VARCHAR(50)			= NULL
	,@sortOrder					VARCHAR(5)			= NULL
	,@pageSize					INT					= NULL
	,@pageNumber				INT					= NULL
	,@sessionID					VARCHAR(100)		= NULL
	,@user_id					VARCHAR(100)		= NULL
	,@acct_num					VARCHAR(100)		= NULL
	,@acct_name					VARCHAR(100)		= NULL
	,@tran_type					VARCHAR(100)		= NULL
	,@tran_amt					VARCHAR(100)		= NULL
	,@isnew						VARCHAR(100)		= NULL
	,@refrence					VARCHAR(100)		= NULL
	,@RunningBalance			VARCHAR(100)		= NULL
	,@remarks					VARCHAR(100)		= NULL
	,@newAccNum					VARCHAR(100)		= NULL
	,@user						VARCHAR(50)			= NULL
AS

/*
	@flag
	s	= select all (with dynamic filters)
	i	= insert
	u	= update
	a	= select by role id
	d	= delete by role id
	l	= drop down list
		
	[applicationMessage]
	
*/
SET NOCOUNT ON
BEGIN TRY
	
 IF @flag = 's'
	BEGIN
		DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter		VARCHAR(MAX)
			
		IF @sortBy IS NULL  
			SET @sortBy = 'tempid'
		IF @sortOrder IS NULL
			SET @sortOrder = 'Asc'
		
	--	SET @msgTo = @admin
	
		--SET @table = '[custodian]'	
		
		SET @table = '(SELECT
							 t1.V_TYPE  [voucher_type]
							,t2.v_type
							,t2.Status
							,t2.tempId 
							,t2.Remarks
							,convert(varchar,t2.TranDate,107) [TranDate] 
							FROM TempTrnTOApprove AS t2
							INNER JOIN VOUCHER_SETTING AS t1 ON t2.V_type = t1.v_code and isnull(t2.Status,'''') = '''')X'	
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
								 tempId
								,voucher_type
								,v_type
								,Status
								,Remarks
								,TranDate'
					
		IF @TempId IS NOT NULL
			SET @sqlFilter = @sqlFilter + ' AND acct_name  LIKE ''%' + @TempId  + '%'''
		IF @voucher_type  IS NOT NULL
			SET  @sqlFilter = @sqlFilter + ' AND acct_num  LIKE ''%' + @voucher_type  + '%'''	
		IF @TranDate  IS NOT NULL
			SET  @sqlFilter = @sqlFilter + ' AND acct_num  LIKE ''%' + @TempId  + '%'''		
		
		
		
		SET @extraFieldList = ',''<a href ="ManageApproveVoucher.aspx?ID='' + CAST(TempId AS VARCHAR(50)) +''&flag=a">Approve</a>'''
		+
		 ' [edit]' 
		
		
		EXEC dbo.proc_paging
			@table					
			,@sqlFilter			
			,@selectFieldList		
			,@extraFieldList		
			,@sortBy				
			,@sortOrder			
			,@pageSize				
			,@pageNumber	
		
	END
	
IF @flag='d'
	BEGIN
		SELECT 
			 ta.v_type
			,ta.Remarks
			,CONVERT(VARCHAR,TA.TranDate,101)TranDate
			,t.acct_num [AC No]
			,t.gl_sub_head_code [Ac Name]
			,t.part_tran_type [Type]
			,t.tran_amt [Amount] 
		FROM temp_tran t
		INNER JOIN TempTrnTOApprove ta ON t.sessionID=ta.TempId WHERE sessionID=@TempId 
		
	END	
	
IF @flag='i'
BEGIN

	INSERT INTO temp_tran(sessionID
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
					SELECT	@sessionID
						   ,@user_id
						   ,@acct_num
						   ,@acct_name
						   ,@tran_type
						   ,@tran_amt
						   ,@TranDate
						   ,@isnew
						   ,@refrence
						   ,dbo.FNAGetRunningBalance(@acct_num,@tran_amt,@tran_type)
						   
	SELECT 'DATA SAVE SUCCESSFULLY!' MSG , @sessionID ID									
							   
END	

IF @flag='u'
BEGIN
   IF @newAccNum IS  NULL 
		SET @newAccNum = @acct_num
   
	UPDATE temp_tran SET  acct_num = @newAccNum, gl_sub_head_code = @acct_name, part_tran_type = @tran_type,
		tran_amt = @tran_amt, tran_date = GETDATE() WHERE sessionID = @sessionID and acct_num = @acct_num
		
	--UPDATE TempTrnTOApprove SET v_type = @voucher_type,Remarks = @remarks WHERE TempId = @TempId 
	SELECT 'DATA UPDATED SUCCESSFULLY!' MSG 
END

IF @flag = 'de'
BEGIN
   
   DELETE FROM temp_tran 
	   WHERE sessionID = @sessionID 
	   AND acct_num = @acct_num
	   
	   SELECT 'DELETE SUCCESSFULLY' msg

END
 

--IF @flag='f'
--BEGIN 
--	INSERT INTO tran_master(
--							 acc_num
--							,entry_user_id
--							,gl_sub_head_code
--							,part_tran_srl_num
--							,part_tran_type
--							,ref_num
--							,tran_amt
--							,tran_date
--							,tran_type
--							)
--					SELECT 
--							t.acct_num
--							,t.entry_user_id
--							,t.gl_sub_head_code
--							,t.tran_id
--							,t.part_tran_type
--							,t.ref_num
--							,t.tran_amt
--							,t.tran_date
--							,t.part_tran_type FROM temp_tran t WHERE sessionID = @sessionID

--		update TempTrnTOApprove set Status = 'Approved' where TempId = @TempId
							
--END

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION
	SELECT 1 errorCode, ERROR_MESSAGE() mes, NULL id
END CATCH
		
		


GO
