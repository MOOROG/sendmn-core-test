USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_luckyDrawSetup]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_luckyDrawSetup]
      @flag					VARCHAR(50)  	= NULL
     ,@user					VARCHAR(30)  	= NULL
     ,@id				    INT			 	= NULL
     ,@sCountry				VARCHAR(100)	= NULL
     ,@sAgent				INT				= NULL	
     ,@rAgent				VARCHAR(MAX)	= NULL 
     ,@pAgent1				VARCHAR(100)	= NULL  
     ,@pAgent2				VARCHAR(100)	= NULL  
     ,@pAgent3				VARCHAR(100)	= NULL  
     ,@pAgent4				VARCHAR(100)	= NULL  
     ,@pAgent5				VARCHAR(100)	= NULL    
     ,@fromDate	            DATETIME		= NULL
	 ,@toDate				DATETIME		= NULL
	 ,@luckyDrawType		VARCHAR(50)		= NULL
	 ,@type					CHAR(1)			= NULL
AS
SET NOCOUNT ON
 IF @flag = 'a'
 BEGIN
	SELECT
	     flag
		,sCountry
		,sAgent
		,pAgent1
		,pAgent2
		,pAgent3
		,pAgent4
		,pAgent5
		,fromDate = CONVERT(VARCHAR, fromDate, 101)
		,toDate = CONVERT(VARCHAR, toDate, 101)
		,luckyDrawType
		,pAgent1Name = am1.agentName
		,pAgent2Name = am2.agentName
		,pAgent3Name = am3.agentName
		,pAgent4Name = am4.agentName
		,pAgent5Name = am5.agentName	
		,sCountryId = cm.countryId	
	FROM luckyDrawSetup lds
	LEFT JOIN agentMaster am1 WITH(NOLOCK) ON lds.pAgent1 = am1.agentId
	LEFT JOIN agentMaster am2 WITH(NOLOCK) ON lds.pAgent2 = am2.agentId
	LEFT JOIN agentMaster am3 WITH(NOLOCK) ON lds.pAgent3 = am3.agentId
	LEFT JOIN agentMaster am4 WITH(NOLOCK) ON lds.pAgent4 = am4.agentId
	LEFT JOIN agentMaster am5 WITH(NOLOCK) ON lds.pAgent5 = am5.agentId
	LEFT JOIN countryMaster cm WITH(NOLOCK) ON lds.sCountry = cm.countryName
	RETURN
 END
 
 IF @flag = 'i'     
 BEGIN
	IF NOT EXISTS(SELECT 'x' from luckyDrawSetup WHERE flag=@type)		
		INSERT luckyDrawSetup(flag) SELECT @type
	
	UPDATE luckyDrawSetup SET
		sCountry		= @sCountry
		,sAgent			= @sAgent
		,pAgent1		= @pAgent1
		,pAgent2		= @pAgent2
		,pAgent3		= @pAgent3
		,pAgent4		= @pAgent4
		,pAgent5		= @pAgent5					       
		,fromDate		= @fromDate					
		,toDate			= @toDate					
		,luckyDrawType  = @luckyDrawType
		
		WHERE flag=@type
				
	SELECT 0 errorCode, 'Record Update successfully.' mes, @id	
	RETURN	
 END
 
 IF @flag = 'senderType'	
 BEGIN			-- Sender lucky Draw Type 
	SELECT 'Sender_Daily' typeId ,'Daily' typeName UNION ALL
	SELECT 'Sender_Weekly' typeId,'Weekly' typeName 
	
	RETURN
 END
 
 IF @flag = 'receiverType'				-- Receiver lucky Draw Type List
 BEGIN
	
	SELECT 'Receiver_Daily' typeId ,'Daily	' typeName UNION ALL
	SELECT 'Receiver_Weekly' typeId,'Weekly' typeName 
	
	RETURN
 END
 
 ELSE IF @FLAG='getImage'
 BEGIN
	SELECT luckyDrawType  FROM luckyDrawSetup WHERE flag=@type		
 END


GO
