using System.Data;
using Swift.DAL.Library;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.AgentPanel.Reports
{
    public class SOAMonthlyDao : SwiftDao
    {
        #region soa report

        public ReportResult GetSoaLogReport(string user, string id)
        {
            var sql = "EXEC proc_soaMonthlyLog @flag='report', @id=" + FilterString(id) + ",@user=" + FilterString(user);
            return ParseReportResult(sql);
        }

        public DataTable AgentSoaReport(string fromDate, string toDate, string agentId, string trnType, string rptType)
        {
            string sql = "";

            if (rptType == "soa")
            {
                sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_V2] @flag = 'SOA'";
                sql += ", @AGENT = " + FilterString(agentId);
                sql += ", @DATE1 = " + FilterString(fromDate);
                sql += ", @DATE2 = " + FilterString(toDate);
                sql += ", @TRN_TYPE = " + FilterString(trnType);
            }
            else if (rptType == "dcom")
            {
                sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_DOMESTIC_COMM_V2] @flag = 'SOA'";
                sql += ", @AGENT = " + FilterString(agentId);
                sql += ", @DATE1 = " + FilterString(fromDate);
                sql += ", @DATE2 = " + FilterString(toDate);
                sql += ", @TRN_TYPE = " + FilterString(trnType);
            }
            else if (rptType == "icom")
            {
                sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_INTERNATIONAL_COMM_V2] @flag = 'SOA'";
                sql += ", @AGENT = " + FilterString(agentId);
                sql += ", @DATE1 = " + FilterString(fromDate);
                sql += ", @DATE2 = " + FilterString(toDate);
                sql += ", @TRN_TYPE = " + FilterString(trnType);
            }

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable AgentSoaDrilldownReport(string fromDate, string toDate, string agentId, string flag, string trnType)
        {
            string sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_V2] ";
            sql += "  @AGENT = " + FilterString(agentId);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @TRN_TYPE = " + FilterString(trnType);

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable AgentSoaDrilldownUserReport(string fromDate, string toDate, string agentId, string branchId, string agentId2, string flag, string trnType)
        {
            string sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_V2] ";
            sql += "  @AGENT = " + FilterString(agentId);
            sql += ", @BRANCH = " + FilterString(branchId);
            sql += ", @AGENT2 = " + FilterString(agentId2);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @TRN_TYPE = " + FilterString(trnType);

            return ExecuteDataset(sql).Tables[0];
        }

        public DataTable AgentSoaDrilldownReportDComm(string fromDate, string toDate, string agentId, string flag, string trnType)
        {
            string sql = "EXEC " + GetUtilityDAO.AccountDbName() + ".[dbo].[PROC_AGENT_SOA_DOMESTIC_COMM_V2] ";
            sql += "  @AGENT = " + FilterString(agentId);
            sql += ", @DATE1 = " + FilterString(fromDate);
            sql += ", @DATE2 = " + FilterString(toDate);
            sql += ", @flag = " + FilterString(flag);
            sql += ", @TRN_TYPE = " + FilterString(trnType);

            return ExecuteDataset(sql).Tables[0];
        }

        #endregion soa report

        public DbResult SOAMonthlyLog(string user, string agentId, string branchId, string fromDate, string toDate,
                string soaType, string message, string logType, string year, string month)
        {
            string sql = "EXEC proc_soaMonthlyLog";
            sql += "  @flag = 'i'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @soaType = " + FilterString(soaType);
            sql += ", @message = '" + message + "'";
            sql += ", @logType = " + FilterString(logType);
            sql += ", @npYear = " + FilterString(year);
            sql += ", @npMonth = " + FilterString(month);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public string GetDate(string engDate, string nepDate)
        {
            string sql = "Exec proc_convertDate @flag='A',@engDate=" + FilterString(engDate) + ",@nepDate=" + FilterString(nepDate) + "";
            string ds = GetSingleResult(sql);
            return ds;
        }

        public DbResult SendMail(string user, string agentId, string branchId, string createdDate, string message)
        {
            string sql = "EXEC proc_soaMonthlyLog";
            sql += "  @flag = 'sendMail'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @createdDate = " + FilterString(createdDate);
            sql += ", @message = " + FilterString(message);

            return ParseDbResult(ExecuteDataset(sql).Tables[0]);
        }

        public DbResult ButtonShowHide(string user, string agentId, string branchId, string fromDate, string toDate, string soaType)
        {
            string sql = "Exec proc_soaMonthlyLog";
            sql += "  @flag = 'btnHideShow'";
            sql += ", @user = " + FilterString(user);
            sql += ", @agentId = " + FilterString(agentId);
            sql += ", @branchId = " + FilterString(branchId);
            sql += ", @fromDate = " + FilterString(fromDate);
            sql += ", @toDate = " + FilterString(toDate);
            sql += ", @soaType = " + FilterString(soaType);
            return ParseDbResult(sql);
        }

        public DataRow GetNepYrMonth(string user)
        {
            string sql = "EXEC proc_soaMonthlyLog @flag ='GetCurrNepYM'";
            sql += ", @user = " + FilterString(user);

            DataSet ds = ExecuteDataset(sql);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
                return null;
            return ds.Tables[0].Rows[0];
        }
    }
}