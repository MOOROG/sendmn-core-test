USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[VIEW_COMPLIANCE_QUESTION_SET]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_COMPLIANCE_QUESTION_SET]
AS
SELECT '1' ID, 'Does this remittance include other person''s income ?</br> (Such as your husband/wife)' QSN, 1 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '2' ID, 'Is there any other additional income included ?' QSN, 1 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '3' ID, 'How long have you been working ?' QSN, 1 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '4' ID, 'How much is your monthly income ?' QSN, 1 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '5' ID, 'How long do you run your business ? </br> (if the sender is business person only)' QSN, 1 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '6' ID, 'What is the type/Nature of your business ? </br> (if the sender is business person only)' QSN, 1 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '7' ID, 'The Origin Of The Fund / Source Of Fund' QSN, 1 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '8' ID, 'Did Staff (user) collected the proof of Source Of Fund from Sender ?' QSN, 1 IS_ACTIVE, 'requiredCompliance' isRequired UNION ALL
SELECT '9' ID, 'Full Name of JME Staff who confirm details with sender' QSN, 1 IS_ACTIVE, 'requiredCompliance' isRequired




GO
