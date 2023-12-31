USE [SendMnPro_Remit]
GO
/****** Object:  View [dbo].[vw_bankAccLedgerMap]    Script Date: 5/18/2021 5:18:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[vw_bankAccLedgerMap]
AS 
	SELECT '1' As SN,'251019082' as AcLedger,'Agriculture Development Bank Ltd.-02-101-00004414-01-1' as bankAccount ,'Agriculture Development Bank Ltd' as bank,'02-101-00004414-01-1' as accountNo
	UNION ALL
	SELECT '2','251019105'	,'Bank of Kathmandu Ltd., Kamaladi- 470000060402' ,'Bank of Kathmandu Ltd., Kamaladi','470000060402'
	UNION ALL
	SELECT '3','801096858'	,'Century Commerical Bank Ltd- 0010000007BO' ,'Century Commerical Bank Ltd','0010000007BO'
	UNION ALL
	SELECT '4','251032161'	,'Citizen Bank International Ltd -0070000031CC' ,'Citizen Bank International Ltd','0070000031CC'
	UNION ALL
	SELECT '5','251086389'	,'Civil Bank ltd.OD -00210019595018' ,'Civil Bank ltd.','00210019595018'
	UNION ALL
	SELECT '6','251019141'	,'Everest Bank Ltd.-00200105001253','Everest Bank Ltd', '00200105001253'
	UNION ALL
	SELECT '7','251084955'	,'Global IME Bank Ltd (3311010000022)' ,'Global IME Bank Ltd','3311010000022'
	UNION ALL
	SELECT '8','251019186'	,'Himalayan Bank Ltd.-01900171060014' ,'Himalayan Bank Ltd','01900171060014'
	UNION ALL
	SELECT '9','251054267'	,'Janata Bank Nepal Ltd.-003002003153304' ,'Janata Bank Nepal Ltd','003002003153304'
	UNION ALL
	SELECT '10','251027951','Kumari Bank Ltd. - Overdraft -1301524280703018' ,'Kumari Bank Ltd','1301524280703018'
	UNION ALL
	SELECT '11','251079452','Laxmi Bank Limited- Newrode-01011003407' ,'Laxmi Bank Limited','01011003407'
	UNION ALL
	SELECT '12','251019222','Lumbini Bank Ltd.-10100471' ,'Lumbini Bank Ltd','10100471'
	UNION ALL
	SELECT '13','251019232','Machhapuchhre Bank Ltd.-1601524001963018','Machhapuchhre Bank Ltd','1601524001963018' 
	UNION ALL
	SELECT '14','251035056','Mega Bank Nepal Ltd-OD A/C-0011059725305' ,'Mega Bank Nepal Ltd','0011059725305'
	UNION ALL
	SELECT '15','251019244','Nabil Bank Ltd. -0101011836201' ,'Nabil Bank Ltd','0101011836201'
	UNION ALL
	SELECT '16','251019282','Nepal Bangladesh Bank Ltd - Newroad -002079282C','Nepal Bangladesh Bank Ltd' ,'002079282C'
	UNION ALL
	SELECT '17','251034116','Nepal Bank ltd-O/D -0002-14-0003515' ,'Nepal Bank ltd','0002-14-0003515'
	UNION ALL
	SELECT '18','251019303','Nepal Credit and Commerce Bank Ltd.-007000098561C' ,'Nepal Credit and Commerce Bank Ltd','007000098561C'
	UNION ALL
	SELECT '19','251025661','Nepal Investment Bank Ltd. - Overdraft A/c. -00159010250986' ,'Nepal Investment Bank Ltd','00159010250986'
	UNION ALL
	SELECT '20','251019348','Nepal SBI Bank Ltd.-17725240000667','Nepal SBI Bank Ltd','17725240000667'
	UNION ALL
	SELECT '21','251019312','NIC ASIA Bank Ltd.-3020090480524001','NIC ASIA Bank Ltd' ,'3020090480524001'
	UNION ALL
	SELECT '22','251026934','Prabhu Bank Ltd. -Newroad -00511600083028000001' ,'Prabhu Bank Ltd','00511600083028000001'
	UNION ALL
	SELECT '23','251019367','Prime Commercial Bank Ltd.-00100056AS' ,'Prime Commercial Bank Ltd','00100056AS'
	UNION ALL
	SELECT '24','251019386','Rastriya Banijaya Bank Ltd. - Overdraft A/c-109006529802','Rastriya Banijaya Bank Ltd' ,'109006529802'
	UNION ALL
	SELECT '25','801129417','Sanima Bank Ltd ( A/C No. 0030000345801)','Sanima Bank Ltd','0030000345801' 
	UNION ALL
	SELECT '26','251027027','Siddhartha Bank Ltd. Newroad -00406225160' ,'Siddhartha Bank Ltd','00406225160'
	UNION ALL
	SELECT '27','251025772','Sunrise Bank Ltd. -01010071639017','Sunrise Bank Ltd','01010071639017'

GO
