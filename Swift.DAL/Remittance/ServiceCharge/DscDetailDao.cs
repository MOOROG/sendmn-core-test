using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ServiceCharge
{
    public class DscDetailDao : SwiftDao
    {
        public DbResult Update(string user, string dscDetailId, string dscMasterId, string fromAmt, string toAmt,
                               string pcnt, string minAmt, string maxAmt)
        {
            string sql = "EXEC proc_dscDetail";
            sql += "  @flag = " + (dscDetailId == "0" || dscDetailId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @dscDetailId = " + FilterString(dscDetailId);
            sql += ", @dscMasterId = " + FilterString(dscMasterId);
            sql += ", @fromAmt = " + FilterString(fromAmt);
            sql += ", @toAmt = " + FilterString(toAmt);
            sql += ", @pcnt = " + FilterString(pcnt);
            sql += ", @minAmt = " + FilterString(minAmt);
            sql += ", @maxAmt = " + FilterString(maxAmt);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string dscDetailId)
        {
            string sql = "EXEC proc_dscDetail";
            sql += "  @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dscDetailId = " + FilterString(dscDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string dscDetailId)
        {
            string sql = "EXEC proc_dscDetail";
            sql += "  @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dscDetailId = " + FilterString(dscDetailId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string dscMasterId)
        {
            string sql = "EXEC proc_dscDetail";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dscDetailId = " + FilterString(dscMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string dscMasterId)
        {
            string sql = "EXEC proc_dscDetail";
            sql += "  @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dscDetailId = " + FilterString(dscMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}