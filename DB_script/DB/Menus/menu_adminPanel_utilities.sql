	-- Multiple Receipt
	EXEC proc_addMenu '20' ,'20191000','Multiple Receipt','Menu for: Multiple Receipt','/Remit/Transaction/MultipleReceipt/list.aspx','utilities','1','Y','20',''
	EXEC proc_AddFunction'20191000','20191000','View'	
	EXEC proc_AddFunction'20191010','20191000','Print'
	EXEC proc_AddFunction'40112010','40112000','Print'



	-- Customer SOA
	EXEC proc_addMenu '20' ,'20192000','Customer SOA','Menu for: Customer SOA','/Remit/CustomerSOA/List.aspx','Customer Management','1','Y','20',''
	EXEC proc_AddFunction'20192000','20192000','View'

	-- Customer SOA
	EXEC proc_addMenu '20' ,'20193000','New Receiver','Menu for: New Receiver','/Remit/Administration/CustomerSetup/Benificiar/NewBenificiarList.aspx','Customer Management','1','Y','20',''
	EXEC proc_AddFunction'20193010','20193000','View'
	EXEC proc_AddFunction'20193020','20193000','Print'

	-- Customer SOA
	EXEC proc_addMenu '20' ,'20194000','Customer Deposit Mapping','Menu for: Customer Deposit Mapping','/Remit/Administration/CustomerDepositMapping/MapCustomerDeposits.aspx','Deposit API','1','Y','20',''
	EXEC proc_AddFunction'20194000','20194000','View'
	EXEC proc_AddFunction'20194010','20194000','Map/Assign'

	--Manual Edit Service Charge (Agent Send Txn)
	EXEC proc_AddFunction'40101440','40101400','Edit Service Charge'
	EXEC proc_AddFunction'40101430','40101400','Enable Customer Signature'
	EXEC proc_AddFunction'40101420','40101400','Allow On-Behalf'
	
	-- Customer Refund
	EXEC proc_addMenu '20' ,'20195000','Customer Refund','Menu for: Customer Refund','/Remit/Administration/CustomerDepositMapping/MapCustomerDeposits.aspx','Deposit API','1','Y','20',''
	EXEC proc_AddFunction'20195010','20195000','View'
	EXEC proc_AddFunction'20195020','20195000','Add'
	EXEC proc_AddFunction'20195030','20195000','Delete'
	EXEC proc_AddFunction'20195040','20195000','Approve'


	EXEC proc_addMenu '20' ,'20196000','Mitasu Report','Menu for: Mitasu Report','/RemittanceSystem/RemittanceReports/MitasuReport/MitasuReport.aspx','Reports','1','Y','20',''
	EXEC proc_AddFunction'20196010','20196000','View'

	EXEC proc_addMenu '20' ,'20197000','Untransacted Report','Menu for: Untransacted Report','/RemittanceSystem/RemittanceReports/UntransactedReport/UntransactedList.aspx','Reports','1','Y','20',''
	EXEC proc_AddFunction'20197010','20197000','View'

	update applicationfunctions set functionname = 'Add' where functionid='20111310'
	EXEC proc_AddFunction'20111320','20111300','Edit'
	EXEC proc_AddFunction'20111330','20111300','View Document'
	EXEC proc_AddFunction'20111340','20111300','Upload Document'
	EXEC proc_AddFunction'20111350','20111300','View KYC'
	EXEC proc_AddFunction'20111360','20111300','Update KYC'
	EXEC proc_AddFunction'20111370','20111300','View Benificiary'
	EXEC proc_AddFunction'20111380','20111300','Add Benificiary'
	EXEC proc_AddFunction'20111390','20111300','Edit Benificiary'


	EXEC proc_addMenu '20' ,'20900000','New Receiver','Menu for: New Receiver','/Remit/Administration/CustomerSetup/Benificiar/NewBenificiarList.aspx',NULL,'1','Y','20','Other Services'
	EXEC proc_AddFunction'20900000','20900000','View'
	EXEC proc_AddFunction'20900010','20900000','Print'


	EXEC proc_AddFunction'20191010','20191000','Print'
	EXEC proc_AddFunction'40112010','40112000','Print'

	EXEC proc_addMenu '20' ,'20121000','Pay On Behalf','Menu for: Pay On Behalf','/Remit/Transaction/AdminTransaction/Pay/PaySearch.aspx',NULL,'1','Y','20','Transaction'
	
	EXEC proc_addMenu '20' ,'20131000','Customer Modify Log','Menu for: Customer Modify Log','/Remit/Administration/CustomerSetup/CustomerModifyLog/List.aspx','Customer Management','1','Y','20',NULL

	EXEC proc_AddFunction'20131000','20131000','View'


	--FOR cash AND vault
	EXEC proc_addMenu '20' ,'20178000','Cash And Vault Setup','Menu for: Cash And Vault Setup','/Remit/CashAndVault/List.aspx','Cash And Vault','1','Y','20',NULL
	EXEC proc_AddFunction'20178000','20178000','View'
	EXEC proc_AddFunction'20178010','20178000','Edit'
	EXEC proc_AddFunction'20178020','20178000','Approve'
	EXEC proc_AddFunction'20178050','20178000','Approve Branch Limit'
	EXEC proc_AddFunction'20178030','20178000','Add'
	EXEC proc_AddFunction'20178040','20178000','ActiveInActive'

	--Transfer To Vault
	DELETE FROM dbo.applicationMenus WHERE functionId = '20179000'
	EXEC proc_addMenu '40' ,'20179000','Transfer To Vault','Menu for: Transfer To Vault','/AgentPanel/TransferToVault/RequestedTransferToVaultList.aspx','Transaction','10','Y','40','Transaction'
	EXEC proc_AddFunction'20179000','20179000','View'

	--Approve Vault Transfer
	EXEC proc_addMenu '40' ,'20198000','Approve Vault Transfer','Menu for: Approve Vault Transfer','/AgentPanel/TransferToVault/ApproveTransferToVaultList.aspx',NULL,'11','Y','40','Transaction'
	EXEC proc_AddFunction'20198000','20198000','View'
	EXEC proc_AddFunction'20198010','20198000','Approve'

	--Cash hold limit top up
	EXEC proc_addMenu '20' ,'20199000','Cash Hold Limit TopUp','Menu for: Cash Hold Limit TopUp','/Remit/CashAndVault/CashHoldLimitTopUp/List.aspx','Cash And Vault','1','Y','20',NULL
	EXEC proc_AddFunction'20199000','20199000','View'
	EXEC proc_AddFunction'20199010','20199000','Approve'

	--Approve Cash hold limit top up
	EXEC proc_addMenu '20' ,'2020000','Approve Cash Hold Limit TopUp','Menu for:Approve Cash Hold Limit TopUp','/Remit/CashAndVault/CashHoldLimitTopUp/Approve.aspx','Cash And Vault','1','Y','20',NULL
	EXEC proc_AddFunction'2020000','2020000','View'
	EXEC proc_AddFunction'2020010','2020000','Approve'


	--Bank/Agent Of Partner
	EXEC proc_addMenu '40' ,'20300000','Partner Agent/Bank List','Menu for:Partner Agent/Bank List','/Remit/TPSetup/BankAndBranchSetup/BankList.aspx','Partner Others','1','Y','20',NULL
	EXEC proc_AddFunction'20300000','20300000','View'
	EXEC proc_AddFunction'20300000','20300010','Add/Edit'

	--Bank/Agent State Of Partner
	EXEC proc_addMenu '40' ,'20500000','Partner Agent/Bank State List','Menu for:Partner Agent/Bank State List','/Remit/TPSetup/StateCityTownSetup/StateList.aspx','Other Services','1','Y','20',NULL
	EXEC proc_AddFunction'20500000','20500000','View'
	EXEC proc_AddFunction'20500010','20500000','Add/Edit'

	--Third Party Exrate
	DELETE FROM dbo.applicationMenus WHERE functionId = '20600000'
	EXEC proc_addMenu '40' ,'20600000','ThirdParty ExRate Setup','Menu for:ThirdParty ExRate Setup','/Remit/TPSetup/TpApiRateSetup/TpApiRateSetupList.aspx','ThirdParty Setups','1','Y','30',NULL
	EXEC proc_AddFunction'20600000','20600000','View'
	EXEC proc_AddFunction'20600010','20600000','Add/Edit'

	-- Partner Sync List
	EXEC proc_addMenu '40' ,'20700000','Partner Sync List','Menu for:Partner Sync List','/Remit/Compliance/PartnerSyncList/PartnerSyncList.aspx','Other Services','1','Y','20',NULL
	EXEC proc_AddFunction'20700000','20700000','View'
	EXEC proc_AddFunction'20700010','20700000','Sync'

	-- Customer SOA for agent
	EXEC proc_addMenu '40' ,'20199000','Deposit Mapping','Menu for: Customer Deposit Mapping','/Remit/Administration/CustomerDepositMapping/MapCustomerDeposits.aspx','','1','Y','20','Other Services'
	EXEC proc_AddFunction'20199000','20199000','View'
	EXEC proc_AddFunction'20199010','20199000','Map/Assign'
	EXEC proc_AddFunction'20199020','20199000','Send'

	
	--TP import exrate
	EXEC proc_addMenu '40' ,'20201000','Import ThirdParty ExRate','Menu for:Import ThirdParty ExRate','/Remit/ImportSettlementRate/ImportSettlementRate.aspx','ThirdParty Setups','1','Y','30',NULL
	EXEC proc_AddFunction'20201000','20201000','View'
	EXEC proc_AddFunction'20201010','20201000','Import'

	--Add Customer
	EXEC proc_addMenu '40' ,'20202000','Add Customer','Menu for:Add Customer','/AgentNew/Customer/AddCustomer.aspx','AgentPanel','2','Y','40','Online Agent'
	EXEC proc_AddFunction'20202000','20202000','View'
	EXEC proc_AddFunction'20202010','20202000','Add'
	
	--Approve customer (Approve EditedCustomerData)
	EXEC proc_AddFunction'20130030','20130000','View Edited Customer'
	EXEC proc_AddFunction'20130020','20130000','View Edited Customer'

	-- add menu for add customer 
	EXEC proc_addMenu '40' ,'20203000','New Customer','Menu for:Add Customer','/AgentNew/Administration/CustomerSetup/CustomerRegistration/Manage.aspx','AgentPanel','2','Y','40','Registration'
	EXEC proc_AddFunction'20203000','20203000','View'
	EXEC proc_AddFunction'20203010','20203000','Add'

	-- add menu for edit customer
	EXEC proc_addMenu '40' ,'20203100','Edit Customer','Menu for:Edit Customer','/AgentNew/Administration/CustomerSetup/CustomerRegistration/Manage.aspx?edit=true','AgentPanel','2','Y','40','Registration'
	EXEC proc_AddFunction'20203100','20203100','View'
	EXEC proc_AddFunction'20203110','20203100','Edit'
	
	-- add menu for add customer KyC
	EXEC proc_addMenu '40' ,'20204000','Customer KYC','Menu for:Customer KYC','/AgentNew/Administration/CustomerSetup/CustomerRegistration/UpdateKYC.aspx','AgentPanel','2','Y','40','Registration'
	EXEC proc_AddFunction'20204000','20204000','View'
	EXEC proc_AddFunction'20204010','20204000','View KYC'
	EXEC proc_AddFunction'20204020','20204000','Update KYC'

	-- add menu for add customer document
	EXEC proc_addMenu '40' ,'20205000','Customer Document','Menu for:Customer Document','/AgentNew/Administration/CustomerSetup/CustomerRegistration/CustomerDocument.aspx','AgentPanel','2','Y','40','Registration'
	EXEC proc_AddFunction'20205000','20205000','View'
	EXEC proc_AddFunction'20205010','20205000','View Document'
	EXEC proc_AddFunction'20205020','20205000','Upload Document'


	----add menu for beneficiary setup
	EXEC proc_addMenu '40' ,'20206000','Beneficiary Setup','Menu for:Beneficiary Setup','/AgentNew/Administration/CustomerSetup/Benificiar/List.aspx','AgentPanel','2','Y','40','Registration'
	EXEC proc_AddFunction'20206000','20206000','View Page'
	EXEC proc_AddFunction'20206010','20206000','Add'
	EXEC proc_AddFunction'20206020','20206000','Edit'
	EXEC proc_AddFunction'20206030','20206000','View'


	EXEC proc_addMenu '40' ,'21100000','Referal Report','Menu for:Referal Report','/Remit/Transaction/Reports/ReferralReport/SearchReferralReport.aspx','Reports','1','Y','30',NULL
	EXEC proc_AddFunction '21100000','21100000','View'

	EXEC proc_addMenu '40' ,'40200000','Daily Cash Txn','Menu for:Daily Cash Txn','/AgentNew/Reports/DailyCashReport/DailyCashReportTransactionWise.aspx','AgentPanel','1','Y','40','AGENT REPORT'
	EXEC proc_AddFunction '40200000','40200000','View'

	--from admin customer registration (beneficiary)
	EXEC proc_addMenu '20' ,'20207000','Beneficiary Setup','Menu for: Beneficiary Setup','/Remit/Administration/CustomerRegistration/Beneficiary/List.aspx','Registration','1','Y','20',NULL
	EXEC proc_AddFunction'20207000','20207000','View Page'
	EXEC proc_AddFunction'20207010','20207000','Add'
	EXEC proc_AddFunction'20207020','20207000','Edit'
	EXEC proc_AddFunction'20207030','20206000','View'

	--from admin customer registration (Customer Document)
	EXEC proc_addMenu '20' ,'20208000','Customer Document','Menu for: Customer Document','/Remit/Administration/CustomerRegistration/CustomerDocument.aspx','Registration','1','Y','20',NULL
	EXEC proc_AddFunction'20208000','20208000','View'
	EXEC proc_AddFunction'20208010','20208000','Add'
	EXEC proc_AddFunction'20208020','20208000','View Document'

	--from admin customer registration (New Customer)
	EXEC proc_addMenu '20' ,'20209000','New Customer','Menu for: New Customer','/Remit/Administration/CustomerRegistration/Manage.aspx','Registration','1','Y','20',NULL
	EXEC proc_AddFunction'20209000','20209000','View'
	EXEC proc_AddFunction'20209010','20209000','Add'


	--from admin customer registration (Edit Customer)
	EXEC proc_addMenu '20' ,'20212000','Edit Customer','Menu for: Edit Customer','/Remit/Administration/CustomerRegistration/Manage.aspx?edit=true','Registration','1','Y','20',NULL
	EXEC proc_AddFunction'20212000','20212000','View'
	EXEC proc_AddFunction'20212010','20212000','Edit'

	--from admin customer registration (Customer KYC)
	EXEC proc_addMenu '20' ,'20211000','Customer KYC','Menu for: Customer KYC','/Remit/Administration/CustomerRegistration/UpdateKYC.aspx','Registration','1','Y','20',NULL
	EXEC proc_AddFunction'20211000','20211000','View'
	EXEC proc_AddFunction'20211010','20211000','Add'

		-- add menu for agentpanel add beneficiary 
	EXEC proc_addMenu '40' ,'20213000','Add Beneficiary','Menu for:Add Beneficiary','/AgentNew/Administration/CustomerSetup/Benificiar/AddBeneficiary.aspx','AgentPanel','2','Y','40','Registration'
	EXEC proc_AddFunction'20213000','20213000','View Page'
	EXEC proc_AddFunction'20213010','20213000','View'
	

		-- add menu for agentpanel add beneficiary 
	EXEC proc_addMenu '40' ,'20180000','Transit Cash Manage','Menu for:Transit Cash Manage','/AccountReport/TransitCashSettlement/Manage.aspx','BILL & VOUCHER','2','Y','40',null
	EXEC proc_AddFunction'20180010','20180000','View Page'

	-- add menu for agentpanel add beneficiary 
	EXEC proc_addMenu '40' ,'20240000','End Of Day','Menu for:End Of Day','/AccountReport/EOD.aspx','BILL & VOUCHER','2','Y','40',null
	EXEC proc_AddFunction'20240000','20240000','View Page'


	-- Send Transaction for agent Tab control
		EXEC proc_addMenu '40' ,'40101600','Send Transaction','Menu for:Send Transaction','/AgentNew/AgentSend/SendV2.aspx','AgentPanel','5','Y','40','Send Money'
		EXEC proc_AddFunction'40101600','40101600','View Page'
		EXEC proc_AddFunction'40101610','40101600','Edit Service Charge'

		
	-- Approve Transaction for agent 
		EXEC proc_addMenu '40' ,'40101800','Approve Hold Txn','Menu for:Approve Hold Txn','/AgentNew/Transaction/ApproveTxn/holdTxnList.aspx','Transaction','5','Y','40','Transaction'
		EXEC proc_AddFunction'40101800','40101800','View Page'
		EXEC proc_AddFunction'40101810','40101800','Modify Transaction'
		EXEC proc_AddFunction'40101820','40101800','Approve Single Transaction'
		EXEC proc_AddFunction'40101830','40101800','Approve Multiple Transaction'
		EXEC proc_AddFunction'40101840','40101800','Reject Transaction'

	-- Customer SOA
	EXEC proc_addMenu '20' ,'20200000','Cash Position Report','Menu for: Cash Position Report','/Remit/Transaction/Reports/CashManagement/Manage.aspx','Reports','1','Y','20',''
	EXEC proc_AddFunction'20200000','20200000','View'

	--Hold Transction Report
	EXEC proc_addMenu '40' ,'20214000','Hold Transaction Report','Menu for:Hold Transaction Report','/AgentNew/Reports/HoldTransactionReport/HoldTransactionReport.aspx','AgentPanel','1','Y','40','AGENT REPORT'
	EXEC proc_AddFunction '20214000','20214000','View'
	EXEC proc_AddFunction '20214010','20214000','ViewBranch'


    
	-- Customer SOA
	EXEC proc_addMenu '20' ,'20210000','Vault Transfer Admin','Menu for: Vault Transfer','/AccountReport/VaultTransfer/Transfer.aspx','','1','Y','20','Cash Management'
	EXEC proc_AddFunction'20210000','20210000','View'

	-- Customer SOA
	EXEC proc_addMenu '20' ,'20220000','Vault Transfer Admin Approve','Menu for: Vault Transfer Admin Approve','/AccountReport/ApproveCashTransfer/List.aspx','','1','Y','20','Cash Management'
	EXEC proc_AddFunction'20220000','20220000','View'
	EXEC proc_AddFunction'20220010','20220000','Approve'

	-- Customer SOA
	EXEC proc_addMenu '20' ,'20230000','Cash Status Report','Menu for: Cash Status Report','/Remit/Transaction/Reports/CashManagement/Manage.aspx','Reports','1','Y','20',''
	EXEC proc_AddFunction'20230000','20230000','View'
	EXEC proc_AddFunction'20220010','20220000','Approve'
	
	-- Customer Details
	EXEC proc_addMenu '20' ,'20293000','Customer Details','Menu for: Customer Details','/Remit/Administration/CustomerSetup/CustomerDetails.aspx','Customer Management','1','Y','20',''
	EXEC proc_AddFunction'20293000','20293000','View'

	-- Customer SOA
	EXEC proc_addMenu '20' ,'21110000','Referral Cash Report','Menu for: Referral Cash Report','/Remit/Transaction/Reports/CashManagement/ManageTransit.aspx','Reports','1','Y','20',''
	EXEC proc_AddFunction'21110000','21110000','View'

	-- Send txn verify for agent Tab control
		EXEC proc_addMenu '40' ,'40201600','Verify Txn','Menu for:Verify Txn','/AgentNew/AgentSend/VerifyTxn.aspx','AgentPanel','5','Y','40','Send Money'
		EXEC proc_AddFunction'40201600','40201600','View Page'
		EXEC proc_AddFunction'40201610','40201600','Approved'
		EXEC proc_AddFunction'40201620','40201600','Reject'
		EXEC proc_AddFunction'40201630','40201600','View Details'
	
	
	-------------- add new function for customersignature 
	--- at customer add page (normal view)
	EXEC proc_AddFunction'20212030','20212000','Signature'
	--- at customer add page (tab view)
	EXEC proc_AddFunction'20202020','20202000','Signature'

	EXEC proc_addMenu '20' ,'20121000','Pay On Behalf','Menu for: Pay On Behalf','/Remit/Transaction/AdminTransaction/Pay/PaySearch.aspx',NULL,'1','Y','20','Transaction'
	
	EXEC proc_addMenu '20' ,'20201600','Txn Verify','Menu For : Verify Txn By Tab Send Page','/Remit/Transaction/TxnVerify/VerifyTxn.aspx','Transaction','1','Y','20',''
	EXEC proc_AddFunction'20201600','20201600','View'
	EXEC proc_AddFunction'20201610','20201600','View Details'
	EXEC proc_AddFunction'20201620','20201600','Approve'
	EXEC proc_AddFunction'20201630','20201600','Reject'
	EXEC proc_AddFunction'20201640','20201600','Modify'

