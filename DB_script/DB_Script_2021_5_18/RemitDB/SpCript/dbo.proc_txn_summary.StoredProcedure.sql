USE [SendMnPro_Remit]
GO
/****** Object:  StoredProcedure [dbo].[proc_txn_summary]    Script Date: 5/18/2021 5:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[proc_txn_summary]
	@flag VARCHAR(20)
	,@startDate DATE = NULL
	,@endDate DATE = NULL
	,@agentId INT = NULL
	,@rptType CHAR(1) = NULL

AS
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN
    IF @flag = 'send'
	BEGIN
	    IF @rptType = 's'
		BEGIN
            SELECT  A.agent_name [AGENT NAME] ,Y.USD_AMT [TOTAL USD],REMAIN_AMT [REMAINING USD] ,WEIGHTEDRATE ,cummNPR [CUMM NPR] ,TRAN_DATE
            FROM    SendTransactionSummary S ( NOLOCK )
                    INNER JOIN ( SELECT S_AGENT ,MAX(TRAN_ID) TRAN_ID
                                 FROM   SendTransactionSummary(NOLOCK)
								 WHERE S_AGENT = ISNULL(@agentId, S_AGENT)
                                 GROUP BY S_AGENT
                               ) X ON S.TRAN_ID = X.TRAN_ID
                    INNER JOIN agenttable A ( NOLOCK ) ON S.S_AGENT = A.map_code
                    INNER JOIN ( SELECT S_AGENT ,SUM(USD_AMT) USD_AMT
                                 FROM   SendTransactionSummary(NOLOCK)
                                 GROUP BY S_AGENT
                               ) Y ON Y.S_AGENT = S.S_AGENT

			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'Sending Agent' head, @agentId value 

			SELECT title = 'Send Transaction Summary'
		END
		IF @rptType = 'd'
		BEGIN
            SELECT  A.AGENT_NAME ,
                    S.USD_AMT ,
                    S.USD_RATE ,
                    S.NPR_AMT ,
                    S.TRAN_DATE ,
                    S.REMAIN_AMT [REMAINING USD],
                    S.WEIGHTEDRATE ,
                    S.CUMMNPR
            FROM    SendTransactionSummary S ( NOLOCK )
                    INNER JOIN agenttable A ( NOLOCK ) ON S.S_AGENT = A.map_code
            WHERE   S.TRAN_DATE BETWEEN @startDate AND CAST(@endDate AS VARCHAR) + ' 23:59:59';

			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'Start Date' head, @startDate value UNION ALL
			SELECT 'End Date' head, @endDate value 

			SELECT title = 'Send Transaction Detail'
		END
	END
	IF @flag = 'fund'
	BEGIN
	    IF @rptType = 's'
		BEGIN
            SELECT  A.AGENT_NAME ,BANK = M.acct_name + ' ' + M.acct_num ,Y.USD_AMT ,REMAIN_AMT_EXCHANGE [REMAINING USD] ,WEIGHTEDRATE ,CUMM_NPR ,TRAN_DATE
            FROM    FundTransactionSummary S ( NOLOCK )
                    INNER JOIN ( SELECT S_AGENT ,MAX(TRAN_ID) TRAN_ID
                                 FROM   FundTransactionSummary(NOLOCK)
								 WHERE S_AGENT = ISNULL(@agentId, S_AGENT)
                                 GROUP BY S_AGENT
                               ) X ON S.TRAN_ID = X.TRAN_ID
                    INNER JOIN agenttable A ( NOLOCK ) ON A.map_code = X.S_AGENT
                    INNER JOIN ac_master M ( NOLOCK ) ON M.acct_num = S.R_BANK
                    INNER JOIN ( SELECT S_AGENT ,
                                        SUM(USD_AMT) USD_AMT
                                 FROM   FundTransactionSummary(NOLOCK)
                                 GROUP BY S_AGENT
                               ) Y ON Y.S_AGENT = S.S_AGENT;

			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'Sending Agent' head, @agentId value 

			SELECT title = 'Fund Transaction Summary'
		END
		IF @rptType = 'd'
		BEGIN
            SELECT  A.AGENT_NAME ,
                    BANK = M.acct_name + ' ' + M.acct_num ,
                    S.USD_AMT ,
                    S.USD_RATE ,
                    S.NPR_AMT ,
                    S.TRAN_DATE ,
                    S.REMAIN_AMT_EXCHANGE [REMAINING USD],
                    S.WEIGHTEDRATE ,
                    S.CUMM_NPR
            FROM    FundTransactionSummary S ( NOLOCK )
                    INNER JOIN agenttable A ( NOLOCK ) ON S.S_AGENT = A.map_code
                    INNER JOIN ac_master M ( NOLOCK ) ON M.acct_num = S.R_BANK
            WHERE   S.TRAN_DATE BETWEEN @startDate AND CAST(@endDate AS VARCHAR) + ' 23:59:59';

			EXEC proc_errorHandler '0', 'Report has been prepared successfully.', NULL

			SELECT 'Start Date' head, @startDate value UNION ALL
			SELECT 'End Date' head, @endDate value 

			SELECT title = 'Fund Transaction Detail'
		END
	END
END
GO
