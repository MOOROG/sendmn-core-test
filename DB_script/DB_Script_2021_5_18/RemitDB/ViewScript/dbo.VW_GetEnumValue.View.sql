USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[VW_GetEnumValue]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[VW_GetEnumValue]
AS

SELECT 'idType'				[type],'11168'  [value], 'Residence Card'			[key],'tranglo' [partner], '11168'[searchValue],'Residence Card'			[searchText]  union all--Residence Permit-5  
SELECT 'idType'				[type],'8008'	[value], 'National ID'				[key],'tranglo' [partner], '8008' [searchValue],'National ID'				[searchText]  union all--Identification ID Code-3  
SELECT 'idType'				[type],'10997'	[value], 'Passport'					[key],'tranglo' [partner], '10997'[searchValue],'Passport'					[searchText]  union all--International Passport Code-2  
SELECT 'idType'				[type],'1302'	[value], 'Alien Registration Card'	[key],'tranglo' [partner], '1302' [searchValue],'Alien Registration Card'	[searchText]  union all --work permit code-1  

SELECT 'idType'				[type],'1302'	[value], 'Alien Registration Card'	[key],'gmeKorea' [partner], '1302' [searchValue],'Alien Registration Card'	[searchText]  union all
SELECT 'idType'				[type],'8008'	[value], 'National ID'				[key],'gmeKorea' [partner], '8008' [searchValue],'National ID'				[searchText]  union all
SELECT 'idType'				[type],'10997'	[value], 'Passport'					[key],'gmeKorea' [partner], '10997'[searchValue],'Passport'					[searchText] union all
																											
SELECT 'RelationwithSender' [type],'11080'	[value], 'BROTHER/SISTER IN LAW'	[key],'gmeKorea' [partner], '10998'[searchValue],'Daughter in Law'			[searchText] union all
SELECT 'RelationwithSender' [type],'11081'	[value], 'BUSINESS PARTNER'			[key],'gmeKorea' [partner], '11085'[searchValue],'Business Partner'			[searchText] union all
SELECT 'RelationwithSender' [type],'11082'	[value], 'COUSIN'					[key],'gmeKorea' [partner], '2117' [searchValue],'Cousin'					[searchText] union all
SELECT 'RelationwithSender' [type],'11083'	[value], 'FATHER/MOTHER'			[key],'gmeKorea' [partner], '2102' [searchValue],'Mother'					[searchText] union all
SELECT 'RelationwithSender' [type],'11083'	[value], 'FATHER/MOTHER'			[key],'gmeKorea' [partner], '2101' [searchValue],'Father'					[searchText] union all
SELECT 'RelationwithSender' [type],'11084'	[value], 'FATHER/MOTHER IN LAW'		[key],'gmeKorea' [partner], '2107' [searchValue],'Father in Law'			[searchText] union all
SELECT 'RelationwithSender' [type],'11084'	[value], 'FATHER/MOTHER IN LAW'		[key],'gmeKorea' [partner], '2108' [searchValue],'Mother in Law'			[searchText] union all
SELECT 'RelationwithSender' [type],'11085'	[value], 'FRIEND'					[key],'gmeKorea' [partner], '2120' [searchValue],'Friend'					[searchText] union all
SELECT 'RelationwithSender' [type],'11089'	[value], 'SELF'						[key],'gmeKorea' [partner], '2121' [searchValue],'Self'						[searchText] union all
SELECT 'RelationwithSender' [type],'11090'	[value], 'SON/DAUGHTER'				[key],'gmeKorea' [partner], '2113' [searchValue],'Son'						[searchText] union all
SELECT 'RelationwithSender' [type],'11090'	[value], 'SON/DAUGHTER'				[key],'gmeKorea' [partner], '2114' [searchValue],'Daughter'					[searchText] 

	--select * from staticdatavalue where typeId = 1300
	--select * from staticdatavalue where typeId = 2100


GO
