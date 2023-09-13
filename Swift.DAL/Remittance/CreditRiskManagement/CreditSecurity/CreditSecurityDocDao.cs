using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.CreditRiskManagement.CreditSecurity
{
    public class CreditSecurityDocDao : RemittanceDao
    {
        public DbResult Update(string user, string sdId, string securityTypeId, string securityType,
                               string fileDescription, string fileType, string sessionId)
        {
            string sql = "EXEC proc_securityDocument";
            sql += " @flag = " + (sdId == "0" || sdId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @sdId = " + FilterString(sdId);
            sql += ", @securityTypeId = " + FilterString(securityTypeId);
            sql += ", @securityType = " + FilterString(securityType);
            sql += ", @fileDescription = " + FilterString(fileDescription);
            sql += ", @fileType = " + FilterString(fileType);
            sql += ", @sessionId = " + FilterString(sessionId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string sdId)
        {
            string sql = "EXEC proc_securityDocument";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sdId = " + FilterString(sdId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataTable PopulateCustomerDocument(string user, string securityTypeId, string securityType)
        {
            string sql = "EXEC proc_securityDocument";
            sql += " @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @securityTypeId = " + FilterString(securityTypeId);
            sql += ", @securityType = " + FilterString(securityType);

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable Delete(string user, string sdIds)
        {
            string sql = "EXEC proc_securityDocument";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sdIds = " + FilterString(sdIds);
            return ExecuteDataset(sql).Tables[0];
        }
    }
}