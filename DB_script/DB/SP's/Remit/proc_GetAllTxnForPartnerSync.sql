-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE proc_GetAllTxnForPartnerSync 
	-- Add the parameters for the stored procedure here
	@flag						VARCHAR(100)		=	NULL,
	@user						VARCHAR(100)		=	NULL,
	@sortBy						VARCHAR(50)			=	NULL,
    @sortOrder					VARCHAR(5)			=	NULL,
    @pageSize					INT					=	NULL,
    @pageNumber					INT					=	NULL,
    @partnerName				VARCHAR(150)		=	NULL,
    @controlNo					VARCHAR(25)			=	NULL,
    @date						VARCHAR(15)			=	NULL,
    @sFullName					VARCHAR(100)		=	NULL,
    @rFullName					VARCHAR(100)		=	NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE 
	@table						VARCHAR(MAX)		=	NULL,		
	@sql_filter					VARCHAR(MAX)		=	NULL,
	@select_field_list			VARCHAR(MAX)		=	NULL

	SET NOCOUNT ON;

	IF @flag ='s'
	BEGIN
	    IF @sortBy IS NULL
			SET @sortBy='date';
		IF @sortOrder IS NULL	
			SET @sortOrder='DESC';

		SET @table='(SELECT 
						id,
						pSuperAgentName partnerName,
						dbo.decryptDb(controlNo) controlNo,
						ISNULL(CONVERT(VARCHAR(20),createdDate,23),'''')+ISNULL(''/''+CONVERT(VARCHAR(20),approvedDate,23),'''') [date],
						sBranchName,
						pAmt,
						senderName sFullName,
						receiverName rFullName,
						tranStatus,
						payStatus 
					FROM dbo.remitTranTemp
					WHERE tranStatus =''Payment'' AND payStatus =''Unpaid''
					 )x';

		SET @sql_filter ='';
			IF ISNULL(@partnerName,'')<>''
				SET @sql_filter+=' AND partnername='+''''+@partnerName+'''';

			IF ISNULL(@controlNo,'')<>''
				SET @sql_filter+=' AND controlNo='+''''+@controlNo+'''';

			IF ISNULL(@date,'')<>''
				SET @sql_filter +=  ' AND date BETWEEN ''' +@date+''' AND ''' +@date +' 23:59:59'''
							
		SET @select_field_list = 'id,partnerName,controlNo,date,sBranchName,pAmt,sFullName,rFullName,tranStatus,payStatus';
		EXEC dbo.proc_paging @table, @sql_filter, @select_field_list,
                    NULL, @sortBy, @sortOrder, @pageSize,
                    @pageNumber;

	END
    -- Insert statements for procedure here
END
GO
