USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_checkPayLock]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	/*
	exec proc_checkPayLock @user ='admin',@controlNo = '',@agentId ='1226'
	
	DECLARE @CTL_NO VARCHAR(50)
	SELECT  @CTL_NO = dbo.FNAEncryptString('7133316037D')
	exec proc_checkPayLock @user ='admin',@controlNo = @CTL_NO,@agentId ='1226'
	select * from tranLockPay
	UPDATE tranLockPay SET APPROVEDBY ='admin',approvedDate = getdate() where id =1
	delete from tranLockPay where id=3

	TRUNCATE TABLE tranLockPay
	*/

	CREATE proc [dbo].[proc_checkPayLock]
		 @user						VARCHAR(10)		= NULL
		,@controlNo					VARCHAR(50)		= NULL
		,@agentId					VARCHAR(50)		= NULL

	AS
	SET NOCOUNT ON
	SET XACT_ABORT ON
	
	declare @pAmt as money, @days as int, @txnDate as datetime, @tSetFlag varchar(10) = 'pay',@eSetFlag varchar(10) = 'pay'
	select @pAmt = pAmt,@txnDate = createdDateLocal from remitTran with(nolock) where controlNo = @controlNo
	if @pAmt > 300000
	begin
		if not exists(select 'x' from tranLockPay with(nolock) 
							where controlNo = @controlNo 
								and pAgent = @agentId 
								and rejecteddate is null 
								and flag = 't')
		begin
			insert into tranLockPay 
			(
				 controlNo
				,pAgent
				,flag
				,createdBy
				,createddate
				,flagValue
			)
			values
			(
				 @controlNo
				,@agentId
				,'t'
				,@user
				,getdate()
				,@pAmt
			)

			set @tSetFlag = 'dontPay'
		end
		if exists(select 'x' from tranLockPay with(nolock) 
							where controlNo = @controlNo 
								and pAgent = @agentId 
								and rejecteddate is null
								and approveddate is null
								and flag = 't')
		begin
			set @tSetFlag = 'dontPay'
		end
	end
	set @days  =  datediff(day,@txnDate,getdate())

	if @days > 30
	begin
		if not exists(select 'x' from tranLockPay with(nolock) 
							where controlNo = @controlNo 
								and pAgent = @agentId 
								and rejecteddate is null 
								and flag = 'e')
		begin
			insert into tranLockPay 
			(
				 controlNo
				,pAgent
				,flag
				,createdBy
				,createddate
				,flagValue
			)
			values
			(
				 @controlNo
				,@agentId
				,'e'
				,@user
				,getdate()
				,@days
			)

			set @eSetFlag = 'dontPay'
		end
		if exists(select 'x' from tranLockPay with(nolock) 
							where controlNo = @controlNo 
								and pAgent = @agentId 
								and rejecteddate is null 
								and approveddate is null
								and flag = 'e')
		begin
			set @eSetFlag = 'dontPay'
		end
	end

	select @tSetFlag tSetFlag, @eSetFlag eSetFlag






GO
