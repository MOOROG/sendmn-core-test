USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[spa_generate_calendar]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- spa_generate_calendar '2010-04-14',2062,31,31,31,32,31,31,29,30,29,30,29,31

CREATE procEDURE [dbo].[spa_generate_calendar]
	@eng_date datetime,
	@nepali_year int,
	@baishakh int,
	@jestha int,
	@ashadh int,
	@shrawan  int,
	@bhadra int,
	@ashwin int,
	@kartik int,
	@mangshir int,
	@poush int,
	@magh int,
	@falgun int,
	@chaitra int

as
begin


	declare @nepali_date varchar(20),@nep_day int,@nep_month int,
		@total_date_diff int,@counter int,@counter_date datetime, @counter_diff int, @daysinyear int
	
	
	set @daysinyear=@baishakh +	@jestha +@ashadh +@shrawan  +	@bhadra +	@ashwin +	@kartik +	@mangshir +	@poush +	@magh +	@falgun +	@chaitra

	
set @nep_day=1
set @nep_month=1

--@total_date_diff=365
--set @total_date_diff=datediff(d,@eng_date,dateadd(yy,1,@eng_date))
set @total_date_diff=datediff(d,@eng_date,dateadd(d,@daysinyear,@eng_date))

set @counter=0
--First Date


while @counter < @total_date_diff
begin
	set @counter_date=dateadd(d,@counter,@eng_date)
	
	if @counter<@baishakh
	begin
		set @nep_day=@counter+1
		set @nep_month=1	
	end
	else if @counter < @baishakh+@jestha
	begin
		set @nep_day=@counter-@baishakh + 1
		set @nep_month=2
	end
	
	else if @counter < @baishakh+@jestha+@ashadh
	begin
		set @nep_day=@counter-@baishakh-@jestha +1
		set @nep_month=3
	end

	else if @counter < @baishakh+@jestha+@ashadh+@shrawan
	begin
		set @nep_day=@counter-@baishakh-@jestha-@ashadh +1 
		set @nep_month=4
	end
	
	else if @counter < @baishakh+@jestha+@ashadh+@shrawan+@bhadra
	begin
		set @nep_day=@counter-@baishakh-@jestha-@ashadh-@shrawan + 1
		set @nep_month=5
	end
	
	else if @counter <  @baishakh+@jestha+@ashadh+@shrawan+@bhadra+@ashwin
	begin
		set @nep_day=@counter-@baishakh-@jestha-@ashadh-@shrawan-@bhadra + 1
		set @nep_month=6
	end

	else if @counter <  @baishakh+@jestha+@ashadh+@shrawan+@bhadra+@ashwin+@kartik
	begin
		set @nep_day=@counter-@baishakh-@jestha-@ashadh-@shrawan-@bhadra-@ashwin + 1
		set @nep_month=7
	end
	
	else if @counter <  @baishakh+@jestha+@ashadh+@shrawan+@bhadra+@ashwin+@kartik+@mangshir
	begin 
		set @nep_day=@counter-@baishakh-@jestha-@ashadh-@shrawan-@bhadra-@ashwin-@kartik + 1
		set @nep_month=8
	end
	
	else if @counter <  @baishakh+@jestha+@ashadh+@shrawan+@bhadra+@ashwin+@kartik+@mangshir+@poush
	begin
		set @nep_day=@counter-@baishakh-@jestha-@ashadh-@shrawan-@bhadra-@ashwin-@kartik-@mangshir + 1
		set @nep_month=9
	end
	
	else if @counter < @baishakh+@jestha+@ashadh+@shrawan+@bhadra+@ashwin+@kartik+@mangshir+@poush+@magh
	begin
		set @nep_day=@counter-@baishakh-@jestha-@ashadh-@shrawan-@bhadra-@ashwin-@kartik-@mangshir-@poush + 1
		set @nep_month=10
	end
	
	else if @counter < @baishakh+@jestha+@ashadh+@shrawan+@bhadra+@ashwin+@kartik+@mangshir+@poush+@magh+@falgun
	begin
		set @nep_day=@counter-@baishakh-@jestha-@ashadh-@shrawan-@bhadra-@ashwin-@kartik-@mangshir-@poush-@magh + 1
		set @nep_month=11
	end
	
	else if @counter < @baishakh+@jestha+@ashadh+@shrawan+@bhadra+@ashwin+@kartik+@mangshir+@poush+@magh+@falgun+@chaitra
	begin
		set @nep_day=@counter-@baishakh-@jestha-@ashadh-@shrawan-@bhadra-@ashwin-@kartik-@mangshir-@poush-@magh-@falgun + 1
		set @nep_month=12
	end

	set @nepali_date=dbo.FNAFormatNumber(@nep_month)+'-'+dbo.FNAFormatNumber(@nep_day)+'-'+cast(@nepali_year as varchar)


	insert tbl_calendar values(@counter_date,@nepali_date)
	set @counter=@counter+1
	
	update tbl_setup
	set
		baisakh=@baishakh,
		jestha=@jestha,
		ashadh=@ashadh,
		shrawan=@shrawan,
		bhadra=@bhadra,
		ashwin=@ashwin,
		kartik=@kartik,
		mangshir=@mangshir,
		paush=@poush,
		magh=@magh,
		falgun=@falgun,
		chaitra=@chaitra

	end
end


--truncate table tbl_calendar



GO
