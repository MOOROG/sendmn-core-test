
ALTER PROC proc_notification
	@user VARCHAR(50)
	,@portal VARCHAR(20) = NULL
	,@branch_id INT = NULL
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN
		IF  @portal = 'AGENT'
		BEGIN
			SELECT COUNT('A') AS [count] , CAST(COUNT('A') AS VARCHAR) + 'Vault Deposit Request(s) pending' AS [msg],
			  'Approve Deposit Request(s)' AS Msg1,'/AgentNew/vaulttransfer/approvetransfertovaultlist.aspx' AS [link] 
			FROM BRANCH_CASH_IN_OUT (NOLOCK) 
			WHERE branchId = @branch_id
			AND HEAD = 'Transfer To Vault'
			AND MODE = 'C'
			AND createdBy <> @user
			AND APPROVEDBY IS NULL

			UNION ALL

			SELECT COUNT('A') AS [count] , CAST(COUNT('A') AS VARCHAR) + 'Vault Deposit Request(s) pending' AS [msg],
			  'Approve Deposit Request(s)' AS Msg1,'/AgentNew/ApproveCashTransfer/List.aspx' AS [link] 
			FROM BRANCH_CASH_IN_OUT B(NOLOCK) 
			INNER JOIN FASTMONEYPRO_ACCOUNT.DBO.AC_MASTER AM(NOLOCK) ON AM.ACCT_NUM = B.TOACC
			WHERE AM.AGENT_ID = @branch_id
			AND AM.ACCT_RPT_CODE = 'BVA'
			AND HEAD = 'Transfer From Vault'
			AND MODE = 'CV'
			AND APPROVEDBY IS NULL
			RETURN
		END
		IF (SELECT dbo.FNAHasRight(@User,'90100000') )='N'
			RETURN
		DECLARE @NotificationList table([count] INT,Msg VARCHAR(100), Msg1 VARCHAR(50),Link VARCHAR(100)) 

		INSERT INTO @NotificationList
        SELECT COUNT('A') AS [count] , CAST(COUNT('A') AS VARCHAR) + ' Modification Request(s) pending' AS [msg],
			  'Approve Modify Txn(s)' AS Msg1,'/Remit/Transaction/ApproveModification/List.aspx' AS [link]
        FROM    tranModifyLog TL WITH ( NOLOCK )
        WHERE   TL.status = 'Request'
        UNION ALL
        SELECT  COUNT('A') AS [count] ,CAST(COUNT('A') AS VARCHAR) + ' Cancel Request(s) pending' AS [msg], 'Approve Cancel Txn(s)' AS Msg1,
                '/Remit/Transaction/Cancel/ApproveReqUnapprovedTxn.aspx' AS [link]
        FROM    vwRemitTran trn WITH ( NOLOCK )
                INNER JOIN tranCancelrequest A WITH ( NOLOCK ) ON A.controlNo = trn.controlNo
        WHERE   trn.tranStatus = 'CancelRequest'
                AND A.cancelStatus = 'CancelRequest'
        UNION ALL
        SELECT  COUNT('A') AS [count] ,
                CAST(COUNT('A') AS VARCHAR) + ' Blocked Transaction(s)' AS [msg], 'Approve Blocked Txn(s)' AS Msg1,
                '/Remit/Transaction/BlockTransaction/List.aspx' AS [link]
        FROM    remitTran trn WITH ( NOLOCK )
        WHERE   trn.tranStatus = 'Block'
        UNION ALL
        SELECT  COUNT('A') AS [count] ,CAST(COUNT('A') AS VARCHAR) + ' Locked Transaction(s)' AS [msg], 'Release Locked Txn(s)' AS Msg1,
                '/Remit/Transaction/UnlockTransaction/List.aspx' AS [link]
        FROM    remitTran trn WITH ( NOLOCK )
        WHERE   trn.tranStatus = 'Lock'
              --  AND trn.tranType = 'D'
        UNION ALL
        SELECT  COUNT('A') AS [count] ,
                CAST(COUNT('A') AS VARCHAR) + ' Txn(s) Pending For Approval' AS [msg], 'Approve Txn(s)' AS Msg1,
                '/Remit/Transaction/Approve/Manage.aspx' AS [link]
        FROM    dbo.remitTran
        WHERE   tranStatus = 'Hold'
                AND payStatus = 'Unpaid'
                AND approvedBy IS NULL
              --  AND tranType = 'D'
        UNION ALL
        SELECT  COUNT('A') AS [count] ,
                CAST(COUNT('A') AS VARCHAR) + ' Txn(s) Pending For Approval(Int''l)' AS [msg], 'Approve International Txn(s)' AS Msg1,
                '/Remit/Transaction/ApproveTxn/holdTxnList.aspx' AS [link]
        FROM    dbo.remitTranTemp
        WHERE   tranStatus IN ( 'Hold')
                AND payStatus = 'Unpaid'
                AND approvedBy IS NULL
                AND tranType = 'I'
		UNION ALL
		 SELECT  COUNT('A') AS [count] ,
                CAST(COUNT('A') AS VARCHAR) + ' &nbsp; Online  Txn(s) Pending For Approval(Int''l)' AS [msg], 'Approve International Txn(s)' AS Msg1,
                '/Remit/Transaction/ApproveTxn/holdOnlineTxnList.aspx?country=JAPAN' AS [link]
        FROM    dbo.remitTranTemp
        WHERE   tranStatus IN ( 'Hold', 'Compliance Hold', 'OFAC Hold', 'OFAC/Compliance Hold' )
                AND payStatus = 'Unpaid'
                AND approvedBy IS NULL
				AND ISNULL(sRouteId,'0')='0'
                AND (tranType = 'O' AND isOnlineTxn='Y');

		SELECT * FROM @NotificationList WHERE [count] > 0
    END;



