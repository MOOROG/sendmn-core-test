


SELECT TOP 10* FROM customerDocument
ALTER TABLE customerDocument ADD documentType INT 
ALTER TABLE customerDocument ADD archivedBy VARCHAR(50), archivedDate DATETIME
ALTER TABLE customerDocument ALTER COLUMN fileType VARCHAR(20)

