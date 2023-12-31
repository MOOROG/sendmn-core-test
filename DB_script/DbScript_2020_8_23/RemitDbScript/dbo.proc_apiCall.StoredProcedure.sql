USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_apiCall]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_apiCall] (	 
	 @flag				VARCHAR(50)
	,@controlNo			VARCHAR(20)		= NULL
	,@user				VARCHAR(30)		= NULL
	)
AS
SET NOCOUNT on;
/*
	dl - district List
	sc - service charge
*/
IF @flag = 'dl'
BEGIN
	--DOMESTIC Distict List:
	Exec ime_plus_01.dbo.spa_SOAP_Domestic_DistrictList 
	'IMENPKA037','sabin123','ime1234','1234','c'
END

ELSE IF @flag = 'sc'
BEGIN
	--DOMESTIC Service Charge:
	Exec ime_plus_01.dbo.spa_SOAP_Domestic_ServiceCharge 
	'IMENPKA037','sabin123','ime1234','1234',10000,'c',109
END


----DOMESTIC Send TXN Create:
--Exec [192.168.2.1].ime_plus_01.dbo.spa_SOAP_Domestic_createTXN 
--'IMENPKA037','sabin123','ime1234','1234',51398,
--'SENDER2','SAddress','SMOBILE','Passport','PASS123','Receiver','RAddress','11111',
--'KTM','Dad','ReceiverIDTYpe','Receiver ID',1000,'c',109

----DOMESTIC Approve TXN :
--Exec [192.168.2.1].ime_plus_01.dbo.spa_SOAP_Domestic_approve_transaction 
--'IMENPKA037','sabin123','ime1234',
--'8425495442D','12222','127.0.0.1'

--DOMESTIC Distict List: Ready 
--DOMESTIC Service Charge: Ready
--DOMESTIC Send TXN Create: Ready
--DOMESTIC Approve TXN: Ready

--Domestic Paid Txn : Pending
--Domestic Cancel Txn: Penging
--Domestic Transaction Status: Pending


GO
