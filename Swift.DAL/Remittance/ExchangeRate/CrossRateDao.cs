using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ExchangeRate
{
    public class CrossRateDao : SwiftDao
    {
        public DataTable FindCrossRate(string user, string ssAgent, string sCountry, string sAgent, string sBranch, string rsAgent, string rCountry, string rAgent, string rBranch, string listType)
        {
            var sql = "EXEC proc_crossExchangeRate";
            sql += "  @user = " + FilterString(user);
            sql += ", @listType = " + FilterString(listType);
            sql += ", @ssAgent = " + FilterString(ssAgent);
            sql += ", @sCountry = " + FilterString(sCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @rsAgent = " + FilterString(rsAgent);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @rAgent = " + FilterString(rAgent);
            sql += ", @rBranch = " + FilterString(rBranch);

            return ExecuteDataset(sql).Tables[0];
        }
    }
}
