using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.CreditRiskManagement.UserTopUpLimit
{
    public class TopupLimitAgentDao : SwiftDao
    {
        public DbResult Update(string user, string rowId, string balanceTopup, string agentId)
        {
            string sql = "EXEC proc_balanceTopUpAgent";
            sql += "  @flag = " + (rowId == "0" || rowId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @btId = " + FilterString(rowId);
            sql += ", @amount = " + FilterString(balanceTopup);
            sql += ", @agentId = " + FilterString(agentId);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string rowId, string agentId)
        {
            string sql = "EXEC proc_balanceTopUpAgent";
            sql += "  @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @btId = " + FilterString(rowId);
            sql += ", @agentId = " + FilterString(agentId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult Delete(string user, string rowId)
        {
            string sql = "EXEC proc_balanceTopUpAgent";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @btId = " + FilterString(rowId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataSet GetRequestList(string user, string agentId, string branchId)
        {
            string sql = "EXEC proc_balanceTopUpAgent ";
            sql += "  @flag = 'ss'";
            sql += ", @user = " + FilterString(user);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @agentId = " + FilterString(agentId);

            return ExecuteDataset(sql);
        }

        public DataRow CheckBankGuaranteeExpiry(string user, string agent)
        {
            string sql = "EXEC proc_balanceTopUpAgent ";
            sql += "  @flag = 'chkExpiry'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agent);

            return ExecuteDataRow(sql);
        }
    }
}