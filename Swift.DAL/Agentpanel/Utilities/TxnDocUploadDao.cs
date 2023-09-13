using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.AgentPanel.Utilities
{
    public class TxnDocUploadDao : RemittanceDao
    {
        public DataTable SelectById(string user, string tranId, string controlNo, string agent, string branch)
        {
            string sql = "EXEC proc_txnDocUpload";
            sql += " @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            sql += ", @agent = " + FilterString(agent);
            sql += ", @branch = " + FilterString(branch);
            return ExecuteDataTable(sql);
        }
        public DbResult Update(string user, string id, string fileName, string fileType, string docFolder)
        {
            var sql = "EXEC proc_txnDocUpload  @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(id);
            sql += ", @fileName = " + FilterString(fileName);
            sql += ", @fileType = " + FilterString(fileType);
            sql += ", @docFolder = " + FilterString(docFolder);
            return ParseDbResult(sql);
        }

        public DbResult Delete(string user, string id, string fileType)
        {
            string sql = "EXEC proc_txnDocUpload  @flag = 'd'";
            sql += ",@tranId=" + FilterString(id);
            sql += ",@user=" + FilterString(user);
            sql += ", @fileType = " + FilterString(fileType);

            return ParseDbResult(sql);
        }
        public DataTable GetTxnDocs(string user, string tranId, string controlNo)
        {
            string sql = "EXEC proc_txnDocUpload";
            sql += " @flag = 'search'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranId = " + FilterString(tranId);
            sql += ", @controlNo = " + FilterString(controlNo);
            return ExecuteDataTable(sql);
        }
        public DbResult SaveTxnDocumentTemp(string user, string batchId, string fileName, string fileType, string fileDescription)
        {
            var sql = "EXEC proc_txnDocUploadTEMP  @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @batchId = " + FilterString(batchId);
            sql += ", @fileName = " + FilterString(fileName);
            sql += ", @fileType = " + FilterString(fileType);
            sql += ", @fileDescription = " + FilterString(fileDescription);
            return ParseDbResult(sql);
        }
        public DataTable GetTxnTempDoc(string user, string batchId)
        {
            string sql = "EXEC proc_txnDocUploadTEMP";
            sql += " @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @batchId = " + FilterString(batchId);
            return ExecuteDataTable(sql);
        }
        public DbResult DeleteTxnTmpDoc(string user, string rowId, string batchId)
        {
            string sql = "EXEC proc_txnDocUploadTEMP  @flag = 'd'";
            sql += ",@user =" + FilterString(user);
            sql += ",@rowId =" + FilterString(rowId);
            sql += ", @batchId = " + FilterString(batchId);

            return ParseDbResult(sql);
        }
    }
}
