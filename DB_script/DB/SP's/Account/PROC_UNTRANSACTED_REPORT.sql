

CREATE PROC PROC_UNTRANSACTED_REPORT
(
	@FLAG	VARCHAR(10)
	,@FROM_DATE VARCHAR(20)
	,@TO_DATE VARCHAR(20)
	,@DATE_FOR VARCHAR(10)
)
AS;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
	
END