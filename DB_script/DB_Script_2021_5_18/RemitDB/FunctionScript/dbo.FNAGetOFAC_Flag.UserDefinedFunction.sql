USE [SendMnPro_Remit]
GO
/****** Object:  UserDefinedFunction [dbo].[FNAGetOFAC_Flag]    Script Date: 5/18/2021 6:38:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
SELECT  DBO.FNAGetOFAC_Flag('4509,16524,16530,4510,4531,1883,4532,1893')
*/	
        
CREATE FUNCTION [dbo].[FNAGetOFAC_Flag](@OFACIds VARCHAR(max))
RETURNS VARCHAR(1)
AS  
BEGIN
		DECLARE  @ofacDataSource  TABLE(dataSorce VARCHAR(100))
		DECLARE @ofacFlag AS VARCHAR(50),@isManual AS VARCHAR(1)='N',@isOther AS VARCHAR(1)='N'
		
		INSERT INTO @ofacDataSource
		SELECT DISTINCT a.dataSource FROM blacklist a WITH(NOLOCK) INNER JOIN 
		(
			SELECT * FROM dbo.SplitXML(',',@OFACIds)
		)b ON a.ofacKey=b.val


		SELECT @isManual='Y' FROM @ofacDataSource WHERE dataSorce = 'MANUAL'
		SELECT @isOther='Y' FROM @ofacDataSource WHERE dataSorce <> 'MANUAL'

		IF @isManual ='Y' AND @isOther='Y'
			SET @ofacFlag = 'A'  

		IF @isManual ='Y' AND @isOther='N'
			SET @ofacFlag = 'M'  
				
		IF @isManual ='N' AND @isOther='Y'
			SET @ofacFlag = 'O'  
			
		RETURN @ofacFlag

END
GO
