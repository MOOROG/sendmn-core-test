USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[ProcSearchAc]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec ProcSearchAc '802400042636'

CREATE PROCEDURE [dbo].[ProcSearchAc]  
 @acct_Num varchar(50),  
 @flag varchar(1) = 'a'  

as  
begin  
set nocount on;  
 
declare @gl_code varchar(50)  
declare @bal_grp varchar(50)  
  
set @gl_code = @acct_Num  
  
create table #accList  
(  
 pos  int identity(1,1),  
 id  varchar(50),  
 Name varchar(50)  
)  
  
if @flag = 'a'  
begin  
 insert  into #accList (id,Name)  
 select acct_num,acct_name from ac_master with (nolock) where acct_Num=@acct_Num  
 select @gl_code=isnull(gl_code,0) from ac_master with (nolock) where acct_Num=@acct_Num  
end 
if @flag = 'G'  
begin  
 insert  into #accList (id,Name) 
 select GL_CODE,GL_NAME from GL_Group WHERE gl_name = @acct_Num
 select @gl_code=isnull(gl_code,0) from GL_Group WHERE gl_name = @acct_Num
end  
  
While isnumeric(@gl_code)=1 and exists(select gl_code from GL_GROUP with (nolock) where gl_code=@gl_code)  
begin  
 insert  into #accList (id,Name)    
 select gl_code,gl_name from GL_GROUP with (nolock) where gl_code=@gl_code    
 select @bal_grp=isnull(bal_grp,'na'),@gl_code=isnull(p_id,'na') from GL_GROUP with (nolock) where gl_code=@gl_code    
end  

--SELECT @bal_grp, @gl_code
--RETURN  


insert  into #accList (id,Name)  
select rowid,lable from report_format with (nolock) where reportid=@bal_grp  
  
  
insert  into #accList (id,Name)  
select   
 case grp_main when 's' then '' else '' end as id,  
 case grp_main when 's' then 'SOURCE OF FUNDS' else 'APPLICATION OF FUNDS' end as name  
 from report_format with (nolock) where reportid=@bal_grp  
  
--select * from #accList
  
declare @rows int  
select @rows=COUNT(*) from #accList  
  
select    
 case when id='' then Name else   
replace(space((@rows-pos) * 10),' ','&nbsp;') + id + ' - ' + Name end as Name from #accList order by pos desc  
  
end 




GO
