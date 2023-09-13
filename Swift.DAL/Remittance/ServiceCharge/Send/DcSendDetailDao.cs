using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Commission.Send
{
    public class DcSendDetailDao : SwiftDao
    {
        public DbResult Update(string user, string dcSendDetailId, string dcSendMasterId, string fromAmt, string toAmt,
                               string pcnt, string minAmt, string maxAmt)
        {
            string sql = "EXEC proc_dcSendDetail";
            sql += "  @flag = " + (dcSendDetailId == "0" || dcSendDetailId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @dcSendDetailId = " + FilterString(dcSendDetailId);
            sql += ", @dcSendMasterId = " + FilterString(dcSendMasterId);
            sql += ", @fromAmt = " + FilterString(fromAmt);
            sql += ", @toAmt = " + FilterString(toAmt);
            sql += ", @pcnt = " + FilterString(pcnt);
            sql += ", @minAmt = " + FilterString(minAmt);
            sql += ", @maxAmt = " + FilterString(maxAmt);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string dcSendDetailId)
        {
            string sql = "EXEC proc_dcSendDetail";
            sql += "  @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcSendDetailId = " + FilterString(dcSendDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string dcSendDetailId)
        {
            string sql = "EXEC proc_dcSendDetail";
            sql += "  @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcSendDetailId = " + FilterString(dcSendDetailId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string dcSendDetailId)
        {
            string sql = "EXEC proc_dcSendDetail";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcSendDetailId = " + FilterString(dcSendDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string dcSendDetailId)
        {
            string sql = "EXEC proc_dcSendDetail";
            sql += "  @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @dcSendDetailId = " + FilterString(dcSendDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}