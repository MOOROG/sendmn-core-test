using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration
{
    public class PaymentModeDao : SwiftDao
    {
        public DbResult Update(string user, string paymentModeId, string paymentCode, string modeTitle, string modeDesc)
        {
            string sql = "EXEC proc_paymentModeMaster";
            sql += " @flag = " + (paymentModeId == "0" || paymentModeId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @paymentModeId = " + FilterString(paymentModeId);

            sql += ", @paymentCode = " + FilterString(paymentCode);
            sql += ", @modeTitle = " + FilterString(modeTitle);
            sql += ", @modeDesc = " + FilterString(modeDesc);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string paymentModeId)
        {
            string sql = "EXEC proc_paymentModeMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @paymentModeId = " + FilterString(paymentModeId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string paymentModeId)
        {
            string sql = "EXEC proc_paymentModeMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @paymentModeId = " + FilterString(paymentModeId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string paymentModeId)
        {
            string sql = "EXEC proc_paymentModeMaster";
            sql += " @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @paymentModeId = " + FilterString(paymentModeId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string paymentModeId)
        {
            string sql = "EXEC proc_paymentModeMaster";
            sql += " @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @paymentModeId = " + FilterString(paymentModeId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}