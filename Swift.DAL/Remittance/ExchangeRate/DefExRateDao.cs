using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ExchangeRate
{
    public class DefExRateDao : RemittanceDao
    {
        public DbResult Update(string user, string defExRateId, string setupType, string currency, string country, string agent, 
                                string baseCurrency, string factor, 
                                string cRate, string cMargin, string cMax, string cMin, 
                                string pRate, string pMargin, string pMax, string pMin, string isEnable)
        {
            var sql = "EXEC proc_defExRate";
            sql += "  @flag = " + (defExRateId == "0" || defExRateId == "" ? "'i'" : "'u'");
            sql += ", @user = " + FilterString(user);
            sql += ", @defExRateId = " + FilterString(defExRateId);
            sql += ", @setupType = " + FilterString(setupType);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @country = " + FilterString(country);
            sql += ", @agent = " + FilterString(agent);
            sql += ", @baseCurrency = " + FilterString(baseCurrency);
            sql += ", @factor = " + FilterString(factor);
            sql += ", @cRate = " + FilterString(cRate);
            sql += ", @cMargin = " + FilterString(cMargin);
            sql += ", @cMax = " + FilterString(cMax);
            sql += ", @cMin = " + FilterString(cMin);
            sql += ", @pRate = " + FilterString(pRate);
            sql += ", @pMargin = " + FilterString(pMargin);
            sql += ", @pMax = " + FilterString(pMax);
            sql += ", @pMin = " + FilterString(pMin);
            sql += ", @isEnable = " + FilterString(isEnable);
            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Delete(string user, string defExRateId)
        {
            var sql = "EXEC proc_defExRate";
            sql += " @flag = 'd'";
            sql += ", @user = " + FilterString(user);
            sql += ", @defExRateId = " + FilterString(defExRateId);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string defExRateId)
        {
            var sql = "EXEC proc_defExRate";
            sql += " @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @defExRateId = " + FilterString(defExRateId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];

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
        public DataSet LoadGrid(string user, string setupType, string pageNumber, string pageSize, string sortBy, string sortOrder, string currency, string country, string agent)
        {
            var sql = "EXEC proc_defExRate @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @setupType = " + FilterString(setupType);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @countryName = " + FilterString(country);
            sql += ", @agentName = " + FilterString(agent);
            
            return ExecuteDataset(sql);
        }
        public DataSet LoadGridApprove(string user, string setupType, string pageNumber, string pageSize, 
            string sortBy, string sortOrder, string hasChanged, string currency, string country, string agent)
        {
            var sql = "EXEC proc_defExRate @flag = 'm'";
            sql += ", @user = " + FilterString(user);
            sql += ", @setupType = " + FilterString(setupType);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @hasChanged = " + FilterString(hasChanged);
            sql += ", @currency = " + FilterString(currency);
            sql += ", @countryName = " + FilterString(country);
            sql += ", @agentName = " + FilterString(agent);
            return ExecuteDataset(sql);
        }

        public DbResult Approve(string user, string defExRateIds, string setupType)
        {
            var sql = "EXEC proc_defExRate @flag='approve'";
            sql += ", @user = " + FilterString(user);
            sql += ", @defExRateIds = " + FilterString(defExRateIds);
            sql += ", @setupType = " + FilterString(setupType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult Reject(string user, string defExRateIds, string setupType)
        {
            var sql = "EXEC proc_defExRate @flag='reject'";
            sql += ", @user = " + FilterString(user);
            sql += ", @defExRateIds = " + FilterString(defExRateIds);
            sql += ", @setupType = " + FilterString(setupType);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult MarkAsActiveInactive(string user, string defExRateIds, string isActive)
        {
            var sql = "EXEC proc_defExRate @flag = 'ai'";
            sql += ", @user = " + FilterString(user);
            sql += ", @defExRateIds = " + FilterString(defExRateIds);
            sql += ", @isActive = " + FilterString(isActive);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
