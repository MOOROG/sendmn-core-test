using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Commission.Pay
{
    public class DcPayDetailDao : SwiftDao
    {
        public DbResult Update(string user, string dcPayDetailId, string dcPayMasterId, string fromAmt, string toAmt,
                               string pcnt, string minAmt, string maxAmt)
        {
            string sql = "EXEC proc_dcPayDetail";
            sql += "  @flag = " + (dcPayDetailId == "0" || dcPayDetailId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @dcPayDetailId = " + FilterString(dcPayDetailId);
            sql += ", @dcPayMasterId = " + FilterString(dcPayMasterId);
            sql += ", @fromAmt = " + FilterString(fromAmt);
            sql += ", @toAmt = " + FilterString(toAmt);
            sql += ", @pcnt = " + FilterString(pcnt);
            sql += ", @minAmt = " + FilterString(minAmt);
            sql += ", @maxAmt = " + FilterString(maxAmt);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string dcPayDetailId)
        {
            string sql = "EXEC proc_dcPayDetail";
            sql += "  @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcPayDetailId = " + FilterString(dcPayDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string dcPayDetailId)
        {
            string sql = "EXEC proc_dcPayDetail";
            sql += "  @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcPayDetailId = " + FilterString(dcPayDetailId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string dcPayDetailId)
        {
            string sql = "EXEC proc_dcPayDetail";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcPayDetailId = " + FilterString(dcPayDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string dcPayDetailId)
        {
            string sql = "EXEC proc_dcPayDetail";
            sql += "  @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcPayDetailId = " + FilterString(dcPayDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}