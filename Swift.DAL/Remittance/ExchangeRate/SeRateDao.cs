using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ExchangeRate
{
    public class SeRateDao : SwiftDao
    {
        public DbResult Update(string user
                            , string seRateId
                            , string baseCurrency
                            , string localCurrency
                            , string sHub
                            , string sCountry
                            , string ssAgent
                            , string sAgent
                            , string sBranch
                            , string rHub
                            , string rCountry
                            , string rsAgent
                            , string rAgent
                            , string rBranch
                            , string state
                            , string zip
                            , string agentGroup
                            , string cost
                            , string margin
                            , string agentMargin
                            , string ve
                            , string ne
                            , string spFlag
                            , string effectiveFrom
                            , string effectiveTo
                            , string isEnable)
        {
            var sql = "EXEC proc_seRate";
            sql += "  @flag = " + (seRateId == "0" || seRateId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @seRateId = " + FilterString(seRateId);
            sql += ", @baseCurrency = " + FilterString(baseCurrency);
            sql += ", @localCurrency = " + FilterString(localCurrency);
            sql += ", @sHub = " + FilterString(sHub);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @ssAgent = " + FilterString(ssAgent);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @rHub = " + FilterString(rHub);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rsAgent = " + FilterString(rsAgent);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rBranch = " + FilterString(rBranch);
            sql += ", @state = " + FilterString(state);
            sql += ", @zip = " + FilterString(zip);
            sql += ", @agentGroup = " + FilterString(agentGroup);
            sql += ", @cost = " + FilterString(cost);
            sql += ", @margin = " + FilterString(margin);
            sql += ", @agentMargin = " + FilterString(agentMargin);
            sql += ", @ve = " + FilterString(ve);
            sql += ", @ne = " + FilterString(ne);
            sql += ", @spFlag = " + FilterString(spFlag);
            sql += ", @effectiveFrom = " + FilterString(effectiveFrom);
            sql += ", @effectiveTo = " + FilterString(effectiveTo);
            sql += ", @isEnable = " + FilterString(isEnable);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string seRateId)
        {
            var sql = "EXEC proc_seRate";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @seRateId = " + FilterString(seRateId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string seRateId)
        {
            var sql = "EXEC proc_seRate";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @seRateId = " + FilterString(seRateId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DbResult UpdateCrossRate(string user
                            , string seRateId
                            , string baseCurrency
                            , string localCurrency
                            , string sHub
                            , string sCountry
                            , string ssAgent
                            , string sAgent
                            , string sBranch
                            , string rHub
                            , string rCountry
                            , string rsAgent
                            , string rAgent
                            , string rBranch
                            , string state
                            , string zip
                            , string agentGroup
                            , string cost
                            , string margin
                            , string agentMargin
                            , string ve
                            , string ne
                            , string spFlag
                            , string effectiveFrom
                            , string effectiveTo
                            , string isEnable)
        {
            var sql = "EXEC proc_seRate";
            sql += "  @flag = 'ci'";
            sql += ", @user = " + FilterString(user);
            sql += ", @seRateId = " + FilterString(seRateId);
            sql += ", @baseCurrency = " + FilterString(baseCurrency);
            sql += ", @localCurrency = " + FilterString(localCurrency);
            sql += ", @sHub = " + FilterString(sHub);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @ssAgent = " + FilterString(ssAgent);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @rHub = " + FilterString(rHub);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rsAgent = " + FilterString(rsAgent);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rBranch = " + FilterString(rBranch);
            sql += ", @state = " + FilterString(state);
            sql += ", @zip = " + FilterString(zip);
            sql += ", @agentGroup = " + FilterString(agentGroup);
            sql += ", @cost = " + FilterString(cost);
            sql += ", @margin = " + FilterString(margin);
            sql += ", @agentMargin = " + FilterString(agentMargin);
            sql += ", @ve = " + FilterString(ve);
            sql += ", @ne = " + FilterString(ne);
            sql += ", @spFlag = " + FilterString(spFlag);
            sql += ", @effectiveFrom = " + FilterString(effectiveFrom);
            sql += ", @effectiveTo = " + FilterString(effectiveTo);
            sql += ", @isEnable = " + FilterString(isEnable);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