EXEC proc_addMenu '20' ,'20202100','Receivable Ageing','Menu For : Receivable Ageing','/Remit/AgeingReport/Search.aspx','Cash Report','1','Y','20',''
EXEC proc_AddFunction'20202100','20202100','View'



EXEC proc_addMenu '20' ,'20202200','Transit Cash Manage','Menu For : Transit Cash Manage','/AgentNew/Administration/TransitCashManagement/Transfer.aspx',NULL,'1','Y','20','Cash Management'
EXEC proc_AddFunction'20202200','20202200','View'


EXEC proc_addMenu '20' ,'20202300','Cash Collected List','Menu For : Cash Collected List','/AgentNew/Administration/TransitCashManagement/Transfer.aspx','Cash Report','1','Y','20',null
EXEC proc_AddFunction'20202300','20202300','View'


EXEC proc_addMenu '20' ,'20202400','Download Inficare Txn','Menu For : Transit Cash Manage','/Remit/Transaction/Reports/ChashCollected/Search.aspx','Other Services','1','Y','20',null
EXEC proc_AddFunction'20202400','20202400','View'



EXEC proc_addMenu '20' ,'20202500','View Statement','Menu For : View Statement','/AgentNew/Reports/AccountReports/Search.aspx',NULL,'1','Y','20','Cash Management'
EXEC proc_AddFunction'20202500','20202500','View'


