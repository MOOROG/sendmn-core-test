
ALTER TABLE #VOUCHER ADD RECEIVER_ACC_NUM VARCHAR(30)

UPDATE #VOUCHER SET RECEIVER_ACC_NUM = CASE BRANCH WHEN 'Funabashi Branch' THEN '100139208487'
												WHEN 'Shinokubo Head Office' THEN '100139292573'
												WHEN 'Nagoya Branch' THEN '100139297551'
												WHEN 'Tokyo Branch' THEN '100139292573'
												WHEN 'Fukuoka Branch' THEN '100139219838'
												END

update v set v.referral_code = r.referral_code from #VOUCHER v
inner join fastmoneypro_remit.dbo.referral_agent_wise r on r.ext_id = v.agent_id


SELECT * FROM AC_MASTER WHERE ACCT_NAME LIKE '%Fukuoka%'


SELECT * FROM VOUCHER_TRANSIT_CASH_MANAGE V
INNER JOIN tran_master T ON T.acc_num = V.RECEIVER_ACC_NUM
WHERE CAST(T.CREATED_DATE AS DATE) = '2019-09-11'
AND FIELD2 = 'Vault Transfer'

SELECT COUNT(0) FROM tran_master 
WHERE FIELD2 = 'Vault Transfer'
AND CAST(CREATED_DATE AS DATE) = '2019-09-11'


SELECT COUNT(0) FROM VOUCHER_TRANSIT_CASH_MANAGE WHERE IS_GEN IS NULL
