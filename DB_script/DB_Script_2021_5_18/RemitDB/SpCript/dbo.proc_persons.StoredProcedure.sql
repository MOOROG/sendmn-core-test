USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_persons]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[proc_persons]
	 @flag				varchar(50) = null
	,@PersonID			int
	,@FirstName			varchar(50)=null
	,@LastName			varchar(50)=null
	,@Address			varchar(50)=null
	,@City				varchar(20)=null
	,@Mobile			varchar(20)=null
	,@Email				varchar(50)=null
	
AS
SET NOCOUNT ON
SET XACT_ABORT ON
BEGIN TRY
	IF @flag='a'
	BEGIN
		SELECT * from persons where PersonID=@PersonID
	END
	IF @flag='i'
	BEGIN
		INSERT INTO persons (
		 FirstName
		,LastName
		,[Address]
		,City
		,Mobile
		,Email)
		values(
		 @FirstName
		,@LastName
		,@Address
		,@City
		,@Mobile
		,@Email)
	EXEC proc_errorHandler 0, 'Record has been added successfully.', NULL
	END
	IF @flag='u'
	BEGIN
		UPDATE persons
		set 
			 FirstName=@FirstName
			,LastName=@LastName
			,[Address]=@Address
			,City=@City
			,Mobile=@Mobile
			,Email=@Email
		WHERE PersonID=@PersonID
	EXEC proc_errorHandler 0,'Record has been updated successfully.', NULL
	END
END TRY
BEGIN CATCH

  if @@trancount > 0
  rollback transaction
  
  select error_message() msg


END CATCH

GO
