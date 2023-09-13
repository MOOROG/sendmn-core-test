
		INSERT INTO dbo.staticdatatype
        (
		typeID,
          typeTitle ,
          typeDesc ,
          isInternal ,
          createdDate ,
          createdBy 
        )
VALUES  ( 
2200,
          'Collection Mode' , -- typeTitle - varchar(200)
          'Collection Mode' , -- typeDesc - varchar(500)
          0 , -- isInternal - int
          GETDATE() , -- createdDate - datetime
          'system' 
        )

	--added by gagan
INSERT INTO dbo.staticdatatype
        (
		typeID,
          typeTitle ,
          typeDesc ,
          isInternal ,
          createdDate ,
          createdBy 
        )
VALUES  ( 
7020,
          'OFAC source' , -- typeTitle - varchar(200)
          'OFAC source' , -- typeDesc - varchar(500)
          0 , -- isInternal - int
          GETDATE() , -- createdDate - datetime
          'system' 
        )
		