USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_fiscalyear_setup]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
select * from FiscalYear
exec [proc_fiscalyear_setup] 'i','admin','2009',''
exec [proc_fiscalyear_setup] 's',@id ='2009'
exec [proc_fiscalyear_setup] 'u','admin','2009','2009','66-67','7/16/2009 12:00:00 AM','7/17/2010 12:00:00 AM','True'
exec [proc_fiscalyear_setup] 'c'
*/
CREATE procedure [dbo].[proc_fiscalyear_setup]
		@flag char(1),
		@user varchar(100)=null,
		@id int=null,
		@FISCAL_YEAR_ENGLISH varchar(20)=null,
		@FISCAL_YEAR_NEPALI varchar(20)=null,
		@EN_YEAR_START_DATE date=null,
		@EN_YEAR_END_DATE date=null,
		@strflag varchar(5)=null	
as
set nocount on;
if(@flag ='c')
begin
	--if exists(select * from FiscalYear where FLAG = @strflag)
	if exists(select * from FiscalYear where FLAG = 'true')
	begin
		select 'True' 'Flag'
	end	
	else
	begin
		select 'False' 'Flag'
		return;
	end
end
if(@flag ='i')
begin
	insert into FiscalYear (FISCAL_YEAR_ENGLISH, 
				FISCAL_YEAR_NEPALI, EN_YEAR_START_DATE,
				EN_YEAR_END_DATE,FLAG)
	values(@FISCAL_YEAR_ENGLISH,@FISCAL_YEAR_NEPALI,
				@EN_YEAR_START_DATE,@EN_YEAR_END_DATE,@strflag)
end
if(@flag ='u')
begin
	update FiscalYear 
			set FISCAL_YEAR_ENGLISH = @FISCAL_YEAR_ENGLISH, 
				FISCAL_YEAR_NEPALI = @FISCAL_YEAR_NEPALI, 
				EN_YEAR_START_DATE = @EN_YEAR_START_DATE,
				EN_YEAR_END_DATE = @EN_YEAR_END_DATE, 
				FLAG = @strflag  
			where FISCAL_YEAR_ID = @id
end
if(@flag ='s')
begin
--CONVERT(VARCHAR,AP.APPLIED_DATE,107)
			select FISCAL_YEAR_ENGLISH, FISCAL_YEAR_NEPALI, CONVERT(VARCHAR,EN_YEAR_START_DATE,101) as 'EN_YEAR_START_DATE',
			CONVERT(VARCHAR, EN_YEAR_END_DATE,101) as 'EN_YEAR_END_DATE',FLAG from FiscalYear
			where FISCAL_YEAR_ID = @id
end


GO
