alter PROC Proc_UpdateBranchCode
	 @flag			VARCHAR(200)
	,@pCountryId	INT					= NULL
	,@pCountryName	VARCHAR(50)			= NULL
	,@bankId		INT					= NULL
	,@branchCode	VARCHAR(50)			= NULL
	,@branchId		INT					= NULL
	,@branchName	VARCHAR(50)			= NULL
	,@editedBranchName	VARCHAR(50)			= NULL
	,@user			varchar(20)			= NULL
AS
BEGIN
IF @FLAG = 'getBankByCountry'
BEGIN
   SELECT  bankId=AL.BANK_ID,   
     0 NS,  
     FLAG = 'E',  
     AGENTNAME = AL.BANK_NAME + ' || ' +  AL.BANK_CODE1 
   FROM API_BANK_LIST AL(NOLOCK)  
   INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BANK_COUNTRY  
   WHERE CM.COUNTRYID = @pCountryId  
   AND AL.IS_ACTIVE = 1  
   AND AL.PAYMENT_TYPE_ID = 2
   ORDER BY AL.BANK_NAME  
END
ELSE IF @FLAG = 'getBranchByBankAndCountry'
BEGIN
   SELECT  bankId=AL.BRANCH_CODE1,   
     0 NS,  
     FLAG = 'E',  
     AGENTNAME = AL.BRANCH_NAME  + ' || ' +  AL.BRANCH_CODE1
   FROM API_BANK_BRANCH_LIST AL(NOLOCK)  
   INNER JOIN COUNTRYMASTER CM(NOLOCK) ON CM.COUNTRYNAME = AL.BRANCH_COUNTRY  
   WHERE CM.COUNTRYID = @pCountryId  
   AND AL.BANK_ID = @bankId
   AND AL.IS_ACTIVE = 1  
   AND AL.PAYMENT_TYPE_ID = 2
   ORDER BY AL.BRANCH_NAME  
END
ELSE IF @FLAG = 'updateBranchCode'
BEGIN
  IF EXISTS(select 1 from API_BANK_BRANCH_LIST WHERE BANK_ID = @bankId and BRANCH_CODE1 = @branchId)
  BEGIN 
	INSERT INTO API_BANK_BRANCH_LIST_LOG
	SELECT BANK_ID,BRANCH_ID,BRANCH_CODE1,@branchCode,@user,GETDATE() FROM API_BANK_BRANCH_LIST
	WHERE BANK_ID = @bankId and BRANCH_CODE1 = @branchId

	UPDATE API_BANK_BRANCH_LIST SET BRANCH_CODE1 = @branchCode,BRANCH_NAME = @editedBranchName where BANK_ID = @bankId and BRANCH_CODE1 = @branchId

	SELECT 0 ERRORCODE,'BranchCode updated successfully' Msg,null
  END
END

ELSE IF @flag = 'insertBranch'
BEGIN
	SELECT @pCountryName = COUNTRYNAME FROM countryMaster WHERE COUNTRYID = @pcountryId
	IF NOT EXISTS(SELECT 'A',* FROM API_BANK_LIST WHERE BANK_ID = @bankId AND BANK_COUNTRY = @pCountryName)
	BEGIN
		SELECT '1' ErrorCode,'Bank Does not exists' Msg,@bankId id
		RETURN
	END
	IF EXISTS (SELECT 'A',* FROM API_BANK_BRANCH_LIST WHERE BANK_ID = @bankId AND BRANCH_COUNTRY = @pCountryName AND BRANCH_CODE1 = @branchCode AND BRANCH_NAME = @branchName)
	BEGIN
		SELECT '1' ErrorCode,'Branch with same name and code already exists' Msg,@bankId id
		RETURN
	END

	INSERT INTO API_BANK_BRANCH_LIST (BANK_ID,BRANCH_NAME,BRANCH_CODE1,BRANCH_COUNTRY,IS_ACTIVE,PAYMENT_TYPE_ID)
	VALUES (@bankId,@branchName,@branchCode,@pCountryName,1,2)

	SELECT '0' ErrorCode,'Branch Inserted Successfully' Msg,@bankId id


END
end