EXEC PROC_VAULTTRANSFER @flag = 'DDL-AGENT', @user = 'shikshya'

select * from applicationmenus where functionid = '20202700'


EXEC proc_addMenu '20' ,'20202600','Cash Collected List','Menu For : Cash Collected List','/AgentNew/Reports/CashCollectedReport/Search.aspx',NULL,'1','Y','20','Cash Management'
EXEC proc_AddFunction'20202600','20202600','View'



EXEC proc_addMenu '20' ,'20202700','Change Referral','Menu For : Change Referral','/Remit/Administration/ChangeReferral/Manage.aspx','Administration','1','Y','20',NULL
EXEC proc_AddFunction'20202700','20202700','View'


EXEC proc_addMenu '20' ,'20202800','Cancel Txn','Menu For : Cancel Txn','/Remit/Administration/ChangeReferral/CancelTxn.aspx','Administration','1','Y','20',NULL
EXEC proc_AddFunction'20202800','20202800','View'

EXEC proc_addMenu '20' ,'20202900','Txn Download And Map','Menu For : Txn Download And Map','/AgentNew/Administration/TransactionSync/TxnDownload.aspx',NULL,'1','Y','20','Other Services'
EXEC proc_AddFunction'20202900','20202900','View'


EXEC proc_addMenu '20' ,'20203200','Referral Report','Menu For : Referral Report','/AgentNew/Reports/ReferralReport/Search.aspx',NULL,'1','Y','20','Cash Management'
EXEC proc_AddFunction'20203200','20203200','View'

