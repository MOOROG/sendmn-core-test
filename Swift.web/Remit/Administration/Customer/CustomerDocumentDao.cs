using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Administration.Customer
{
    public class CustomerDocumentDao : RemittanceDao
    {
        public DbResult Update(string user, string cdId, string customerId, string fileDescription
            , string fileType, string agentId, string branchId)
        {
            string sql = "EXEC proc_customerDocument";
            sql += "  @flag = " + (cdId == "0" || cdId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @cdId = " + FilterString(cdId);
            sql += ", @customerId = " + FilterString(customerId);
            sql += ", @fileDescription = " + FilterString(fileDescription);
            sql += ", @fileType = " + FilterString(fileType);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @branchId = " + FilterString(branchId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string cdId)
        {
            string sql = "EXEC proc_customerDocument";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @cdId = " + FilterString(cdId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataTable PopulateCustomerDocument(string user, string customerId)
        {
            string sql = "EXEC proc_customerDocument";
            sql += " @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @customerId = " + FilterString(customerId);
            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable Delete(string user, string cdIds)
        {
            string sql = "EXEC proc_customerDocument";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @cdIds = " + FilterString(cdIds);
            return ExecuteDataset(sql).Tables[0];
        }

        public DbResult MakeProfilePicture(string user, string cdId)
        {
            string sql = "EXEC proc_customerDocument";
            sql += " @flag = 'p'";
            sql += ", @user = " + FilterString(user);
            sql += ", @cdIds = " + FilterString(cdId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}