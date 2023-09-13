using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.Notification
{
    public class ApplicationLogsDao : SwiftDao
    {
        public DataTable PopulateAppLogById(string logId)
        {
            string sql = "exec [proc_applicationLogs] 'a', @rowId=" + logId + "";
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable PopulateLoginLogById(string logId)
        {
            string sql = "exec [proc_applicationLogs] 'lv', @rowId=" + logId + "";
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable GetAuditDataForFunction(string oldData, string newData)
        {
            string sql = "exec [proc_applicationLogs] 'auditFunction' ";
            sql += ", @oldData='" + oldData + "'";
            sql += ", @newData='" + newData + "'";
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable GetAuditDataForRole(string oldData, string newData)
        {
            string sql = "exec [proc_applicationLogs] 'auditRole' ";
            sql += ", @oldData='" + oldData + "'";
            sql += ", @newData='" + newData + "'";
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable GetAuditDataForAgent(string oldData, string newData)
        {
            string sql = "exec [proc_applicationLogs] 'auditAgent'";
            sql += ", @oldData='" + oldData + "'";
            sql += ", @newData='" + newData + "'";
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable GetAuditDataForRuleCriteria(string oldData, string newData)
        {
            string sql = "exec [proc_applicationLogs] 'auditRuleCriteria'";
            sql += ", @oldData='" + oldData + "'";
            sql += ", @newData='" + newData + "'";
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable GetAuditDataForIdCriteria(string oldData, string newData, string id)
        {
            string sql = "exec [proc_applicationLogs] 'auditIdCriteria'";
            sql += ", @oldData='" + oldData + "'";
            sql += ", @newData='" + newData + "'";
            sql += ", @dataId='" + id + "'";
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable GetAuditDataForCommissionPackage(string oldData, string newData)
        {
            string sql = "exec [proc_applicationLogs] 'auditPackage'";
            sql += ", @oldData='" + oldData + "'";
            sql += ", @newData='" + newData + "'";
            return ExecuteDataset(sql).Tables[0];
        }

        public DataRow GetAppExecDetails(string user, string id)
        {
            string sql = "exec [proc_ErrorLogs] 'a', @Id=" + id;
            sql += ", @user = " + FilterString(user);
            var ds = ExecuteDataset(sql);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

    }
}