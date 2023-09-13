using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Compliance
{
    public class CsDetailDao : RemittanceDao
    {
        public DbResult Update(string user, string csDetailId, string csMasterId, string condition, string collMode,
                               string paymentMode, string tranCount, string amount, string period, string nextAction,
                               string criteria, string profession, string isRequireDocument)
        {
            string sql = "EXEC proc_csDetail";
            sql += " @flag = " + (csDetailId == "0" || csDetailId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @csDetailId = " + FilterString(csDetailId);

            sql += ", @csMasterId = " + FilterString(csMasterId);
            sql += ", @condition = " + FilterString(condition);
            sql += ", @collMode = " + FilterString(collMode);
            sql += ", @paymentMode = " + FilterString(paymentMode);
            sql += ", @tranCount = " + FilterString(tranCount);
            sql += ", @amount = " + FilterString(amount);
            sql += ", @period = " + FilterString(period);
            sql += ", @nextAction = " + FilterString(nextAction);
            sql += ", @criteria = " + FilterString(criteria);
            sql += ", @profession = " + FilterString(profession);
            sql += ", @isRequireDocument = " + FilterString(isRequireDocument);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);

        }

        public DbResult Delete(string user, string csDetailId)
        {
            string sql = "EXEC proc_csDetail";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csDetailId = " + FilterString(csDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Disable(string user, string csDetailId)
        {
            string sql = "EXEC proc_csDetail";
            sql += " @flag = 'disabled'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csDetailId = " + FilterString(csDetailId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string csDetailId)
        {
            string sql = "EXEC proc_csDetail";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csDetailId = " + FilterString(csDetailId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}