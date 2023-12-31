﻿INSERT * INTO #TEMP
FROM(
SELECT 'Affin Bank Berhad' BANK_NAME ,'6000001' BANK_CODE UNION ALL
SELECT 'Affin Islamic Bank Berhad' BANK_NAME ,'6000002' BANK_CODE UNION ALL
SELECT 'Agro Bank' BANK_NAME ,'6000003' BANK_CODE UNION ALL
SELECT 'Alliance Bank Berhad' BANK_NAME ,'6000004' BANK_CODE UNION ALL
SELECT 'Alliance Islamic Bank Berhad' BANK_NAME ,'6000005' BANK_CODE UNION ALL
SELECT 'Al-Rajhi Banking and Investment Corporation (M)' BANK_NAME ,'6000006' BANK_CODE UNION ALL
SELECT 'AmIslamic Bank' BANK_NAME ,'6000007' BANK_CODE UNION ALL
SELECT 'Arab-Malaysian Bank Berhad' BANK_NAME ,'6000008' BANK_CODE UNION ALL
SELECT 'Bank Islam Malaysia Berhad' BANK_NAME ,'6000009' BANK_CODE UNION ALL
SELECT 'Bank Kerjasama Rakyat Berhad' BANK_NAME ,'6000010' BANK_CODE UNION ALL
SELECT 'Bank Muamalat Malaysia Berhad' BANK_NAME ,'6000011' BANK_CODE UNION ALL
SELECT 'Bank of America Malaysia Berhad' BANK_NAME ,'6000012' BANK_CODE UNION ALL
SELECT 'Bank Simpanan Nasional Berhad' BANK_NAME ,'6000014' BANK_CODE UNION ALL
SELECT 'BNP Paribas (M) Bhd' BANK_NAME ,'6000015' BANK_CODE UNION ALL
SELECT 'BNP Paribas (M) Bhd (Islamic)' BANK_NAME ,'6000016' BANK_CODE UNION ALL
SELECT 'CIMB Bank Berhad' BANK_NAME ,'6000017' BANK_CODE UNION ALL
SELECT 'CIMB Islamic Bank' BANK_NAME ,'6000018' BANK_CODE UNION ALL
SELECT 'Citibank' BANK_NAME ,'6000019' BANK_CODE UNION ALL
SELECT 'Deutsche Bank (M) Bhd' BANK_NAME ,'6000021' BANK_CODE UNION ALL
SELECT 'Hong Leong Bank Bhd' BANK_NAME ,'6000022' BANK_CODE UNION ALL
SELECT 'Hong Leong Islamic Bank Bhd' BANK_NAME ,'6000023' BANK_CODE UNION ALL
SELECT 'HSBC Amanah Malaysia' BANK_NAME ,'6000024' BANK_CODE UNION ALL
SELECT 'HSBC Bank Berhad' BANK_NAME ,'6000025' BANK_CODE UNION ALL
SELECT 'Indust & Comm Bank of China (M) Berhad' BANK_NAME ,'6000026' BANK_CODE UNION ALL
SELECT 'JP Morgan Chase Bank Berhad' BANK_NAME ,'6000027' BANK_CODE UNION ALL
SELECT 'Kuwait Finance House Malaysia Berhad' BANK_NAME ,'6000028' BANK_CODE UNION ALL
SELECT 'Malayan Banking Berhad' BANK_NAME ,'6000029' BANK_CODE UNION ALL
SELECT 'MayBank Islamic Berhad' BANK_NAME ,'6000030' BANK_CODE UNION ALL
SELECT 'Mizuho Bank (M) Berhad' BANK_NAME ,'6000031' BANK_CODE UNION ALL
SELECT 'OCBC AL-AMIN Bank Berhad' BANK_NAME ,'6000032' BANK_CODE UNION ALL
SELECT 'OCBC Bank Berhad' BANK_NAME ,'6000033' BANK_CODE UNION ALL
SELECT 'Public Bank Bhd' BANK_NAME ,'6000034' BANK_CODE UNION ALL
SELECT 'Public Finance Bhd' BANK_NAME ,'6000035' BANK_CODE UNION ALL
SELECT 'Public Islamic Bank Bhd' BANK_NAME ,'6000036' BANK_CODE UNION ALL
SELECT 'RHB Bank Berhad' BANK_NAME ,'6000037' BANK_CODE UNION ALL
SELECT 'RHB Islamic Bank Berhad' BANK_NAME ,'6000038' BANK_CODE UNION ALL
SELECT 'Standard Chartered Bank' BANK_NAME ,'6000039' BANK_CODE UNION ALL
SELECT 'Standard Chartered SAADIQ Bhd' BANK_NAME ,'6000040' BANK_CODE UNION ALL
SELECT 'Sumitomo Mitsui Banking Corporation (M) Bhd' BANK_NAME ,'6000041' BANK_CODE UNION ALL
SELECT 'United Overseas Bank (M) Bhd' BANK_NAME ,'6000043' BANK_CODE UNION ALL
SELECT 'Agrobank (Islamic)' BANK_NAME ,'6000046' BANK_CODE UNION ALL
SELECT 'Bank Simpanan Nasional Berhad (Islamic)' BANK_NAME ,'6000048' BANK_CODE 
)X


