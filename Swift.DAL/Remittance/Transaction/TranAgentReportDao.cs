using Swift.DAL.Library;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.Remit.Transaction
{
    public class TranAgentReportDao : RemittanceDao
    {
        public ReportResult GetUserwiseReport(string user, string sAgent, string sBranch, string userName, string fromDate, string toDate,
            string rptType, string rCountry, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_UserwiseTxnDetail ";
            sql += "  @user = " + FilterString(user);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @userName = " + FilterString(userName);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(rptType);
            sql += ", @rCountry = " + FilterString(rCountry);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public DataSet getDailyCashReportTransactionWise(string user, string fromDate, string toDate, string introducer)
        {
            string sql = "EXEC proc_DailyTxnRpt @flag ='dailyTxnRptCash' ";
            sql += ",  @user = " + FilterString(user);
            sql += ",  @fromDate = " + FilterString(fromDate);
            sql += ",  @toDate = " + FilterString(toDate);
            sql += ",  @referralCode = " + FilterString(introducer);

            return ExecuteDataset(sql);
        }

        public DataSet getUnPostTransaction(string user)
        {
            string sql = "EXEC proc_DailyTxnRpt @flag ='unPostTransaction' ";
            sql += ",  @user = " + FilterString(user);

            return ExecuteDataset(sql);
        }

        public ReportResult Get_40111600_Report(string user, string pCountry, string pAgent, string sBranch, string depositType
        , string orderBy, string status, string paymentType, string dateField, string from, string to, string transType, string displayTranNo,
        string searchBy, string searchByValue, string pageNumber, string pageSize, string rptType)
        {
            string sql = "EXEC proc_RSPTXN_report ";
            sql += " @user=" + FilterString(user);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgent = " + FilterString(pAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @depositType = " + FilterString(depositType);
            sql += ", @orderBy = " + FilterString(orderBy);
            sql += ", @status = " + FilterString(status);
            sql += ", @paymentType = " + FilterString(paymentType);
            sql += ", @dateField = " + FilterString(dateField);
            sql += ", @dateFrom = " + FilterString(from);
            sql += ", @dateTo = " + FilterString(to);
            sql += ", @transType = " + FilterString(transType);
            sql += ", @displayTranNo = " + FilterString(displayTranNo);
            sql += ", @searchBy = " + FilterString(searchBy);

            sql += ", @searchByValue = " + FilterString(searchByValue);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @rptType = " + FilterString(rptType);

            return ParseReportResult(sql);
        }

        public ReportResult GetTxnSummaryReport(string user, string sBranch, string sAgent, string pCountry, string pAgentId, string status, string dateType
            , string fromDate, string toDate, string rptType, string countryBankId, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_GetRSPTxnSummaryReport ";
            sql += "  @user = " + FilterString(user);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @pAgentId = " + FilterString(pAgentId);
            sql += ", @status = " + FilterString(status);
            sql += ", @DateType = " + FilterString(dateType);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(rptType);
            sql += ", @countryBankId = " + FilterString(countryBankId);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetholdTxnreportReport(string user, string fromDate, string toDate, string rptType, string pageNumber, string pageSize, string branchId)
        {
            string sql = "EXEC proc_GetholdTxnreportReport ";
            sql += "  @user = " + FilterString(user);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @rptType = " + FilterString(rptType);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            sql += ", @branchId = " + FilterString(branchId);

            return ParseReportResult(sql);
        }

        public ReportResult GetSettlement(string user, string pCountry, string sAgent, string sBranch, string fromDate, string toDate, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_settlement ";
            sql += "  @flag = 's'";
            sql += ", @user = " + FilterString(user);
            sql += ", @pCountry = " + FilterString(pCountry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);

            return ParseReportResult(sql);
        }

        public ReportResult GetSettlementDdl(string user, string pCoutry, string sAgent, string sBranch, string fromDate, string toDate, string pageNumber, string pageSize, string flag)
        {
            string sql = "EXEC proc_settlementDdl ";
            sql += " @user = " + FilterString(user);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @pCountry = " + FilterString(pCoutry);
            sql += ", @sAgent = " + FilterString(sAgent);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @pageNumber = " + FilterString(pageNumber);
            sql += ", @pageSize = " + FilterString(pageSize);
            return ParseReportResult(sql);
        }

        public ReportResult GetCancelReport(string user, string pCoutry, string sBranch, string fromDate, string toDate, string cancelType, string pageNumber, string pageSize)
        {
            string sql = "EXEC proc_cancelRpt ";
            sql += " @user = " + FilterString(user);
            sql += ", @pCountry = " + FilterString(pCoutry);
            sql += ", @sBranch = " + FilterString(sBranch);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @cancelType = " + FilterString(cancelType);
            return ParseReportResult(sql);
        }

        public DataTable AgentSoaReport(string fromDate, string toDate, string agentId)
        {
            string sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_INT] @flag = 'SOA'";
            sql += ", @AGENT = " + FilterString(agentId);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);

            return ExecuteDataTable(sql);
        }

        public DataTable AgentSoaReportAgentNew(string fromDate, string toDate, string agentId, string branchId, string user)
        {
            string sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_V3] @flag = 'SOA'";
            sql += ", @AGENT = " + FilterString(agentId);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @BRANCH = " + FilterString(branchId);
            sql += ", @user = " + FilterString(user);

            return ExecuteDataTable(sql);
        }

        public string AgentCurrency(string agentId)
        {
            string sql = "EXEC proc_dropDownLists @flag = 'agentSettCurr'";
            sql += ", @agentId = " + FilterString(agentId);

            return GetSingleResult(sql);
        }

        public DataTable AgentSoaDrilldownReport(string fromDate, string toDate, string agentId, string flag)
        {
            string sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_INT] ";
            sql += "  @AGENT = " + FilterString(agentId);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(flag);

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable AgentSoaDrilldownReportNew(string fromDate, string toDate, string agentId, string flag, string branch, string FLAG2)
        {
            string sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_V3] ";
            sql += "  @AGENT = " + FilterString(agentId);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @BRANCH = " + FilterString(branch);
            sql += ", @FLAG2 = " + FilterString(FLAG2);

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable AdminSoaDrilldownReportNew(string fromDate, string toDate, string agentId, string flag, string branch, string FLAG2, string rptName)
        {
            string sql = "";
            if (rptName.ToLower().Equals("statementofaccountrec"))
                sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_V3_RECEIVE_ADMIN]";
            else
                sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_V3_SEND_ADMIN]";

            sql += "  @AGENT = " + FilterString(agentId);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @BRANCH = " + FilterString(branch);
            sql += ", @FLAG2 = " + FilterString(FLAG2);

            return ExecuteDataset(sql).Tables[0];
        }

        public ReportResult GetBonusPoint(string user, string fromDate, string toDate, string orderBy, string membershipId, string branchId)
        {
            var sql = "proc_bonusRpt @flag='bonusPoint'";
            sql += ",@user=" + FilterString(user);
            sql += ",@mFrom=" + FilterString(fromDate);
            sql += ",@mTo=" + FilterString(toDate);
            sql += ",@orderBy=" + FilterString(orderBy);
            sql += ",@membershipId =" + FilterString(membershipId);
            sql += ",@branchId=" + FilterString(branchId);
            return ParseReportResult(sql);
        }

        public ReportResult GetBonusRedeemed(string user, string fromDate, string toDate, string orderBy, string membershipId, string giftItem, string branchId)
        {
            var sql = "proc_bonusRpt @flag='bonusRedeemed'";
            sql += ",@user=" + FilterString(user);
            sql += ",@fromDate=" + FilterString(fromDate);
            sql += ",@toDate=" + FilterString(toDate);
            sql += ",@orderBy=" + FilterString(orderBy);
            sql += ",@membershipId =" + FilterString(membershipId);
            sql += ",@prizeId =" + FilterString(giftItem);
            sql += ",@branchId=" + FilterString(branchId);

            return ParseReportResult(sql);
        }

        public DataTable StatementOfAccount(string user, string fromDate, string toDate, string agentId, string branch, string rptType, string rptName, string userId = "", string country = "")
        {
            string sql = "";
            //if (rptName.ToLower().Equals("statementofaccountrec"))
            //    sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_V3_RECEIVE_ADMIN] @flag = 'SOA'";
            //else
            //sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_V3_SEND_ADMIN] @flag = 'SOA'";

            if (rptName.ToLower().Equals("statementofaccountrec"))
                sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_V3_SEND_ADMIN] @flag = 'SOA-Receive'";
            else
                sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_V3_SEND_ADMIN] @flag = 'SOA'";

            sql += ", @AGENT = " + FilterString(agentId);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @BRANCH = " + FilterString(branch);
            sql += ", @ACCTYPE = " + FilterString(rptType);
            sql += ", @userId = " + FilterString(userId);
            sql += ", @country = " + FilterString(country);
            return ExecuteDataset(sql).Tables[0];
        }

        public ReportResult GetAgentWiseReferrerReport(string user, string fromDate, string toDate, string referralCode)
        {
            var sql = "PROC_REFERRAL_REPORT @flag='S'";
            sql += ",@user=" + FilterString(user);
            sql += ",@FROM_DATE=" + FilterString(fromDate);
            sql += ",@TO_DATE=" + FilterString(toDate);
            sql += ",@REFERRAL_CODE=" + FilterString(referralCode);
            return ParseReportResult(sql);
        }

        public ReportResult GetReferral(string user, string controlNo, string tranNo)
        {
            var sql = "PROC_REFERRAL_REPORT @flag='checkReferral'";
            sql += ",@user=" + FilterString(user);
            sql += ",@controlNo=" + FilterString(controlNo);
            sql += ",@tranNo=" + FilterString(tranNo);
            return ParseReportResult(sql);
        }

        public ReportResult PrepareJpDepositList(string user, string particulars, string txnDate, string amount)
        {
            var sql = "proc_DailyTxnRpt @flag='depositListNew'";
            sql += ",@user=" + FilterString(user);
            sql += ",@particulars=N" + FilterString(particulars);
            sql += ",@trandate=" + FilterString(txnDate);
            sql += ",@depositAmount=" + FilterString(amount);
            return ParseReportResult(sql);
        }

        public ReportResult GetRejectedReport(string user, string flag, string fromDate, string toDate, string agentId, string branchId, string withAgent)
        {
            var sql = "PROC_REGISTRATION_REPORT ";
            sql += "@flag =" + FilterString(flag); ;
            sql += ",@user=" + FilterString(user);
            sql += ",@FROM_DATE=" + FilterString(fromDate);
            sql += ",@TO_DATE=" + FilterString(toDate);
            sql += ",@agentId=" + FilterString(agentId);
            sql += ",@branchId=" + FilterString(branchId);
            sql += ",@withAgent=" + FilterString(withAgent);
            return ParseReportResult(sql);
        }

        public ReportResult GetNewRegistrationReport(string user, string flag, string fromDate, string toDate, string agentId, string branchId, string withAgent)
        {
            var sql = "PROC_REGISTRATION_REPORT ";
            sql += "@flag =" + FilterString(flag); ;
            sql += ",@user=" + FilterString(user);
            sql += ",@FROM_DATE=" + FilterString(fromDate);
            sql += ",@TO_DATE=" + FilterString(toDate);
            sql += ",@agentId=" + FilterString(agentId);
            sql += ",@branchId=" + FilterString(branchId);
            sql += ",@withAgent=" + FilterString(withAgent);
            return ParseReportResult(sql);
        }

        public ReportResult GetCustomerHistory(string user, string flag, string customerId)
        {
            var sql = "proc_DailyTxnRpt ";
            sql += "@flag =" + FilterString(flag); ;
            sql += ",@user=" + FilterString(user);
            sql += ",@customerId=" + FilterString(customerId);
            return ParseReportResult(sql);
        }
    }
}