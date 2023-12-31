USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentToAgentCardTransfer]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_agentToAgentCardTransfer]
(
	 @flag			 VARCHAR(20)	= 	NULL
	,@user  		 VARCHAR(30)	= 	NULL	
	,@rowId			 INT			= 	NULL
	,@agentFrmName	 VARCHAR(255)	= 	NULL
	,@agentToName	 VARCHAR(255)	= 	NULL
	,@remitCardNo	 VARCHAR(30)	= 	NULL
	,@cardType		 VARCHAR(30)	= 	NULL
	,@cardStatus	 VARCHAR(30)	= 	NULL	
	,@fromCardNo	 BIGINT			=	NULL
	,@toCardNo		 BIGINT			=	NULL
	,@modifiedDate	 VARCHAR(30)	= 	NULL
	,@modifiedBy	 VARCHAR(30)	= 	NULL
	,@createdDate	 VARCHAR(30)	= 	NULL
	,@createdBy		 VARCHAR(30)	= 	NULL	
)
AS
SET NOCOUNT ON
SET	XACT_ABORT ON


BEGIN
	BEGIN TRY
			
			IF @flag='agentTransfer'
			BEGIN
				
					
				IF EXISTS (select 'X'  from imeremitcardmaster where (len(@remitCardNo)<>16 and @cardType='r'))   
					   BEGIN  							   
						   SELECT '1' errorCode,'Invalid length of remit card serial number.' AS mes,null id    
						   RETURN;  
					   END 	
				   
				IF EXISTS (select 'X'  from imeremitcardmaster where (len(@remitCardNo)<>16 and @cardType='p'))   
				   BEGIN  							   
					   SELECT '1' errorCode,'Invalid length of remit card pin number.' AS mes ,null id   
					   RETURN;  
				   END 
					
				IF EXISTS (select 'X'  from imeremitcardmaster where (len(@remitCardNo)<>8 and @cardType='c'))   
				   BEGIN  							   
					   SELECT '1' errorCode,'Invalid length of customer card serial number.' AS mes ,null id   
					   RETURN;  
				   END 	
						   
				IF EXISTS(SELECT 'X' from imeremitcardmaster where remitcardNo = @remitCardNo and cardStatus='Enrolled' and ISNULL(isDeleted,'N') <> 'Y')
				BEGIN
					SELECT '1' errorCode,'Card is already enrolled.' AS mes ,null id   
					RETURN; 
				END
				
				IF NOT EXISTS(SELECT 'X' from imeremitcardmaster where remitcardNo = @remitCardNo and cardStatus='Transfered' and ISNULL(agentId,'1001') = @agentFrmName and ISNULL(isDeleted,'N') <> 'Y')
				BEGIN
					SELECT '1' errorCode,'Cards is not in stock with provided agent.' AS mes ,null id   
					RETURN; 
				END 
												
				
				BEGIN TRANSACTION
						   UPDATE imeremitcardmaster
								SET agentId = @agentToName
									,cardStatus ='Transfered'
									,transferedBy =@user
									,transferedDate =GETDATE()	
									where remitcardNo = @remitCardNo
									
						   SELECT '0' errorCode,'Successfully transfered.' AS mes ,null id   
							RETURN;
						   
				COMMIT TRANSACTION
				
			END
			
			IF @flag ='loopTransfer'
			BEGIN
				IF EXISTS (select 'X'  from imeremitcardmaster where (len(@fromCardNo)<>8 and @cardType='c') or (len(@toCardNo)<>8 and @cardType='c'))   
					   BEGIN  							   
						   SELECT '1' errorCode,'Invalid length of customer card serial number.' AS mes ,null id   
						   RETURN;  
					   END
					   
				IF EXISTS(SELECT 'X' from imeremitcardmaster where remitcardNo between @fromCardNo and @toCardNo and cardStatus='Enrolled' AND ISNULL(agentId,'1001') = @agentFrmName AND ISNULL(isDeleted,'N') <> 'Y')
				BEGIN
					SELECT '1' errorCode,'Some of the cards are already Enrolled.' AS mes ,null id   
					RETURN; 
				END
				
				IF  EXISTS(SELECT 'X' from imeremitcardmaster where remitcardNo between @fromCardNo and @toCardNo and (cardStatus='Transfered' OR cardStatus='HO') AND ISNULL(agentId,'1001') = @agentFrmName and ISNULL(isDeleted,'N') <> 'Y' having count('x') <> (@toCardNo - @fromCardNo)+ 1)
				BEGIN
					SELECT '1' errorCode,'Provided cards are not in stock with assigned agent.' AS mes ,null id   
					RETURN; 
				END
				
				IF EXISTS(SELECT 'X' FROM imeremitcardmaster WITH(NOLOCK) WHERE remitCardNo between @fromCardNo and @toCardNo   AND ISNULL(isDeleted,'N') <> 'Y' having count('x') <> (@toCardNo - @fromCardNo)+ 1 )
					BEGIN
						SELECT 1 errorCode,'Some of card number doesnot exists in stock. \n Please update your stock. ' mes ,null id
						RETURN
					END	
						
				IF NOT EXISTS (select 'X'  from imeremitcardmaster where remitCardNo = @toCardNo and @cardType='c')   
				   BEGIN  							   
					   SELECT '1' errorCode,'Card stock exceeds for transfer.' AS mes ,null id   
					   RETURN;  
				   END 	
									
				BEGIN TRANSACTION
					BEGIN
							UPDATE 
								icm
							SET 							 															
								agentId=@agentToName
								,modifiedBy=@user
								,cardStatus ='Transfered'
								,transferedBy =@user
								,transferedDate =GETDATE()	
								,modifiedDate=GETDATE()	
								FROM imeremitcardmaster icm 
								INNER JOIN 
								imeremitcardmaster im 
								ON icm.remitCardNo = im.remitCardNo WHERE icm.remitCardNo between @fromCardNo and @toCardNo
															
						END
					COMMIT TRANSACTION
					SELECT '0' errorCode,'Successfully Assigned.' AS mes ,null id  
				
			END
			
			IF @flag = 'getStockAmount'
			BEGIN
				SELECT COUNT(remitcardno) FROM imeremitcardmaster  WITH(NOLOCK) 
				WHERE ISNULL(agentId,'1001') = @agentFrmName
				AND (cardStatus ='Transfered' or cardStatus ='HO') and cardtype = @cardType
			END
			
	END TRY
	
	BEGIN CATCH
		SELECT 1 , ERROR_MESSAGE()+ERROR_LINE() mes , null id
		RETURN
	END CATCH
END


GO