select * from agentMaster
SELECT * FROM #TEMP
INSERT INTO API_BANK_LIST(API_PARTNER_ID,BANK_NAME,BANK_CODE1,BANK_STATE,BANK_DISTRICT,BANK_ADDRESS,BANK_PHONE
,BANK_EMAIL,SUPPORT_CURRENCY,BANK_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE)
SELECT 394450, BANK_NAME, BANK_CODE, NULL, NULL, NULL, NULL, NULL, NULL, 'MALAYSIA', 2, 1 FROM #TEMP


--AUSTRALIA
SELECT * INTO #TEMP1
FROM(
SELECT 'Act. Bank (division of Community Sector Banking)' BANK_NAME ,'610001' BANK_CODE UNION ALL
SELECT 'Adelaide Bank' BANK_NAME ,'610042' BANK_CODE UNION ALL
SELECT 'AMP Bank Limited' BANK_NAME ,'610002' BANK_CODE UNION ALL
SELECT 'Arab Bank Australia Limited' BANK_NAME ,'610003' BANK_CODE UNION ALL
SELECT 'Australia and New Zealand Banking Group Limited (ANZ)' BANK_NAME ,'610004' BANK_CODE UNION ALL
SELECT 'Australian Military Bank' BANK_NAME ,'610005' BANK_CODE UNION ALL
SELECT 'Australian Settlements Limited' BANK_NAME ,'610006' BANK_CODE UNION ALL
SELECT 'Auswide Bank' BANK_NAME ,'610043' BANK_CODE UNION ALL
SELECT 'Bank Australia' BANK_NAME ,'610007' BANK_CODE UNION ALL
SELECT 'Bank of China (Australia) Limited' BANK_NAME ,'610008' BANK_CODE UNION ALL
SELECT 'Bank of Cyprus Australia Pty Limited' BANK_NAME ,'610009' BANK_CODE UNION ALL
SELECT 'Bank of Melbourne' BANK_NAME ,'610010' BANK_CODE UNION ALL
SELECT 'Bank of Queensland Limited' BANK_NAME ,'610011' BANK_CODE UNION ALL
SELECT 'Bank SA' BANK_NAME ,'610013' BANK_CODE UNION ALL
SELECT 'bankmecu' BANK_NAME ,'610014' BANK_CODE UNION ALL
SELECT 'Bendigo and Adelaide Bank Limited' BANK_NAME ,'610015' BANK_CODE UNION ALL
SELECT 'Beyond Bank Australia' BANK_NAME ,'610016' BANK_CODE UNION ALL
SELECT 'Citibank Australia' BANK_NAME ,'610044' BANK_CODE UNION ALL
SELECT 'Commonwealth Bank' BANK_NAME ,'610017' BANK_CODE UNION ALL
SELECT 'Defence Bank' BANK_NAME ,'610018' BANK_CODE UNION ALL
SELECT 'Delphi Bank' BANK_NAME ,'610019' BANK_CODE UNION ALL
SELECT 'Greater Bank' BANK_NAME ,'610020' BANK_CODE UNION ALL
SELECT 'Heritage Bank' BANK_NAME ,'610021' BANK_CODE UNION ALL
SELECT 'Heritage Bank' BANK_NAME ,'610022' BANK_CODE UNION ALL
SELECT 'HSBC Bank Australia Limited' BANK_NAME ,'610023' BANK_CODE UNION ALL
SELECT 'Hume Bank' BANK_NAME ,'610024' BANK_CODE UNION ALL
SELECT 'IMB Bank' BANK_NAME ,'610025' BANK_CODE UNION ALL
SELECT 'ING DIRECT AUSTRALIA BANK' BANK_NAME ,'610026' BANK_CODE UNION ALL
SELECT 'Macquarie Bank Limited' BANK_NAME ,'610027' BANK_CODE UNION ALL
SELECT 'Members Equity Bank Pvt Limited' BANK_NAME ,'610028' BANK_CODE UNION ALL
SELECT 'MyState Bank' BANK_NAME ,'610029' BANK_CODE UNION ALL
SELECT 'National Australia Bank Limited' BANK_NAME ,'610030' BANK_CODE UNION ALL
SELECT 'P&N Bank' BANK_NAME ,'610031' BANK_CODE UNION ALL
SELECT 'Police Bank' BANK_NAME ,'610032' BANK_CODE UNION ALL
SELECT 'Qudos Bank' BANK_NAME ,'610033' BANK_CODE UNION ALL
SELECT 'Queensland Teachers Mutual Bank' BANK_NAME ,'610034' BANK_CODE UNION ALL
SELECT 'Rabobank' BANK_NAME ,'610046' BANK_CODE UNION ALL
SELECT 'Rural Bank Limited' BANK_NAME ,'610035' BANK_CODE UNION ALL
SELECT 'St. George Bank Limited' BANK_NAME ,'610036' BANK_CODE UNION ALL
SELECT 'Suncorp-Metway Limited' BANK_NAME ,'610037' BANK_CODE UNION ALL
SELECT 'Teachers Mutual Bank Limited' BANK_NAME ,'610038' BANK_CODE UNION ALL
SELECT 'Ubank' BANK_NAME ,'610039' BANK_CODE UNION ALL
SELECT 'Victoria Teachers Mutual Bank' BANK_NAME ,'610040' BANK_CODE UNION ALL
SELECT 'Westpac Banking Corporation' BANK_NAME ,'610041' BANK_CODE 
)X

