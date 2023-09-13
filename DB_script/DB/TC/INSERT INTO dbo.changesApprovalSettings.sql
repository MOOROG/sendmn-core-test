INSERT INTO dbo.changesApprovalSettings
        ( functionId ,
          mainTable ,
          modTable ,
          pKfield ,
          spName ,
          pageName
        )
VALUES  ( 20195000 , -- functionId - int
          'CUSTOMER_REFUND' , -- mainTable - varchar(255)
          'CUSTOMER_REFUNDMOD' , -- modTable - varchar(255)
          'rowId' , -- pKfield - varchar(255)
          'proc_customerRefund' , -- spName - varchar(255)
          'Customer Refund'  -- pageName - varchar(255)
        )

--FOR cash AND vault

INSERT INTO dbo.changesApprovalSettings
        ( functionId ,
          mainTable ,
          modTable ,
          pKfield ,
          spName ,
          pageName
        )
VALUES  ( 20178030 , -- functionId - int
          'CASH_HOLD_LIMIT_BRANCH_WISE' , -- mainTable - varchar(255)
          'CASH_HOLD_LIMIT_BRANCH_WISE_MOD' , -- modTable - varchar(255)
          'cashHoldLimitId' , -- pKfield - varchar(255)
          'PROC_CASHANDVAULT' , -- spName - varchar(255)
          'Cash And Vault'  -- pageName - varchar(255)
        )

--for customer Data edit Approve
INSERT INTO dbo.changesApprovalSettings
        ( functionId ,
          mainTable ,
          modTable ,
          pKfield ,
          spName ,
          pageName
        )
VALUES  ( 20130020 , -- functionId - int
          'customerMaster' , -- mainTable - varchar(255)
          'customerMasterEditedDataMod' , -- modTable - varchar(255)
          'customerId' , -- pKfield - varchar(255)
          'proc_online_approve_Customer' , -- spName - varchar(255)
          'Customer Data Edit Approve'  -- pageName - varchar(255)
        )
--for customer Data edit Approve
INSERT INTO dbo.changesApprovalSettings
        ( functionId ,
          mainTable ,
          modTable ,
          pKfield ,
          spName ,
          pageName
        )
VALUES  ( 20220010 , -- functionId - int
          'BRANCH_CASH_IN_OUT' , -- mainTable - varchar(255)
          'BRANCH_CASH_IN_OUT_MOD' , -- modTable - varchar(255)
          'rowId' , -- pKfield - varchar(255)
          'PROC_VAULTTRANSFER' , -- spName - varchar(255)
          'Transfer from vault Approve'  -- pageName - varchar(255)
        )

