ALTER TABLE CUSTOMERMASTER ADD street VARCHAR(80), streetUnicode NVARCHAR(100), cityUnicode NVARCHAR(100),
visaStatus INT, employeeBusinessType INT, nameOfEmployeer VARCHAR(80), SSNNO VARCHAR(20), remittanceAllowed BIT,
remarks VARCHAR(800), registerationNo VARCHAR(30), organizationType INT, dateofIncorporation DATETIME,
natureOfCompany INT, position INT, nameOfAuthorizedPerson VARCHAR(80)

ALTER TABLE CUSTOMERMASTER ADD monthlyIncome VARCHAR (50)
----
ALTER TABLE dbo.customerMaster ALTER COLUMN idType INT
