using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Commission.Send
{
    public class ScSendDetailDao : RemittanceDao
    {
        public DbResult Update(string user, string scSendDetailId, string scSendMasterId, string fromAmt, string toAmt,
                               string pcnt, string minAmt, string maxAmt)
        {
            string sql = "EXEC proc_scSendDetail";
            sql += "  @flag = " + (scSendDetailId == "0" || scSendDetailId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @scSendDetailId = " + FilterString(scSendDetailId);
            sql += ", @scSendMasterId = " + FilterString(scSendMasterId);
            sql += ", @fromAmt = " + FilterString(fromAmt);
            sql += ", @toAmt = " + FilterString(toAmt);
            sql += ", @pcnt = " + FilterString(pcnt);
            sql += ", @minAmt = " + FilterString(minAmt);
            sql += ", @maxAmt = " + FilterString(maxAmt);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string scSendDetailId)
        {
            string sql = "EXEC proc_scSendDetail";
            sql += "  @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scSendDetailId = " + FilterString(scSendDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string scSendDetailId)
        {
            string sql = "EXEC proc_scSendDetail";
            sql += "  @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scSendDetailId = " + FilterString(scSendDetailId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string scSendDetailId)
        {
            string sql = "EXEC proc_scSendDetail";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scSendDetailId = " + FilterString(scSendDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string scSendDetailId)
        {
            string sql = "EXEC proc_scSendDetail";
            sql += "  @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scSendDetailId = " + FilterString(scSendDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        
        public DataSet PopulateCommissionDetail(string user, string scSendMasterId)
        {
            var sql = "EXEC proc_scSendDetail @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @scSendMasterId = " + FilterString(scSendMasterId);
            sql += ", @pageNumber = '1', @pageSize='100', @sortBy='scSendDetailId', @sortOrder='ASC'";
            return ExecuteDataset(sql);
        }

        public DbResult CopySlab(string user, string oldscSendMasterId, string newScSendMasterId)
        {
            string sql = "EXEC proc_scSendDetail";
            sql += " @flag = 'cs'";
            sql += ", @user = " + FilterString(user);
            sql += ", @oldScSendMasterId = " + FilterString(oldscSendMasterId);
            sql += ", @scSendMasterId = " + FilterString(newScSendMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}