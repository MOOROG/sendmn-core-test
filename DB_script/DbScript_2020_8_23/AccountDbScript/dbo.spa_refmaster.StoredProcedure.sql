USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[spa_refmaster]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spa_refmaster]  
 @flag char(1),  
 @refid int = null,  
 @ref_rec_type int = null,  
 @ref_code varchar(100) = null,  
 @ref_desc varchar(100) = null,  
 @username varchar(50) = null  
 --@del_flg char(1) = null  
  
AS  
set nocount on;  
if @flag='s'  
begin  
  
 select * from ref_master with(nolock) where refid=@refid  
  
end  
if @flag='a'  
begin  
  
 select * from ref_master with(nolock) where ref_rec_type=@ref_rec_type  
  
end  
  
if @flag='c'  
begin  
  
 select ref_code, ref_desc as refDesc from ref_master with(nolock)   
 where ref_rec_type=@ref_rec_type order by ref_code  
  
end  
  
if @flag = 'i'  
begin  
  insert into ref_master  
  (  
   ref_rec_type,  
   ref_code,  
   ref_desc,  
   CREATED_BY,  
   CREATED_DATE  
   --del_flg  
  )  
  values  
  (  
   @ref_rec_type,  
   @ref_code,  
   @ref_desc,  
   @username,  
   GETDATE()  
   --@del_flg  
  )  
  --###### Exec JobHistoryRecord 'i','JOB NAME','OLD VALUE','NEW VALUE','REMARKS','UPDATED ROW','user'  
 Exec JobHistoryRecord 'i','DATA ADDED','',@ref_code,@ref_desc ,'',@ref_rec_type  
    
end  
  
  
if @flag = 'u'  
begin  
  update ref_master set  
   --ref_rec_type = @ref_rec_type,  
   ref_code = @ref_code,  
   ref_desc = @ref_desc,  
   MODIFIED_BY = @username,  
   MODIFIED_DATE = GETDATE()  
   --del_flg = @del_flg  
  where refid = @refid  
 --###### Exec JobHistoryRecord 'i','JOB NAME','OLD VALUE','NEW VALUE','REMARKS','UPDATED ROW','user'  
 Exec JobHistoryRecord 'i','DATA MODIFIED','',@ref_code,@ref_desc ,@refid,''  
   
end  
  
if @flag = 'd'  
begin  
  delete from ref_master where refid = @refid  
end  
GO
