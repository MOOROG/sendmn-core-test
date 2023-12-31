USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_agentBlock]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_agentBlock](
     @flag				VARCHAR(30)	= NULL
	,@user				VARCHAR(30) = NULL
	,@id				VARCHAR(30)	= NULL
	,@agentId			VARCHAR(30)	= NULL
	,@agentStatus		VARCHAR(30)	= NULL
	,@remarks			VARCHAR(255)= NULL
	,@sortBy			VARCHAR(50)	= NULL
	,@sortOrder			VARCHAR(5)	= NULL
	,@pageSize			INT			= NULL
	,@pageNumber		INT			= NULL  
	,@modType			VARCHAR(30) = NULL	
	,@fromDate			VARCHAR(30) = NULL
	,@toDate			VARCHAR(30) = NULL
)AS
BEGIN
	DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter			VARCHAR(MAX)



	IF @flag='a'
	BEGIN
		SELECT 
			 id
			,agentId
			,agentStatus
			,remarks
		FROM agentBlock WHERE id=@id
		RETURN
	END
	IF @flag = 's'
	BEGIN					
		IF @sortBy IS NULL  
			SET @sortBy = 'agentId'			
	
		SET @table = '(		
						SELECT 
							 id			= ag.id
							,agentId	= am.agentName
							,agentStatus= ag.agentStatus							 
							,remarks	= ag.remarks
							,createdBy	= ag.createdBy	
							,createdDate= ag.createdDate		
							,approvedDate= ag.approvedDate
							,approvedBy	= ag.approvedBy		
							,modifiedBy = ISNULL(x.createdBy, ag.createdBy)
							,modifiedDate = ISNULL(x.createdDate, ag.createdDate)
							,hasChanged = CASE WHEN (x.id IS NOT NULL) OR (ag.approvedBy IS NULL) THEN ''Y'' ELSE ''N'' END
						FROM agentBlock ag WITH(NOLOCK) 
						LEFT JOIN (
							SELECT
								 id
								,createdBy = MAX(createdBy)
								,createdDate = MAX(createdDate)
							FROM agentBlockMod agm WITH(NOLOCK)
							GROUP BY id
						) x ON ag.id = x.id	
						LEFT JOIN agentMaster am with(nolock) on am.agentId=ag.agentId
						where ag.agentStatus=''Block'' OR ag.agentStatus=''Inactive''		
					  ) x'	
		
					
		SET @sqlFilter = ''	

		IF @fromDate IS NOT NULL AND @toDate IS NOT NULL
			SET @sqlFilter=@sqlFilter+ 'AND approvedDate between '''+@fromDate +'''and '''+@toDate+' 23:59:59'''
		IF @agentStatus IS NOT NULL
			SET @sqlFilter=@sqlFilter+' AND agentStatus='''+@agentStatus+''''
		IF @agentId IS NOT NULL
			SET @sqlFilter=@sqlFilter+' AND agentId like ''%'+@agentId+'%'''

		
		SET @selectFieldList = '
							 id
							,agentId	 
							,agentStatus 
							,remarks	 
							,createdBy  
							,createdDate 
							,modifiedBy
							,modifiedDate							
							,approvedDate
							,approvedBy
							,hasChanged  
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
	IF @flag='i'
	BEGIN
		IF EXISTS(SELECT 'X' FROM agentBlock WITH(NOLOCK) WHERE agentId = @agentId AND approvedDate IS NULL)
		BEGIN
			EXEC proc_errorHandler 1, 'Request already in pending.', NULL
			RETURN			
		END
		
		INSERT INTO agentBlock
		(
			 agentId
			,agentStatus
			,remarks
			,createdDate
			,createdBy			
		)
		SELECT 
			 @agentId
			,@agentStatus
			,@remarks
			,GETDATE()
			,@user			 

		EXEC proc_errorHandler 0, 'Record has been requested successfully.', NULL
		RETURN
	END
	IF @flag = 'u'
    BEGIN
	
		IF EXISTS (SELECT 'X' FROM agentBlock WITH(NOLOCK) WHERE  id = @id AND approvedBy IS NULL AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', NULL
			RETURN
		END
		IF EXISTS (SELECT 'X' FROM agentBlockMod WITH(NOLOCK) WHERE id = @id AND createdBy <> @user)
		BEGIN
			EXEC proc_errorHandler 1, 'You can not modify this record. Previous Modification has not been approved yet.', NULL
			RETURN
		END 
		BEGIN TRANSACTION
			
			IF EXISTS (SELECT 'X' FROM agentBlock WITH(NOLOCK) WHERE id = @id AND approvedBy IS NULL AND createdBy = @user)
			BEGIN
				UPDATE agentBlock SET
					 agentId		=@agentId
					,agentStatus	=@agentStatus
					,remarks		=@remarks
					,modifiedDate	=GETDATE()
					,modifiedBy		=@user
			END 
			ELSE
			BEGIN
				DELETE FROM agentBlockMod WHERE id = @id
				INSERT INTO agentBlockMod (
					 id
					,agentId
					,agentStatus
					,remarks
					,createdDate
					,createdBy	
					,modType    					          
				)
				SELECT
					 @id
					,@agentId
					,@agentStatus
					,@remarks
					,GETDATE()
					,@user
					,'U'  
					       
			END
        COMMIT TRANSACTION       
        EXEC proc_errorHandler 0, 'Record updated successfully', @agentId		
	END
	IF @flag = 'approve'
	BEGIN			
		DECLARE @updateAbleCol VARCHAR(30)=NULL	
		IF EXISTS (SELECT 'X' FROM agentBlock  WITH(NOLOCK) WHERE approvedBy IS NULL AND id = @id)
		BEGIN
			SET @modType = 'I'
			SELECT @agentId=agentId FROM agentBlock  WITH(NOLOCK) WHERE id = @id
			IF EXISTS(SELECT 'x' FROM agentBlock WITH(NOLOCK) WHERE id=@id AND agentStatus='Inactive')
			BEGIN
				SET @updateAbleCol='isActive'
			END
			ELSE
			BEGIN
				SET @updateAbleCol='agentBlock'
			END				
		END
		ELSE
		BEGIN
			SELECT @modType = modType FROM agentBlockMod WITH(NOLOCK) WHERE id = @id
			SELECT @agentId=agentId FROM agentBlockMod  WITH(NOLOCK) WHERE id = @id
			IF EXISTS(SELECT 'x' FROM agentBlockMod WITH(NOLOCK) WHERE id=@id AND agentStatus='Inactive')
			BEGIN
				SET @updateAbleCol='isActive'
			END
			ELSE
			BEGIN
				SET @updateAbleCol='agentBlock'
			END		
		END			
		IF @modType = 'I'
		BEGIN --New record
			BEGIN TRAN
				UPDATE agentBlock SET					
					 approvedBy = @user
					,approvedDate= GETDATE()
				WHERE id = @id	
				
				IF(@updateAbleCol='isActive')
				BEGIN
					UPDATE agentMaster 
						SET isActive='N',
						modifiedBy = @user,
						modifiedDate = GETDATE()
					WHERE agentId=@agentId	
				END	
				ELSE IF(@updateAbleCol='agentBlock')	
				BEGIN
					UPDATE agentMaster SET 
						agentBlock='B',
						isActive = 'N',
						modifiedBy = @user,
						modifiedDate = GETDATE()
					WHERE agentId=@agentId	
				END	
			COMMIT TRAN										
		END
		ELSE IF @modType = 'U'
		BEGIN								
			BEGIN TRAN
				UPDATE main SET	
					 main.agentId						=mode.agentId
					,main.agentStatus					=mode.agentStatus
					,main.remarks						=mode.remarks					            
					,main.modifiedDate					=GETDATE()
					,main.modifiedBy					= @user					
				FROM agentBlock main
				INNER JOIN agentBlockMod mode ON mode.id= main.id
					WHERE mode.id = @id								
					
				IF(@updateAbleCol='isActive')
				BEGIN
					UPDATE agentMaster 
						SET isActive='N',
						modifiedBy = @user,
						modifiedDate = GETDATE()
					WHERE agentId=@agentId	
				END	
				ELSE IF(@updateAbleCol='agentBlock')	
				BEGIN
					UPDATE agentMaster 
						SET agentBlock='B',
						isActive = 'N',
						modifiedBy = @user,
						modifiedDate = GETDATE()
					WHERE agentId=@agentId	
				END			
			COMMIT TRAN
		END			
		DELETE FROM agentBlockMod WHERE id = @id			
		EXEC proc_errorHandler 0, 'Modification approved successfully', @agentId
	END
	IF @flag='ddlstatus'
	BEGIN
		SELECT '' value, 'Select' text 
		UNION ALL SELECT 'Block' value, 'Blocked' text 
		UNION ALL SELECT 'Inactive' value, 'Inactive' text
	END
END


GO
