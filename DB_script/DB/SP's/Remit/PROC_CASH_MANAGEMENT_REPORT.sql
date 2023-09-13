
ALTER PROC PROC_CASH_MANAGEMENT_REPORT
(
	@FLAG VARCHAR(20)
	,@USER VARCHAR(80) = NULL
	,@DATE VARCHAR(25) = NULL
	,@BRANCH_ID INT = NULL
	,@USER_ID INT = NULL
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
	BEGIN
		IF @FLAG = 'EOD'
		BEGIN
			IF EXISTS (SELECT TOP 1 1 FROM BRANCH_CASH_IN_OUT(NOLOCK) WHERE APPROVEDDATE IS NULL)
			BEGIN
				EXEC PROC_ERRORHANDLER 1, 'Please approve all pending vault transfer''s before performing this operation!', null
				RETURN
			END
			IF EXISTS (SELECT TOP 1 1 FROM BRANCH_CASH_IN_OUT(NOLOCK) WHERE createdDate < GETDATE())
			BEGIN
				EXEC PROC_ERRORHANDLER 1, 'EOD pending for previous date!', null
				RETURN
			END
			IF EXISTS (SELECT TOP 1 1 FROM BRANCH_CASH_IN_OUT_HISTORY(NOLOCK) WHERE createdDate BETWEEN CAST(GETDATE() AS DATE) AND GETDATE())
			BEGIN
				EXEC PROC_ERRORHANDLER 1, 'EOD already performed!', null
				RETURN
			END

			INSERT INTO BRANCH_CASH_IN_OUT_HISTORY(inAmount ,outAmount ,branchId ,userId ,referenceId ,tranDate ,head ,remarks 
					,createdBy ,createdDate ,approvedBy ,approvedDate, mode, fromAcc, toAcc)
			SELECT inAmount ,outAmount ,branchId ,userId ,referenceId ,tranDate ,head ,remarks 
					,createdBy ,createdDate ,approvedBy ,approvedDate, mode, fromAcc, toAcc
			FROM BRANCH_CASH_IN_OUT (NOLOCK)
			
			EXEC PROC_ERRORHANDLER 0, 'EOD Success!', null
		END
	END
END TRY
BEGIN CATCH
	IF @@TRANCOUNT<>0
		ROLLBACK TRANSACTION

	DECLARE @errorMessage VARCHAR(MAX)
	SET @errorMessage = ERROR_MESSAGE()
	EXEC proc_errorHandler 1, @errorMessage, @user
END CATCH