EXEC proc_addMenu '20' ,'20203300','Status Change List','Menu For : Status Change List','/Remit/Transaction/SuspiciousTxn/TxnList.aspx','Other Services','1','Y','20',null
EXEC proc_AddFunction'20203300','20203300','View'



	--AmendmentReport admin side
	EXEC proc_addMenu '20' ,'20302000','Amendment Report','Menu for: Amendment Report','/RemittanceSystem/RemittanceReports/AmendmentReport/AmendmentReport.aspx','Reports','1','Y','20',''
	EXEC proc_AddFunction'20302000','20302000','View'

		--Customer Details Agent panel
	EXEC proc_addMenu '40' ,'20302100','Customer Details','Menu for:Customer Details','/AgentNew/Customer/CustomerDetails.aspx','AgentPanel','1','Y','40','Other Services'
	EXEC proc_AddFunction'20302100','20302100','View'

		--New customer registration report
	EXEC proc_addMenu '20' ,'20302200','New Customer Registration Report','Menu for: New Customer Registration Report','/RemittanceSystem/RemittanceReports/NewCustomerRegistrationReport/NewCustomerRegistrationReport.aspx','Reports','1','Y','20',''
	EXEC proc_AddFunction'20302200','20302200','View'

		--New customer registration report
	EXEC proc_addMenu '20' ,'20302300','Voucher Upload','Menu for: Voucher Upload','/BillVoucher/CustomerDeposit/Upload.aspx','BILL & VOUCHER','1','Y','20',null
	EXEC proc_AddFunction'20302300','20302300','View'

		--Voucher Entry
	EXEC proc_addMenu '20' ,'20302400','Voucher Entry With Tax','Menu for: Voucher Entry With Tax','/BillVoucher/VoucherEntryWithTax/VoucherEntry.aspx','BILL & VOUCHER','1','Y','20',null
	EXEC proc_AddFunction'20302400','20302400','View'
	EXEC proc_AddFunction'20302410','20302400','Date Changed'

	--Send Transaction Manually
	EXEC proc_addMenu '20' ,'20302500','Send Transaction Manually','Menu for: Send Transaction Manually','/AgentNew/SendTxnManual/SendV2.aspx','AgentPanel','1','Y','20','Send Money'
	EXEC proc_AddFunction'20302500','20302500','View'

		--Send Transaction Manually
	EXEC proc_addMenu '20' ,'20302500','Send Transaction Manually','Menu for: Send Transaction Manually','/AgentNew/SendTxnManual/SendV2.aspx','AgentPanel','1','Y','20','Send Money'
	EXEC proc_AddFunction'20302500','20302500','View'


	--ofac tracker setting
	EXEC proc_addMenu '20' ,'20302600','Ofac Tracker Setting','Menu for: Ofac Tracker Setting','/Remit/OFACManagement/OfacTrackerSetting/OfacTrackerSetting.aspx','OFAC Management','1','Y','20',null
	EXEC proc_AddFunction'20302600','20302600','View'

	--Daily Sending Report
	EXEC proc_addMenu '20' ,'20302700','Daily Sending Report Agent','Menu for: Daily Sending Report Agent','/Remit/Transaction/Reports/DailySendingReportAgent/DailySendingReportAgent.aspx','Reports-Master','1','Y','20',null
	EXEC proc_AddFunction'20302700','20302700','View'

	--Daily Paid Report
	EXEC proc_addMenu '20' ,'20302800','Daily Paid Report Agent','Menu for: Daily Paid Report Agent','/Remit/Transaction/Reports/DailyPaidReportAgent/DailyPaidReportAgent.aspx','Reports-Master','1','Y','20',null
	EXEC proc_AddFunction'20302800','20302800','View'

	--Agent Commission Entry
	EXEC proc_addMenu '20' ,'20302900','Agent Commission Entry','Menu for: Agent Commission Entry','/AccountReport/AgentCommissionEntry/AgentCommissionEntry.aspx','Cash Report','1','Y','20',''
	EXEC proc_AddFunction'20302900','20302900','View'

	--Add Confirm Page Function
	EXEC proc_AddFunction'40101460','40101400','Confirm Page'

		--Customer Registration Report
	EXEC proc_addMenu '40' ,'20303000','Customer Registration Report','Menu for:Customer Registration Report','/AgentNew/Reports/CustomerRegistrationReport/Manage.aspx','AgentPanel','1','Y','40','AGENT REPORT'
	EXEC proc_AddFunction '20303000','20303000','View'

		--Beneficiarty Registration Report
	EXEC proc_addMenu '40' ,'20304000','Beneficiary Registation Report','Menu for:Beneficiary Registation Report','/AgentNew/Reports/NewBeneficiaryRegistrationReport/Manage.aspx','AgentPanel','1','Y','40','AGENT REPORT'
	EXEC proc_AddFunction '20304000','20304000','View'

	--Jp Bank deposit detail Report
	EXEC proc_addMenu '40' ,'20305000','JP Deposit Details','Menu for:JP Deposit Details','/AgentNew/Transaction/JPBankDetails/Manage.aspx','AgentPanel','1','Y','40','Other Services'
	EXEC proc_AddFunction '20305000','20305000','View'
	EXEC proc_AddFunction '20305010','20305000','Map'
	EXEC proc_AddFunction '20305020','20305000','UnMap'

		-- JP Deposit Details
	EXEC proc_addMenu '20' ,'20306000','JP Deposit Details','Menu for: JP Deposit Details','/Remit/Administration/JpBankDetails/Manage.aspx','Deposit API','1','Y','20',''
	EXEC proc_AddFunction '20306000','20306000','View'
	EXEC proc_AddFunction '20306010','20306000','Map'
	EXEC proc_AddFunction '20306020','20306000','UnMap'

		-- Check Referral
	EXEC proc_addMenu '40' ,'20307000','Check Referral','Menu for:Check Referral','/AgentNew/Transaction/CheckReferral/CheckReferral.aspx','AgentPanel','1','Y','40','Other Services'
	EXEC proc_AddFunction '20307000','20307000','View'

	--Customer SOA for agent panel
	EXEC proc_addMenu '40' ,'20308000','Customer SOA','Menu for:Customer SOA','/AgentNew/CustomerSOA/List.aspx','AgentPanel','1','Y','40','Agent Report'
	EXEC proc_AddFunction '20308000','20308000','View'

	
		--New beneficiary registration report (admin)
	EXEC proc_addMenu '20' ,'20309000','Beneficiary Registation Report','Menu for: Beneficiary Registation Report','/RemittanceSystem/RemittanceReports/NewBeneficiaryRegistrationReport/Manage.aspx','Reports','1','Y','20',''
	EXEC proc_AddFunction'20309000','20309000','View'

		--UnPost Transaction List agent
	EXEC proc_addMenu '40' ,'20310000','UnPost Transaction List','Menu for:UnPost Transaction List','/AgentNew/UnpostTransaction/List.aspx','AgentPanel','1','Y','40','Transaction'
	EXEC proc_AddFunction '20310000','20310000','View'

			--UnPost Transaction List admin
	EXEC proc_addMenu '20' ,'20311000','UnPost Transaction List','Menu for: UnPost Transaction List','/Remit/Transaction/Reports/UnPostTransaction/List.aspx','Reports-Master','1','Y','20',null
	EXEC proc_AddFunction'20311000','20311000','View'

			--Rejected Transaction Report (admin)
	EXEC proc_addMenu '20' ,'20312000','Rejected Transaction Report','Menu for: Rejected Transaction Report','/RemittanceSystem/RemittanceReports/RejectTransactionReport/Mange.aspx','Reports','1','Y','20',''
	EXEC proc_AddFunction'20312000','20312000','View'

			--Rejected Transaction Report agent
	EXEC proc_addMenu '40' ,'20313000','Rejected Transaction Report','Menu for:Rejected Transaction Report','/AgentNew/RejectedTransactionList/Manage.aspx','AgentPanel','1','Y','40','Transaction'
	EXEC proc_AddFunction '20313000','20313000','View'
					--Approve Customer agent
	EXEC proc_addMenu '40' ,'20314000','Approve Customer','Menu for:Approve Customer','/AgentNew/Transaction/ApproveCustomer/List.aspx','AgentPanel','1','Y','40','Other Services'
	EXEC proc_AddFunction '20314000','20314000','View'
	EXEC proc_AddFunction '20314010','20314000','Approve'

		--JP Deposit List
	EXEC proc_addMenu '20' ,'20315000','JP Deposit List','Menu for: JP Deposit List','/Remit/Transaction/Reports/JpDepositList/List.aspx','Reports-Master','1','Y','20',null
	EXEC proc_AddFunction'20315000','20315000','View'

	--Add delete and edit function in Approve customer of agent
	EXEC proc_AddFunction'20130040','20130000','Edit Customer'
	EXEC proc_AddFunction'20130050','20130000','Delete Customer'

			--Mitatsu Check
	EXEC proc_addMenu '20' ,'20316000','Mitatsu Check','Menu for: Mitatsu Check','/RemittanceSystem/RemittanceReports/MitatsuCheck/Search.aspx','Reports','1','Y','20',null
	EXEC proc_AddFunction'20316000','20316000','View'

		-- Update Branch Code
	EXEC proc_addMenu '20' ,'20317000','Update Branch Code','Menu for: Update Branch Code','/Remit/Transaction/UpdateBranchCode/Manage.aspx','utilities','1','Y','20',''
	EXEC proc_AddFunction'20317000','20317000','View'	
	EXEC proc_AddFunction'20317010','20317000','Update'
	
	EXEC proc_addMenu '20' ,'20318000','SMS Log','Menu for: SMS Log','/AgentNew/SMSLog/SMSLog.aspx','','1','Y','20','Other Services'
	EXEC proc_AddFunction'20318000','20318000','View'	
	EXEC proc_AddFunction'20318010','20318000','Re-Send SMS'	
	EXEC proc_AddFunction'20318020','20318000','Sync Status'	

	select * from applicationmenus where menuname = 'cancel txn'

	
	EXEC proc_addMenu '20' ,'20320000','Promotion Setup','Menu for: Promotion Setup','/Remit/Transaction/PromotionalCampaign/List.aspx','Administration','1','Y','20',NULL
	EXEC proc_AddFunction'20320000','20320000','View'	
	EXEC proc_AddFunction'20320010','20320000','Add/Edit'	
	EXEC proc_AddFunction'20320020','20320000','Approve'
	
	EXEC proc_addMenu '20' ,'20330000','Liquidity Report','Menu for: Liquidity Report','/AccountReport/LiquidityReport/LiquidityReportSearch.aspx','ACCOUNT REPORT','1','Y','20',NULL
	EXEC proc_AddFunction'20330000','20330000','View'	

