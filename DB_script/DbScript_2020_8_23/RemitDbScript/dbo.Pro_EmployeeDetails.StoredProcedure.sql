USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[Pro_EmployeeDetails]    Script Date: 8/23/2020 5:48:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Pro_EmployeeDetails] 
	@Id INT =NULL,
	@Name NVARCHAR(500)  =NULL,
	@Address NVARCHAR(500) = NULL,
	@Email NVARCHAR(50) = NULL,
	@MobileNo NVARCHAR(50) = NULL,
	@DepartName NVARCHAR(50) =NULL,
	@DOB DATETIME  =NULL,
	@CompanyJoinDate DATETIME=  NULL,
	@WorkDayOnWeek INT=  NULL,
	@Description NVARCHAR(MAX) =NULL,
	@flag Nvarchar(10)  =NULL,
	@sortBy					 VARCHAR(50)  = NULL,
	@sortOrder				 VARCHAR(5)   = NULL,  
	@pageSize					 INT		  = NULL,  
	@pageNumber				 INT		  = NULL,
	@user						 VARCHAR(30)  = NULL
AS
BEGIN
	DECLARE  @table NVARCHAR(MAX),
			 @sql_filter  VARCHAR(MAX),
			 @select_field_list VARCHAR(MAX),
			 @extra_field_list VARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

   IF @flag='I'
   BEGIN
		 
			IF @Name IS NULL
				BEGIN
					SELECT 1,'Name Is Required' Msg,NULL;
					RETURN
				END
			IF @Address IS NULL
				BEGIN
					SELECT 1,'Address Is Required' Msg,NULL
					RETURN
				END
			IF @Email IS NULL
				BEGIN
					SELECT 1,'Email Is Required' Msg,NULL
					RETURN
				END
			IF @DOB IS NULL
				BEGIN
					SELECT 1,'DOB Is Required' Msg,NULL
					RETURN
				END
			IF @MobileNo IS NULL
				BEGIN
					SELECT 1,'Mobile No Is Required' Msg,NULL
					RETURN
				END

			BEGIN
				INSERT INTO EmployeeDetails (Name,Address,Email,MobileNo,DepartName,DOB,CompanyJoinDate,WorkDayOnWeek,Description)
				VALUES(@Name,@Address,@Email,@MobileNo,@DepartName,@DOB,@CompanyJoinDate,@WorkDayOnWeek,@Description)
				SELECT * FROM dbo.EmployeeDetails WHERE Name=@Name;
			END
		RETURN;
   END;
   IF @flag='U'
   BEGIN
       IF @Id IS NULL
		BEGIN
		    SELECT 1,'Id Is Required' Msg,NULL
		END;
	UPDATE dbo.EmployeeDetails SET
			Name=@Name,
			Address=@Address,
			Email=@Email,
			MobileNo=@MobileNo,
			DepartName=@DepartName,
			DOB=@DOB,
			CompanyJoinDate=@CompanyJoinDate,
			WorkDayOnWeek=@WorkDayOnWeek,
			Description=@Description
			WHERE Id=@Id
	SELECT 0,NULL,NULL;
	RETURN;
   END;

   IF @flag ='S'
   BEGIN
			SELECT * FROM dbo.EmployeeDetails WHERE Id=@Id;
			RETURN;
   END;
   IF @flag='D'
   BEGIN
       DELETE FROM dbo.EmployeeDetails WHERE Id=@Id;
	   EXEC proc_errorHandler 0, 'Record deleted successfully.', @Id
	   RETURN;
   END;

   IF @flag='Employee-List'
   PRINT 'Hello'
   BEGIN
			IF @sortBy IS NULL
				SET @sortBy='Id'
			IF @sortOrder IS NULL
				SET	@sortOrder ='DESC'
		SET @table=	'(SELECT * FROM	dbo.EmployeeDetails)x'
		--PRINT @table
		SET @sql_filter = ''
        IF @Email IS NOT NULL
			SET @sql_filter += ' AND EMAIL = '''+@Email+'''';

		SET @select_field_list ='Id,Name,Address,Email,MobileNo,DepartName,DOB,CompanyJoinDate'
		EXEC dbo.proc_paging
			@table,
			@sql_filter,
			@select_field_list,
			@extra_field_list,
			@sortBy,
			@sortOrder,
			@pageSize,
			@pageNumber
		RETURN
		END;
END;

GO
