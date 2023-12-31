USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_imeRemitcardStockTransfer]    Script Date: 8/23/2020 5:48:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE procEDURE [dbo].[proc_imeRemitcardStockTransfer](
	 @flag			 VARCHAR(10)	= 	NULL
	,@user  		 VARCHAR(30)	= 	NULL	
	,@rowId			 INT			= 	NULL
	,@agentName		 VARCHAR(255)	= 	NULL
	,@xml			 XML			=	NULL
	,@remitCardNo	 VARCHAR(30)	= 	NULL
	,@cardType		 VARCHAR(30)	= 	NULL
	,@cardStatus	 VARCHAR(30)	= 	NULL
	,@accountNumber	 VARCHAR(30)	= 	NULL	
	,@fromCardNo	 BIGINT			=	NULL
	,@toCardNo		 BIGINT			=	NULL
	,@modifiedDate	 VARCHAR(30)	= 	NULL
	,@modifiedBy	 VARCHAR(30)	= 	NULL
	,@createdDate	 VARCHAR(30)	= 	NULL
	,@createdBy		 VARCHAR(30)	= 	NULL
	,@pageSize		 INT			=	NULL
	,@pageNumber	 INT			=	NULL
	,@sortBy		 VARCHAR(50)	=	NULL
	,@sortOrder		 VARCHAR(50)	=	NULL	
)AS
SET NOCOUNT ON
SET	XACT_ABORT ON
BEGIN
	BEGIN TRY
			DECLARE
				 @table				VARCHAR(MAX)
				,@select_field_list	VARCHAR(MAX)
				,@extra_field_list	VARCHAR(MAX)
				,@sql_filter		VARCHAR(MAX)				
				,@validateCard		VARCHAR(20)		
		IF @flag='s'
				BEGIN		
					SET @sortBy='rowId'
					SET @sortOrder='DESC'

					SET @table='
					(	
						SELECT	 id as rowId
								,ISNULL(am.agentName,'''') as AGENT
								,remitCardNo											
								,case when cardType=''r'' then ''IME Remit Card'' else
									case when cardType=''c'' then ''Customer Card''
									else ''PIN-IME Remit Card'' end end	 as cardType																				
								,cardStatus
								,icm.createdBy as [user]
								,icm.createdDate as createdDate
								,icm.modifiedDate as modifiedDate
								,icm.modifiedBy as modifiedBy
								
						  FROM imeremitcardmaster icm with (nolock) left join agentmaster am
						  on icm.agentId=am.agentId where cardStatus =''Transfered'' and ISNULL(icm.isDeleted,''N'')<>''Y''					
					)x'
									
					SET @sql_filter = ''
							
					IF @remitCardNo IS NOT NULL  
						SET @sql_filter=@sql_filter + ' AND remitCardNo = ''' +@remitCardNo+''''
					IF @cardType IS NOT NULL  
						SET @sql_filter=@sql_filter + ' AND cardType = ''' +@cardType+''''	
					IF @agentName IS NOT NULL  
						SET @sql_filter=@sql_filter + ' AND AGENT like ''%' +@agentName+'%'''	
					IF @cardStatus IS NOT NULL
						SET @sql_filter=@sql_filter + ' AND cardStatus = ''' +@cardStatus+''''		
					IF @createdDate IS NOT NULL
						SET @sql_filter=@sql_filter + ' AND cast(createdDate as date)  = ''' +@createdDate +''''
					IF @createdBy IS NOT NULL
						SET @sql_filter=@sql_filter + ' AND [user] like ''%' +@createdBy+'%'''
					IF @modifiedDate IS NOT NULL
						SET @sql_filter=@sql_filter + ' AND cast(modifiedDate as date)  = ''' +@modifiedDate +''''
					IF @modifiedBy IS NOT NULL
						SET @sql_filter=@sql_filter + ' AND modifiedBy like ''' +@modifiedBy+''''	
						
					SET @select_field_list = '
											 rowId
											,Agent	
											,remitCardNo																		
											,cardType								
											,cardStatus
											,[user]
											,createdDate
											,modifiedDate
											,modifiedBy										
										'
										
					EXEC dbo.proc_paging
					 @table
					,@sql_filter
					,@select_field_list
					,@extra_field_list
					,@sortBy
					,@sortOrder
					,@pageSize
					,@pageNumber
				
				END	
				
		IF @flag='i'
			BEGIN				
					
				IF EXISTS (select 'X'  from imeremitcardmaster where (len(@remitCardNo)<>16 and @cardType='r'))   
					   BEGIN  							   
						   SELECT '1' errorCode,'Invalid length of remit card serial number.' AS mes ,null id   
						   RETURN;  
					   END
					   
				IF EXISTS (select 'X'  from imeremitcardmaster where (len(@remitCardNo)<>8 and @cardType='c') )   
					   BEGIN  							   
						   SELECT '1' errorCode,'Invalid length of customer card serial number.' AS mes ,null id   
						   RETURN;  
					   END
					   
				IF EXISTS (select 'X'  from imeremitcardmaster where (len(@remitCardNo)<>16 and @cardType='p'))   
					   BEGIN  							   
						   SELECT '1' errorCode,'Invalid length of remit pin number.' AS mes,null id  
						   RETURN;  
					   END
					   
				IF EXISTS(SELECT 'X' FROM imeremitcardmaster WITH(NOLOCK) WHERE remitCardNo=@remitCardNo AND cardStatus ='Transfered' AND ISNULL(isDeleted,'N') <> 'Y')
					BEGIN
						SELECT 1 errorCode,'Card is already Transfered !!!' mes ,null id
						RETURN
					END
					
				IF NOT EXISTS(SELECT 'X' FROM imeremitcardmaster WITH(NOLOCK) WHERE remitCardNo=@remitCardNo AND ISNULL(isDeleted,'N') <> 'Y')
					BEGIN
						SELECT 1 errorCode,'Card number doesnot exists in stock !!!' mes ,null id
						RETURN
					END
					   
			   BEGIN TRANSACTION			  
					
						BEGIN
							UPDATE imeremitcardmaster 
								SET 
									agentId = @agentName
									,modifiedBy=@user
									,modifiedDate = GETDATE()
									,cardStatus ='Transfered'
										WHERE remitCardNo = @remitCardNo and cardType = @cardType
						END					
			COMMIT TRANSACTION	
			
			SELECT '0' errorCode,'Successfully Assigned !!!' AS mes ,null id														
			END	
			
		IF @flag='upload'  
					BEGIN  
					  DECLARE @TEMP TABLE(remitCardNo VARCHAR(50),agentID VARCHAR(50))  
					  DECLARE @totalQuantity VARCHAR(10)=NULL
							INSERT @TEMP(
								remitCardNo
								,agentID
								)  
								   SELECT  
									 p.value('@casId','VARCHAR(50)') 
									,p.value('@agentId','VARCHAR(50)') 
								   FROM @xml.nodes('/root/row') AS tmp(p)     
					     
					DECLARE @outOfStockNumber INT,@availability VARCHAR(50)
					SELECT @outOfStockNumber=count('x') FROM @temp t LEFT JOIN imeremitcardmaster m ON m.remitCardNo=t.remitCardNo WHERE m.remitCardNo is null and ISNULL(m.isDeleted,'N') <> 'Y'
					SELECT @availability=count('x') FROM @temp t LEFT JOIN imeremitcardmaster m ON m.remitCardNo=t.remitCardNo WHERE m.cardStatus='Transfered' and ISNULL(m.isDeleted,'N') <> 'Y'												
					   IF @outOfStockNumber<>0  
						   BEGIN  
								SELECT '1' errorCode,cast(@outOfStockNumber as varchar)+' Items are not in stocks. \n Please update your stock.' AS mes ,null id   
								RETURN;  
						   END 
						   
						IF @availability<>0  
						   BEGIN  
								SELECT '1' errorCode,cast(@availability as varchar)+' Items are already reserverd. \n Please review your data. !!!' AS mes ,null id   
								RETURN;  
						   END 
					  
					   IF EXISTS(select remitCardNo,count('x') from @TEMP group by remitCardNo having count('x')>1)  
						   BEGIN  
							   SELECT '1' errorCode,'Duplicate serial number exists in your upload file.' AS mes,null id    
							   RETURN;  
						   END 
						 
					 			
					 	IF EXISTS (select 'X'  from @TEMP where (len(remitCardNo)<>16 and @cardType='r'))   
						   BEGIN  							   
							   SELECT '1' errorCode,'Invalid length of remit card serial number.' AS mes,null id    
							   RETURN;  
						   END 	
						   
						IF EXISTS (select 'X'  from @TEMP where (len(remitCardNo)<>16 and @cardType='p'))   
						   BEGIN  							   
							   SELECT '1' errorCode,'Invalid length of remit card pin number.' AS mes ,null id   
							   RETURN;  
						   END 
						   
						IF EXISTS (select 'X'  from @TEMP where (len(remitCardNo)<>8 and @cardType='c'))   
						   BEGIN  							   
							   SELECT '1' errorCode,'Invalid length of customer card serial number.' AS mes ,null id   
							   RETURN;  
						   END 	   
					   BEGIN TRANSACTION  
							 UPDATE
								icm
									SET
										 icm.agentId=tt.agentID
										,icm.modifiedBy=@user
										,icm.modifiedDate=GETDATE()
										,icm.cardStatus='Transfered'
											FROM
											imeremitcardmaster icm JOIN @TEMP tt 
											ON icm.remitCardNo = tt.remitCardNo WHERE 
											icm.cardType = @cardType						
					      					      
					   SELECT @totalQuantity=COUNT(*) FROM imeremitcardmaster   
					  SELECT '0' errorCode,'Stock Transfer Sucessfully Assigned.' mes,null id    
					  COMMIT TRANSACTION  
					 END 
			
		IF @flag='delete'
			BEGIN
				UPDATE  imeremitcardmaster SET 
					isDeleted ='Y'
					,modifiedBy = @user
					,modifiedDate=GETDATE()
				 where id = @rowId
				SELECT '0' ,'Successfully Deleted !!!' mes ,null id
			END	
		
		IF @flag='select'
			BEGIN
				SELECT	id as rowId
							,ISNULL(am.agentName,'') AS AGENT
							,icm.agentId
							,remitCardNo													
							,cardType																				
							,cardStatus
							,icm.createdBy AS [user]
							,icm.createdDate AS createdDate
							,icm.modifiedDate AS modifiedDate
							,icm.modifiedBy AS modifiedBy
																
					  FROM imeremitcardmaster icm WITH (NOLOCK) left join agentmaster am
					  ON icm.agentId=am.agentId WHERE icm.id = @rowid and ISNULL(icm.isDeleted,'N') <> 'Y'
			END	
		
		IF @flag ='u'	
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
						IF NOT EXISTS(SELECT 'X' FROM imeremitcardmaster WITH(NOLOCK) WHERE remitCardNo=@remitCardNo and ISNULL(isDeleted,'N') <> 'Y' )
							BEGIN
								SELECT 1 errorCode,'Card number doesnot exists in stock !!!' mes ,null id
								RETURN
							END	
											
						IF EXISTS (select 'X'  from imeremitcardmaster where id <> @rowId and accountNo=@accountNumber and ISNULL(isDeleted,'N') <> 'Y') 	
							BEGIN
								SELECT 1 errorCode,'Account number already exists.' mes ,null id
								RETURN
							END	
							
						IF EXISTS (select 'X'  from imeremitcardmaster where id <>@rowId and remitCardNo=@remitCardNo and ISNULL(isDeleted,'N') <> 'Y' and cardStatus='Transferred') 	
						BEGIN
							SELECT 1 errorCode,'Card number already exists.' mes ,null id
							RETURN
						END	
						
						SET @validateCard =(SELECT remitCardNo from  imeremitcardmaster where id = @rowId)
								
					UPDATE 
						imeremitcardmaster
							SET 
								remitCardNo=@remitCardNo								
								,agentId=@agentName
								,modifiedBy=@user
								,modifiedDate=GETDATE()
								,cardStatus='Transfered'
							WHERE remitCardNo=@remitCardNo
							
					IF 	@remitCardNo <> @validateCard
					UPDATE imeremitcardmaster
							SET 
								remitCardNo=@validateCard								
								,agentId=NULL
								,modifiedBy=@user
								,modifiedDate=GETDATE()
								,cardStatus='HO'
							WHERE remitCardNo=@validateCard
						
				SELECT '0' errorCode,'Successfully Assigned !!!' AS mes ,null id	
			END	 
		
		IF @flag ='loopUpdate'
		BEGIN
					   
				IF EXISTS (select 'X'  from imeremitcardmaster where (len(@fromCardNo)<>8 and @cardType='c') or (len(@toCardNo)<>8 and @cardType='c'))   
					   BEGIN  							   
						   SELECT '1' errorCode,'Invalid length of customer card serial number.' AS mes ,null id   
						   RETURN;  
					   END
					   
				IF EXISTS(SELECT 'X' from imeremitcardmaster where remitcardNo between @fromCardNo and @toCardNo and cardStatus='Enrolled' and ISNULL(isDeleted,'N') <> 'Y')
				BEGIN
					SELECT '1' errorCode,'Some of the cards are already Enrolled.' AS mes ,null id   
					RETURN; 
				END
				
				IF EXISTS(SELECT 'X' from imeremitcardmaster where remitcardNo between @fromCardNo and @toCardNo and cardStatus='Transfered' and ISNULL(isDeleted,'N') <> 'Y')
				BEGIN
					SELECT '1' errorCode,'Some of the cards are already Transfered.' AS mes ,null id   
					RETURN; 
				END
				
				IF NOT EXISTS(SELECT 'X' FROM imeremitcardmaster WITH(NOLOCK) WHERE remitCardNo between @fromCardNo and @toCardNo and ISNULL(isDeleted,'N') <> 'Y' )
					BEGIN
						SELECT 1 errorCode,'Card number doesnot exists in stock. \n Please update your stock. ' mes ,null id
						RETURN
					END	
				
				UPDATE imeremitcardmaster SET 															
								agentId=@agentName
								,modifiedBy=@user
								,modifiedDate=GETDATE()
								,cardStatus='Transfered'
							WHERE remitCardNo BETWEEN @fromCardNo AND @toCardNo


				--BEGIN TRANSACTION
				--WHILE(@fromCardNo <= @toCardNo)
				--		BEGIN
				--			UPDATE imeremitcardmaster SET 															
				--				agentId=@agentName
				--				,modifiedBy=@user
				--				,modifiedDate=GETDATE()
				--				,cardStatus='Transfered'
				--			WHERE remitCardNo=@fromCardNo
							
				--			SET @fromCardNo = @fromCardNo + 1	
				--		END
				--	COMMIT TRANSACTION
					SELECT '0' errorCode,'Successfully Assigned.' AS mes ,null id   				
		END	
					
	END TRY
	BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK
	SELECT 1 errorCode, ERROR_MESSAGE()+ERROR_LINE() mes, @rowId id	
	END CATCH
END


GO
