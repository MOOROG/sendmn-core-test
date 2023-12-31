USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[populate_customer]    Script Date: 5/18/2021 5:17:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Exec populate_customer @firstName='binay', @lastName ='rai',@mobileNo =null, @dob =null
Exec populate_customer @firstName='satish', @lastName =null,@mobileNo =null, @dob =null
EXEC populate_customer @flag = 'p', @memberID = 1234
*/
CREATE proc [dbo].[populate_customer]
(
 @flag		    char	(5) 
 ,@firstName	varchar(50) = null
 ,@lastName		varchar(50)	= null
 ,@mobileNo		varchar (15)= null
 ,@dob			varchar(10)	= null
 ,@memberID		varchar(10)			= null
)
as 
SET NOCOUNT ON ;

DECLARE @SQL VARCHAR (MAX);

--If @mobileNo is null and @dob is null 
--BEGIN

--select 'Please enter either Date of Birth Or mobile No.!' as msg
--return;

--END
--select membershipId as [Member Id] 
--	,firstName + ISNULL(' '+middleName,'')+ISNULL(' '+lastName1,'')+ISNULL(' '+lastName2,'') as NAME
--	,(address+','+city+','+stateName+','+countryName) as [Address]
--	,mobile as [Mobile No.]
--	,convert(varchar,dob,103) as [DOB]
--from customers
--Inner join countryMaster on countryId = country
--INNER JOIN countryStateMaster on stateId = state

IF @flag = 's'
BEGIN 

			SET @SQL = 'select membershipId as [Member Id] 
				,firstName + ISNULL('' ''+middleName,'''')+ISNULL('' ''+lastName1,'''')+ISNULL('' ''+lastName2,'''') as NAME
				,(address+'',''+city+'',''+stateName+'',''+countryName) as [Address]
				,mobile as [Mobile No.]
				,convert(varchar,dob,103) as [DOB]
			from customers
			Inner join countryMaster on countryId = country
			INNER JOIN countryStateMaster on stateId = state where 1=1 '

			IF @firstName is not null 
			BEGIN 
				SET @SQL = @SQL+ ' AND firstName like  ''' + @firstName +'%'''
			END 

			IF @lastName is not null 
			BEGIN 
				SET @SQL = @SQL +  ' AND lastName1 like ''' + @lastName + '%'''
			END

			IF @mobileNo is not null 
			BEGIN 
				SET @SQL = @SQL + '	AND mobile = '+ @mobileNo
			END

			IF @dob is not null
			BEGIN 
				SET @SQL = @SQL + ' AND convert(varchar,dob,107) = '+ CONVERT(varchar,@dob,107)
			END

			IF @memberID is not null 
			BEGIN
				SET @SQL = @SQL + ' AND membershipId = '+ @memberID
			END

--print(@SQL)
EXEC (@SQl)
END

IF @flag = 'p' 
BEGIN 

--select * from customers

select membershipId  
				,firstName
				,middleName
				,lastName1
				--,lastName2
				,address
				,city
				,state
				,zipCode
				,country 
				,ISnull(homePhone, workPhone) as telephone
				,email
				,mobile 
				,convert(varchar,dob,103) as [DOB]
			from customers
			where membershipId = @memberID
			--Inner join countryMaster on countryId = country
			--INNER JOIN countryStateMaster on stateId = state where 1=1


END 

GO
