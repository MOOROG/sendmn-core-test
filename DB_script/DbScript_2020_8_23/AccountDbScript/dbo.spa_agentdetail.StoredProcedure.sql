ALTER PROCEDURE [dbo].[spa_agentdetail]
	@flag char(1),
	@agent_id int =null,
	@agent_name varchar(100)=null,
	@agent_short_name varchar(50)=null,
	@agent_address varchar(50)=null,
	@agent_city varchar(50)=null,
	@agent_address2 varchar(100)=null,
	@agent_phone varchar(50)=null,
	@agent_fax varchar(50)=null,
	@agent_email varchar(50)=null,
	@agent_contact_person varchar(50)=null,
	@agent_contact_person_mobile varchar(50)= null,
	@agent_status char(1)=null,
	
	@MAP_code varchar(20)=null,
	@MAP_code2 varchar(20)=null,
	@agenttype varchar(25) = NULL,
	@agent_imecode varchar(25) = NULL,
	@TDS_PCNT money = null,
	@agentregion varchar(25)= null,
	@agentzone varchar(25) = null,
	@agentdistrict varchar(25) = null,
	
	@agent_panno varchar(50)= null,
	@regno varchar(50)= null,
	@bankcode varchar(50)= null,
	@bankaccno varchar(50)= null,
	@bankbranch varchar(50) = null,
	@accholderName varchar(50)=null,
	@constitution varchar(50)= null,
	@tid varchar(50)= null,
	@central_sett	CHAR(1) = NULL,
	
	@ismainAgent		CHAR(1)  = NULL,
	@CENTRAL_SETT_CODE	VARCHAR(50) = NULL,
	
	@commissionDeduction money=null,
	@username varchar(20)=null,
	@company_id varchar(20)=NULL,
	@agent_country VARCHAR(50) = NULL
	


AS
set nocount on;

	declare @glcode varchar(10), @acct_num varchar(20);
	create table #tempACnum (acct_num varchar(20));

if @flag='a' 
begin
	Select * from agentTable WITH (NOLOCK)
end

if @flag='s' 
begin
	
	Select * from agentTable WITH (NOLOCK) where agent_id=@agent_id

end

if @flag='v' 
begin
	
	Select *
	from agentTable WITH (NOLOCK) where agent_id=@agent_id

end

if @flag='i' 
begin

		if exists(
		select agent_id from agentTable WITH (NOLOCK) where isnull(map_code,0) = @MAP_code
		) and @MAP_code <> 0
		begin
			select 'Already Exists Map Code International ' as REMARKS
			return;
		end
    
		--print @agent_imecode

		if exists(
		select agent_id from agentTable WITH (NOLOCK) where isnull(AGENT_IME_CODE,0) = @agent_imecode
		) and @agent_imecode<>0
		begin
			select 'Already Exists Map code Domestic ' as REMARKS
			return;
		end

	if not exists(
	select 'a' from SendMnPro_Remit.dbo.agentMaster WITH (NOLOCK) where agentId = @MAP_code and agentApiType='Receiving Partner'	) 
	begin
		select 'Invalid Receiving Partner' as REMARKS
		return;
	end

	insert into agentTable(agent_name,agent_short_name,agent_address,
	agent_address2,agent_city,
	agent_phone,agent_fax,agent_email,agent_contact_person,
	AGENT_CONTACTPERSON_MOBILE,agent_create_date,
	agent_create_by,agent_status,map_code,map_code2,
	AGENT_TYPE,AGENT_IME_CODE,TDS_PCNT,AGENT_REGION,AGENTZONE,AGENTDISTRICT,
	PANNUMBER,REGNUMBER,
	BANKCODE,BANKACCOUNTNUMBER,BANKBRANCH,CONSTITUTION,RECEIVING_CURRANCY
     ,tid,central_sett,central_sett_code,IsMainAgent,commissionDeduction,ACCOUNTHOLDERNAME, agent_country
	)--
	values (@agent_name,@agent_short_name,@agent_address,@agent_address2,@agent_city,
	@agent_phone,@agent_fax,@agent_email,@agent_contact_person,@agent_contact_person_mobile,GETDATE(),
	@username,@agent_status,@MAP_code,@MAP_code2,
	@agenttype,@agent_imecode,@TDS_PCNT,@agentregion,@agentzone,@agentdistrict,
	@agent_panno,@regno,@bankcode,
	@bankaccno,@bankbranch,@constitution,'NPR'
	,@tid,@central_sett,@CENTRAL_SETT_CODE,@ismainAgent,@commissionDeduction,@accholderName,@agent_country
	)

	set @agent_id = @@identity

