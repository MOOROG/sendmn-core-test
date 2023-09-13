USE [FastMoneyPro_Remit]
GO

/****** Object:  View [dbo].[VIEW_COMPLIANCE_QUESTION_SET]    Script Date: 11/26/2019 11:33:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--SELECT * FROM VIEW_COMPLIANCE_QUESTION_SET

CREATE VIEW [dbo].[VIEW_COMPLIANCE_QUESTION_SET]
AS
SELECT '1' ID, 'Does this remittance include other person''s income ?</br> (Such as your husband/wife)' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '2' ID, 'Is there any other additional income included ?' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '3' ID, 'Is there anyone working in your family ?' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '4' ID, 'How long do you continue working ?' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '5' ID, 'What kind of job do you do ?' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '6' ID, 'How much is the anual income ?' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '7' ID, 'How long do you run your business ? </br> (if the sender is business person only)' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '8' ID, 'What is the type of your business ? </br> (if the sender is business person only)' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '9' ID, 'Name of associated organization' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '10' ID, 'Address and contact details of Associated Organization' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '11' ID, 'The Origin Of The Fund' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '12' ID, 'Purpose of Remittance' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '13' ID, 'Relationship with Benificiary' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '14' ID, 'Did Staff (user) collected the proof of Source Of Fund from Sender ?' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '15' ID, 'Full Name of JME Staff, who confirm details with sender' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired


GO

--CREATE TABLE TBL_TXN_COMPLIANCE_CDDI
--(
--	ROW_ID BIGINT NOT NULL IDENTITY(1, 1) PRIMARY KEY
--	,TRAN_ID BIGINT NOT NULL
--	,QUES_ID INT NOT NULL
--	,ANSWER_TEXT NVARCHAR(300) 
--);

--select * from TBL_TXN_COMPLIANCE_CDDI


