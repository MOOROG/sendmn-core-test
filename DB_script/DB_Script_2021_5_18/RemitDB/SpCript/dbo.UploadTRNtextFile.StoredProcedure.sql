USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[UploadTRNtextFile]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Load text file
-- Exec UploadTRNtextFile 'a', 'd:\PINManagement_TEST\files\trn\sample.csv','12312'
-- Exec [UploadTRNtextFile] @flag='a',@filename='',@username=bhim,@sessionId='anrtwpqtb43dnszpkqhrjji2'
-- Exec [UploadTRNtextFile] @flag='a',@filename='C:\Users\bhim\Desktop\sample_TRN.csv',@username='bhim',@sessionId='cc0sh30xxw5zin1d2rebr101'

CREATE proc [dbo].[UploadTRNtextFile]
	@flag char(1),
	@filename varchar(200),
	@sessionId varchar(100),
	@username varchar(20)
AS
if @flag='a'
begin

	--Create table SN|PIN|VALUE|EXPIRY
	declare @SQL varchar(1000)
	
	create table #tempTranUpload
	(
		AC_NUMBER varchar(20) null,
		DRAMOUNT	 money null,
		CRAMOUNT	 money null,
	)
	


	SET @SQL = ' BULK INSERT #tempTranUpload  FROM '''+@filename+''' 
				 WITH (FIELDTERMINATOR = '','',FIRSTROW  = 2, ROWTERMINATOR =''\n'') '
				 
				

	exec(@SQL)
	print @SQL
	return

	alter table #tempTranUpload add rowid [int] IDENTITY(1,1) NOT NULL

	if @@error=0 
		begin	
			-- ########### Clean Temp TAble
			delete from temp_tran where sessionID=@sessionId

			-- update #tempTranUpload set DRAMOUNT=REPLACE(DRAMOUNT,SPACE(1),'')

			update #tempTranUpload set CRAMOUNT=REPLACE(CRAMOUNT,SPACE(1),'')
			
			
			-- update #tempTranUpload set AC_NUMBER=REPLACE(AC_NUMBER,SPACE(1),'')
			-- ############ Check format
			--delete from #tempTranUpload where cast(DRAMOUNT as int)= 0 and cast(CRAMOUNT as int)= 0

	
			-- ############### Insert into TempTable 
			insert into temp_tran (entry_user_id,acct_num,gl_sub_head_code,part_tran_type,tran_amt,tran_date,sessionID)
			select @username,t.AC_NUMBER,t.AC_NUMBER +'|'+ a.acct_name,
						case when t.DRAMOUNT=0 then 'cr' else 'dr' end as TRN_TYPE,
						case when t.DRAMOUNT=0 then cast(t.CRAMOUNT as money) else cast(t.DRAMOUNT as money) end as TRN_AMT,
						getdate(),@sessionId
			from #tempTranUpload t join  ac_master a  on a.acct_num=t.AC_NUMBER order by t.rowid
			
			
			-- ############### Drop temp Table
			drop table #tempTranUpload

			Select 'Upload Complete.'
		end
	else
		Select 'Erro while uploadfile' PINSN,'' PIN,'' PINEXPIRY

end










GO
