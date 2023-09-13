------------bank Turkey
IF OBJECT_ID('tempdb..#TempBankTURKEY') IS NOT NULL
			DROP TABLE #TempBankTURKEY

SELECT * INTO #TempBankTURKEY
FROM
(
	SELECT '90001' BANK_CODE , 'ADABANK A.S.' BANK_NAME UNION ALL
	SELECT '90002' BANK_CODE , 'AKBANK T.A.S.' BANK_NAME UNION ALL
	SELECT '90003' BANK_CODE , 'AKTIF YATIRIM BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90004' BANK_CODE , 'ALBARAKA TURK KATILIM BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90005' BANK_CODE , 'ALTERNATIFBANK A.S.' BANK_NAME UNION ALL
	SELECT '90006' BANK_CODE , 'ANADOLUBANK A.S.' BANK_NAME UNION ALL
	SELECT '90007' BANK_CODE , 'ARAP TRK BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90008' BANK_CODE , 'BANK OF CHINA TURKEY' BANK_NAME UNION ALL
	SELECT '90009' BANK_CODE , 'BANK OF TOKYO-MITSUBISHI UFJ TURKEY A.S.' BANK_NAME UNION ALL
	SELECT '90010' BANK_CODE , 'BANKA MELLAT TRKIYE A.S' BANK_NAME UNION ALL
	SELECT '90011' BANK_CODE , 'BANKPOZITIF KREDI VE KALK.BANK.A.S.' BANK_NAME UNION ALL
	SELECT '90043' BANK_CODE , 'BIRLESIK FON BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90012' BANK_CODE , 'BURGAN BANK A.S.' BANK_NAME UNION ALL
	SELECT '90013' BANK_CODE , 'CITIBANK A.S.' BANK_NAME UNION ALL
	SELECT '90014' BANK_CODE , 'DENIZ BANK A.S.' BANK_NAME UNION ALL
	SELECT '90015' BANK_CODE , 'DEUTSCHE BANK A.S.' BANK_NAME UNION ALL
	SELECT '90016' BANK_CODE , 'DILER YATIRIM BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90017' BANK_CODE , 'EFT MERKEZI' BANK_NAME UNION ALL
	SELECT '90018' BANK_CODE , 'EMKT MERKEZI' BANK_NAME UNION ALL
	SELECT '90019' BANK_CODE , 'EMKT MERKEZI' BANK_NAME UNION ALL
	SELECT '90020' BANK_CODE , 'FINANSBANK A.S.' BANK_NAME UNION ALL
	SELECT '90021' BANK_CODE , 'FIBABANKA A.S.' BANK_NAME UNION ALL
	SELECT '90022' BANK_CODE , 'GSD YATIRIM BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90023' BANK_CODE , 'HALK BANKASI' BANK_NAME UNION ALL
	SELECT '90024' BANK_CODE , 'HSBC BANK A.S.' BANK_NAME UNION ALL
	SELECT '90025' BANK_CODE , 'ICBC TURKEY BANK A.S' BANK_NAME UNION ALL
	SELECT '90026' BANK_CODE , 'ING BANK A.S.' BANK_NAME UNION ALL
	SELECT '90027' BANK_CODE , 'INTESA SANPAOLO S.p.A' BANK_NAME UNION ALL
	SELECT '90028' BANK_CODE , 'ILLER BANKASI' BANK_NAME UNION ALL
	SELECT '90029' BANK_CODE , 'ISTANBUL TAKAS VE SAKLAMA BANKASI' BANK_NAME UNION ALL
	SELECT '90030' BANK_CODE , 'JP MORGAN CHASE BANK NA MERK COL.OH' BANK_NAME UNION ALL
	SELECT '90031' BANK_CODE , 'KUVEYT TURK KATILIM BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90032' BANK_CODE , 'MERKEZI KAYIT KURULUSU' BANK_NAME UNION ALL
	SELECT '90033' BANK_CODE , 'MERRILL LYNCH YATIRIM BANK A.S.' BANK_NAME UNION ALL
	SELECT '90034' BANK_CODE , 'NUROL YATIRIM BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90035' BANK_CODE , 'ODEA BANK A.S.' BANK_NAME UNION ALL
	SELECT '90036' BANK_CODE , 'PASHA YATIRIM BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90037' BANK_CODE , 'RABOBANK A.S.' BANK_NAME UNION ALL
	SELECT '90038' BANK_CODE , 'SOCIETE GENERALE' BANK_NAME UNION ALL
	SELECT '90039' BANK_CODE , 'STANDARD CHARTERED YATIRIM BANKASI TURK A.S.' BANK_NAME UNION ALL
	SELECT '90040' BANK_CODE , 'SEKERBANK T.A.S.' BANK_NAME UNION ALL
	SELECT '90041' BANK_CODE , 'T.C.MERKEZ BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90042' BANK_CODE , 'T.EKONOMI BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90044' BANK_CODE , 'T.GARANTI BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90045' BANK_CODE , 'T.IHRACAT KREDI BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90046' BANK_CODE , 'T.IS BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90047' BANK_CODE , 'T.KALKINMA BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90048' BANK_CODE , 'T.SINAI KALK. BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90049' BANK_CODE , 'T.VAKIFLAR BANKASI T.A.O.' BANK_NAME UNION ALL
	SELECT '90050' BANK_CODE , 'TC ZIRAAT BANKASI' BANK_NAME UNION ALL
	SELECT '90051' BANK_CODE , 'THE ROYAL BANK OF SCOTLAND N.V. ISTANBUL' BANK_NAME UNION ALL
	SELECT '90052' BANK_CODE , 'TURKISHBANK' BANK_NAME UNION ALL
	SELECT '90053' BANK_CODE , 'TURKIYE FINANS KATILIM BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90054' BANK_CODE , 'TURKLAND BANK A.S.' BANK_NAME UNION ALL
	SELECT '90055' BANK_CODE , 'VAKIF KATILIM BANKASI' BANK_NAME UNION ALL
	SELECT '90056' BANK_CODE , 'WESTDEUTSCHE LANDESBANK GIROZENTRAL' BANK_NAME UNION ALL
	SELECT '90057' BANK_CODE , 'YAPI VE KREDI BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90058' BANK_CODE , 'YNLENDIRICI' BANK_NAME UNION ALL
	SELECT '90059' BANK_CODE , 'ZIRAAT KATILIM BANKASI A.S.' BANK_NAME UNION ALL
	SELECT '90060' BANK_CODE , 'ZIRAAT KATILIM BANKASI A.S.' BANK_NAME
)x		
				  
DELETE b 
FROM #TempBankTURKEY b
INNER JOIN dbo.API_BANK_LIST A ON A.BANK_CODE1=b.BANK_CODE

INSERT INTO API_BANK_LIST(API_PARTNER_ID,BANK_NAME,BANK_CODE1,BANK_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE)
SELECT 394450, BANK_NAME, BANK_CODE, 'TURKEY', 2, 1 FROM #TempBankTURKEY

---------- cash

IF NOT EXISTS(SELECT '' FROM dbo.API_BANK_LIST WHERE BANK_CODE1='CPUPT')
BEGIN
    INSERT INTO API_BANK_LIST(API_PARTNER_ID,BANK_NAME,BANK_CODE1,BANK_STATE,BANK_DISTRICT,BANK_ADDRESS,BANK_PHONE
	,BANK_EMAIL,SUPPORT_CURRENCY,BANK_COUNTRY,PAYMENT_TYPE_ID,IS_ACTIVE)
	SELECT 394450, 'Turkey UPT', 'CPUPT', NULL, NULL, NULL, NULL, NULL, NULL, 'TURKEY', 1, 1
END