DELETE FROM API_BANK_LIST WHERE BANK_COUNTRY='AUSTRALIA'

INSERT INTO API_BANK_LIST(API_PARTNER_ID,BANK_NAME,BANK_CODE1,BANK_STATE,BANK_DISTRICT,BANK_ADDRESS,BANK_PHONE
,BANK_EMAIL,SUPPORT_CURRENCY,BANK_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE)
SELECT 394450, BANK_NAME, BANK_CODE, NULL, NULL, NULL, NULL, NULL, NULL, 'AUSTRALIA', 2, 1 FROM #TEMP1


--CHINA
SELECT * INTO #TEMP3
FROM(
SELECT N'Bank of Nanjing (南京银行)' BANK_NAME, '8600001' BANK_CODE UNION ALL
SELECT N'Baoshang Bank (包商银行)' BANK_NAME, '8600002' BANK_CODE UNION ALL
SELECT N'China Construction Bank (中国建设银行)' BANK_NAME, '8600004' BANK_CODE UNION ALL
SELECT N'China Everbright Bank (光大银行)' BANK_NAME, '8600005' BANK_CODE UNION ALL
SELECT N'China Minsheng Bank (中国民生银行)' BANK_NAME, '8600006' BANK_CODE UNION ALL
SELECT N'Industrial Bank Co., Ltd. (兴业银行)' BANK_NAME, '8600007' BANK_CODE UNION ALL
SELECT N'Hana Bank (China) (韩亚银行（中国）)' BANK_NAME, '8600009' BANK_CODE UNION ALL
SELECT N'China Bohai Bank (渤海银行)' BANK_NAME, '8600010' BANK_CODE UNION ALL
SELECT N'Tianjin Bank (天津银行)' BANK_NAME, '8600011' BANK_CODE UNION ALL
SELECT N'Tianjin Rural Cooperative Bank (Tianjin Rural Credit Union, Tianjin Rural Commercial Bank) (天津农村合作银行（天津农村信用联社、天津农村商业银行）)' BANK_NAME, '8600012' BANK_CODE UNION ALL
SELECT N'Shenzhen Rural Commercial Bank (深圳农村商业银行)' BANK_NAME, '8600014' BANK_CODE UNION ALL
SELECT N'Ping An Bank (平安银行)' BANK_NAME, '8600015' BANK_CODE UNION ALL
SELECT N'Dongguan Rural Commercial Bank (东莞农村商业银行)' BANK_NAME, '8600016' BANK_CODE UNION ALL
SELECT N'Bank of Guangzhou (广州银行)' BANK_NAME, '8600017' BANK_CODE UNION ALL
SELECT N'Guangzhou Rural Commercial Bank (广州农村商业银行)' BANK_NAME, '8600018' BANK_CODE UNION ALL
SELECT N'Industrial and Commercial Bank of China (中国工商银行)' BANK_NAME, '8600019' BANK_CODE UNION ALL
SELECT N'Bank of Communications (交通银行)' BANK_NAME, '8600020' BANK_CODE UNION ALL
SELECT N'China Citic Bank (中信银行)' BANK_NAME, '8600021' BANK_CODE UNION ALL
SELECT N'Guangdong Development Bank (广发银行)' BANK_NAME, '8600024' BANK_CODE UNION ALL
SELECT N'Postal Savings Bank of China (中国邮政储蓄银行)' BANK_NAME, '8600025' BANK_CODE UNION ALL
SELECT N'Bank of Dongguan (Dongguan Commercial Bank) (东莞银行（东莞市商业银行）)' BANK_NAME, '8600028' BANK_CODE UNION ALL
SELECT N'Shanghai Pudong Development Bank (上海浦东发展银行)' BANK_NAME, '8600030' BANK_CODE UNION ALL
SELECT N'Anhui Province Rural Credit Union (安徽省农村信用联社)' BANK_NAME, '8600031' BANK_CODE UNION ALL
SELECT N'Xiamen Bank (厦门银行)' BANK_NAME, '8600032' BANK_CODE UNION ALL
SELECT N'Guangxi Beibu Gulf Bank (广西北部湾银行)' BANK_NAME, '8600033' BANK_CODE UNION ALL
SELECT N'Bank of Changsha (长沙银行)' BANK_NAME, '8600034' BANK_CODE UNION ALL
SELECT N'Suzhou Bank (苏州银行)' BANK_NAME, '8600036' BANK_CODE UNION ALL
SELECT N'Rural Commercial Bank of Zhangjiagang (张家港农村商业银行)' BANK_NAME, '8600037' BANK_CODE UNION ALL
SELECT N'Nanchang Bank (南昌银行)' BANK_NAME, '8600038' BANK_CODE UNION ALL
SELECT N'Bank of Shangrao (上饶银行)' BANK_NAME, '8600039' BANK_CODE UNION ALL
SELECT N'Dongying City Commercial Bank (东营市商业银行)' BANK_NAME, '8600040' BANK_CODE UNION ALL
SELECT N'Bank of Jining (济宁银行)' BANK_NAME, '8600041' BANK_CODE UNION ALL
SELECT N'Laishang Bank (莱商银行)' BANK_NAME, '8600042' BANK_CODE UNION ALL
SELECT N'Linshang Bank (临商银行)' BANK_NAME, '8600043' BANK_CODE UNION ALL
SELECT N'Qishang Bank (齐商银行)' BANK_NAME, '8600044' BANK_CODE UNION ALL
SELECT N'Bank of Qingdao (青岛银行)' BANK_NAME, '8600045' BANK_CODE UNION ALL
SELECT N'Bank of Rizhao (日照银行)' BANK_NAME, '8600046' BANK_CODE UNION ALL
SELECT N'Taian City Commercial Bank (泰安市商业银行)' BANK_NAME, '8600047' BANK_CODE UNION ALL
SELECT N'Weihai City Commercial Bank (威海市商业银行)' BANK_NAME, '8600048' BANK_CODE UNION ALL
SELECT N'Yantai Bank (烟台银行)' BANK_NAME, '8600049' BANK_CODE UNION ALL
SELECT N'Bank of Dalian (大连银行)' BANK_NAME, '8600050' BANK_CODE UNION ALL
SELECT N'Bank of Jinzhou (锦州银行)' BANK_NAME, '8600051' BANK_CODE UNION ALL
SELECT N'Anshan City Commercial Bank (鞍山市商业银行)' BANK_NAME, '8600052' BANK_CODE UNION ALL
SELECT N'Bank of Huludao (葫芦岛银行)' BANK_NAME, '8600053' BANK_CODE UNION ALL
SELECT N'Bank of Shanghai (上海银行)' BANK_NAME, '8600055' BANK_CODE UNION ALL
SELECT N'Zhejiang Chouzhou Commercial Bank (浙江稠州商业银行)' BANK_NAME, '8600056' BANK_CODE UNION ALL
SELECT N'Hangzhou Bank (Hangzhou Commercial Bank) (杭州银行（杭州市商业银行）)' BANK_NAME, '8600057' BANK_CODE UNION ALL
SELECT N'Bank of Ningbo (宁波银行)' BANK_NAME, '8600059' BANK_CODE UNION ALL
SELECT N'Bank of Wenzhou (温州银行)' BANK_NAME, '8600061' BANK_CODE UNION ALL
SELECT N'China Zheshang Bank (浙商银行)' BANK_NAME, '8600063' BANK_CODE UNION ALL
SELECT N'Shanghai Rural Commercial Bank (上海农村商业银行)' BANK_NAME, '8600065' BANK_CODE UNION ALL
SELECT N'Bank of China (中国银行)' BANK_NAME, '8600066' BANK_CODE UNION ALL
SELECT N'Chongqing Rural Commercial Bank (重庆农村商业银行)' BANK_NAME, '8600069' BANK_CODE UNION ALL
SELECT N'Jiangsu Bank (江苏银行)' BANK_NAME, '8600070' BANK_CODE UNION ALL
SELECT N'Hubei Province Rural Credit Union (湖北省农村信用社联合社)' BANK_NAME, '8600071' BANK_CODE UNION ALL
SELECT N'Guangdong Nanyue Bank (广东南粤银行)' BANK_NAME, '8600072' BANK_CODE UNION ALL
SELECT N'Zhejiang Province Rural Credit Union (浙江省农村信用社联合社)' BANK_NAME, '8600073' BANK_CODE UNION ALL
SELECT N'Fujian Province Rural Credit Union (福建省农村信用社联合社)' BANK_NAME, '8600074' BANK_CODE UNION ALL
SELECT N'Lanzhou Bank (兰州银行)' BANK_NAME, '8600075' BANK_CODE UNION ALL
SELECT N'Guilin Bank (桂林银行)' BANK_NAME, '8600076' BANK_CODE UNION ALL
SELECT N'Jiangsu Province Rural Credit Union (江苏省农村信用社联合社)' BANK_NAME, '8600077' BANK_CODE UNION ALL
SELECT N'Harbin Bank (哈尔滨银行)' BANK_NAME, '8600078' BANK_CODE UNION ALL
SELECT N'Foshan Shunde Rural Commercial Bank (佛山顺德农村商业银行)' BANK_NAME, '8600079' BANK_CODE UNION ALL
SELECT N'Rural Credit Union of Guangxi Zhuang Autonomous Region (广西壮族自治区农村信用社联合社)' BANK_NAME, '8600080' BANK_CODE UNION ALL
SELECT N'Panzhihua Commercial Bank (攀枝花市商业银行)' BANK_NAME, '8600081' BANK_CODE UNION ALL
SELECT N'Zhengzhou Bank (郑州银行)' BANK_NAME, '8600082' BANK_CODE UNION ALL
SELECT N'Handan Commercial Bank (邯郸市商业银行)' BANK_NAME, '8600083' BANK_CODE UNION ALL
SELECT N'Shandong Province Rural Credit Union (山东省农村信用社联合社)' BANK_NAME, '8600084' BANK_CODE UNION ALL
SELECT N'Qilu Bank (齐鲁银行)' BANK_NAME, '8600085' BANK_CODE UNION ALL
SELECT N'Taizhou Bank (台州银行)' BANK_NAME, '8600086' BANK_CODE UNION ALL
SELECT N'Inner Mongolia Bank (内蒙古银行)' BANK_NAME, '8600087' BANK_CODE UNION ALL
SELECT N'Guangdong Huaxing Bank (广东华兴银行)' BANK_NAME, '8600088' BANK_CODE UNION ALL
SELECT N'Bank of Deyang (Great Wall Western China Bank) (德阳银行(长城华西银行）)' BANK_NAME, '8600089' BANK_CODE UNION ALL
SELECT N'Chang’an Bank (长安银行)' BANK_NAME, '8600090' BANK_CODE UNION ALL
SELECT N'Urumqi City Commercial Bank (乌鲁木齐市商业银行)' BANK_NAME, '8600091' BANK_CODE UNION ALL
SELECT N'Weifang Bank (潍坊银行)' BANK_NAME, '8600092' BANK_CODE UNION ALL
SELECT N'Jilin Bank (吉林银行)' BANK_NAME, '8600093' BANK_CODE UNION ALL
SELECT N'Hengfeng Bank (恒丰银行)' BANK_NAME, '8600094' BANK_CODE UNION ALL
SELECT N'Erdos Bank (鄂尔多斯银行)' BANK_NAME, '8600095' BANK_CODE UNION ALL
SELECT N'Jiangsu Changshu Rural Commercial Bank (江苏常熟农村商业银行)' BANK_NAME, '8600096' BANK_CODE UNION ALL
SELECT N'Hankou Bank (汉口银行)' BANK_NAME, '8600097' BANK_CODE UNION ALL
SELECT N'Zhangjiakou Commercial bank (张家口市商业银行)' BANK_NAME, '8600098' BANK_CODE UNION ALL
SELECT N'Huishang Bank (徽商银行)' BANK_NAME, '8600099' BANK_CODE UNION ALL
SELECT N'Bank of Hebei (河北银行)' BANK_NAME, '8600100' BANK_CODE UNION ALL
SELECT N'Jilin Rural Credit Cooperative Union (吉林省农村信用社联合社)' BANK_NAME, '8600101' BANK_CODE UNION ALL
SELECT N'Zigong Commercial Bank (自贡市商业银行)' BANK_NAME, '8600102' BANK_CODE UNION ALL
SELECT N'Guiyang Commercial Bank (Guiyang Bank) (贵阳市商业银行（贵阳银行）)' BANK_NAME, '8600103' BANK_CODE UNION ALL
SELECT N'Bank of Kunlun (昆仑银行)' BANK_NAME, '8600104' BANK_CODE UNION ALL
SELECT N'Bank of Liuzhou (柳州银行)' BANK_NAME, '8600105' BANK_CODE UNION ALL
SELECT N'Ningxia Huanghe Rural Commercial Bank (宁夏黄河农村商业银行)' BANK_NAME, '8600106' BANK_CODE UNION ALL
SELECT N'Jiangxi Ganzhou Rural Bank (江西赣州银座村镇银行)' BANK_NAME, '8600107' BANK_CODE UNION ALL
SELECT N'Jincheng bank (晋城银行)' BANK_NAME, '8600108' BANK_CODE UNION ALL
SELECT N'Longjiang Bank (龙江银行)' BANK_NAME, '8600109' BANK_CODE UNION ALL
SELECT N'Zhuhai China Resources Bank (珠海华润银行)' BANK_NAME, '8600110' BANK_CODE UNION ALL
SELECT N'Ganzhou Bank (赣州银行)' BANK_NAME, '8600111' BANK_CODE UNION ALL
SELECT N'Chongqing Bank (重庆银行)' BANK_NAME, '8600112' BANK_CODE UNION ALL
SELECT N'Jinshang Bank (晋商银行)' BANK_NAME, '8600113' BANK_CODE UNION ALL
SELECT N'Hainan Rural Credit Union (海南省农村信用社联合社)' BANK_NAME, '8600114' BANK_CODE UNION ALL
SELECT N'Fujian Haixia Bank (福建海峡银行)' BANK_NAME, '8600115' BANK_CODE UNION ALL
SELECT N'Dezhou Bank (德州银行)' BANK_NAME, '8600116' BANK_CODE UNION ALL
SELECT N'Bank of Luoyang (洛阳银行)' BANK_NAME, '8600117' BANK_CODE UNION ALL
SELECT N'Bank of Xingtai (邢台银行)' BANK_NAME, '8600118' BANK_CODE UNION ALL
SELECT N'Bank of Yingkou (营口银行)' BANK_NAME, '8600119' BANK_CODE UNION ALL
SELECT N'Bank of Jiaxing (嘉兴银行)' BANK_NAME, '8600120' BANK_CODE UNION ALL
SELECT N'Bank of Ningxia (宁夏银行)' BANK_NAME, '8600121' BANK_CODE UNION ALL
SELECT N'Ningbo Yinzhou Rural Cooperative bank (宁波鄞州农村合作银行)' BANK_NAME, '8600122' BANK_CODE UNION ALL
SELECT N'Bank of Cangzhou (沧州银行)' BANK_NAME, '8600123' BANK_CODE UNION ALL
SELECT N'Bank of Langfang (廊坊银行)' BANK_NAME, '8600124' BANK_CODE UNION ALL
SELECT N'Wujiang Rural Commercial Bank (吴江农村商业银行)' BANK_NAME, '8600125' BANK_CODE UNION ALL
SELECT N'Bank of Chengde (承德银行)' BANK_NAME, '8600126' BANK_CODE UNION ALL
SELECT N'Bank of Qinghai (青海银行)' BANK_NAME, '8600127' BANK_CODE UNION ALL
SELECT N'Bank of Shaoxing (绍兴银行)' BANK_NAME, '8600128' BANK_CODE UNION ALL
SELECT N'Xinhan Bank (新韩银行（中国）)' BANK_NAME, '8600129' BANK_CODE UNION ALL
SELECT N'Mianyang City Commercial Bank (绵阳市商业银行)' BANK_NAME, '8600130' BANK_CODE UNION ALL
SELECT N'Bank of Shangqiu (商丘市商业银行)' BANK_NAME, '8600131' BANK_CODE UNION ALL
SELECT N'Bank of Fuxin (阜新银行)' BANK_NAME, '8600132' BANK_CODE UNION ALL
SELECT N'Shenzhen Futian Yinzuo Rural Bank (深圳福田银座村镇银行)' BANK_NAME, '8600133' BANK_CODE UNION ALL
SELECT N'Luohe City Commercial Bank (漯河市商业银行)' BANK_NAME, '8600134' BANK_CODE UNION ALL
SELECT N'Beijing Shunyi Yinzuo Rural Bank (北京顺义银座村镇银行)' BANK_NAME, '8600135' BANK_CODE UNION ALL
SELECT N'Industrial Bank of Korea (企业银行（中国）)' BANK_NAME, '8600136' BANK_CODE UNION ALL
SELECT N'Woori Bank (友利银行(中国))' BANK_NAME, '8600137' BANK_CODE UNION ALL
SELECT N'Chongqing Yubei Yinzuo Rural Bank (重庆渝北银座村镇银行)' BANK_NAME, '8600138' BANK_CODE UNION ALL
SELECT N'Zhejiang Sanmen Yinzuo Rural Bank (浙江三门银座村镇银行)' BANK_NAME, '8600139' BANK_CODE UNION ALL
SELECT N'China Merchants Bank (招商银行)' BANK_NAME, '8600023' BANK_CODE 
)X


