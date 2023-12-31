USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[PROC_REPORT_JOB]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



/*


EXEC PROC_REPORT_JOB
 @flag='c'
,@job_name ='PLReport'
,@job_user ='admin'
,@SQL=''


EXEC PROC_REPORT_JOB
 @flag='r'
,@job_name ='PLReport'
,@job_user ='admin'
,@reportJobId = '6'


--truncate table DUMP_PL_REPORT
--truncate table ReportJobHistory

select * from ReportJobHistory
select * from DUMP_PL_REPORT

EXEC PROC_REPORT_JOB @flag='r',@job_name ='CompileReport',@job_user ='admin', @reportJobId ='29'


EXEC PROC_REPORT_JOB @flag='c',@job_name ='CompileReport',@job_user ='admin', 
@date1='12/30/2012', @date2= '12/30/2012', @SQL= 'EXEC proc_compileReport @flag=''A'', @DATE=''12/30/2012'',@SAGENT=Null,@INCLUDEZERO=''Y'',@BANKCODE=Null,@DR1= Null,@DR2= Null,@CR1= Null,@CR2= Null'

EXEC proc_compileReport @flag='A', @DATE='12/30/2012',@SAGENT=Null,@INCLUDEZERO='Y',@BANKCODE=Null,@DR1= Null,@DR2= Null,@CR1= Null,@CR2= Null, @reportJobId = 14


*/

create PROC [dbo].[PROC_REPORT_JOB]
    @flag varchar(20),
    @job_name varchar(20),
    @job_user varchar(20)=null,
    @SQL VARCHAR(2000)=null,
    @reportJobId varchar(20) =null,
    @date1 varchar(20) =null,
    @date2 varchar(20) =null,
    @url varchar(max) =null
AS

 SET NOCOUNT ON;


IF @job_name ='CompileReport' 
BEGIN

      If @flag ='c'
	 BEGIN
		  
		 -- alter table ReportJobHistory add url varchar(max)
          
		INSERT INTO ReportJobHistory(job_user,job_date,job_name,job_desc,job_status, rdate1, rdate2, url )
		VALUES (@job_user,GETDATE(), @job_name, @job_name + ' is processing ..','N',@date1,@date2, @url)

		SET @reportJobId = @@IDENTITY 
		SET @SQL = @SQL + ', @reportJobId = '+ @reportJobId

		--print @SQL

		EXEC ProcCreateSchedultJobOneTime 
				 @JOB_NAME=@job_name
				,@SQL=@SQL
				,@DB='FastMoneyPro_account'
				,@ReplaceIfExists='Y'

     END

    If @flag ='v'
    BEGIN
      
		  SELECT TOP 20 rowid, job_user, job_date, job_desc, job_status, rdate1, rdate2, url  from ReportJobHistory 
		  WHERE job_name = @job_name 
		  ORDER BY rowid DESC
	   
    END
    If @flag ='r'
    BEGIN
      
		  SELECT  *
		  FROM DUMP_COMPILE_REPORT
		  WHERE reportJobId = @reportJobId
		  ORDER BY BANKCODE, agent_name
	   
    END
    
    If @flag ='d'
    BEGIN
	   
		delete from ReportJobHistory 
		where   rowid = @reportJobId

		DELETE
		FROM DUMP_COMPILE_REPORT
		WHERE reportJobId = @reportJobId

    END

END


IF @job_name ='PLReport' 
BEGIN

      If @flag ='c'
	 BEGIN
		  
		 -- alter table ReportJobHistory add job_ready_date datetime
          
		INSERT INTO ReportJobHistory(job_user,job_date,job_name,job_desc,job_status, rdate1, rdate2, url )
		VALUES (@job_user,GETDATE(), 'PLReport', 'PL Report is processing ..','N',@date1,@date2, @url)

		SET @reportJobId = @@IDENTITY 

		SET @SQL = ' Exec procBalancesheet @flag = ''p'',@date1='''+ @date1 +''',@date2='''+ @date2 +''', @reportJobId = '''+ @reportJobId +''' '

		EXEC ProcCreateSchedultJobOneTime 
				 @JOB_NAME=@job_name
				,@SQL=@SQL
				,@DB='FastMoneyPro_account'
				,@ReplaceIfExists='Y'

     END

    If @flag ='v'
    BEGIN
      
		  SELECT TOP 20 rowid, job_user, job_date, job_desc, job_status, rdate1, rdate2, url  from ReportJobHistory 
		  WHERE job_name = @job_name 
		  ORDER BY rowid DESC
	   
    END
    If @flag ='r'
    BEGIN
      
		  SELECT  GL_DESC,gl_code, YEARTODATE, THISMONTH, tree_sape, FILTER, reportJobId 
		  FROM DUMP_PL_REPORT
		  WHERE reportJobId = @reportJobId
	   
    END
    If @flag ='d'
    BEGIN

		  delete from ReportJobHistory 
		  where rowid = @reportJobId
          
		  DELETE
		  FROM DUMP_PL_REPORT
		  WHERE reportJobId = @reportJobId

    END

END





GO
