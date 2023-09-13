using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ExchangeRate
{
    public class AgentExRateMenuDao : RemittanceDao
    {
        public DbResult Delete(string user, string rowId)
        {
            var sql = "EXEC proc_agentExRateMenu @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Update(string user, string rowId, string countryId, string agentId, string menuId)
        {
            string sql = "EXEC proc_agentExRateMenu";
            sql += " @flag = " + (rowId == "0" || rowId == "" ? "'i'" : "'u'");
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @user = " + FilterString(user);
            sql += ", @countryId = " + FilterString(countryId);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @menuId = " + FilterString(menuId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string rowId)
        {
            var sql = "EXEC proc_agentExRateMenu @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}
