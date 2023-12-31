USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_imeRemitcardStockUpload]    Script Date: 5/18/2021 5:17:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procEDURE [dbo].[proc_imeRemitcardStockUpload](
	 @flag			 VARCHAR(10)	= 	NULL
	,@user  		 VARCHAR(30)	= 	NULL	
	,@rowId			 INT			= 	NULL
	,@agentName		 VARCHAR(255)	= 	NULL
	,@xml			 XML			=	NULL
	,@remitCardNo	 VARCHAR(30)	= 	NULL
	,@cardType		 VARCHAR(30)	= 	NULL
	,@cardStatus	 VARCHAR(30)	= 	NULL
	,@accountNumber	 VARCHAR(30)	= 	NULL
	,@fromSn		 BIGINT			=	NULL
	,@toSn			 BIGINT			=	NULL
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
				DECLARE @startLoopFirst AS INT
				SET @startLoopFirst = 0				
				DECLARE @startLoopLast AS BIGINT
				SET @startLoopLast = CAST(@toSn AS BIGINT) - CAST(@fromSn AS BIGINT)				
		IF @flag='s'
				BEGIN		
					SET @sortBy='rowId'
					SET @sortOrder='DESC'

					SET @table='
					(	
						SELECT	 id as rowId
								,ISNULL(am.agentName,''Head Office'') as AGENT
								,accountNo
								,remitCardNo							
								,case when cardType=''r'' then ''IME Remit Card'' else
									case when cardType=''c'' then ''Customer Card''
									else ''PIN-IME Remit Card'' end end	 as cardType																		
								,icm.createdBy as [user]		
								,cardStatus
								,icm.createdDate as createdDate								
								,icm.modifiedDate as modifiedDate
								,icm.modifiedBy as modifiedBy
								
						  FROM imeremitcardmaster icm with (nolock) left join agentmaster am
						  on icm.agentId=am.agentId where ISNULL(icm.isDeleted,''N'')<>''Y''					
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
						
					SET @select_field_list = '
											 rowId
											,Agent	
											,remitCardNo
											,accountNo									
											,cardType								
											,cardStatus
											,[user]
											,createdDate
											,modifiedDate
											,modifiedBy										
										'
					--print(@table + @sql_filter)					
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
				
		IF @flag= 'loopInsert'
			BEGIN
				IF EXISTS(SELECT 'X' FROM imeremitcardmaster WITH(NOLOCK) WHERE remitCardNo Between @fromSn and @toSn and ISNULL(isDeleted,'N') <> 'Y')
					BEGIN
						SELECT 1 errorCode,'Card Number Already Exists !!!' mes ,null id
						RETURN
					END
					
				IF EXISTS (select 'X'  from imeremitcardmaster where (len(@fromSn)<>16 and @cardType='r') or (len(@toSn)<>16 and @cardType='r'))   
					   BEGIN  							   
						   SELECT '1' errorCode,'Invalid length of remit card serial number.' AS mes ,null id   
						   RETURN;  
					   END
					   
				IF EXISTS (select 'X'  from imeremitcardmaster where (len(@fromSn)<>8 and @cardType='c') or (len(@toSn)<>8 and @cardType='c'))   
					   BEGIN  							   
						   SELECT '1' errorCode,'Invalid length of customer card serial number.' AS mes ,null id   
						   RETURN;  
					   END
					   
				IF EXISTS (select 'X'  from imeremitcardmaster where (len(@fromSn)<>16 and @cardType='p') or (len(@toSn)<>16 and @cardType='p'))   
					   BEGIN  							   
						   SELECT '1' errorCode,'Invalid length of remit pin number.' AS mes,null id  
						   RETURN;  
					   END
					   				
					   
			   BEGIN TRANSACTION			  
					WHILE(@fromSn <= @toSn)
						BEGIN
							INSERT INTO imeremitcardmaster (
										remitCardNo
										,cardStatus
										,createdBy
										,createdDate
										,cardType
									)
							 select 
								 cast(@fromSn as bigint)
								 ,'HO'
								 ,@user
								 ,GETDATE()
								 ,@cardType
							
							SET @fromSn = @fromSn + 1	
						END					
			COMMIT TRANSACTION	
			
			SELECT '0' errorCode,'Successfully Inserted !!!' AS mes ,null id														
			END	
			
		IF @flag='i'
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
						
						IF EXISTS (select 'X'  from imeremitcardmaster where accountNo=@accountNumber and ISNULL(isDeleted,'N')<>'Y') 	
							BEGIN
								SELECT 1 errorCode,'Account number already exists.' mes ,null id
								RETURN
							END	
						IF EXISTS (select 'X'  from imeremitcardmaster where  remitCardNo=@remitCardNo and ISNULL(isDeleted,'N')<>'Y') 	
							BEGIN
								SELECT 1 errorCode,'Card number already exists.' mes ,null id
								RETURN
							END	
							
					BEGIN TRANSACTION
						INSERT INTO imeremitcardmaster (
											remitCardNo
											,accountNo
											,cardStatus
											,createdBy
											,createdDate
											,cardType
										)
								 VALUES (
									 cast(@remitCardNo as bigint)
									 ,@accountNumber
									 ,'HO'
									 ,@user
									 ,GETDATE()
									 ,@cardType
									 )
									 
									 IF @cardType='r'																		 
									 INSERT INTO imeremitcardmaster (
											remitCardNo
											,accountNo
											,cardStatus
											,createdBy
											,createdDate
											,cardType
												)
										 VALUES (
											 cast(@remitCardNo as bigint)
											 ,@accountNumber
											 ,'HO'
											 ,@user
											 ,GETDATE()
											 ,'p'
											 )
									 
					COMMIT TRANSACTION
					
					SELECT '0' errorCode,'Successfully Inserted !!!' AS mes ,null id
				END
			
		IF @flag= 'upload'  
					BEGIN  
					  DECLARE @TEMP TABLE(remitCardNo VARCHAR(50),accountNo VARCHAR(50))  
					  DECLARE @totalQuantity VARCHAR(10)=NULL
							INSERT @TEMP(
								remitCardNo
								,accountNo
								)  
								   SELECT  
									 p.value('@casId','VARCHAR(50)')  
									,p.value('@account','VARCHAR(50)')  
								   FROM @xml.nodes('/root/row') AS tmp(p)     
					     
					   IF EXISTS(SELECT 'X' FROM @TEMP WHERE remitCardNo IN (SELECT remitCardNo FROM imeremitcardmaster where ISNULL(isDeleted,'N') <> 'Y'))  
						   BEGIN  
								SELECT '1' errorCode,'Stock with these serial number already exists.' AS mes ,null id   
								RETURN;  
						   END  
						   
					 IF EXISTS(SELECT 'X' FROM @TEMP WHERE accountNo IN (SELECT accountNo FROM imeremitcardmaster where ISNULL(isDeleted,'N') <> 'Y'))  
					   BEGIN  
							SELECT '1' errorCode,'Some of the account number already exists.' AS mes ,null id   
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
						   INSERT INTO imeremitcardmaster(  
							   remitCardNo 
							  ,accountNo 
							  ,cardStatus 
							  ,cardType 
							  ,createdBy
							  ,createdDate  
							)SELECT   
							   remitCardNo 
							  ,accountNo
							  ,'HO'   
							  ,@cardType
							  ,@user
							  ,GETDATE()  
							FROM @temp  
						      
					      IF @cardType='r'	 
					      INSERT INTO imeremitcardmaster(  
							   remitCardNo 
							  ,accountNo 
							  ,cardStatus 
							  ,cardType 
							  ,createdBy
							  ,createdDate  
							)SELECT   
							   remitCardNo 
							  ,accountNo
							  ,'HO'   
							  ,'p'
							  ,@user
							  ,GETDATE()  
							FROM @temp 
					      
					      
					      
					   SELECT @totalQuantity=COUNT(*) FROM imeremitcardmaster   
					  SELECT '0' errorCode,'Stock Sucessfully Uploaded.' mes,null id    
					  COMMIT TRANSACTION  
					 END 
			
		IF @flag = 'typedll'
			BEGIN
			SELECT '' AS name, 'Select' AS value
			UNION ALL
			SELECT 'IME Remit Card' AS name, 'IME Remit Card' AS value
			UNION ALL
			SELECT 'Customer Card' AS name, 'Customer Card' AS value
			UNION ALL
			SELECT 'PIN-IME Remit Card' AS name, 'PIN-IME Remit Card' AS value				
			END		 
				
		IF @flag = 'statusdll'
			BEGIN
			SELECT '' AS name, 'Select' AS value			
			UNION ALL
			SELECT 'HO' AS name, 'Head Office' AS value
			UNION ALL
			SELECT 'Transfered' AS name, 'Transfered' AS value
			UNION ALL
			SELECT 'Enrolled' AS name, 'Enrolled' AS value							
			END	
			
		IF @flag= 'delete'
			BEGIN
				
				UPDATE  imeremitcardmaster 
					SET 
					 isDeleted ='Y'
					,modifiedBy = @user
					,modifiedDate=GETDATE()
				 where id = @rowId
				SELECT '0' ,'Successfully Deleted !!!' mes ,null id
			END	
		
		IF @flag= 'select'
			BEGIN
				SELECT	id as rowId
							,ISNULL(am.agentName,'') AS AGENT
							,icm.agentId
							,remitCardNo
							,accountNo							
							,cardType																				
							,cardStatus
							,icm.createdBy AS [user]
							,icm.createdDate AS createdDate
							,icm.modifiedDate AS modifiedDate
							,icm.modifiedBy AS modifiedBy
																
					  FROM imeremitcardmaster icm WITH (NOLOCK) left join agentmaster am
					  ON icm.agentId=am.agentId WHERE icm.id = @rowid and ISNULL(icm.isDeleted,'N')<>'Y'
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
						
						IF EXISTS (select 'X'  from imeremitcardmaster where id <> @rowId and accountNo=@accountNumber and ISNULL(isDeleted,'N')<>'Y') 	
							BEGIN
								SELECT 1 errorCode,'Account number already exists.' mes ,null id
								RETURN
							END	
						IF EXISTS (select 'X'  from imeremitcardmaster where id <> @rowId and remitCardNo=@remitCardNo and ISNULL(isDeleted,'N')<>'Y') 	
							BEGIN
								SELECT 1 errorCode,'Card number already exists.' mes ,null id
								RETURN
							END	
					UPDATE 
						imeremitcardmaster
							SET 
								remitCardNo=@remitCardNo
								,accountNo=@accountNumber
								,agentId=@agentName
								,modifiedBy=@user
								,modifiedDate=GETDATE()
								,cardStatus='HO'
							WHERE id= @rowId 
						
				SELECT '0' errorCode,'Successfully Assigned !!!' AS mes ,null id	
			END			 		
	END TRY
	BEGIN CATCH
	IF @@TRANCOUNT > 0
	ROLLBACK
	SELECT 1 errorCode, ERROR_MESSAGE()+ERROR_LINE() mes, @rowId id	
	END CATCH
END

GO
