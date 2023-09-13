USE [FastMoneyPro_Remit]
GO

/****** Object:  View [dbo].[VIEW_COMPLIANCE_QUESTION_SET]    Script Date: 12/24/2019 11:40:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--SELECT * FROM VIEW_COMPLIANCE_QUESTION_SET

ALTER VIEW [dbo].[VIEW_COMPLIANCE_QUESTION_SET]
AS
SELECT '1' ID, 'Does this remittance include other person''s income ?</br> (Such as your husband/wife)' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '2' ID, 'Is there any other additional income included ?' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '3' ID, 'How long have you been working ?' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '4' ID, 'How much is your monthly income ?' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '5' ID, 'How long do you run your business ? </br> (if the sender is business person only)' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '6' ID, 'What is the type/Nature of your business ? </br> (if the sender is business person only)' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '7' ID, 'The Origin Of The Fund / Source Of Fund' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '8' ID, 'Did Staff (user) collected the proof of Source Of Fund from Sender ?' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '9' ID, 'Full Name of JME Staff who confirm details with sender' QSN, 0 IS_ACTIVE, 'requiredCompliance' isRequired

GO


