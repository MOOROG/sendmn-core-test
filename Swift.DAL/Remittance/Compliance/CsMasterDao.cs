using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Compliance
{
    public class CsMasterDao : RemittanceDao
    {
        public DbResult Update(string user, string csMasterId, string sCountry, string sAgent,
                               string sState, string sZip, string sGroup, string sCustType, string rCountry,
                               string rAgent, string rState, string rZip, string rGroup, string rCustType,
                               string currency,string ruleScope)
        {
            string sql = "EXEC proc_csMaster";
            sql += " @flag = " + (csMasterId == "0" || csMasterId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @csMasterId = " + FilterString(csMasterId);

            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sState = " + FilterString(sState);
            sql += ", @sZip = " + FilterString(sZip);
            sql += ", @sGroup = " + FilterString(sGroup);
            sql += ", @sCustType = " + FilterString(sCustType);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rState = " + FilterString(rState);
            sql += ", @rZip = " + FilterString(rZip);
            sql += ", @rGroup = " + FilterString(rGroup);
            sql += ", @rCustType = " + FilterString(rCustType);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @ruleScope = " + FilterString(ruleScope);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string csMasterId)
        {
            string sql = "EXEC proc_csMaster";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csMasterId = " + FilterString(csMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Disable(string user, string csMasterId)
        {
            string sql = "EXEC proc_csMaster";
            sql += " @flag = 'disable'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csMasterId = " + FilterString(csMasterId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string csMasterId)
        {
            string sql = "EXEC proc_csMaster";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csMasterId = " + FilterString(csMasterId);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataRow SelectRuleDetailById(string user, string csMasterId)
        {
            string sql = "EXEC proc_csMaster";
            sql += " @flag = 'rd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @csMasterId = " + FilterString(csMasterId);

            return ExecuteDataRow(sql);
        }
    }
}