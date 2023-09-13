
using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.ExchangeRate
{
    public class ExRateReportDao : RemittanceDao
    {
        public ReportResult GetExRateReport(string cCountry, string pCountry, string cAgent, string pAgent, string cAgentGroup,
            string pAgentGroup, string cBranch, string pBranch, string cBranchGroup, string pBranchGroup, string pageSize, string pageNumber, string user)
        {
            string sql = "EXEC proc_exchangeRateSystem_Rpt @flag = 'a'";
            sql += ", @user = " + FilterString(user);
            sql += ", @cCountry = " + FilterString(cCountry);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @cAgent = " + FilterString(cAgent);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @cAgentGroup = " + FilterString(cAgentGroup);
            sql += ", @pAgentGroup = " + FilterString(pAgentGroup);
            sql += ", @cBranch = " + FilterString(cBranch);
            sql += ", @pBranch = " + FilterString(pBranch);
            sql += ", @cBranchGroup = " + FilterString(cBranchGroup);
            sql += ", @pBranchGroup = " + FilterString(pBranchGroup);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }

        public DataSet GetExRateReportAdmin(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string cCountry, string cAgent, string cBranch, string cCurrency, string pCountry, string pAgent, string pCurrency, string tranType)
        {
            var sql = "EXEC proc_exRateTreasury @flag = 'r'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @cCountry = " + FilterString(cCountry);
            sql += ", @cAgent = " + FilterString(cAgent);
            sql += ", @cBranch = " + FilterString(cBranch);
            sql += ", @cCurrency = " + FilterString(cCurrency);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pCurrency = " + FilterString(pCurrency);
            sql += ", @tranType = " + FilterString(tranType);

            return ExecuteDataset(sql);
        }

        public DataSet GetExRateOperationReportAdmin(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string cCountry, string cAgent, string cBranch, string cCurrency, string pCountry, string pAgent, string pCurrency, string tranType)
        {
            var sql = "EXEC proc_exRateTreasury @flag = 'or'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @cCountry = " + FilterString(cCountry);
            sql += ", @cAgent = " + FilterString(cAgent);
            sql += ", @cBranch = " + FilterString(cBranch);
            sql += ", @cCurrency = " + FilterString(cCurrency);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pCurrency = " + FilterString(pCurrency);
            sql += ", @tranType = " + FilterString(tranType);

            return ExecuteDataset(sql);
        }

        public DataTable GetModifySummary(string user, string exRateTreasuryIds)
        {
            var sql = "EXEC proc_exRateTreasury @flag = 'ms'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateTreasuryIds = " + FilterString(exRateTreasuryIds);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable GetApproveSummary(string user, string exRateTreasuryIds)
        {
            var sql = "EXEC proc_exRateTreasury @flag = 'as'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateTreasuryIds = " + FilterString(exRateTreasuryIds);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataTable LoadGridForCopy(string user, string cCountry, string cAgent, string pCountry, string pAgent, string applyFor, string applyAgent)
        {
            var sql = "EXEC proc_exRateTreasury @flag = 'cl'";
            sql += ", @user = " + FilterString(user);
            sql += ", @cCountry = " + FilterString(cCountry);
            sql += ", @cAgent = " + FilterString(cAgent);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @applyFor = " + FilterString(applyFor);
            sql += ", @applyAgent = " + FilterString(applyAgent);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DbResult Copy(string user, string exRateTreasuryIds, string applyAgent, string applyFor)
        {
            var sql = "EXEC proc_exRateTreasury @flag = 'copy'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateTreasuryIds = " + FilterString(exRateTreasuryIds);
            sql += ", @applyAgent = " + FilterString(applyAgent);
            sql += ", @applyFor = " + FilterString(applyFor);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DataTable GetCopySummary(string user, string exRateTreasuryIds, string applyAgent, string applyFor)
        {
            var sql = "EXEC proc_exRateTreasury @flag = 'cs'";
            sql += ", @user = " + FilterString(user);
            sql += ", @exRateTreasuryIds = " + FilterString(exRateTreasuryIds);
            sql += ", @applyAgent = " + FilterString(applyAgent);
            sql += ", @applyFor = " + FilterString(applyFor);

            var ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0)
                return null;
            return ds.Tables[0];
        }

        public DataSet GetForexReport(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string cCountry, string cAgent, string cBranch, string cCurrency, string pCountry, string pAgent, string pCurrency, string tranType)
        {
            var sql = "EXEC proc_exRateReport @flag = 'forex'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @cCountry = " + FilterString(cCountry);
            sql += ", @cAgent = " + FilterString(cAgent);
            sql += ", @cBranch = " + FilterString(cBranch);
            sql += ", @cCurrency = " + FilterString(cCurrency);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pCurrency = " + FilterString(pCurrency);
            sql += ", @tranType = " + FilterString(tranType);

            return ExecuteDataset(sql);
        }

        public DataSet GetForexReportIrh(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string cCountry, string cAgent, string cBranch, string cCurrency, string pCountry, string pAgent, string pCurrency, string tranType)
        {
            var sql = "EXEC proc_exRateReport @flag = 'forexIrh'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @cCountry = " + FilterString(cCountry);
            sql += ", @cAgent = " + FilterString(cAgent);
            sql += ", @cBranch = " + FilterString(cBranch);
            sql += ", @cCurrency = " + FilterString(cCurrency);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pCurrency = " + FilterString(pCurrency);
            sql += ", @tranType = " + FilterString(tranType);

            return ExecuteDataset(sql);
        }

        public DataSet GetHistoryReportIrh(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string cCountry, string cAgent, string cBranch, string cCurrency, string pCountry, string pAgent, string pCurrency, string tranType, string filterByPCountryOnly, string fromDate, string toDate)
        {
            var sql = "EXEC proc_exRateReport @flag = 'historyIRH'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @cCountry = " + FilterString(cCountry);
            sql += ", @cAgent = " + FilterString(cAgent);
            sql += ", @cBranch = " + FilterString(cBranch);
            sql += ", @cCurrency = " + FilterString(cCurrency);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pCurrency = " + FilterString(pCurrency);
            sql += ", @tranType = " + FilterString(tranType);
            sql += ", @filterByPCountryOnly = " + FilterString(filterByPCountryOnly);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);

            return ExecuteDataset(sql);
        }

        public DataSet GetHistoryReportRsp(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string cCountry, string cAgent, string cBranch, string cCurrency, string pCountry, string pAgent, string pCurrency, string tranType)
        {
            var sql = "EXEC proc_exRateReport @flag = 'historyRSP'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @cCountry = " + FilterString(cCountry);
            sql += ", @cAgent = " + FilterString(cAgent);
            sql += ", @cBranch = " + FilterString(cBranch);
            sql += ", @cCurrency = " + FilterString(cCurrency);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pCurrency = " + FilterString(pCurrency);
            sql += ", @tranType = " + FilterString(tranType);

            return ExecuteDataset(sql);
        }

        public DataSet GetExRateTodayRegional(string user, string pageNumber, string pageSize, string sortBy, string sortOrder, string cCountry, string cAgent, string cBranch, string cCurrency, string pCountry, string pAgent, string pCurrency, string tranType)
        {
            var sql = "EXEC proc_exRateReport @flag = 'exRateRegional'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @sortBy = " + FilterString(sortBy);
            sql += ", @sortOrder = " + FilterString(sortOrder);
            sql += ", @cCountry = " + FilterString(cCountry);
            sql += ", @cAgent = " + FilterString(cAgent);
            sql += ", @cBranch = " + FilterString(cBranch);
            sql += ", @cCurrency = " + FilterString(cCurrency);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @pCurrency = " + FilterString(pCurrency);
            sql += ", @tranType = " + FilterString(tranType);

            return ExecuteDataset(sql);
        }
    }
}
