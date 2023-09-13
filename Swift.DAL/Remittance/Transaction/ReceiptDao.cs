using System;
using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Transaction
{
    public class ReceiptDao : RemittanceDao
    {
        public DbResult SearchCancleTxn(string user, string controlNo, string agentId)
        {
            string sql = "EXEC proc_cancelTran @flag = 'checkCancleTxn'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agentId = " + FilterString(agentId);

            return ParseDbResult(sql);
        }
        public DbResult SearchSentTxn(string user, string controlNo)
        {
            string sql = "EXEC proc_sendReceipt @flag = 'c'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseDbResult(sql);
        }

        public DbResult SearchSentTxnInt(string user, string controlNo,string tranId)
        {
            string sql = "EXEC proc_sendReceipt @flag = 'checkInt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @tranId = " + FilterString(tranId);
            return ParseDbResult(sql);
        }

        public DataSet GetSendReceipt(string controlNo, string user, string msgType)
        {
            string sql = "EXEC proc_sendReceipt @flag = 'receipt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @msgType = " + FilterString(msgType);

            return ExecuteDataset(sql);
        }

        public DataTable GetMultipleReceiptData(string user, string tranId)
        {
            string sql = "EXEC proc_sendIntlReceipt_New @flag = 'receipt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);

            return ExecuteDataTable(sql);
        }

        public DbResult SearchSentIntlTxn(string user, string controlNo)
        {
            string sql = "EXEC proc_sendIntlReceipt @flag = 'c'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseDbResult(sql);
        }

        public DataSet GetSendIntlReceipt(string controlNo, string user, string msgType)
        {
            string sql = "EXEC proc_sendIntlReceipt @flag = 'receipt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @msgType = " + FilterString(msgType);

            return ExecuteDataset(sql);
        }

        public DataRow GetTxnDataForSMS(string user, string controlNo)
        {
            string sql = "EXEC PROC_SMS_LOG @flag = 'SMS'";
            sql += ", @user = " + FilterString(user);
            sql += ", @CONTROL_NO = " + FilterString(controlNo);

            return ExecuteDataRow(sql);
        }

        public void LogSMS(string controlNo, string user, string msgBody, string mobileNumber, string processId, string mtId, string isSuccess)
        {
            string sql = "EXEC PROC_SMS_LOG @FLAG = 'I'";
            sql += ", @USER = " + FilterString(user);
            sql += ", @CONTROL_NO = " + FilterString(controlNo);
            sql += ", @MSG_BODY = " + FilterString(msgBody);
            sql += ", @MOBILE_NUMBER = " + FilterString(mobileNumber);
            sql += ", @PROCESS_ID = " + FilterString(processId);
            sql += ", @MT_ID = " + FilterString(mtId);
            sql += ", @IS_SUCCESS = " + FilterString(isSuccess);

            GetSingleResult(sql);
        }

        public void LogSMSSyncStatus(string user, string rowId, string status, string msg)
        {
            string sql = "EXEC PROC_SMS_LOG @FLAG = 'U'";
            sql += ", @USER = " + FilterString(user);
            sql += ", @ROW_ID = " + FilterString(rowId);
            sql += ", @STATUS = " + FilterString(status);
            sql += ", @STATUS_DETAIL = " + FilterString(msg);

            GetSingleResult(sql);
        }

        public DbResult SearchPaidTxn(string user, string controlNo)
        {
            string sql = "EXEC proc_payReceipt @flag = 'c'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseDbResult(sql);
        }

        public DataSet GetPayReceipt(string controlNo, string user, string msgType)         //API
        {
            string sql = "EXEC proc_payReceipt @flag = 'receipt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @msgType = " + FilterString(msgType);

            return ExecuteDataset(sql);
        }

        public DbResult SearchPaidIntlTxn(string user, string controlNo)
        {
            string sql = "EXEC proc_payIntlReceipt @flag = 'c'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseDbResult(sql);
        }

        public DataSet GetPayIntlReceipt(string controlNo, string user, string msgType)         //API
        {
            string sql = "EXEC proc_payIntlReceipt @flag = 'receiptLocal'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @msgType = " + FilterString(msgType);

            return ExecuteDataset(sql);
        }

        public DataSet GetPayReceiptLocal(string controlNo, string user, string msgType)
        {
            string sql = "EXEC proc_payReceipt @flag = 'receiptLocal'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @msgType = " + FilterString(msgType);

            return ExecuteDataset(sql);
        }

        public DataRow GetInvoiceMode(string user)
        {
            string sql = "EXEC proc_agentBusinessFunction @flag = 'inv'";
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;

            return ds.Tables[0].Rows[0];
        }

        public DbResult TranViewLog(
                         string user
                        , string tranId
                        , string controlNo
                        , string remarks
                        , string tranViewType
                    )
        {
            string sql = "EXEC proc_tranViewHistory";
            sql += "  @flag = 'i1'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @remarks = " + FilterString(remarks);
            sql += ", @tranViewType = " + FilterString(tranViewType);

            return ParseDbResult(sql);
        }

        public DataSet GetSendReceiptFeeCollection(string controlNo, string user, string msgType)
        {
            string sql = "EXEC proc_sendReceipt @flag = 'receiptFeeCollection'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @msgType = " + FilterString(msgType);

            return ExecuteDataset(sql);
        }
    }
}