SELECT * FROM #TEMP3
INSERT INTO API_BANK_LIST(API_PARTNER_ID,BANK_NAME,BANK_CODE1,BANK_CODE2,BANK_STATE,BANK_DISTRICT,BANK_ADDRESS,BANK_PHONE
,BANK_EMAIL,SUPPORT_CURRENCY,BANK_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE,BANK_NAME_UNICODE)
SELECT 394450, REPLACE(REPLACE(REPLACE(CAST(BANK_NAME AS VARCHAR(200)), '?', ''), '()', ''), '()', ''), BANK_CODE,NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'CHINA', 2, 1, 
RIGHT(LEFT(REPLACE(BANK_NAME, REPLACE(REPLACE(REPLACE(CAST(BANK_NAME AS VARCHAR(200)), '?', ''), '()', ''), '()', ''), ''), LEN(REPLACE(BANK_NAME, REPLACE(REPLACE(REPLACE(CAST(BANK_NAME AS VARCHAR(200)), '?', ''), '()', ''), '()', ''), '')) -1), LEN(REPLACE(BANK_NAME, REPLACE(REPLACE(REPLACE(CAST(BANK_NAME AS VARCHAR(200)), '?', ''), '()', ''), '()', ''), '')) - 2) FROM #TEMP3

SELECT REPLACE(REPLACE(REPLACE(CAST(BANK_NAME AS VARCHAR(200)), '?', ''), '()', ''), '()', '') FROM #TEMP3
SELECT RIGHT(REPLACE(BANK_NAME, REPLACE(REPLACE(REPLACE(CAST(BANK_NAME AS VARCHAR(200)), '?', ''), '()', ''), '()', ''), ''), LEN(REPLACE(BANK_NAME, REPLACE(REPLACE(REPLACE(CAST(BANK_NAME AS VARCHAR(200)), '?', ''), '()', ''), '()', ''), '')) -1) FROM #TEMP3
SELECT RIGHT(LEFT(REPLACE(BANK_NAME, REPLACE(REPLACE(REPLACE(CAST(BANK_NAME AS VARCHAR(200)), '?', ''), '()', ''), '()', ''), ''), LEN(REPLACE(BANK_NAME, REPLACE(REPLACE(REPLACE(CAST(BANK_NAME AS VARCHAR(200)), '?', ''), '()', ''), '()', ''), '')) -1), LEN(REPLACE(BANK_NAME, REPLACE(REPLACE(REPLACE(CAST(BANK_NAME AS VARCHAR(200)), '?', ''), '()', ''), '()', ''), '')) - 2) FROM #TEMP3


--insert china ali pay wallet
INSERT INTO API_BANK_LIST(API_PARTNER_ID,BANK_NAME,BANK_CODE1,BANK_STATE,BANK_DISTRICT,BANK_ADDRESS,BANK_PHONE
,BANK_EMAIL,SUPPORT_CURRENCY,BANK_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE)
SELECT 394450, 'Alipay Ewallet', 'EWALIPAY', NULL, NULL, NULL, NULL, NULL, NULL, 'China', 13, 1 

--insert china union pay Card Payment
INSERT INTO API_BANK_LIST(API_PARTNER_ID,BANK_NAME,BANK_CODE1,BANK_STATE,BANK_DISTRICT,BANK_ADDRESS,BANK_PHONE
,BANK_EMAIL,SUPPORT_CURRENCY,BANK_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE)
SELECT 394450, 'Union Pay Card Payment', '8600067', NULL, NULL, NULL, NULL, NULL, NULL, 'China', 2, 1 

select * from API_BANK_LIST where bank_code1='8600067'

