USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[SplitSingleChar]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[SplitSingleChar] (@Name varchar(100))
RETURNS @table TABLE (Cnt int,SingleChar char(1),sNo int)
AS
begin
	declare @str int=0
	DECLARE @RESULT TABLE(SingleChar char(1))
	while LEN(@Name) >= @str
	begin
		if (substring(@Name,@str,1) <>' ')
		begin
			insert into @RESULT
			SELECT substring(@Name,@str,1)
		end
		set @str = @str+1 
	end

	INSERT INTO @table
	select count(1),SingleChar,ROW_NUMBER() over(order by SingleChar) from @RESULT group by SingleChar

RETURN 
end

----select * from dbo.[SplitSingleChar]('asjbasad')
GO