select * FROM dbo.applicationmenus WHERE FUNCTIONID='20330000'

select * FROM dbo.applicationfunctions WHERE parentFUNCTIONID='20320000'
select * FROM dbo.applicationmenus WHERE menuname='day book'


--bank deposit start
	EXEC proc_addMenu '20' ,'20122900','Download Ac Deposit','Menu for: Download Ac Deposit','/Remit/ThirdPartyTXN\ACDeposit\gme\List.aspx','Bank Deposit Transaction','17','Y','20','' 
	EXEC proc_AddFunction'20122900','20122900','View'

	EXEC proc_addMenu '20' ,'20122500','Pay Account Deposit','Menu for: Pay Account Deposit','/Remit/Transaction/PostAcDeposit/PaidTransaction/Manage.aspx','Bank Deposit Transaction','13','Y','20',''
	EXEC proc_AddFunction'20122500','20122500','View'

	EXEC proc_addMenu '20' ,'20122600','Post Account Deposit','Menu for: Post Account Deposit','/Remit/Transaction/PostAcDeposit/PostTransaction/Manage.aspx','Bank Deposit Transaction','14','Y','20',''
	EXEC proc_AddFunction'20122600','20122600','View'
--bank deposit end 


update APPLICATIONMENUS set menugroup='Other Services', agentmenugroup=null, linkpage='/Remit/Transaction/SuspiciousTxn/TxnList.aspx' WHERE FUNCTIONID='20203300'






