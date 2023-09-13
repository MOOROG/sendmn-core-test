using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Reconciliation
{
    public class TxnDocumentsDao : RemittanceDao
    {
        public DbResult Update(string user, string rowId, string tranId, string fileDescription, string fileType, string txnYear, string agentId, string txnType)
        {
            string sql = "EXEC proc_txnDocuments @flag='i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @fileDescription = " + FilterString(fileDescription);
            sql += ", @fileType = " + FilterString(fileType);
            sql += ", @txnYear = " + FilterString(txnYear);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @txnType = " + FilterString(txnType);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        public DataTable DisplayDocs(string user, string id, string txnType)
        {
            var sql = "EXEC proc_txnDocuments @flag='displayDoc'";
            sql += ",@user=" + FilterString(user);
            sql += ",@rowId=" + FilterString(id);
            sql += ",@txnType=" + FilterString(txnType);
            return ExecuteDataTable(sql);
        }
        public DataRow SelectByIdTxn(string user, string rowId)
        {
            string sql = "EXEC proc_txnDocuments";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DbResult DeleteDoc(string user, string rowId)
        {
            var sql = "EXEC proc_txnDocuments @flag='deleteDoc'";
            sql += ",@user=" + FilterString(user);
            sql += ",@rowId=" + FilterString(rowId);
            var dr = ParseDbResult(sql);


            return dr;        }
        public DataSet GetDocuments(string user, string rowId)
        {
            string sql = "EXEC proc_txnDocuments";
            sql += "  @flag = 'image-display'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(@rowId);

            DataSet ds = ExecuteDataset(sql);
            return ds;
        }
        public DbResult UpdateAgentDoc(string user, string rowId, string tranId, string fileDescription, string fileType, string txnYear, string agentId, string txnType)
        {
            string sql = "EXEC proc_txnDocumentsForAgent @flag='i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @fileDescription = " + FilterString(fileDescription);
            sql += ", @fileType = " + FilterString(fileType);
            sql += ", @txnYear = " + FilterString(txnYear);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @txnType = " + FilterString(txnType);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataTable DisplayDocsAgent(string user, string id, string txnType)
        {
            var sql = "EXEC proc_txnDocumentsForAgent @flag='displayDoc'";
            sql += ",@user=" + FilterString(user);
            sql += ",@rowId=" + FilterString(id);
            sql += ",@txnType=" + FilterString(txnType);
            return ExecuteDataTable(sql);
        }
        public DbResult ApproveDocument(string user, string rowId, string tranId, string voucherType, string agentId, string remarks)
        {
            var sql = "EXEC proc_txnDocumentsForAgent @flag='approve'";
            sql += ",@user=" + FilterString(user);
            sql += ",@rowId=" + FilterString(rowId);
            sql += ",@tranId=" + FilterString(tranId);
            sql += ",@vouType=" + FilterString(voucherType);
            sql += ",@agentId=" + FilterString(agentId);
            sql += ",@remarks=" + FilterString(remarks);
            return ParseDbResult(sql);
        }
        public DbResult RejectDocument(string user, string rowId, string tranId, string voucherType, string agentId, string remarks)
        {
            var sql = "EXEC proc_txnDocumentsForAgent @flag='reject'";
            sql += ",@user=" + FilterString(user);
            sql += ",@rowId=" + FilterString(rowId);
            sql += ",@tranId=" + FilterString(tranId);
            sql += ",@vouType=" + FilterString(voucherType);
            sql += ",@agentId=" + FilterString(agentId);
            sql += ",@remarks=" + FilterString(remarks);
            return ParseDbResult(sql);
        }
        public DataRow SelectById(string rowId, string user)
        {
            string sql = "Exec proc_txnDocumentsForAgent @flag='details',@rowId=" + FilterString(rowId) + "";
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DbResult DeleteDocAgent(string user, string rowId)
        {
            var sql = "EXEC proc_txnDocumentsForAgent @flag='deleteDoc'";
            sql += ",@user=" + FilterString(user);
            sql += ",@rowId=" + FilterString(rowId);
            return ParseDbResult(sql);
        }
    }
}
