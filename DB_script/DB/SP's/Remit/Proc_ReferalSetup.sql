USE [FastMoneyPro_Remit]
GO

ALTER PROC PROC_REFERALSETUP
		@FLAG    VARCHAR(20)  
		,@user					VARCHAR(50)  = NULL  
		,@pageSize				VARCHAR(50)  = NULL  
		,@pageNumber			VARCHAR(50)  = NULL  
		,@sortBy				VARCHAR(50)  = NULL  
		,@sortOrder				VARCHAR(50)  = NULL  
		,@agentID				BIGINT		 = NULL  
		,@referralName			VARCHAR(50)  = NULL
		,@referralAddress		VARCHAR(100) = NULL
		,@referralMobile		VARCHAR(50)	 = NULL
		,@referralEmail			VARCHAR(50)	 = NULL
		,@isActive				CHAR(1)		 = NULL
		,@rowId					INT			 = NULL
		,@REFERRAL_CODE			VARCHAR(30)  = NULL
		,@AGENTNAME				VARCHAR(30)  = NULL
		,@REFERRAL_NAME			VARCHAR(30)  = NULL
		,@REFERRAL_MOBILE		VARCHAR(30)  = NULL
		,@REFERRAL_ADDRESS		VARCHAR(30)  = NULL
		,@REFERRAL_EMAIL		VARCHAR(50)  = NULL
		,@IS_ACTIVE				VARCHAR(30)  = NULL
		,@referralTypecode		VARCHAR(30)  = NULL
		,@referralType			VARCHAR(50)  = NULL
		,@branchId				VARCHAR(30)  = NULL
		,@referralCode			VARCHAR(30)  = NULL
		,@ruleType				CHAR(1)		 = NULL
		,@cashHoldLimitAmount	VARCHAR(30)  = NULL
		,@DEDUCT_TAX_ON_SC		BIT			 = NULL
		,@DEDUCT_P_COMM_ON_SC	BIT			 = NULL
		,@partnerId				INT			 = Null
		,@commissionPercent		DECIMAL(10,4) = NULL
		,@forexPercent			DECIMAL(10,4)  = NULL
		,@flatTxnWise			MONEY		 = NULL
		,@NewCustomer			MONEY		 = NULL
		,@effectiveFrom			DATETIME	 = NULL
		,@referralId			INT			 = NULL
		,@ROW_ID				INT			 = NULL
	
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	 DECLARE  @table    VARCHAR(MAX)  
			 ,@select_field_list VARCHAR(MAX)  
			 ,@extra_field_list VARCHAR(MAX)  
			 ,@sql_filter  VARCHAR(MAX)  
			 ,@ACC_NUM VARCHAR(30)
