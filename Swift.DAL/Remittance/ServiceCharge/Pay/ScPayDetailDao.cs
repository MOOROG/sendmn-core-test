using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Commission.Pay
{
    public class ScPayDetailDao : RemittanceDao
    {
        public DbResult Update(string user, string scPayDetailId, string scPayMasterId, string fromAmt, string toAmt,
                               string pcnt, string minAmt, string maxAmt)
        {
            string sql = "EXEC proc_scPayDetail";
            sql += "  @flag = " + (scPayDetailId == "0" || scPayDetailId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @scPayDetailId = " + FilterString(scPayDetailId);
            sql += ", @scPayMasterId = " + FilterString(scPayMasterId);
            sql += ", @fromAmt = " + FilterString(fromAmt);
            sql += ", @toAmt = " + FilterString(toAmt);
            sql += ", @pcnt = " + FilterString(pcnt);
            sql += ", @minAmt = " + FilterString(minAmt);
            sql += ", @maxAmt = " + FilterString(maxAmt);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string scPayDetailId)
        {
            string sql = "EXEC proc_scPayDetail";
            sql += "  @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scPayDetailId = " + FilterString(scPayDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string scPayDetailId)
        {
            string sql = "EXEC proc_scPayDetail";
            sql += "  @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scPayDetailId = " + FilterString(scPayDetailId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string scPayDetailId)
        {
            string sql = "EXEC proc_scPayDetail";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scPayDetailId = " + FilterString(scPayDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string scPayDetailId)
        {
            string sql = "EXEC proc_scPayDetail";
            sql += "  @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scPayDetailId = " + FilterString(scPayDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet PopulateCommissionDetail(string user, string scPayMasterId)
        {
            var sql = "EXEC proc_scPayDetail @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scPayMasterId = " + FilterString(scPayMasterId);
            sql += ", @pageNumber = '1', @pageSize='100', @sortBy='scPayDetailId', @sortOrder='ASC'";
            return ExecuteDataset(sql);
        }

        public DbResult CopySlab(string user, string oldScPayMasterId, string newScPayMasterId)
        {
            string sql = "EXEC proc_scPayDetail";
            sql += " @flag = 'cs'";
            sql += ", @user = " + FilterString(user);
            sql += ", @oldScPayMasterId = " + FilterString(oldScPayMasterId);
            sql += ", @scPayMasterId = " + FilterString(newScPayMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}