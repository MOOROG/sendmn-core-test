
--------------------------- Add On Occupation

		INSERT INTO dbo.staticDataValue(
				typeID,detailTitle,detailDesc,createdDate,createdBy,modifiedDate,modifiedBy,isActive,IS_DELETE
				)
				VALUES (1300,'Tohon','Tohon',GETDATE(),'',GETDATE(),'','Y', 'N')
		INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2000 , 'BUSINESS OWNER', 'BUSINESS OWNER',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
				
		INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2000 , 'DEPENDENT', 'DEPENDENT',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
		INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2000 , 'COMPANY EMPLOYEE', 'COMPANY EMPLOYEE',GETDATE(),'',GETDATE(),'','Y', 'N'
				)

		INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2000 , 'UNEMPLOYED', 'UNEMPLOYED',GETDATE(),'',GETDATE(),'','Y', 'N'
				)

		INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2000 , 'TRAINEE', 'TRAINEE',GETDATE(),'',GETDATE(),'','Y', 'N'
				)

		INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2000 , 'Part Time Job Holder', 'Part Time Job',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	---------------------- Add On Relationship
	DELETE FROM dbo.staticDataValue WHERE typeID=2100
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Parents', 'Parents',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Spouse', 'Spouse',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Children', 'Children',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Brother/ Sister', 'Brother/ Sister',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Uncle/ Auntie', 'Uncle/ Auntie',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Cousin', 'Cousin',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Business Partner', 'Business Partner',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Employer', 'Employer',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Employee', 'Employee',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Friends', 'Friends',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Family', 'Family',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'BROTHER', 'BROTHER',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'SISTER', 'SISTER',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Air Ticket', 'Air Ticket',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'Donee', 'Donee',GETDATE(),'',GETDATE(),'','Y', 'N'
				)
	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'father in law', 'father in law',GETDATE(),'',GETDATE(),'','Y', 'N'
				)

--------------------------- Update On Collection Mode
	UPDATE dbo.staticDataValue SET detailTitle='Cash Payment', detailDesc='Cash Payment' WHERE valueId=11062
	UPDATE dbo.staticDataValue SET detailTitle='Bank Transfer', detailDesc='Bank Transfer' WHERE valueId=11063


--------------------------- Add On Purpose of Remit


	INSERT INTO dbo.staticDataValue( 
				typeID ,detailTitle ,detailDesc ,createdDate ,createdBy ,modifiedDate ,modifiedBy ,isActive ,IS_DELETE
				)
				VALUES (2100 , 'father in law', 'father in law',GETDATE(),'',GETDATE(),'','Y', 'N'
				)


	--update employee business type

	UPDATE dbo.staticDataValue SET detailTitle = 'Employeed',detailDesc = 'Employeed' WHERE valueId = 11007 AND typeID = 7004
	UPDATE dbo.staticDataValue SET detailTitle = 'Self-Employeed',detailDesc= 'Self-Employeed' WHERE valueId = 11008 AND typeID = 7004
	UPDATE dbo.staticDataValue SET detailTitle = 'Unemployeed',detailDesc = 'Unemployeed' WHERE valueId = 11009 AND typeID = 7004
	--correct spelling
	UPDATE dbo.staticdatatype SET typeTitle= 'Employment Business Type',typeDesc = 'Employment Business Type' WHERE typeID= 7004


				















