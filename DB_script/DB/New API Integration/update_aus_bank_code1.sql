----- Bank Of India
IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
			DROP TABLE #Temp
SELECT * INTO #Temp
FROM
(
	SELECT '610002' BANK_CODE, 'AMP' BANK_CODE2 UNION ALL
SELECT '610003' BANK_CODE, 'ARA' BANK_CODE2 UNION ALL
SELECT '610004' BANK_CODE, 'ANZ' BANK_CODE2 UNION ALL
SELECT '610005' BANK_CODE, 'ADC' BANK_CODE2 UNION ALL
SELECT '610006' BANK_CODE, 'ASL' BANK_CODE2 UNION ALL
SELECT '610006' BANK_CODE, 'ALX' BANK_CODE2 UNION ALL
SELECT '610007' BANK_CODE, 'MCU' BANK_CODE2 UNION ALL
SELECT '610008' BANK_CODE, 'BCA' BANK_CODE2 UNION ALL
SELECT '610010' BANK_CODE, 'BOM' BANK_CODE2 UNION ALL
SELECT '610011' BANK_CODE, 'BQL' BANK_CODE2 UNION ALL
SELECT '610013' BANK_CODE, 'BSA' BANK_CODE2 UNION ALL
SELECT '610015' BANK_CODE, 'BBL' BANK_CODE2 UNION ALL
SELECT '610016' BANK_CODE, 'BYB' BANK_CODE2 UNION ALL
SELECT '610017' BANK_CODE, 'CBA' BANK_CODE2 UNION ALL
SELECT '610018' BANK_CODE, 'DBL' BANK_CODE2 UNION ALL
SELECT '610019' BANK_CODE, 'BCY' BANK_CODE2 UNION ALL
SELECT '610021' BANK_CODE, 'HBS' BANK_CODE2 UNION ALL
SELECT '610023' BANK_CODE, 'HBA' BANK_CODE2 UNION ALL
SELECT '610024' BANK_CODE, 'HUM' BANK_CODE2 UNION ALL
SELECT '610025' BANK_CODE, 'IMB' BANK_CODE2 UNION ALL
SELECT '610026' BANK_CODE, 'ING' BANK_CODE2 UNION ALL
SELECT '610027' BANK_CODE, 'MBL' BANK_CODE2 UNION ALL
SELECT '610028' BANK_CODE, 'MEB' BANK_CODE2 UNION ALL
SELECT '610030' BANK_CODE, 'NAB' BANK_CODE2 UNION ALL
SELECT '610031' BANK_CODE, 'PNB' BANK_CODE2 UNION ALL
SELECT '610036' BANK_CODE, 'STG' BANK_CODE2 UNION ALL
SELECT '610037' BANK_CODE, 'MET' BANK_CODE2 UNION ALL
SELECT '610038' BANK_CODE, 'TCU' BANK_CODE2 UNION ALL
SELECT '610041' BANK_CODE, 'WBC' BANK_CODE2 UNION ALL
SELECT '610043' BANK_CODE, 'MPB' BANK_CODE2 UNION ALL
SELECT '610044' BANK_CODE, 'CNA' BANK_CODE2 UNION ALL
SELECT '610045' BANK_CODE, 'APO' BANK_CODE2 UNION ALL
SELECT '610046' BANK_CODE, 'PIB' BANK_CODE2 UNION ALL
SELECT '610047' BANK_CODE, 'BAE' BANK_CODE2 UNION ALL
SELECT '610048' BANK_CODE, 'BAL' BANK_CODE2 UNION ALL
SELECT '610050' BANK_CODE, 'COM' BANK_CODE2 UNION ALL
SELECT '610051' BANK_CODE, 'LBA' BANK_CODE2 UNION ALL
SELECT '610053' BANK_CODE, 'BWA' BANK_CODE2 UNION ALL
SELECT '610054' BANK_CODE, 'SKY' BANK_CODE2 UNION ALL
SELECT '610055' BANK_CODE, 'BNP' BANK_CODE2 UNION ALL
SELECT '610056' BANK_CODE, 'BPS' BANK_CODE2 UNION ALL
SELECT '610057' BANK_CODE, 'CAP' BANK_CODE2 UNION ALL
SELECT '610058' BANK_CODE, 'CFC' BANK_CODE2 UNION ALL
SELECT '610060' BANK_CODE, 'CUA' BANK_CODE2 UNION ALL
SELECT '610061' BANK_CODE, 'CRU' BANK_CODE2 UNION ALL
SELECT '610062' BANK_CODE, 'DBA' BANK_CODE2 UNION ALL
SELECT '610065' BANK_CODE, 'GCB' BANK_CODE2 UNION ALL
SELECT '610066' BANK_CODE, 'GTW' BANK_CODE2 UNION ALL
SELECT '610068' BANK_CODE, 'HIC' BANK_CODE2 UNION ALL
SELECT '610069' BANK_CODE, 'HCC' BANK_CODE2 UNION ALL
SELECT '610071' BANK_CODE, 'CUS' BANK_CODE2 UNION ALL
SELECT '610072' BANK_CODE, 'IBK' BANK_CODE2 UNION ALL
SELECT '610074' BANK_CODE, 'CMB' BANK_CODE2 UNION ALL
SELECT '610075' BANK_CODE, 'MMB' BANK_CODE2 UNION ALL
SELECT '610078' BANK_CODE, 'ICB' BANK_CODE2 UNION ALL
SELECT '610079' BANK_CODE, 'MCB' BANK_CODE2 UNION ALL
SELECT '610080' BANK_CODE, 'NEW' BANK_CODE2 UNION ALL
SELECT '610083' BANK_CODE, 'RBA' BANK_CODE2 UNION ALL
SELECT '610087' BANK_CODE, 'SNX' BANK_CODE2 UNION ALL
SELECT '610088' BANK_CODE, 'SSB' BANK_CODE2 UNION ALL
SELECT '610089' BANK_CODE, 'SMB' BANK_CODE2 UNION ALL
SELECT '610090' BANK_CODE, 'SCU' BANK_CODE2 UNION ALL
SELECT '610091' BANK_CODE, 'STH' BANK_CODE2 UNION ALL
SELECT '610092' BANK_CODE, 'TBB' BANK_CODE2 UNION ALL
SELECT '610093' BANK_CODE, 'MSL' BANK_CODE2 UNION ALL
SELECT '610094' BANK_CODE, 'UBS' BANK_CODE2 UNION ALL
SELECT '610095' BANK_CODE, 'UOB' BANK_CODE2 UNION ALL
SELECT '610096' BANK_CODE, 'UFS' BANK_CODE2 UNION ALL
SELECT '610097' BANK_CODE, 'WCU' BANK_CODE2 UNION ALL
SELECT '610098' BANK_CODE, 'ADV' BANK_CODE2 UNION ALL
SELECT '610099' BANK_CODE, 'INV' BANK_CODE2 UNION ALL
SELECT '610100' BANK_CODE, 'CBL' BANK_CODE2 UNION ALL
SELECT '610101' BANK_CODE, 'CCB' BANK_CODE2 UNION ALL
SELECT '610102' BANK_CODE, 'OCB' BANK_CODE2 UNION ALL
SELECT '610103' BANK_CODE, 'QTM' BANK_CODE2 UNION ALL
SELECT '610104' BANK_CODE, 'RAB' BANK_CODE2 UNION ALL
SELECT '610105' BANK_CODE, 'MMP' BANK_CODE2 UNION ALL
SELECT '610106' BANK_CODE, 'ANZ' BANK_CODE2 UNION ALL
SELECT '610107' BANK_CODE, 'BTA' BANK_CODE2 UNION ALL
SELECT '610108' BANK_CODE, 'BOT' BANK_CODE2 UNION ALL
SELECT '610109' BANK_CODE, 'VOL' BANK_CODE2 UNION ALL
SELECT '610110' BANK_CODE, 'BCC' BANK_CODE2 UNION ALL
SELECT '610111' BANK_CODE, 'SEL' BANK_CODE2 UNION ALL
SELECT '610112' BANK_CODE, 'HOM' BANK_CODE2 UNION ALL
SELECT '610113' BANK_CODE, 'PPB' BANK_CODE2 UNION ALL
SELECT '610114' BANK_CODE, 'QCB' BANK_CODE2 UNION ALL
SELECT '610115' BANK_CODE, 'ROK' BANK_CODE2 UNION ALL
SELECT '610116' BANK_CODE, 'RCU' BANK_CODE2
)
x

UPDATE	tbb
SET	tbb.BANK_CODE2=ABL.BANK_CODE2
FROM dbo.API_BANK_LIST tbb
INNER JOIN #Temp ABL ON ABL.BANK_CODE=tbb.BANK_CODE1