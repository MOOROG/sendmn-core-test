USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[procLederMovement]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Exec procLederMovement 'm','20','10','111021511, 111010152, 111000495, 111020859'

CREATE proc  [dbo].[procLederMovement]
	@flag char(1),
	@moveFrom varchar(20),
	@moveTo varchar(20),
	@AcNumbers varchar(5000)
AS
	set nocount on;

If @flag='m'
begin
	
	declare @ExistOrNot as varchar(20)

	if @moveFrom='' or @moveTo='' or @AcNumbers=''
	begin
		SELECT 'INVALID GL CODES TO MOVE' as REMARKS
		return;
	end
	
	set @ExistOrNot=''
	set @ExistOrNot=''+@AcNumbers+''
	 
	-- UPDATE AC TABLE
		exec('update ac_master set gl_code='+ @moveTo +' where gl_code='+ @moveFrom +'
			and acct_num in ('+ @AcNumbers +')')
		
	-- UPDATE TRAN TABLE
		exec('update tran_master set gl_sub_head_code='+ @moveTo +' where gl_sub_head_code='+ @moveFrom +'
			and acc_num in ('+ @AcNumbers +')')
		
	--  UPDATE CONFIG TABLE
		-- update configTable set value=@moveTo where value=@moveFrom
	 
	-- select * from configTable where value=@moveFrom
		SELECT 'UPDATE SUCCESS' as REMARKS
	
end



GO
