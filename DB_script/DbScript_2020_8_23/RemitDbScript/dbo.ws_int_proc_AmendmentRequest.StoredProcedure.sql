USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[ws_int_proc_AmendmentRequest]    Script Date: 8/23/2020 5:48:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--IF  EXISTS (SELECT 'x' FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ws_int_proc_AmendmentRequest]') AND TYPE IN (N'P', N'PC'))
--	DROP PROCEDURE [dbo].ws_int_proc_AmendmentRequest

--GO 
 /*
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <AmendmentRequest xmlns="WebServices">
      <AGENT_CODE>string</AGENT_CODE>
      <USER_ID>string</USER_ID>
      <PASSWORD>string</PASSWORD>
      <AGENT_SESSION_ID>string</AGENT_SESSION_ID>
      <PINNO>string</PINNO>
      <AMENDMENT_FIELD>string</AMENDMENT_FIELD>
      <AMENDMENT_VALUE>string</AMENDMENT_VALUE>
    </AmendmentRequest>
  </soap:Body>
</soap:Envelope>
---------------------------------

<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <AmendmentRequestResponse xmlns="WebServices">
      <AmendmentRequestResult>
        <CODE>string</CODE>
        <AGENT_SESSION_ID>string</AGENT_SESSION_ID>
        <MESSAGE>string</MESSAGE>
        <PINNO>string</PINNO>
      </AmendmentRequestResult>
    </AmendmentRequestResponse>
  </soap:Body>
</soap:Envelope>


 */
 
CREATE proc [dbo].[ws_int_proc_AmendmentRequest] (	 
	@AGENT_CODE			VARCHAR(50),
	@USER_ID			VARCHAR(50),
	@PASSWORD			VARCHAR(50),
	@AGENT_SESSION_ID   VARCHAR(50),
	@PINNO				VARCHAR(50),
	@AMENDMENT_FIELD	VARCHAR(50),
	@AMENDMENT_VALUE	VARCHAR(50)	
)

AS

SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @errCode INT
DECLARE @EXRATEID VARCHAR(40) = NEWID()	

DECLARE @autMsg	VARCHAR(500)
	EXEC ws_int_proc_checkAuthntication @USER_ID,@PASSWORD,@AGENT_CODE,@errCode OUT, @autMsg OUT
	DECLARE @message VARCHAR(100) = ''
	IF (@errCode=1 )
	BEGIN
		SELECT 
			'1002'					CODE
			,@AGENT_SESSION_ID		AGENT_SESSION_ID
			,ISNULL(@autMsg,'Authentication Fail') MESSAGE
			,@PINNO					PINNO
			
		RETURN
	END
	IF EXISTS(SELECT 'A' FROM applicationUsers WITH (NOLOCK) WHERE 
			userName = @USER_ID AND forceChangePwd = 'Y')
	BEGIN
			SELECT 
				'1002' CODE
				,@AGENT_SESSION_ID		AGENT_SESSION_ID
				,'You logged on first time,must first change your password and try again!' MESSAGE
				,@PINNO					PINNO
			RETURN
	END
	------------------VALIDATION-------------------------------	
	
	IF @PINNO IS NULL
	BEGIN
		SELECT 
			'1001' CODE
			,@AGENT_SESSION_ID		AGENT_SESSION_ID
			,'PIN NO Field is Empty' MESSAGE
			,@PINNO					PINNO

		RETURN;
	END
	IF @AMENDMENT_FIELD IS NULL
	BEGIN
		SELECT 
			'1001' CODE
			,@AGENT_SESSION_ID		AGENT_SESSION_ID
			,'AMENDMENT FIELD Field is Empty' MESSAGE
			,@PINNO					PINNO
		RETURN;
	END
	IF @AMENDMENT_VALUE IS NULL
	BEGIN
		SELECT 
			'9001' CODE
			,@AGENT_SESSION_ID		AGENT_SESSION_ID
			,'AMENDMENT VALUE is Empty' MESSAGE
			,@PINNO					PINNO
		RETURN;
	END
	
	IF @AGENT_SESSION_ID IS NULL
	BEGIN
		SELECT 
			'1001' CODE
			,@AGENT_SESSION_ID		AGENT_SESSION_ID
			,'AGENT SESSION ID Field is Empty' MESSAGE
			,@PINNO					PINNO
		RETURN;
	END

	SELECT 
		'0'							CODE,		
		@AGENT_SESSION_ID			AGENT_SESSION_ID,		
		'Successfully Amended'		MESSAGE,
		@PINNO						PINNO

		/*

		Sender 
		Name
		Address:
		Mobile No
		Passport (Idtype) 
		PassportNo (IdNo)

		Receiver 
		Name
		Address:
		Mobile No
		Passport (Idtype) 
		PassportNo (IdNo)
		Receiver Relationship With Sender


		*/


GO
