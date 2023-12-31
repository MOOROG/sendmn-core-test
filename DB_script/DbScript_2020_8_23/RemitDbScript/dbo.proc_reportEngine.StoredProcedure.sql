USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_reportEngine]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE proc [dbo].[proc_reportEngine]
	@functionID VARCHAR(100)
	,@user VARCHAR(30)
	,@pageFrom INT
	,@pageTo INT
	,@branch INT
	,@agent INT	
	,@fxml XML = NULL
	,@qxml XML = NULL
	,@dxml XML = NULL
	,@downloadAll CHAR(1) = NULL
AS

SET NOCOUNT ON
SET @pageFrom = ISNULL(NULLIF(@pageFrom, 0), 1)
SET @pageTo = ISNULL(@pageTo, @pageFrom)
DECLARE @pageSize INT = 50

CREATE TABLE #params (
	 ReportTitle VARCHAR(500)
	,Filters VARCHAR(500)
	
	,FieldAlignment VARCHAR(100)
	,FieldFormat VARCHAR(100)
	
	
	,TotalTextCol INT DEFAULT (-1)
	,TotalText VARCHAR(100)
	,TotalFields VARCHAR(100)


	,HasGrandTotal BIT DEFAULT (0)
	,GTotalText VARCHAR(100)
	,GTData VARCHAR(2000)
	
	,SubTotalBy INT  DEFAULT (-1)
	,SubTotalTextCol INT DEFAULT (-1)
	,SubTotalText VARCHAR(100)
	,SubTotalFields VARCHAR(100)
		
	,IncludeSerialNo BIT
	,FieldWrap VARCHAR(100)
	,ExcludeColumns VARCHAR(100) DEFAULT('row_Id')
	,CssClass VARCHAR(100)
	,UseDBRowColorCode BIT
	,MergeColumnHead BIT
	,NoHeader BIT
	,PageSize INT
	,PageNumber INT
	,LoadMode TINYINT DEFAULT(0)--1->Button-Only; 2->Scroll-Only; 3->Both
)
--INSERT #params (ReportTitle) SELECT 'INVALID OPERATION - OPERATION TOKEN EXPIRED.'
INSERT #params (ReportTitle) SELECT ''

IF @functionID='20168000'
BEGIN
	EXEC proc_MapCodeReport  @functionID, @user, @pageFrom, @pageTo, @branch, @agent, @fxml, @qxml, @dxml
	RETURN
END

IF @functionID='20168100'
BEGIN
	EXEC proc_agentMasterTempReport  @functionID, @user, @pageFrom, @pageTo, @branch, @agent, @fxml, @qxml, @dxml,@downloadAll
	RETURN
END
IF @functionID IN('20168400', '20168400-d1','20168400-d2','20168400-d3','20168400-d4','20168400-d5')
BEGIN
	EXEC proc_txnDocumentReport	@functionID, @user, @pageFrom , @pageTo, @branch, @agent, @fxml, @qxml, @dxml
	RETURN
END
--SELECT 'INVALID OPERATION' ErrorCode, 'OPERATION TOKEN EXPIRED.' Reason
--select * from #params



GO
