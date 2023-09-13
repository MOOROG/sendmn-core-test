UPDATE dbo.applicationMenus SET linkPage = '/Remit/Transaction/MultipleReceipt/list.aspx',menuName = 'Multiple Receipt',
		menuDescription = 'Menu for: Multiple Receipt'	WHERE functionId = '40112000' 

UPDATE dbo.applicationMenus SET isActive = 'N' WHERE menuName = 'Agent And Group Mapping' 
UPDATE dbo.applicationMenus SET isActive = 'N' WHERE menuName = 'Location and Group Mapping' 
UPDATE dbo.applicationMenus SET isActive = 'N' WHERE menuName = 'Email Server Setup' 
UPDATE dbo.applicationMenus SET isActive = 'N' WHERE menuName = 'Agent Bank Mapping ' 
UPDATE dbo.applicationMenus SET isActive = 'N' WHERE menuName = 'KFTC Logs' 
UPDATE dbo.applicationMenus SET isActive = 'N' WHERE menuName = 'Cancel Transaction With Charge' 
UPDATE dbo.applicationMenus SET isActive = 'N' WHERE menuName = 'Reprocess Transaction' 
UPDATE dbo.applicationMenus SET isActive = 'N' WHERE menuName = 'GIBL Reconcile Rpt' 
UPDATE dbo.applicationMenus SET isActive = 'N' WHERE menuName = 'Regulatory Report(BOK)' 
UPDATE dbo.applicationMenus SET isActive = 'N' WHERE menuName = 'Virtual AC Upload'
DELETE FROM dbo.applicationFunctions WHERE parentFunctionId='20194000'


--update link of Transaction Analysis Report
UPDATE dbo.applicationMenus SET linkPage='/Remit/Transaction/Reports/TranAnalysisRpt/ManageIntl.aspx' WHERE menuName='Transaction Analysis Report'

UPDATE dbo.applicationFunctions SET functionName='Add From Send Page' WHERE functionId='20206030'
UPDATE dbo.applicationMenus SET menuName='Reprint Receipt',menuDescription='Reprint Receipt' WHERE functionId='40101900'
