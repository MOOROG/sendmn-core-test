DECLARE @lastId INT

SELECT @lastId=MAX(typeID) FROM dbo.staticdatatype

		INSERT INTO dbo.staticdatatype
        (
		typeID,
          typeTitle ,
          typeDesc ,
          isInternal ,
          createdDate ,
          createdBy ,
          modifiedDate ,
          modifiedBy
        )
VALUES  ( 
@lastId+1,
          'Customer Document Type' , -- typeTitle - varchar(200)
          'Customer Document Type' , -- typeDesc - varchar(500)
          0 , -- isInternal - int
          GETDATE() , -- createdDate - datetime
          '' , -- createdBy - varchar(30)
          GETDATE() , -- modifiedDate - datetime
          ''  -- modifiedBy - varchar(30)
        )

SELECT @lastId=MAX(typeID) FROM dbo.staticdatatype

		INSERT INTO dbo.staticdatatype
        (
		typeID,
          typeTitle ,
          typeDesc ,
          isInternal ,
          createdDate ,
          createdBy ,
          modifiedDate ,
          modifiedBy
        )
VALUES  ( 
@lastId+1,
          'Position' , -- typeTitle - varchar(200)
          'Position' , -- typeDesc - varchar(500)
          0 , -- isInternal - int
          GETDATE() , -- createdDate - datetime
          '' , -- createdBy - varchar(30)
          GETDATE() , -- modifiedDate - datetime
          ''  -- modifiedBy - varchar(30)
        )

		INSERT INTO dbo.staticdatatype
        (
		typeID,
          typeTitle ,
          typeDesc ,
          isInternal ,
          createdDate ,
          createdBy ,
          modifiedDate ,
          modifiedBy
        )
VALUES  ( 
@lastId+1,
          'Visa STATUS' , -- typeTitle - varchar(200)
          'Visa STATUS' , -- typeDesc - varchar(500)
          0 , -- isInternal - int
          GETDATE() , -- createdDate - datetime
          '' , -- createdBy - varchar(30)
          GETDATE() , -- modifiedDate - datetime
          ''  -- modifiedBy - varchar(30)
        )

		INSERT INTO dbo.staticdatatype
        (
		typeID,
          typeTitle ,
          typeDesc ,
          isInternal ,
          createdDate ,
          createdBy ,
          modifiedDate ,
          modifiedBy
        )
VALUES  ( 
@lastId+1,
          'Employement Business Type' , -- typeTitle - varchar(200)
          'Employement Business Type' , -- typeDesc - varchar(500)
          0 , -- isInternal - int
          GETDATE() , -- createdDate - datetime
          '' , -- createdBy - varchar(30)
          GETDATE() , -- modifiedDate - datetime
          ''  -- modifiedBy - varchar(30)
        )


		INSERT INTO dbo.staticdatatype
        (
		typeID,
          typeTitle ,
          typeDesc ,
          isInternal ,
          createdDate ,
          createdBy ,
          modifiedDate ,
          modifiedBy
        )
VALUES  ( 
@lastId+1,
          'Nature Of Company' , -- typeTitle - varchar(200)
          'Nature Of Company' , -- typeDesc - varchar(500)
          0 , -- isInternal - int
          GETDATE() , -- createdDate - datetime
          '' , -- createdBy - varchar(30)
          GETDATE() , -- modifiedDate - datetime
          ''  -- modifiedBy - varchar(30)
        )
		INSERT INTO dbo.staticdatatype
        ( typeID,
          typeTitle ,
          typeDesc ,
          isInternal ,
          createdDate ,
          createdBy ,
          modifiedDate ,
          modifiedBy
        )
VALUES  ( 
@lastId+1,
          'Organization Type' , -- typeTitle - varchar(200)
          'Organization Type' , -- typeDesc - varchar(500)
          0 , -- isInternal - int
          GETDATE() , -- createdDate - datetime
          '' , -- createdBy - varchar(30)
          GETDATE() , -- modifiedDate - datetime
          ''  -- modifiedBy - varchar(30)
        )


		---added by gagan
	INSERT INTO dbo.staticdatatype
        (  typeID,
          typeTitle ,
          typeDesc ,
          isInternal ,
          createdDate ,
          createdBy ,
          modifiedDate ,
          modifiedBy
        )
VALUES  ( @lastId+1 , -- typeID - int
          'KYC Method' , -- typeTitle - varchar(200)
          'KYC Method' , -- typeDesc - varchar(500)
          0 , -- isInternal - int
          GETDATE() , -- createdDate - datetime
          '' , -- createdBy - varchar(30)
          GETDATE() , -- modifiedDate - datetime
         NULL  -- modifiedBy - varchar(30)
        )

		INSERT INTO dbo.staticdatatype
        (  typeID,
          typeTitle ,
          typeDesc ,
          isInternal ,
          createdDate ,
          createdBy ,
          modifiedDate ,
          modifiedBy
        )
VALUES  ( @lastId+1 , -- typeID - int
          'KYC Status ' , -- typeTitle - varchar(200)
          'KYC Status ' , -- typeDesc - varchar(500)
          0 , -- isInternal - int
          GETDATE() , -- createdDate - datetime
          '' , -- createdBy - varchar(30)
          GETDATE() , -- modifiedDate - datetime
         NULL  -- modifiedBy - varchar(30)
        )
		INSERT INTO dbo.staticdatatype
        (  typeID,
          typeTitle ,
          typeDesc ,
          isInternal ,
          createdDate ,
          createdBy ,
          modifiedDate ,
          modifiedBy
        )
VALUES  ( @lastId+1 , -- typeID - int
          'Province List' , -- typeTitle - varchar(200)
          'Province List' , -- typeDesc - varchar(500)
          0 , -- isInternal - int
          GETDATE() , -- createdDate - datetime
          '' , -- createdBy - varchar(30)
          GETDATE() , -- modifiedDate - datetime
         NULL  -- modifiedBy - varchar(30)
        )