IF @FLAG = 'S'  
	BEGIN  
		--SET @sortBy = 'createdDate'  
		--SET @sortOrder = 'desc' 
		SET @table = '(SELECT   ROW_ID
								,REFERRAL_CODE
							    ,REFERRAL_NAME
								,REFERRAL_MOBILE
								,REFERRAL_ADDRESS
								,REFERRAL_EMAIL
								,BRANCH_ID
								,REFERRAL_TYPE
								,REFERRAL_TYPE_CODE
								,AM.agentName BranchName
								,createdDate
								,CASE WHEN IS_ACTIVE = ''1'' THEN ''Yes'' else ''No'' END  IS_ACTIVE
								,CASE WHEN RULE_TYPE = ''H'' THEN ''Hold'' else ''Block'' END RULE_TYPE
								,REFERRAL_LIMIT
				          FROM REFERRAL_AGENT_WISE RA (NOLOCK)
						  LEFT JOIN agentMaster AM ON AM.agentId = RA.BRANCH_ID'  
		SET @sql_filter = ''  
		SET @table = @table + ')x'  
		IF @referralName IS NOT NULL
			SET @sql_filter = @sql_filter +' And REFERRAL_NAME LIKE '''+@referralName+'%'+''''  
		IF @referralCode IS NOT NULL
			SET @sql_filter = @sql_filter +' And REFERRAL_CODE LIKE '''+@referralCode+'%'+''''
		IF @branchId IS NOT NULL
			SET @sql_filter = @sql_filter +' And BRANCH_ID = '''+@branchId+''''  
		IF @referralTypecode IS NOT NULL
			SET @sql_filter = @sql_filter +' And REFERRAL_TYPE_CODE =  '''+@referralTypecode+''''
			
		SET @select_field_list  = '  
		    REFERRAL_CODE,REFERRAL_NAME,REFERRAL_MOBILE,REFERRAL_ADDRESS,REFERRAL_EMAIL,IS_ACTIVE,ROW_ID,
			BranchName,REFERRAL_TYPE,REFERRAL_TYPE_CODE,createdDate,RULE_TYPE,REFERRAL_LIMIT'  
		      
		EXEC dbo.proc_paging @table, @sql_filter, @select_field_list, @extra_field_list  
							, @sortBy, @sortOrder, @pageSize, @pageNumber  
	END  

ELSE IF @FLAG = 'i'
	BEGIN
		IF EXISTS(SELECT 1 FROM REFERRAL_AGENT_WISE WHERE REFERRAL_NAME = @referralName AND REFERRAL_MOBILE = @referralMobile)
		BEGIN
			EXEC proc_errorHandler 1,'Refererral with same name and mobile No. already exists',null
			RETURN
		END

		DECLARE @LATEST_ID INT

		INSERT INTO REFERRAL_AGENT_WISE (AGENT_ID,REFERRAL_CODE,REFERRAL_NAME,REFERRAL_ADDRESS,REFERRAL_MOBILE,REFERRAL_EMAIL,IS_ACTIVE,CREATED_BY,CREATED_DATE,BRANCH_ID,REFERRAL_TYPE_CODE,REFERRAL_TYPE,RULE_TYPE,REFERRAL_LIMIT)
								VALUES (0,'',@referralName,@referralAddress,@referralMobile,@referralEmail,@isActive,@user,GETDATE(),@branchId,@referralTypecode,@referralType,@ruleType,@cashHoldLimitAmount)

		SET @LATEST_ID =  @@IDENTITY

		SELECT @REFERRAL_CODE = 'JME' + RIGHT('0000000000' + CAST(@LATEST_ID AS VARCHAR), 4)

		UPDATE REFERRAL_AGENT_WISE SET REFERRAL_CODE = @REFERRAL_CODE
		WHERE ROW_ID = @LATEST_ID
		
		SELECT  '0' ErrorCode ,'Referral has been added successfully.' Msg ,@LATEST_ID id;
			
		DECLARE @ACC_NUM_COMM VARCHAR(30)
		--INSERT INTO AGENT_BRANCH_RUNNING_BALANCE
		INSERT INTO AGENT_BRANCH_RUNNING_BALANCE
		values (@LATEST_ID,'R',@referralName,0,0,0,0)

		SELECT @ACC_NUM = MAX(CAST(ACCT_NUM AS BIGINT)) + 1 
		FROM FastMoneyPro_Account.dbo.ac_master
		WHERE GL_CODE = 0 AND ACCT_RPT_CODE = 'RA'

		SELECT @ACC_NUM_COMM = MAX(CAST(ACCT_NUM AS BIGINT)) + 1 
		FROM FastMoneyPro_Account.dbo.ac_master
		WHERE GL_CODE = 0 AND ACCT_RPT_CODE = 'RAC'

		----## AUTO CREATE LEDGER FOR REFERRAL (COMM AND PRINCIPLE ACC)
		INSERT INTO FastMoneyPro_Account.dbo.ac_master (acct_num, acct_name,gl_code, agent_id, 
		acct_ownership,dr_bal_lim, acct_rpt_code,acct_opn_date,clr_bal_amt, system_reserved_amt, 
		lien_amt, utilised_amt, available_amt,created_date,created_by,company_id, ac_currency)
		SELECT @ACC_NUM,@REFERRAL_CODE,'0', @LATEST_ID,'o',0,'RA',getdate(),0,0,0,0,0,getdate(),@user,1, 'JPY' UNION ALL
		SELECT @ACC_NUM_COMM,ISNULL(@referralName, @REFERRAL_CODE)+'- Comm Payable Account','0', @LATEST_ID,'o',0,'RAC',getdate(),0,0,0,0,0,getdate(),@user,1, 'JPY'

		----##AUTO CREATE AGENT LOGIN DETAILS
		INSERT INTO REFERRAL_APPLICATION_USER 
		SELECT @REFERRAL_CODE, DBO.FNAENCRYPTSTRING('japan@12345'),0,null,1,null,0,null,null,null,1,30,30,null,0
		
	END

ELSE IF @FLAG = 'agentNames'
	BEGIN
   	  select agentId,AgentName  from agentmaster where actasbranch= 'N' and parentid='393877'
	END
ELSE IF @FLAG = 'branchNameForFilter'
	BEGIN
	  SELECT  null value,   'Select' [text] 
	  UNION ALL  
   	  select agentId as value,AgentName as text from agentMaster WHERE agentType = 2903 AND parentId= 393877 AND actAsBranch  = 'Y'
	END
ELSE IF @FLAG = 'getData'
	BEGIN
		SELECT AGENT_ID,REFERRAL_NAME,REFERRAL_ADDRESS,REFERRAL_EMAIL,IS_ACTIVE,REFERRAL_MOBILE,REFERRAL_TYPE_CODE,REFERRAL_TYPE,BRANCH_ID,RULE_TYPE,REFERRAL_LIMIT,DEDUCT_TAX_ON_SC
			   FROM REFERRAL_AGENT_WISE 
			   WHERE ROW_ID = @rowId
	END
ELSE IF @FLAG = 'u'
	BEGIN
		UPDATE REFERRAL_AGENT_WISE 
		SET AGENT_ID = 0
			,REFERRAL_NAME = @referralName
			,REFERRAL_ADDRESS = @referralAddress
			,REFERRAL_MOBILE = @referralMobile
			,REFERRAL_EMAIL = @referralEmail
			,IS_ACTIVE = @isActive
			,BRANCH_ID = @branchId
			,REFERRAL_TYPE = @referralType
			,REFERRAL_TYPE_CODE = @referralTypecode
			,RULE_TYPE = @ruleType
			,REFERRAL_LIMIT = @cashHoldLimitAmount
		where ROW_ID = @rowId
		SELECT  '0' ErrorCode ,'Referral has been updated successfully.' Msg ,
                        @agentID id;	
	END
ELSE IF @FLAG = 'delete'
	BEGIN
		DELETE FROM REFERRAL_AGENT_WISE WHERE ROW_ID = @rowId
		SELECT  '0' ErrorCode ,'Referral has been deleted successfully.' Msg ,
                        null id;	

	END
ELSE IF @FLAG = 'branchList'
	BEGIN
	select * FROM agentMaster WHERE agentType = 2903 AND parentId= 393877 AND actAsBranch  = 'Y'
	END
ELSE IF @FLAG = 'referalType'
	BEGIN
	SELECT  null value,   'Select' [text] 
	UNION ALL 
	SELECT 'RB' VALUE,'JME Referral Branches' [text]
	UNION ALL 
	SELECT 'RC' VALUE,'Referral''S with no comm' [text]
	UNION ALL 
	SELECT 'RR' VALUE,'Regular Referral Agent''s' [text]
	END

ELSE IF @FLAG = 'S-commList'  
	BEGIN  
		--SET @sortBy = 'createdDate'  
		--SET @sortOrder = 'desc' 
		SET @table = '(	SELECT ISRW.REFERRAL_ID
							  ,AM.AGENTID	
							  ,REFERRAL_NAME = RA.REFERRAL_NAME + '' - '' + RA.REFERRAL_CODE
							  ,AM.agentName
							  ,COMM_PCNT
							  ,FX_PCNT
							  ,FLAT_TXN_WISE
							  ,NEW_CUSTOMER
							  ,EFFECTIVE_FROM
							  ,CASE WHEN ISRW.IS_ACTIVE = ''1'' THEN ''Yes'' else ''No'' END  IS_ACTIVE
							  ,ISRW.ROW_ID
							  ,DEDUCT_P_COMM_ON_SC = CASE WHEN ISRW.DEDUCT_P_COMM_ON_SC = ''1'' THEN ''Yes'' else ''No'' END
							  ,DEDUCT_TAX_ON_SC = CASE WHEN ISRW.DEDUCT_TAX_ON_SC = ''1'' THEN ''Yes'' else ''No'' END
							  ,RA.REFERRAL_CODE
					   FROM dbo.INCENTIVE_SETUP_REFERRAL_WISE ISRW
					   INNER JOIN dbo.agentMaster AM ON AM.agentId = ISRW.PARTNER_ID
					   LEFT JOIN REFERRAL_AGENT_WISE RA ON RA.ROW_ID = ISRW.REFERRAL_ID
					   WHERE RA.REFERRAL_CODE = '''+@REFERRAL_CODE+''''  
		SET @sql_filter = ''  
		SET @table = @table + ')x' 
		 
		SET @select_field_list  = 'REFERRAL_ID,ROW_ID,AGENTID,REFERRAL_NAME,agentName,FX_PCNT,COMM_PCNT,FLAT_TXN_WISE,NEW_CUSTOMER,EFFECTIVE_FROM,IS_ACTIVE,DEDUCT_TAX_ON_SC,DEDUCT_P_COMM_ON_SC,REFERRAL_CODE'
		
		EXEC dbo.proc_paging @table, @sql_filter, @select_field_list, @extra_field_list  
							, @sortBy, @sortOrder, @pageSize, @pageNumber  
	END  
ELSE IF @FLAG = 'getCommissionRule'  
	BEGIN  
		SELECT PARTNER_ID,COMM_PCNT,FX_PCNT,FLAT_TXN_WISE,NEW_CUSTOMER,EFFECTIVE_FROM,IS_ACTIVE, DEDUCT_P_COMM_ON_SC, DEDUCT_TAX_ON_SC
		FROM INCENTIVE_SETUP_REFERRAL_WISE WHERE ROW_ID = @ROW_ID
	END  

ELSE IF @FLAG = 'saveCommission'  
BEGIN  
		IF(@referralId IS NULL)
		SELECT @referralId = ROW_ID FROM dbo.REFERRAL_AGENT_WISE WHERE REFERRAL_CODE = @referralCode
		

		--IF EXISTS(SELECT 1 FROM dbo.INCENTIVE_SETUP_REFERRAL_WISE WHERE REFERRAL_ID = @referralId AND PARTNER_ID = @partnerId)
		--BEGIN
		--	SELECT '0' ErrorCode, 'Commission Already Defined for this partner and referral' Msg,@referralId id
		--	RETURN
		--END 
		INSERT INTO dbo.INCENTIVE_SETUP_REFERRAL_WISE
	        ( REFERRAL_ID ,
	          PARTNER_ID ,
	          AGENT_ID ,
	          COMM_PCNT ,
	          FX_PCNT ,
	          FLAT_TXN_WISE ,
	          NEW_CUSTOMER ,
	          EFFECTIVE_FROM ,
	          IS_ACTIVE ,
	          CREATED_BY ,
	          CREATED_DATE,
			  DEDUCT_TAX_ON_SC,
			  DEDUCT_P_COMM_ON_SC
	        )
		VALUES  ( @referralId , -- REFERRAL_ID - int
	          @partnerId , -- PARTNER_ID - int
	          0 , -- AGENT_ID - int
	          @commissionPercent , -- COMM_PCNT - decimal(5, 2)
	          @forexPercent , -- FX_PCNT - decimal(5, 2)
	          @flatTxnWise , -- FLAT_TXN_WISE - money
	          @NewCustomer , -- NEW_CUSTOMER - money
	          @effectiveFrom , -- EFFECTIVE_FROM - datetime
	          @isActive , -- IS_ACTIVE - bit
	          @user , -- CREATED_BY - varchar(80)
	          GETDATE(),  -- CREATED_DATE - datetime
			  @DEDUCT_TAX_ON_SC,
			  @DEDUCT_P_COMM_ON_SC
	        )
		SELECT '0' ErrorCode, 'Record inserted successfully' Msg,@referralId id
	
END  
ELSE IF @FLAG = 'updateCommission'  
BEGIN  
		IF EXISTS(SELECT 1 FROM dbo.INCENTIVE_SETUP_REFERRAL_WISE WHERE ROW_ID = @ROW_ID)
		BEGIN
			UPDATE dbo.INCENTIVE_SETUP_REFERRAL_WISE SET COMM_PCNT = @commissionPercent
													 ,FX_PCNT	= @forexPercent
													 ,FLAT_TXN_WISE = @flatTxnWise
													 ,NEW_CUSTOMER = @NewCustomer
													 ,EFFECTIVE_FROM = @effectiveFrom
													 ,IS_ACTIVE = @isActive
													 ,MODIFIED_BY = @USER
													 ,MODIFIED_DATE = GETDATE()
													 ,DEDUCT_TAX_ON_SC = @DEDUCT_TAX_ON_SC
													 ,DEDUCT_P_COMM_ON_SC = @DEDUCT_P_COMM_ON_SC
				WHERE ROW_ID = @ROW_ID
			SELECT '0' ErrorCode, 'Record updated successfully' Msg,@referralId id
			return
		END 
		SELECT '1' ErrorCode, 'No record found!' Msg,@referralId id
END
	
END

--select * from INCENTIVE_SETUP_REFERRAL_WISE
