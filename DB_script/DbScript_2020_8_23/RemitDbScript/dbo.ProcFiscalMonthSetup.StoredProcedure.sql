USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ProcFiscalMonthSetup]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
select nplYear, convert(varchar, engDateBaisakh,107) 'engDateBaisakh', baisakh, jestha, ashadh, shrawan, bhadra, ashwin,kartik, mangshir, poush, magh, falgun, chaitra from  Fiscal_Month
exec ProcFiscalMonthSetup 'i',
exec ProcFiscalMonthSetup 'c',@nplYear = '2066'
exec ProcFiscalMonthSetup 'c',@nplYear = '2066',@engDateBaisakh='2010-07-17'
--SELECT * FROM Fiscal_Month
*/
CREATE procedure [dbo].[ProcFiscalMonthSetup]
		@flag char(1),
		@nplYear varchar(10),
		@engDateBaisakh varchar(10)=null,
		@baisakh int=null,
		@jestha int=null,
		@ashadh int=null,
		@shrawan int=null,
		@bhadra int=null,
		@ashwin int=null,
		@kartik int=null,
		@mangshir int=null,
		@poush int=null,
		@magh int=null,
		@falgun int=null,
		@chaitra int=null
as		
		set nocount on;
if(@flag ='c')
begin
	if  exists(select * from Fiscal_Month where nplYear = @nplYear or YEAR(engDateBaisakh) = YEAR(@engDateBaisakh))	
	select 'True'
	else
	select 'False'
end	
	
if(@flag ='i')
begin
	begin	
		if  exists(select * from Fiscal_Month where nplYear = @nplYear or YEAR(engDateBaisakh) = YEAR(@engDateBaisakh))		
		select 'True'
		else
			begin
				insert into Fiscal_Month
						(nplYear,  engDateBaisakh, baisakh, jestha, ashadh, shrawan, bhadra, ashwin, kartik, mangshir, poush, magh, falgun, chaitra)
				values	(@nplYear, @engDateBaisakh,@baisakh,@jestha,@ashadh,@shrawan,@bhadra,@ashwin,@kartik,@mangshir,@poush,@magh,@falgun,@chaitra)
			
						exec spa_generate_calendar @engDateBaisakh,@nplYear,@baisakh,@jestha,@ashadh,@shrawan,@bhadra,@ashwin,@kartik,@mangshir,
						@poush,@magh,@falgun,@chaitra
			end
	end
end


GO
