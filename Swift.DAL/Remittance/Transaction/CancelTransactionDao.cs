using System.Data;
using Swift.DAL.SwiftDAL;
using Swift.DAL.Common;

namespace Swift.DAL.BL.Remit.Transaction
{
    public class CancelTransactionDao : RemittanceDao
    {
        public DataSet SelectTransaction(string controlNo, string user)
        {
            string sql = "EXEC proc_cancelTran @flag = 'details'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            DataSet ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataSet SelectTransactionAgent(string controlNo, string user)
        {
            string sql = "EXEC proc_cancelTran @flag = 'detailsAgent'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DataSet SelectTransactionAgentInt(string user, string controlNo, string tranId, string agentCancel)
        {
            //string sql = (agentCancel == "Y" ? "EXEC proc_cancelTranInt @flag = 'searchAgent'" : "EXEC proc_cancelTranRsp @flag = 'searchAgent'");
            string sql = ("EXEC proc_cancelTranInt @flag = 'searchAgent'");

            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @tranId = " + FilterString(tranId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

        public DbResult SaveCancelRequest(string user, string controlNo, string cancelReason, string agentCancel)
        {
            //string sql = (agentCancel == "Y" ? "EXEC proc_cancelTran @flag = 'request'" : "EXEC proc_cancelTranRsp @flag = 'request'");
            string sql = ("EXEC proc_cancelTranInt @flag = 'request'");
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @cancelReason = " + FilterString(cancelReason);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult ApproveCancelRequest(string user, string controlNo, string approveRemarks, string scRefund, string agentCancel)
        {
            //string sql = (agentCancel == "Y" ? "EXEC proc_cancelTran @flag = 'approve'" : "EXEC proc_cancelTranRsp @flag = 'approve'");
            string sql = ("EXEC proc_cancelTranInt @flag = 'approve'");

            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @cancelReason = " + FilterString(approveRemarks);
            sql += ", @scRefund = " + FilterString(scRefund);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow DisplayRequest(string user, string controlNo)
        {
            string sql = "EXEC proc_cancelTran @flag = 'displayRequest' ";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult RejectCancelRequestV2(string user, string controlNo)
        {
            var sql = "EXEC proc_cancelTranAPI_v2 @flag = 'cancelReject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult CancelLocal(string user, string controlNo, string cancelReason, string refund)
        {
            string sql = "EXEC proc_cancelTran";
            sql += "  @flag = 'cancel'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @cancelReason = " + FilterString(cancelReason);
            sql += ", @refund = " + FilterString(refund);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult RejectCancelRequestInt(string user, string controlNo, string approveRemarks, string scRefund, string agentCancel)
        {
            //string sql = (agentCancel == "Y" ? "EXEC proc_cancelTran @flag = 'reject'" : "EXEC proc_cancelTranRsp @flag = 'reject'");
            string sql = ("EXEC proc_cancelTranInt @flag = 'reject'");
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @cancelReason = " + FilterString(approveRemarks);
            sql += ", @scRefund = " + FilterString(scRefund);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult CancelRequest(string user, string controlNo, string cancelReason)
        {
            string sql = "EXEC proc_cancelTran @flag = 'cancelRequest'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @cancelReason = " + FilterString(cancelReason);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult CancelRequestWithRealTime(string user, string controlNo, string cancelReason, string cancelId)
        {
            string sql = "EXEC proc_cancelTran @flag = 'cancelRequest'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @cancelReason = " + FilterString(cancelReason);
            sql += ", @cancelId = " + FilterString(cancelId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult ErrorPayRequest(string user, string controlNo, string cancelReason)
        {
            string sql = "EXEC proc_cancelTran @flag = 'cancelRequest'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @cancelReason = " + FilterString(cancelReason);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
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
            sql += "  @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @remarks = " + FilterString(remarks);
            sql += ", @tranViewType = " + FilterString(tranViewType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow LoadReceipt(string user, string tranId)
        {
            var sql = "EXEC proc_cancelTran @flag = 'cancelReceipt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow LoadReceiptInt(string user, string controlNo)
        {
            var sql = "EXEC proc_cancelTranInt @flag = 'cancelReceipt'";
            sql += ", @user = " + FilterString(user);
            sql += ", @controlNo = " + FilterString(controlNo);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        #region AUTO REFUND METHOD LOG

        public DbResult SendAutoRefund(KJAutoRefundModel kj)
        {
            var sql = "EXEC PROC_KJAUTOREFUND @flag = " + FilterString(kj.flag);
            sql += ", @pCustomerId = " + FilterString(kj.customerId);
            sql += ", @pCustomerSummary = " + FilterString(kj.customerSummary);
            sql += ", @pAmount = " + FilterString(kj.amount);
            sql += ", @pAction = " + FilterString(kj.action);
            sql += ", @pActionBy = " + FilterString(kj.actionBy);
            sql += ", @pRowId = " + FilterString(kj.rowId);
            sql += ", @pBankCode = " + FilterString(kj.bankCode);
            sql += ", @pBankAccountNo = " + FilterString(kj.bankAccountNo);

            return ParseDbResult(sql);
        }

        #endregion AUTO REFUND METHOD LOG
    }
}