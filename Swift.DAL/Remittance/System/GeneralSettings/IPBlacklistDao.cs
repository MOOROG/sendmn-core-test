using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.GeneralSettings
{
    public class IPBlacklistDao : SwiftDao
    {
        public DbResult Update(string user, string blId, string IPAddress, string msg, string reason,
                               string isEnable)
        {
            string sql = "EXEC proc_IPBlacklist";
            sql += " @flag = " + (blId == "0" || blId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @blId = " + FilterString(blId);
            sql += ", @IPAddress = " + FilterString(IPAddress);
            sql += ", @msg = " + FilterString(msg);
            sql += ", @reason = " + FilterString(reason);
            sql += ", @isEnable = " + FilterString(isEnable);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string blId)
        {
            string sql = "EXEC proc_IPBlacklist";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @blId = " + FilterString(blId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string blId)
        {
            string sql = "EXEC proc_IPBlacklist";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @blId = " + FilterString(blId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}
