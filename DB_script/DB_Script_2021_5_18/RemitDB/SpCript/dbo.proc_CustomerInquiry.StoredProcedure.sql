USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_CustomerInquiry]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[proc_CustomerInquiry]
@flag		varchar(20),
@mobileNo	varchar(15)		= null,
@complian	varchar(max)	= null,
@msgType	varchar(50)		= null,
@Country	varchar(50)		= null,
@startDate	varchar(10)		= null,
@endDate	varchar(20)		= null,
@User		varchar(50)

as
set nocount on ;

if @flag = 'i'
begin
	insert into tblCustomerInquiry(mobileNo,complian,msgType,Country,createdBy)
	select @mobileNo,@complian,@msgType,@Country,@User

	exec proc_errorHandler '0','Complain added successfully',null
	return
end

ELSE IF @flag ='S'
BEGIN
	DECLARE @mobileNo1 VARCHAR(15)
	SET @mobileNo1 = CASE WHEN LEFT(@mobileNo,1) = '0' THEN '82'+RIGHT(@mobileNo,LEN(@mobileNo)-1) ELSE @mobileNo END

	SELECT * FROM tblCustomerInquiry(NOLOCK) WHERE mobileNo = @mobileNo
	UNION ALL
	select t.id,s.mobile,'Transaction'
		,'Send Transaction of control no : '+'<a target="_blank" href="../../Remit/Transaction/Reports/SearchTransaction.aspx?commentFlag=N&showBankDetail=N&tranId='+cast(t.id as varchar)+'" >'+dbo.FNADecryptString(t.controlNo)+' </a>'
			,t.pCountry,t.approvedBy,t.approvedDate
	from tranSenders s(nolock)
	INNER JOIN remitTran t(nolock) on t.id = s.tranId
	where s.mobile = @mobileNo1
	order by id desc
	RETURN
END
ELSE IF @flag ='r'
BEGIN
	SELECT Country,MobileNo,[Complain] = complian,[Inquiry Type]= msgType,[Submitted By] = createdBy,[Submitted Date] = createdDate
	FROM tblCustomerInquiry(NOLOCK) 
	WHERE createdDate between @startDate and @endDate +' 23:59:59'

	 EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL
			
	SELECT  'From Date ' head,@startDate value union all
	SELECT  'To Date ' head,@endDate value 
		
	SELECT 'Customer Inquiry Report' title

	RETURN
END
GO
