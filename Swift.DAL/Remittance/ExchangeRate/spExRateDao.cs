using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ExchangeRate
{
    public class SpExRateDao : SwiftDao
    {
        public DbResult Update(string user, string spExRateId, string cCountry, string cAgent, string cAgentGroup, string cBranch, string cBranchGroup,
                                string pCountry, string pAgent, string pAgentGroup, string pBranch, string pBranchGroup, string cCurrency, string pCurrency,
                                string cRateFactor, string pRateFactor, string cRate, string pRate, string cCurrHOMargin, string pCurrHOMargin, string cCurrAgentMargin, string pCurrAgentMargin,
                                string cHOTolMax, string cHOTolMin, string pHOTolMax, string pHOTolMin,
                                string cAgentTolMax, string cAgentTolMin, string pAgentTolMax, string pAgentTolMin, string crossRate, string crossRateFactor, string effectiveFrom, string effectiveTo)
        {
            var sql = "EXEC proc_spExRate";
            sql += "  @flag = " + (spExRateId == "0" || spExRateId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @spExRateId = " + FilterString(spExRateId);
            sql += ", @cCountry = " + FilterString(cCountry);
            sql += ", @cAgent = " + FilterString(cAgent);
            sql += ", @cAgentGroup = " + FilterString(cAgentGroup);
            sql += ", @cBranch = " + FilterString(cBranch);
            sql += ", @cBranchGroup = " + FilterString(cBranchGroup);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pAgentGroup = " + FilterString(pAgentGroup);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @pBranchGroup = " + FilterString(pBranchGroup);
            sql += ", @cCurrency = " + FilterString(cCurrency);
            sql += ", @pCurrency = " + FilterString(pCurrency);
            sql += ", @cRateFactor = " + FilterString(cRateFactor);
            sql += ", @pRateFactor = " + FilterString(pRateFactor);
            sql += ", @cRate = " + FilterString(cRate);
            sql += ", @pRate = " + FilterString(pRate);
            sql += ", @cCurrHOMargin = " + FilterString(cCurrHOMargin);
            sql += ", @pCurrHOMargin = " + FilterString(pCurrHOMargin);
            sql += ", @cCurrAgentMargin = " + FilterString(cCurrAgentMargin);
            sql += ", @pCurrAgentMargin = " + FilterString(pCurrAgentMargin);
            sql += ", @cHOTolMax = " + FilterString(cHOTolMax);
            sql += ", @cHoTolMin = " + FilterString(cHOTolMin);
            sql += ", @pHOTolMax = " + FilterString(pHOTolMax);
            sql += ", @pHoTolMin = " + FilterString(pHOTolMin);
            sql += ", @cAgentTolMax = " + FilterString(cAgentTolMax);
            sql += ", @cAgentTolMin = " + FilterString(cAgentTolMin);
            sql += ", @pAgentTolMax = " + FilterString(pAgentTolMax);
            sql += ", @pAgentTolMin = " + FilterString(pAgentTolMin);
            sql += ", @crossRate = " + FilterString(crossRate);
            sql += ", @effectiveFrom = " + FilterString(effectiveFrom);
            sql += ", @effectiveTo = " + FilterString(effectiveTo);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string spExRateId)
        {
            var sql = "EXEC proc_spExRate";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @spExRateId = " + FilterString(spExRateId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string spExRateId)
        {
            var sql = "EXEC proc_spExRate";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @spExRateId = " + FilterString(spExRateId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];

        }
        public DataRow SelectCurrencyRate(string user, string tranType, string currency, string country, string agent, string rateType)
        {
            var sql = "EXEC proc_spExRate";
            sql += "  @flag = 'cr'";
            sql += ", @user = " + FilterString(user);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @country = " + FilterString(country);
            sql += ", @agent = " + FilterString(agent);
            sql += ", @rateType = " + FilterString(rateType);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
        public DataSet LoadGrid(string user, string sortBy, string sortOrder, string pageSize, string pageNumber, string currency, string country, string agent)
        {
            var sql = "EXEC proc_spExRate @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @cCurrency = " + FilterString(currency);
            sql += ", @cCountryName = " + FilterString(country);
            sql += ", @cAgentName = " + FilterString(agent);

            return ExecuteDataset(sql);
        }

        public DataSet LoadGridApprove(string user, string setupType, string pageNumber, string pageSize, 
            string sortBy, string sortOrder, string hasChanged, string currency, string country, string agent)
        {
            var sql = "EXEC proc_spExRate @flag = 'm'";
            sql += ", @user = " + FilterString(user);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @cCurrency = " + FilterString(currency);
            sql += ", @cCountryName = " + FilterString(country);
            sql += ", @cAgentName = " + FilterString(agent);
            return ExecuteDataset(sql);
        }

        public DbResult Approve(string user, string defExRateIds)
        {
            var sql = "EXEC proc_spExRate @flag = 'approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @spExRateIds = " + FilterString(defExRateIds);
            
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string defExRateIds)
        {
            var sql = "EXEC proc_spExRate @flag = 'reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @spExRateIds = " + FilterString(defExRateIds);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectRateMask(string user, string currency, string factor)
        {
            var sql = "EXEC proc_defExRate";
            sql += "  @flag = 'rateMask'";
            sql += ", @user = " + FilterString(user);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @factor = " + FilterString(factor);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}
