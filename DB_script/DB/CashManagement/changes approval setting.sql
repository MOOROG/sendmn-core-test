

--FOR cash AND vault
DELETE FROM dbo.changesApprovalSettings WHERE functionId = 20178030
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

INSERT INTO dbo.changesApprovalSettings
        ( functionId ,
          mainTable ,
          modTable ,
		  pKfield ,
          spName ,
          pageName
        )
VALUES  ( 20178040 , -- functionId - int
          'CASH_HOLD_LIMIT_USER_WISE' , -- mainTable - varchar(255)
          'CASH_HOLD_LIMIT_USER_WISE_MOD' , -- modTable - varchar(255)
          'cashHoldLimitId' , -- pKfield - varchar(255)
          'PROC_CASHANDVAULT_USERWISE' , -- spName - varchar(255)
          'Cash And Vault'  -- pageName - varchar(255)
        )


INSERT INTO dbo.changesApprovalSettings
        ( functionId ,
          mainTable ,
          modTable ,
          pKfield ,
          spName ,
          pageName
        )
VALUES  ( 20198010 , -- functionId - int
          'BRANCH_CASH_IN_OUT' , -- mainTable - varchar(255)
          'BRANCH_CASH_IN_OUT_MOD' , -- modTable - varchar(255)
          'rowId' , -- pKfield - varchar(255)
          'PROC_VAULTTRANSFER' , -- spName - varchar(255)
          'ApproveVaultTransfer'  -- pageName - varchar(255)
        )

		