if not exists(SELECT 'a'  FROM SendMnPro_Remit.dbo.AgentMaster (nolock) where agentId = @MAP_code AND agentApiType = 'Parent')
begin
	set @glcode = '77'	--Correspondent Principle Payable
			
		insert into #tempACnum
		exec spa_createAccountNumber 'a', @glcode

		select @acct_num=acct_num from #tempACnum

		insert into ac_master (acct_num, acct_name,gl_code, agent_id, branch_id, 
		acct_ownership,dr_bal_lim, lim_expiry, acct_rpt_code, acct_type_code,
		frez_ref_code, acct_opn_date,clr_bal_amt, system_reserved_amt,
		system_reserver_remarks,lien_amt, lien_remarks, utilised_amt, available_amt,
		created_date,created_by,company_id)
		values(@acct_num,@agent_name+'- Principle',@glcode, @MAP_code,null,'c',0,null,'TP',
		null,null,getdate(),0,0,null,0,null,0,0,getdate(),@username,1)

		delete from #tempACnum
		-----------------------------
		
		--############# Comm AC #######
		set @glcode = '78'	--Intl comession
		
		
		insert into #tempACnum
		exec spa_createAccountNumber 'a', @glcode

		select @acct_num = acct_num from #tempACnum

		insert into ac_master (acct_num, acct_name,gl_code, agent_id, branch_id, 
		acct_ownership,dr_bal_lim, lim_expiry, acct_rpt_code, acct_type_code,
		frez_ref_code, acct_opn_date,clr_bal_amt, system_reserved_amt, 
		system_reserver_remarks,lien_amt, lien_remarks, utilised_amt, available_amt,
		created_date,created_by,company_id)
		values(@acct_num,@agent_name+'- Commission',@glcode, @MAP_code,null,'c',0,null,'TC',
		null,null,getdate(),0,0,null,0,null,0,0,getdate(),@username,1)

		delete from #tempACnum
end

    select 'Created Successfully ' as REMARKS

	--###### Exec JobHistoryRecord 'i','JOB NAME','OLD VALUE','NEW VALUE','REMARKS','UPDATED ROW','raghu'
	Exec JobHistoryRecord  'i','AGENT ADDED','',@glcode,@agent_name ,@agent_id,@username
end

if @flag='u' 
begin
	SELECT @agent_id = AGENT_ID FROM agentTable (NOLOCK) WHERE isnull(map_code,0) = @agent_id

	if exists(
		select agent_id from agentTable where isnull(map_code,0) = @MAP_code
		and agent_id <> @agent_id
		) and isnull(@MAP_code,0) <> 0
		begin
			select 'Already Exists Map Code International' as REMARKS
			return;
		end

		if exists(
		select agent_id from agentTable where isnull(AGENT_IME_CODE,0) = @agent_imecode
		and agent_id<>@agent_id
		) and isnull(@agent_imecode,0)<>0 
		begin
			select 'Already Exists Map code domestic' as REMARKS
			return;
		end
		
	update agentTable set
	agent_name = @agent_name,
	agent_short_name = @agent_short_name,
	agent_address = @agent_address,
	agent_city = @agent_city,
	agent_address2 = @agent_address2,
	agent_phone = @agent_phone,
	agent_fax = @agent_fax,
	agent_email = @agent_email,
	agent_contact_person = @agent_contact_person,
	AGENT_CONTACTPERSON_MOBILE = @agent_contact_person_mobile,
	agent_modify_date = getdate(),
	agent_modify_by = @username,
	agent_status = @agent_status,
	[AGENT_IME_CODE] = @agent_imecode,
	TDS_PCNT = @TDS_PCNT,
	AGENT_REGION = @agentregion,
	AGENTZONE = @agentzone,
	AGENTDISTRICT = @agentdistrict,
	
	PANNUMBER = @agent_panno,
	REGNUMBER = @regno,
	BANKCODE = @bankcode,
	BANKACCOUNTNUMBER = @bankaccno,
	BANKBRANCH = @bankbranch,
	ACCOUNTHOLDERNAME=@accholderName,
	CONSTITUTION = @constitution,
	RECEIVING_CURRANCY = 'NPR',
    tid = @tid,
    central_sett = @central_sett,
	central_sett_code = @CENTRAL_SETT_CODE,
	IsMainAgent = @ismainAgent,
	commissionDeduction = @commissionDeduction,
	agent_country = @agent_country
	where agent_id = @agent_id
	
	if @agent_status='n'
	begin
		update ac_master set acct_cls_flg = 'c', acct_cls_date = getdate() where agent_id = @agent_id
	end

     --select 'Updated Successfully ' as REMARKS

	--###### Exec JobHistoryRecord 'i','JOB NAME','OLD VALUE','NEW VALUE','REMARKS','UPDATED ROW','raghu'
	Exec JobHistoryRecord  'i','AGENT DETAIL MODIFIED','',@glcode,@agent_name ,@agent_id,@username
	
end

if @flag='d' 
begin
	Delete from agentTable where agent_id=@agent_id
end







GO
