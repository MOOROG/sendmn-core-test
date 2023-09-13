using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Reconciliation
{
    public class ReconciliationDao : SwiftDao
    {
        public DbResult Update(string user, string rowId, string agentId, string voucherType, string fromDate, string toDate, string boxNo)
        {
            string sql = "EXEC proc_reconciliationVoucher";
            sql += "  @flag = " + (rowId == "0" || rowId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @vouType = " + FilterString(voucherType);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @boxNo = " + FilterString(boxNo);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string rowId)
        {
            string sql = "EXEC proc_reconciliationVoucher";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet LoadDataForReconciliaton(string user,string agentId,string fromDate, string toDate,
                string boxNo, string fileNo, string vouType, string status, string pageNumber, string pageSize, string controlNo, string tranAmt
           , string senderName, string receiverName)
        {
            var sql = "EXEC proc_reconciliationVoucher @flag='recon'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @boxNo = " + FilterString(boxNo);
            sql += ", @fileNo = " + FilterString(fileNo);
            sql += ", @vouType = " + FilterString(vouType);
            sql += ", @status   =" + FilterString(status);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize   =" + FilterString(pageSize);
            sql += ", @controlNo   =" + FilterString(controlNo);
            sql += ", @tranAmt    =" + FilterString(tranAmt);
            sql += ", @senderName   =" + FilterString(senderName);
            sql += ", @receiverName   =" + FilterString(receiverName);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }

       
        public DataRow SelectByIdRec(string user, string rowId)
        {
            string sql = "EXEC proc_reconciliationVoucher";
            sql += " @flag = 'aRec'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Delete(string user, string rowId)
        {
            var sql = "EXEC proc_reconciliationVoucher";
            sql += " @flag = 'delete'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        
        #region resolve complain
        public DataRow SelectByIdResolveComplain(string user, string rowId)
        {
            string sql = "EXEC proc_reconComplainResolve";
            sql += "  @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult ComplainResolve(string user, string id, string remarks)
        {
            string sql = "proc_reconComplainResolve @flag='resolve'";
            sql += ",@rowId=" + FilterString(id);
            sql += ",@user=" + FilterString(user);
            sql += ",@remarks=" + FilterString(remarks);
            return ParseDbResult(sql);
        }

        public DbResult ReceiveForm(string user, string agent, string fromDate, string toDate, string boxNo, string voucherType)
        {
            string sql = "proc_formRecive @flag='i'";
            sql += ", @user = " + FilterString(user);
            sql += ",@agentId=" + FilterString(agent);
            sql += ",@fromDate=" + FilterString(fromDate);
            sql += ",@toDate=" + FilterString(toDate);
            sql += ",@boxNo=" + FilterString(boxNo);
            sql += ",@voucherType=" + FilterString(voucherType);
            return ParseDbResult(sql);
        }

        public DbResult DeleteReceived(string user, string rowId)
        {
            string sql = "EXEC proc_formRecive";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @id = " + FilterString(rowId);

            return ParseDbResult(sql);
        }


        #endregion 

        #region update reconciliation
        public DataRow SelectByIdUpdateRecon(string user, string rowId)
        {
            string sql = "EXEC proc_reconUpdate";
            sql += "  @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult UpdateReconciliation(string user, string rowId, string boxNo, string fileNo, string remarks)
        {
            string sql = "EXEC proc_reconUpdate";
            sql += "  @flag = 'update'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @boxNo = " + FilterString(boxNo);
            sql += ", @fileNo = " + FilterString(fileNo);
            sql += ", @remarks = " + FilterString(remarks);
            return ParseDbResult(sql);
        }

        public DbResult UpdateComplain(string user, string rowId, string remarks)
        {
            string sql = "EXEC proc_reconUpdate";
            sql += "  @flag = 'update-complain'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @remarks = " + FilterString(remarks);
            return ParseDbResult(sql);
        }
        #endregion

        public string GenerateBoxNoReceive(string user)
        {
            var sql = "EXEC proc_reconUpdate";
            sql += " @flag = 'genBox1'";
            sql += ", @user = " + FilterString(user);
            return GetSingleResult(@sql);
        }

        public DataSet GetTranList(string user, string agentId, string fromDate, string toDate,
                string boxNo, string fileNo, string vouType, string status, string controlNo, string tranAmt
           , string senderName, string receiverName,string sendCardNo,string recCardNo)
        {
            var sql = "EXEC proc_reconciliationVoucher @flag='tran-list'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @boxNo = " + FilterString(boxNo);
            sql += ", @fileNo = " + FilterString(fileNo);
            sql += ", @vouType = " + FilterString(vouType);
            sql += ", @status   =" + FilterString(status);
            sql += ", @controlNo   =" + FilterString(controlNo);
            sql += ", @tranAmt    =" + FilterString(tranAmt);
            sql += ", @senderName   =" + FilterString(senderName);
            sql += ", @receiverName   =" + FilterString(receiverName);
            sql += ", @sendCardNo   =" + FilterString(sendCardNo);
            sql += ", @recCardNo   =" + FilterString(recCardNo);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds;
        }
        public DataTable DisplayDocs(string user, string id)
        {
            var sql = "EXEC proc_txnDocumentUpload @flag='displayDoc'";
            sql += ",@user=" + FilterString(user);
            sql += ",@rowId=" + FilterString(id);
            return ExecuteDataTable(sql);
        }       
        public DbResult DeleteDoc(string user, string rowId)
        {
            var sql = "EXEC proc_txnDocumentUpload @flag='deleteDoc'";
            sql += ",@user=" + FilterString(user);
            sql += ",@rowId=" + FilterString(rowId);
            return ParseDbResult(sql);
        }

        public DataRow SelectByIdTxn(string user, string rowId)
        {
            string sql = "EXEC proc_txnDocumentUpload";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DbResult TXNUpdateDoc(string user, string tranId, string fileDescription, string fileType)
        {
            string sql = "EXEC proc_txnDocumentUpload @flag='i'";           
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(tranId);          
            sql += ", @fileDescription = " + FilterString(fileDescription);
            sql += ", @fileType = " + FilterString(fileType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet GetDocuments(string user,  string rowId)
        {
            string sql = "EXEC proc_txnDocumentUpload";
            sql += "  @flag = 'image-display'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(@rowId);

            DataSet ds = ExecuteDataset(sql);
            return ds;
        }


    }
}
