
INSERT INTO dbo.staticdatatype
        ( typeID ,
          typeTitle ,
          typeDesc ,
          isInternal ,
          createdDate ,
          createdBy ,
          modifiedDate ,
          modifiedBy
        )
VALUES  (  7010, -- typeID - int
          'Japan Bank Names' , -- typeTitle - varchar(200)
          'Japan Bank Names' , -- typeDesc - varchar(500)
          0 , -- isInternal - int
          GETDATE() , -- createdDate - datetime
          '' , -- createdBy - varchar(30)
          GETDATE() , -- modifiedDate - datetime
          ''  -- modifiedBy - varchar(30)
        )

		