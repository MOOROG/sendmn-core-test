using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration.Agent
{
    public class AgentCurrencyDao : SwiftDao
    {
        public DbResult Update(string user, string agentCurrencyId, string agentId, string currencyId, string spFlag,
                               string isDefault)
        {
            string sql = "EXEC proc_agentCurrency";
            sql += " @flag = " + (agentCurrencyId == "0" || agentCurrencyId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @agentCurrencyId = " + FilterString(agentCurrencyId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @currencyId = " + FilterString(currencyId);
            sql += ", @spFlag = " + FilterString(spFlag);
            sql += ", @isDefault = " + FilterString(isDefault);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string agentCurrencyId)
        {
            string sql = "EXEC proc_agentCurrency";
            sql += " @flag = 'd'";
            sql += ", @agentCurrencyId = " + agentCurrencyId;
            sql += ", @user = " + FilterString(user);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string agentCurrencyId)
        {
            string sql = "EXEC proc_agentCurrency";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentCurrencyId = " + FilterString(agentCurrencyId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}