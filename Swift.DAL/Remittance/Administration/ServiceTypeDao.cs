using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration
{
    public class ServiceTypeDao : SwiftDao
    {
        public DbResult Update(string user, string serviceTypeId, string serviceCode, string typeTitle, string typeDesc,
                               string isActive)
        {
            string sql = "EXEC proc_serviceTypeMaster";
            sql += " @flag = " + (serviceTypeId == "0" || serviceTypeId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @serviceTypeId = " + FilterString(serviceTypeId);

            sql += ", @serviceCode = " + FilterString(serviceCode);
            sql += ", @typeTitle = " + FilterString(typeTitle);
            sql += ", @typeDesc = " + FilterString(typeDesc);
            sql += ", @isActive = " + FilterString(isActive);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string serviceTypeId)
        {
            string sql = "EXEC proc_serviceTypeMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @serviceTypeId = " + FilterString(serviceTypeId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string serviceTypeId)
        {
            string sql = "EXEC proc_serviceTypeMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @serviceTypeId = " + FilterString(serviceTypeId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string serviceTypeId)
        {
            string sql = "EXEC proc_serviceTypeMaster";
            sql += " @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @serviceTypeId = " + FilterString(serviceTypeId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string serviceTypeId)
        {
            string sql = "EXEC proc_serviceTypeMaster";
            sql += " @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @serviceTypeId = " + FilterString(serviceTypeId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}