using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ExchangeRate
{
    public class ExRateOperationDao : SwiftDao
    {
        public DbResult Update(string user, string exRateTreasuryId, string premium, string isUpdated)
        {
            var sql = "EXEC proc_exRateOperation @flag = 'u'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateTreasuryId = " + FilterString(exRateTreasuryId);
            sql += ", @premium = " + FilterString(premium);
            sql += ", @isUpdated = " + FilterString(isUpdated);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult UpdateBranchWiseXml(string user, string exRateTreasuryId, string premium, string isUpdated, string xml)
        {
            var sql = "EXEC proc_exRateOperation @flag = 'ubxml'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateTreasuryId = " + FilterString(exRateTreasuryId);
            sql += ", @premium = " + FilterString(premium);
            sql += ", @isUpdated = " + FilterString(isUpdated);
            sql += ", @xml = " + FilterString(xml);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public string UpdateXml(string user, string xml)
        {
            var sql = "EXEC proc_exRateOperation @flag = 'uxml'";
            sql += ", @user = " + FilterString(user);
            sql += ", @xml = " + FilterString(xml);

            return GetSingleResult(sql);
        }

        public DataSet LoadGrid(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string pCurrency, string pCountry, string pAgent, string isUpdated)
        {
            var sql = "EXEC proc_exRateOperation @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @pCurrency = " + FilterString(pCurrency);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @isUpdated = " + FilterString(isUpdated);

            return ExecuteDataset(sql);
        }

        public DataTable GetModifySummary(string user, string exRateTreasuryIds)
        {
            var sql = "EXEC proc_exRateOperation @flag = 'ms'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateTreasuryIds = " + FilterString(exRateTreasuryIds);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DbResult UpdateRateFromMaster(string user, string exRateTreasuryIds)
        {
            var sql = "EXEC proc_exRateOperation @flag = 'ufm'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateTreasuryIds = " + FilterString(exRateTreasuryIds);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult InsertBranchwise(string user, string exRateTreasuryId, string tranType, string cCurrency, string cCountry, string cAgent, string cBranch, string pCurrency, string pCountry, string pAgent, string premium, string customerRate, string margin)
        {
            var sql = "EXEC proc_exRateOperation @flag = 'ib'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateTreasuryId = " + FilterString(exRateTreasuryId);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @cCurrency = " + FilterString(cCurrency);
            sql += ", @cCountry = " + FilterString(cCountry);
            sql += ", @cAgent = " + FilterString(cAgent);
            sql += ", @cBranch = " + FilterString(cBranch);
            sql += ", @pCurrency = " + FilterString(pCurrency);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @premium = " + FilterString(premium);
            sql += ", @customerRate = " + FilterString(customerRate);
            sql += ", @margin = " + FilterString(margin);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataRow SelectById(string user, string exRateTreasuryId)
        {
            var sql = "EXEC proc_exRateOperation @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateTreasuryId = " + FilterString(exRateTreasuryId);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }

        public DataSet LoadBranchwiseGrid(string user, string exRateTreasuryId, string pageNumber, string pageSize, string sortBy, string sortOrder, string cCurrency, string cCountry, string cAgent, string pCurrency, string pCountry, string pAgent, string isActive)
        {
            var sql = "EXEC proc_exRateOperation @flag = 'sb'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateTreasuryId = " + FilterString(exRateTreasuryId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @cCurrency = " + FilterString(cCurrency);
            sql += ", @cCountry = " + FilterString(cCountry);
            sql += ", @cAgent = " + FilterString(cAgent);
            sql += ", @pCurrency = " + FilterString(pCurrency);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @isActive = " + FilterString(isActive);

            return ExecuteDataset(sql);
        }

        public DbResult UpdateBranchwisePremium(string user, string exRateBranchWiseId, string premium)
        {
            var sql = "EXEC proc_exRateOperation @flag = 'ub'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateBranchWiseId = " + FilterString(exRateBranchWiseId);
            sql += ", @premium = " + FilterString(premium);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult UpdateCheckedBranchPremium(string user, string exRateBranchWiseIds, string premium, string customerRate, string margin)
        {
            var sql = "EXEC proc_exRateOperation @flag = 'ucb'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateBranchWiseIds = " + FilterString(exRateBranchWiseIds);
            sql += ", @premium = " + FilterString(premium);
            sql += ", @customerRate = " + FilterString(customerRate);
            sql += ", @margin = " + FilterString(margin);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult MarkAsActiveInactive(string user, string erbwId, string isActive)
        {
            var sql = "EXEC proc_exRateOperation @flag = 'ai'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateBranchWiseIds = " + FilterString(erbwId);
            sql += ", @isActive = " + FilterString(isActive);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }
    }
}
