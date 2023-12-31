USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_isoLogDetail]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_isoLogDetail](
	@flag    VARCHAR(50)  
   ,@sortBy   VARCHAR(50)  = NULL
   ,@sortOrder   VARCHAR(50)  = NULL
   ,@pageSize   VARCHAR(50)  = NULL
   ,@pageNumber  VARCHAR(50)  = NULL
   ,@user    VARCHAR(50)  = NULL
   ,@status   VARCHAR(50)  = NULL
   ,@accountNo1	VARCHAR(50)=NULL
   ,@accountNo2	VARCHAR(50)=NULL
   ,@fromAmt	VARCHAR(10)=NULL
   ,@toAmt	VARCHAR(10)=NULL
   ,@fromDate VARCHAR(10)=NULL
   ,@toDate VARCHAR(10)=NULL
  )
AS
SET NOCOUNT ON;
BEGIN
	IF @flag = 's'
	BEGIN
	 DECLARE 
	   @table			VARCHAR(MAX)
	  ,@selectFieldList     VARCHAR(MAX)
	  ,@extraFieldList     VARCHAR(MAX)
	  ,@sqlFilter   VARCHAR(MAX)
   
	IF @sortBy IS NULL  
	 SET @sortBy = 'rowId'
	IF @sortOrder IS NULL  
	 SET @sortOrder = 'DESC'   
	 SET @table = '(SELECT  					
					 SN=ROW_NUMBER() OVER (ORDER BY rowId Desc)
					,rowId
					,methodName
					,amount
					,accountNumber
					,accountNumber2
					,errorCode
					,errorMessage
					,requestedDate 
				FROM RemittanceLogData.dbo.isoLogs (NOLOCK)
			 )x' 
     
	 SET @sqlFilter = '' 


	 IF @fromAmt IS NOT NULL AND @toAmt IS NOT NULL
		 SET @sqlFilter=@sqlFilter + ' AND amount Between'''+@fromAmt+ ''' AND'''+@toAmt+''''

	 IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
		 SET @sqlFilter=@sqlFilter + ' AND requestedDate Between'''+@fromDate+ ''' AND'''+@toDate+' 23:59:59'+''''
 
	 IF @accountNo1 IS NOT NULL  
	  SET @sqlFilter=@sqlFilter + ' AND accountNumber ='''+@accountNo1+''''

	 IF @accountNo2 IS NOT NULL  
	  SET @sqlFilter=@sqlFilter + ' AND accountNumber2 ='''+@accountNo2+''''

	 SET @selectFieldList = '		
		 rowId
		,methodName
		,amount
		,accountNumber
		,accountNumber2
		,errorCode
		,errorMessage
		,requestedDate 
	' 
   	

	 EXEC dbo.proc_paging
	   @table     
	  ,@sqlFilter   
	  ,@selectFieldList  
	  ,@extraFieldList  
	  ,@sortBy    
	  ,@sortOrder   
	  ,@pageSize    
	  ,@pageNumber 

	END
END



GO
