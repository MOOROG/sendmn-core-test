using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ServiceCharge
{
    public class SscDetailDao : RemittanceDao
    {
        public DbResult Update(string user, string sscDetailId, string sscMasterId, string fromAmt, string toAmt,
                               string pcnt, string minAmt, string maxAmt)
        {
            string sql = "EXEC proc_sscDetail";
            sql += "  @flag = " + (sscDetailId == "0" || sscDetailId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @sscDetailId = " + FilterString(sscDetailId);
            sql += ", @sscMasterId = " + FilterString(sscMasterId);
            sql += ", @fromAmt = " + FilterString(fromAmt);
            sql += ", @toAmt = " + FilterString(toAmt);
            sql += ", @pcnt = " + FilterString(pcnt);
            sql += ", @minAmt = " + FilterString(minAmt);
            sql += ", @maxAmt = " + FilterString(maxAmt);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string sscDetailId)
        {
            string sql = "EXEC proc_sscDetail";
            sql += "  @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sscDetailId = " + FilterString(sscDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string sscDetailId)
        {
            string sql = "EXEC proc_sscDetail";
            sql += "  @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sscDetailId = " + FilterString(sscDetailId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string sscDetailId)
        {
            string sql = "EXEC proc_sscDetail";
            sql += "  @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sscDetailId = " + FilterString(sscDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string sscDetailId)
        {
            string sql = "EXEC proc_sscDetail";
            sql += "  @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sscDetailId = " + FilterString(sscDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet PopulateCommissionDetail(string user, string sscMasterId)
        {
            var sql = "EXEC proc_sscDetail @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sscMasterId = " + FilterString(sscMasterId);
            sql += ", @pageNumber = '1', @pageSize='100', @sortBy='sscDetailId', @sortOrder='ASC'";
            return ExecuteDataset(sql);
        }

        public DbResult CopySlab(string user, string oldSscMasterId, string newSscMasterId)
        {
            string sql = "EXEC proc_sscDetail";
            sql += " @flag = 'cs'";
            sql += ", @user = " + FilterString(user);
            sql += ", @oldSscMasterId = " + FilterString(oldSscMasterId);
            sql += ", @sscMasterId = " + FilterString(newSscMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
        //copy details
        public DataRow SelectCopyById(string user, string sscDetailId)
        {
            string sql = "EXEC proc_sscCopyDetail";
            sql += "  @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sscDetailId = " + FilterString(sscDetailId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        

        public DbResult CopyUpdate(string user, string sscDetailId, string sscMasterId, string fromAmt, string toAmt,
                               string pcnt, string minAmt, string maxAmt, string sessionId)
        {
            string sql = "EXEC proc_sscCopyDetail";
            sql += "  @flag = " + (sscDetailId == "0" || sscDetailId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @sscDetailId = " + FilterString(sscDetailId);
            sql += ", @sscMasterId = " + FilterString(sscMasterId);
            sql += ", @fromAmt = " + FilterString(fromAmt);
            sql += ", @toAmt = " + FilterString(toAmt);
            sql += ", @pcnt = " + FilterString(pcnt);
            sql += ", @minAmt = " + FilterString(minAmt);
            sql += ", @maxAmt = " + FilterString(maxAmt);
            sql += ", @sessionId = " + FilterString(sessionId);
            
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }


        public DbResult CopyDelete(string user, string sscDetailId)
        {
            string sql = "EXEC proc_sscCopyDetail";
            sql += "  @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sscDetailId = " + FilterString(sscDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}