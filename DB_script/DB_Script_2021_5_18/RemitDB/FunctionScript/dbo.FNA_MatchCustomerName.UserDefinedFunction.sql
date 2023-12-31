USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNA_MatchCustomerName]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNA_MatchCustomerName](@CName varchar(100),@CompName varchar(100))
returns bit
as
begin
declare @str int = 1,@cnt int 
	
	DECLARE @TempCustomer TABLE(Cnt int,SingleChar char(1),sNO INT)
	DECLARE @TempCompare TABLE(Cnt int,SingleChar char(1),sNO INT)

	INSERT INTO @TempCustomer
	select * from dbo.[SplitSingleChar](@CName) 

	INSERT INTO @TempCompare
	select * from dbo.[SplitSingleChar](@CompName)

	select @cnt = count(1) from @TempCustomer

	declare @SingleChar char(1),@chatCnt int

	declare @result table (SingleChar char(1),Cnt int, hasMatched bit)

	while @cnt >= @str
	begin
		select @SingleChar = SingleChar,@chatCnt = Cnt from @TempCustomer where sNo = @str

		IF EXISTS(select * from @TempCompare where SingleChar = @SingleChar and Cnt > =@chatCnt)
		BEGIN
			INSERT INTO @result
			select @SingleChar,@chatCnt,1 from @TempCompare where SingleChar = @SingleChar and Cnt > =@chatCnt 
		END
		ELSE
		BEGIN
			INSERT INTO @result
			select @SingleChar,@chatCnt,0
		END
		set @str = @str + 1
	end
	IF EXISTS(SELECT * FROM @result WHERE hasMatched = 0)
		SET @cnt = 0
	else
		SET @cnt = 1

	RETURN @cnt
end
GO
