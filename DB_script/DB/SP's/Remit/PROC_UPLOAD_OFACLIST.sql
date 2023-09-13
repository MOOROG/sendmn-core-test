alter procedure PROC_UPLOAD_OFACLIST
(
	@FLAG VARCHAR(20)
	,@USER VARCHAR(60) = NULL
	,@XML NVARCHAR(MAX)	= NULL
	,@SESSION_ID VARCHAR(30) = NULL
	,@IDS VARCHAR(MAX) = NULL
	,@DATASOURCE VARCHAR(50)  = NULL
)
AS
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
	declare @rowId    int   
	IF @FLAG = 'i'
	BEGIN
		IF OBJECT_ID('tempdb..#ofaclist') IS NOT NULL 
			DROP TABLE #ofaclist
		
		DECLARE @XMLDATA XML = CONVERT(xml, replace(@XML,'&','&amp;'), 2) 

		SELECT  IDENTITY(INT, 1, 1) AS rowId
					,p.value('@NAME','VARCHAR(20)') AS 'Name'
					,p.value('@ADDRESS','VARCHAR(100)') AS 'Address'
					--,p.value('@BANKNAME', 'varchar(50)') AS 'BankName'
					,p.value('@COUNTRY','varchar(10)') AS 'Country'
					,p.value('@REMARKS','varchar(10)') AS 'Remarks'
					--,p.value('@SETTLMENTRATE','varchar(10)') AS 'SettlementRate'
		INTO #ofaclist
		FROM @XMLDATA.nodes('/root/row') AS ofacDatas(p)
		
		SELECT Name,Address,Country,Remarks 
		INTO #ofaclist1
		FROM #ofaclist
		GROUP BY Name,Address,Country,Remarks
		insert into blacklist (name,address,country,isActive,createdBy,createdDate,dataSource,remarks)
						select Name,Address,Country,'Y',@user,GETDATE(),@DATASOURCE,Remarks
						from #ofaclist1 OL(NOLOCK)
		UPDATE dbo.blacklist   SET entNum= rowId,   
					           ofacKey = @DATASOURCE+CAST(rowId AS VARCHAR)  
				

		 SELECT '0' errorCode,'Compliance Successfully added' msg,null  
		 RETURN  
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT <> 0
			ROLLBACK TRAN
    DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()
	EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH