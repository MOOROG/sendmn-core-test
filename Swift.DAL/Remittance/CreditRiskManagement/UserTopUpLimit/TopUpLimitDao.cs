using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.CreditRiskManagement.UserTopUpLimit
{
    public class TopUpLimitDao : RemittanceDao
    {
        public DbResult Update(string user, string tulId, string userId, string currency, string limitPerDay,
                               string perTopUpLimit, string maxCreditLimitForAgent)
        {
            string sql = "EXEC proc_topUpLimit";
            sql += " @flag = " + (tulId == "0" || tulId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @tulId = " + FilterString(tulId);

            sql += ", @userId = " + FilterString(userId);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @limitPerDay = " + FilterString(limitPerDay);
            sql += ", @perTopUpLimit = " + FilterString(perTopUpLimit);
            sql += ", @maxCreditLimitForAgent = " + FilterString(maxCreditLimitForAgent);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string tulId)
        {
            string sql = "EXEC proc_topUpLimit";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tulId = " + FilterString(tulId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string tulId)
        {
            string sql = "EXEC proc_topUpLimit";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tulId = " + FilterString(tulId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult UpdateInt(string user, string tulId, string userId, string currency, string limitPerDay,
                               string perTopUpLimit)
        {
            string sql = "EXEC proc_topUpLimitInt";
            sql += " @flag = " + (tulId == "0" || tulId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @tulId = " + FilterString(tulId);

            sql += ", @userId = " + FilterString(userId);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @limitPerDay = " + FilterString(limitPerDay);
            sql += ", @perTopUpLimit = " + FilterString(perTopUpLimit);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult DeleteInt(string user, string tulId)
        {
            string sql = "EXEC proc_topUpLimitInt";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tulId = " + FilterString(tulId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectByIdInt(string user, string tulId)
        {
            string sql = "EXEC proc_topUpLimitInt";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tulId = " + FilterString(tulId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}