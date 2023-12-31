USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[sp_students]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	      CREATE procedure [dbo].[sp_students]

			(

							@flag char(10)
							,@id int = null
							,@name varchar(20) = null
							,@pwd varchar(20) = null
							,@sortBy		varchar(100)=null
							,@sortOrder		varchar(100)=null
							,@pageSize		varchar(100)=null
							,@pageNumber	varchar(100)=null
							,@user          varchar(100)=null


            )

					as 

					  if @flag='i'

						begin

							insert into students values(@name,@pwd)

						    select 0 errorcode,'row is inserted' Msg, @id Id

						end

					  if @flag='d'

								begin 

								delete from students where sid=@id

								select 0 success,'row is deleted' msg , @id sid

								end

					 if @flag='u'

							   begin

							   update students set name=@name,password=@pwd where sid=@id

							 select 0 success,'row has been updated' msg, @id sid

							   end

IF @flag = 's'
	BEGIN
		DECLARE 
			 @selectFieldList	VARCHAR(MAX)
			,@extraFieldList	VARCHAR(MAX)
			,@table				VARCHAR(MAX)
			,@sqlFilter			VARCHAR(MAX)
			
			
		--IF @sortBy IS NULL  
			SET @sortBy = 'sid'			
	
		SET @table = '(		
						select sid,name,password from students
					  ) x'	
		
					
		SET @sqlFilter = ''	
		
		SET @selectFieldList = '
							 sid
							,name
							,password
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
					 if @flag='sbyid'

						  begin 

						  select  name,password from students where sid=@id

						  end
                if @flag='flike'
				     begin
					   select * from students where name like '%'+@name+'%'
                     end
               if @flag='llike'
			       begin 
				    select *  from students where name like '%' +@name
					end
             if @flag='rlike'
			    begin
				 select * from students where name like @name+'%'
				 end

GO
