using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Compliance
{
    public class CisDetailDao : SwiftDao
    {
        public DbResult Update(string user, string cisDetailId, string cisMasterId, string condition, string collMode,
                               string paymentMode, string tranCount, string amount, string period, string isEnable,
                               string criteria, string criteriaValue)
        {
            string sql = "EXEC proc_cisDetail";
            sql += " @flag = " + (cisDetailId == "0" || cisDetailId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @cisDetailId = " + FilterString(cisDetailId);
            sql += ", @cisMasterId = " + FilterString(cisMasterId);
            sql += ", @condition = " + FilterString(condition);
            sql += ", @collMode = " + FilterString(collMode);
            sql += ", @paymentMode = " + FilterString(paymentMode);
            sql += ", @tranCount = " + FilterString(tranCount);
            sql += ", @amount = " + FilterString(amount);
            sql += ", @period = " + FilterString(period);
            sql += ", @isEnable = " + FilterString(isEnable);
            sql += ", @criteria = " + FilterString(criteria);
            sql += ", @criteriaValue = " + FilterString(criteriaValue);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string cisDetailId)
        {
            string sql = "EXEC proc_cisDetail";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @cisDetailId = " + FilterString(cisDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Disable(string user, string cisDetailId)
        {
            string sql = "EXEC proc_cisDetail";
            sql += " @flag = 'disabled'";
            sql += ", @user = " + FilterString(user);
            sql += ", @cisDetailId = " + FilterString(cisDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string cisDetailId)
        {
            string sql = "EXEC proc_cisDetail";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @cisDetailId = " + FilterString(cisDetailId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}