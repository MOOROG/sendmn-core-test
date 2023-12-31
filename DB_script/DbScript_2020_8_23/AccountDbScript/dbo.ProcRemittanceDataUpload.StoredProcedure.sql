USE [SendMnPro_Account]
GO
/****** Object:  StoredProcedure [dbo].[ProcRemittanceDataUpload]    Script Date: 8/23/2020 5:46:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[ProcRemittanceDataUpload]
    @xml XML = NULL ,
    @user NVARCHAR(35) ,
    @flag VARCHAR(10)
AS
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN
        IF @flag = 'temp'
            BEGIN TRY 
                BEGIN TRANSACTION;
                SELECT  TRN_REF_NO = p.value('@TRN_REF_NO', 'varchar(35)') ,
                        S_AGENT = p.value('@S_AGENT', 'varchar(35)') ,
                        S_BRANCH = p.value('@S_BRANCH', 'varchar(35)') ,
                        P_AGENT = p.value('@P_AGENT', 'varchar(35)') ,
                        P_BRANCH = p.value('@P_BRANCH', 'varchar(35)') ,
                        S_CURR = p.value('@S_CURR', 'varchar(35)') ,
                        S_AMT = p.value('@S_AMT', 'varchar(15)') ,
                        TRN_TYPE = p.value('@TRN_TYPE', 'varchar(10)') ,
                        TRN_STATUS = p.value('@TRN_STATUS', 'varchar(35)') ,
                        PAY_STATUS = p.value('@PAY_STATUS', 'varchar(35)') ,
                        SC_TOTAL = p.value('@SC_TOTAL', 'varchar(35)') ,
                        SC_HO = p.value('@SC_HO', 'varchar(35)') ,
                        SC_S_AGENT = p.value('@SC_S_AGENTSC_S_AGENT',
                                             'varchar(35)') ,
                        SC_P_AGENT = p.value('@SC_P_AGENT', 'varchar(35)') ,
                        USD_AMT = p.value('@USD_AMT', 'varchar(35)') ,
                        P_CURR = p.value('@P_CURR', 'varchar(35)') ,
                        NPR_USD_RATE = p.value('@NPR_USD_RATE', 'varchar(35)') ,
                        EX_USD = p.value('@EX_USD', 'varchar(35)') ,
                        EX_FLC = p.value('@EX_FLC', 'varchar(35)') ,
                        P_AMT = p.value('@P_AMT', 'varchar(35)') ,
                        TRN_DATE = p.value('@TRN_DATE', 'varchar(35)') ,
                        PAID_DATE = p.value('@PAID_DATE', 'varchar(35)') ,
                        CANCEL_DATE = p.value('@CANCEL_DATE', 'varchar(35)') ,
                        SENDER_NAME = p.value('@SENDER_NAME', 'varchar(35)') ,
                        RECEIVER_NAME = p.value('@RECEIVER_NAME',
                                                'varchar(35)') ,
                        SETTLEMENT_RATE = p.value('@SETTLEMENT_RATE',
                                                  'varchar(35)') ,
                        APPROVE_BY = p.value('@APPROVE_BY', 'varchar(35)') ,
                        S_COUNTRY = p.value('@S_COUNTRY', 'varchar(35)') ,
                        TRANNO = p.value('@TRANNO', 'varchar(35)') ,
                        TRANIDNEW = p.value('@TRANIDNEW', 'varchar(35)')
                INTO    #temp
                FROM    @xml.nodes('/root/row') AS tmp ( p );
                
				DELETE  t1
                FROM    #temp t1
                        INNER JOIN dbo.REMIT_TRN_MASTER t2 ON t1.TRN_REF_NO = t2.TRN_REF_NO
                WHERE   t1.TRN_REF_NO = t2.TRN_REF_NO;
                
                DECLARE @txnCount INT; 
                DECLARE @pAmtCount MONEY;
                DECLARE @sAmtCount MONEY;
                SELECT  @txnCount = COUNT(*)
                FROM    #temp;
                
				INSERT  INTO dbo.temp_remit_tran
                        ( TRN_REF_NO ,
                          S_AGENT ,
                          S_BRANCH ,
                          P_AGENT ,
                          P_BRANCH ,
                          S_CURR ,
                          S_AMT ,
                          TRN_TYPE ,
                          TRN_STATUS ,
                          PAY_STATUS ,
                          SC_TOTAL ,
                          SC_HO ,
                          SC_S_AGENT ,
                          SC_P_AGENT ,
                          USD_AMT ,
                          P_CURR ,
                          NPR_USD_RATE ,
                          EX_USD ,
                          EX_FLC ,
                          P_AMT ,
                          TRN_DATE ,
                          PAID_DATE ,
                          CANCEL_DATE ,
                          SENDER_NAME ,
                          RECEIVER_NAME ,
                          SETTLEMENT_RATE ,
                          approve_by ,
                          S_COUNTRY ,
                          tranno ,
                          TranIdNew
		                )
                        SELECT  TRN_REF_NO ,
                                S_AGENT ,
                                S_BRANCH ,
                                P_AGENT ,
                                P_BRANCH ,
                                S_CURR ,
                                S_AMT ,
                                TRN_TYPE ,
                                TRN_STATUS ,
                                PAY_STATUS ,
                                SC_TOTAL ,
                                SC_HO ,
                                SC_S_AGENT ,
                                SC_P_AGENT ,
                                USD_AMT ,
                                P_CURR ,
                                CAST(( CASE WHEN NPR_USD_RATE = 'NULL'
                                            THEN '0'
                                            ELSE NPR_USD_RATE
                                       END ) AS FLOAT) ,
                                CAST(( CASE WHEN EX_USD = 'NULL' THEN '0'
                                            ELSE EX_USD
                                       END ) AS FLOAT) ,
                                CAST(( CASE WHEN EX_FLC = 'NULL' THEN '0'
                                            ELSE EX_FLC
                                       END ) AS FLOAT) ,
                                P_AMT ,
                                CAST(( CASE WHEN TRN_DATE = 'NULL' THEN NULL
                                            ELSE TRN_DATE
                                       END ) AS DATETIME) ,
								CAST(( CASE WHEN PAID_DATE = 'NULL' THEN NULL
                                            ELSE PAID_DATE
                                       END ) AS DATETIME) ,
								CAST(( CASE WHEN CANCEL_DATE = 'NULL' THEN NULL
                                            ELSE CANCEL_DATE
                                       END ) AS DATETIME) ,
                                SENDER_NAME ,
                                RECEIVER_NAME ,
                                CAST(( CASE WHEN SETTLEMENT_RATE = 'NULL'
                                            THEN '0'
                                            ELSE SETTLEMENT_RATE
                                       END ) AS FLOAT) ,
                                APPROVE_BY ,
                                S_COUNTRY ,
                                TRANNO ,
                                TRANIDNEW
                        FROM    #temp;	
                
				SELECT  @pAmtCount = SUM(ALL S_AMT) ,
                        @sAmtCount = SUM(ALL P_AMT)
                FROM    temp_remit_tran;
                
				IF ISNULL(@txnCount, 0) = 0
				BEGIN
				    SELECT  1 code,'Record not found/File already uploaded.' AS msg
				END
				ELSE
				SELECT  0 code,'success' msg ,@pAmtCount AS P_AMT ,
                        @sAmtCount AS S_AMT ,
                        @txnCount AS [COUNT];
                COMMIT TRAN;
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN;
                SELECT  'ERROR' AS msg;
            END CATCH;
        ELSE
            IF @flag = 'confirm'
                BEGIN TRY 
                BEGIN TRANSACTION;

                    SELECT  @txnCount = COUNT(*)
                    FROM    temp_remit_tran;

                    DECLARE @logId INT;

                    INSERT  INTO RemitDataLog
                            ( createdBy ,
                              createdDate ,
                              moduleName ,
                              txnCount 
                            )
                            SELECT  @user ,
                                    GETDATE() ,
                                    'REMIT_TRN_MASTER' ,
                                    @txnCount; 

                    SET @logId = @@IDENTITY;

                    INSERT  INTO dbo.REMIT_TRN_MASTER
                            ( TRN_REF_NO ,
                              S_AGENT ,
                              S_BRANCH ,
                              P_AGENT ,
                              P_BRANCH ,
                              S_CURR ,
                              S_AMT ,
                              TRN_TYPE ,
                              TRN_STATUS ,
                              PAY_STATUS ,
                              SC_TOTAL ,
                              SC_HO ,
                              SC_S_AGENT ,
                              SC_P_AGENT ,
                              USD_AMT ,
                              P_CURR ,
                              NPR_USD_RATE ,
                              EX_USD ,
                              EX_FLC ,
                              P_AMT ,
                              TRN_DATE ,
                              PAID_DATE ,
                              CANCEL_DATE ,
                              SENDER_NAME ,
                              RECEIVER_NAME ,
                              SETTLEMENT_RATE ,
                              approve_by ,
                              S_COUNTRY ,
                              tranno ,
                              TranIdNew ,
                              logId
		                    )
                            SELECT  TRN_REF_NO ,
                                    S_AGENT ,
                                    S_BRANCH ,
                                    P_AGENT ,
                                    P_BRANCH ,
                                    S_CURR ,
                                    S_AMT ,
                                    TRN_TYPE ,
                                    TRN_STATUS ,
                                    PAY_STATUS ,
                                    SC_TOTAL ,
                                    SC_HO ,
                                    SC_S_AGENT ,
                                    SC_P_AGENT ,
                                    USD_AMT ,
                                    P_CURR ,
                                    NPR_USD_RATE ,
                                    EX_USD ,
                                    EX_FLC ,
                                    P_AMT ,
                                    TRN_DATE ,
                                    PAID_DATE ,
                                    CANCEL_DATE ,
                                    SENDER_NAME ,
                                    RECEIVER_NAME ,
                                    SETTLEMENT_RATE ,
                                    approve_by ,
                                    S_COUNTRY ,
                                    tranno ,
                                    TranIdNew ,
                                    @logId
                            FROM    temp_remit_tran;

                    EXEC dbo.proc_errorHandler @errorCode = '0', -- varchar(10)
                        @msg = 'Transaction uploaded successfully', -- varchar(max)
                        @id = ''; -- varchar(max)
                    TRUNCATE TABLE temp_remit_tran;
                COMMIT TRAN;
            END TRY
            BEGIN CATCH
                ROLLBACK TRAN;
                EXEC dbo.proc_errorHandler @errorCode = '1', -- varchar(10)
                @msg = 'Error uploading data', -- varchar(max)
                @id = ''; -- varchar(max)
            END CATCH;
    END;    
	

GO
