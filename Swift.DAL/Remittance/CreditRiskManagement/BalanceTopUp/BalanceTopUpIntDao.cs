using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.CreditRiskManagement.BalanceTopUp
{
    public class BalanceTopUpIntDao : RemittanceDao
    {
        public DbResult Update(string user, string btId, string agentId, string amount, string topUpExpiryDate)
        {
            string sql = "EXEC proc_balanceTopUpInt";
            sql += " @flag = " + (btId == "0" || btId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @btId = " + FilterString(btId);

            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @amount = " + FilterString(amount);
            sql += ", @topUpExpiryDate = " + FilterString(topUpExpiryDate);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string btId)
        {
            string sql = "EXEC proc_balanceTopUpInt";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @btId = " + FilterString(btId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string agentId)
        {
            string sql = "EXEC proc_balanceTopUpInt";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow GetLimitDetail(string user, string agentId)
        {
            var sql = "EXEC proc_balanceTopUpInt";
            sql += " @flag = 'ld'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Approve(string user, string btId)
        {
            var sql = "EXEC proc_balanceTopUpInt";
            sql += " @flag = 'approve'";
            sql += ", @btId = " + FilterString(btId);
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string btId)
        {
            var sql = "EXEC proc_balanceTopUpInt";
            sql += " @flag = 'reject'";
            sql += ", @btId = " + FilterString(btId);
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}