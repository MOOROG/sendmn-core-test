using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.DAL.AccountReport
{
    public class  AccountReportDao : SwiftDao
    {
        public ReportResult GetIntMonthlyReport(String sagentId, String ragentId, String fromDate, String toDate, String dateType, String paymentStatus, String reportType)
        {
            string sql="";
            if (reportType == "s")
            {
                sql = "Exec procAgentSummaryReportMonthly ";
                sql += " @flag=" + FilterString(dateType);
                sql += ", @dateform =" + FilterString(fromDate);
                sql += " ,@dateto =" + FilterString(toDate);
                sql += ", @agent =" + FilterString(sagentId);
                sql += ", @ragent =" + FilterString(ragentId);
                sql += " ,@pay_status =" + FilterString(paymentStatus);
                sql += " ,@reportType =" + FilterString(reportType);
            }
            else if (reportType == "p")
            {
                sql = "Exec procAgentSummaryReportReceiving ";
                sql += " @flag=" + FilterString(dateType);
                sql += ", @dateform =" + FilterString(fromDate);
                sql += " ,@dateto =" + FilterString(toDate);
                sql += ", @agent =" + FilterString(sagentId);
                sql += " ,@pay_status =" + FilterString(paymentStatus);
                sql += " ,@req_type =" + FilterString(reportType);
            }
            return ParseReportResult(sql);
        }

        public ReportResult GetIntShowCentralizeReport(string agentId, string fromDate, string toDate, string dateType, string paymentStatus)
        {
            string sql = "Exec procAgentSummaryReportReceiving @req_type='c'";
            sql += " ,@flag=" + FilterString(dateType);
            sql += ", @dateform =" + FilterString(fromDate);
            sql += " ,@dateto =" + FilterString(toDate);
            sql += ", @agent =" + FilterString(agentId);
            sql += " ,@pay_status =" + FilterString(paymentStatus);
            return ParseReportResult(sql);
        }
        public ReportResult GetIntShowReport(string agentId, string fromDate, string toDate, string dateType, string paymentStatus)
        {
            string sql = "Exec procAgentSummaryReportReceiving";
            sql += " @flag=" + FilterString(dateType);
            sql += ", @dateform =" + FilterString(fromDate);
            sql += " ,@dateto =" + FilterString(toDate);
            sql += ", @agent =" + FilterString(agentId);
            sql += " ,@pay_status =" + FilterString(paymentStatus);
            return ParseReportResult(sql);
        }
        public ReportResult GetIntOldReport(string agentId, string fromDate, string toDate, string dateType, string paymentStatus)
        {
            string sql = "Exec procAgentSummaryReport";
            sql += " @flag=" + FilterString(dateType);
            sql += ", @dateform =" + FilterString(fromDate);
            sql += " ,@dateto =" + FilterString(toDate);
            sql += ", @agent =" + FilterString(agentId);
            sql += " ,@pay_status =" + FilterString(paymentStatus);
            return ParseReportResult(sql);
        }
        public ReportResult GetIntNewReport(string agentId, string fromDate, string toDate, string dateType, string paymentStatus)
        {
            string sql = "Exec procAgentSummaryReport_new";
            sql += " @flag=" + FilterString(dateType);
            sql += ", @dateform =" + FilterString(fromDate);
            sql += " ,@dateto =" + FilterString(toDate);
            sql += ", @agent =" + FilterString(agentId);
            sql += " ,@pay_status =" + FilterString(paymentStatus);
            return ParseReportResult(sql);
        }
        public ReportResult GetIntlReconcileRpt(string sDate, string eDate)
        {
            string sql = "Exec Proc_ReconcileReport @flag='a' ";
            sql += " ,@date =" + FilterString(sDate);
            sql += ", @date2 =" + FilterString(eDate);
            return ParseReportResult(sql);
        }
        public ReportResult GetDomesticTxnReport(string user, string agentId, string fromDate, string todate, string DateType, string payment_status, string type)
        {
            string sql = "EXEC procLocalAgentSummaryReport ";
            sql += " @flag = " + FilterString(DateType);
            sql += ", @user = " + FilterString(user);
            sql += ", @dateform = " + FilterString(fromDate);
            sql += ", @dateto = " + FilterString(todate);
            sql += ", @agent = " + FilterString(agentId);
            sql += ", @PAY_STATUS = " + FilterString(payment_status);
            sql += ", @type = " + FilterString(type);
            return ParseReportResult(sql);
        }

        public ReportResult GetDomesticReceivingTxnReport(string user, string agentId, string fromDate, string todate, string DateType, string payment_status, string type)
        {
            string sql = "EXEC procLocalAgentSummaryReportReceiving ";
            sql += " @flag = " + FilterString(DateType);
            sql += ", @user = " + FilterString(user);
            sql += ", @dateform = " + FilterString(fromDate);
            sql += ", @dateto = " + FilterString(todate);
            sql += ", @agent = " + FilterString(agentId);
            sql += ", @PAY_STATUS = " + FilterString(payment_status);
            sql += ", @type = " + FilterString(type);
            return ParseReportResult(sql);
        }
        public ReportResult GetNrbDetailReport(string flag, string fromDate, string todate, string agentId)
        {
            string sql = "EXEC procNRBDetailReport";
            sql += " @flag = " + FilterString(flag);
            sql += ", @dateform = " + FilterString(fromDate);
            sql += ", @dateto = " + FilterString(todate);
            sql += ", @agent = " + FilterString(agentId);
            return ParseReportResult(sql);

        }

        public ReportResult GetNrbProcessReport(string dateFrom, string dateTo, string agentId)
        {
            string sql = "EXEC procAgentDepositReport";
            sql += " @dateform = " + FilterString(dateFrom);
            sql += ", @dateto = " + FilterString(dateTo);
            sql += ", @agent = " + FilterString(agentId);
            return ParseReportResult(sql);
        }

        public ReportResult GetPaidTxnReport(string fromDate, string toDate, string dateType, string reportType)
        {
            string sql = "EXEC proc_paidTxnReport";
            sql += " @FROMDATE = " + FilterString(fromDate);
            sql += ", @TODATE = " + FilterString(toDate);
            sql += ", @DATETYPE = " + FilterString(dateType);
            sql += ", @REPORTTYPE = " + FilterString(reportType);
            return ParseReportResult(sql);
        }

        public ReportResult GetDomesticSettlementReport(string fromDate)
        {
            string sql = "Exec [proc_DomesticSettelmentReport]";
            sql = sql + "@flag= " + FilterString("a");
            sql = sql + ",@date= " + FilterString(fromDate);
            return ParseReportResult(sql);
        }

        public ReportResult GetTxnDetailRpt(string fromDate, string toDate, string agentId)
        {
            string sql = "Exec proc_settlementDetailRpt @flag='rpt'";
            sql += ",@fromDate=" + FilterString(fromDate) + "";
            sql += ",@toDate=" + FilterString(toDate) + "";
            sql += ",@agentId=" + FilterString(agentId) + "";

            return ParseReportResult(sql);
        }

        public ReportResult GetSettlementHoRptDrillDown(string fromDate, string toDate, string agentId, string branch, string user, string country, string flag)
        {
            string sql = "Exec PROC_SETTLEMENT_REPORT @FLAG =" + FilterString(flag) + "";
            sql += ",@AGENT=" + FilterString(agentId) + "";
            sql += ",@DATE1=" + FilterString(fromDate) + "";
            sql += ",@DATE2=" + FilterString(toDate) + "";
            sql += ",@BRANCH=" + FilterString(branch) + "";
            sql += ",@USER=" + FilterString(user) + "";
            sql += ",@COUNTRY=" + FilterString(country) + "";

            return ParseReportResult(sql);
        }

        public ReportResult GetSettlementHoRpt(string fromDate, string toDate, string agentId, string branch, string user)
        {
            string sql = "Exec PROC_SETTLEMENT_REPORT @FLAG='m'";
            sql += ",@AGENT=" + FilterString(agentId) + "";
            sql += ",@DATE1=" + FilterString(fromDate) + "";
            sql += ",@DATE2=" + FilterString(toDate) + "";
            sql += ",@BRANCH=" + FilterString(branch) + "";
            sql += ",@USER=" + FilterString(user) + "";

            return ParseReportResult(sql);
        }

        public ReportResult GetAgentSummaryRpt(string agentGroup, string date, string tranType, string agentId)
        {
            string sql = "Exec proc_agentDebitBalance_weekly @FLAG='RPT'";
            sql += ",@agentGrp=" + FilterString(agentGroup) + "";
            sql += ",@agentId=" + FilterString(agentId) + "";
            sql += ",@date=" + FilterString(date) + "";
            sql += ",@trantype=" + FilterString(tranType) + "";

            return ParseReportResult(sql);
        }

        public ReportResult GetDailySettlemetReport(string fromDate, string toDate)
        {
            string sql = "exec Proc_dailySettlementReport @flag='dsr'";
            sql += ",@FROMDATE=" + FilterString(fromDate) + "";
            sql += ",@TODATE=" + FilterString(toDate) + "";

            return ParseReportResult(sql);
        }
        public ReportResult GetInternational_OldRpt(string agentId, string fromDate, string toDate, string dateType, string paymentStatus)
        {
            string sql = "Exec procAgentSummaryReport @flag=" + FilterString(dateType);
            sql = sql + ",@agent= " + FilterString(agentId);
            sql = sql + ",@dateform= " + FilterString(fromDate);
            sql = sql + ",@dateto= " + FilterString(toDate);
            // sql = sql + "@dateType= " + FilterString(dateType);
            sql = sql + ",@pay_status= " + FilterString(paymentStatus);
            return ParseReportResult(sql);
        }
        public ReportResult GetIndividualTxnRpt(string icn)
        {
            string sql = "exec Proc_dailySettlementReport @flag='icn', @ICN=" + FilterString(icn) + "";

            return ParseReportResult(sql);

        }

        public ReportResult GetTdsReport(string fromDate, string party)
        {
            string sql = "Exec CommissionAndTDSreport ";
            sql += " @date1=" + FilterString(fromDate);
            sql += ",@agentid=" + FilterString(party);
            return ParseReportResult(sql);
        }
        public ReportResult GetCompileReport(string asOnDate, string agentCode, string includeZeroValue, string bankCode, string fromDrAmt, string toDrAmt, string fromCrAmt, string toCrAmt)
        {
            string sql = "Exec proc_compileReport_web @flag='A'";
            sql += ",@DATE=" + FilterString(asOnDate);
            sql += ",@SAGENT=" + FilterString(agentCode);
            sql += ",@INCLUDEZERO=" + FilterString(includeZeroValue);
            sql += ",@BANKCODE=" + FilterString(bankCode);
            sql += ",@DR1=" + FilterString(fromDrAmt);
            sql += ",@DR2=" + FilterString(toDrAmt);
            sql += ",@CR1=" + FilterString(fromCrAmt);
            sql += ",@CR2=" + FilterString(toCrAmt);
            return ParseReportResult(sql);
        }

        public ReportResult CurrencyPositionRpt(string user, string startDate, string endDate, string flag)
        {
            string sql = "EXEC proc_StockPositionReport @flag = '" + flag + "'";
            sql += ",@fromDate = " + FilterString(startDate);
            sql += ",@toDate = " + FilterString(endDate);
            sql += ",@user = " + FilterString(user);
            return ParseReportResult(sql);
        }
        public ReportResult MultiCurrencyClosingRpt(string user, string asOnDate, string partner)
        {
            string sql = "EXEC proc_multiCurrencyClosingReport @flag = 'rpt'";
            sql += ",@asOnDate = " + FilterString(asOnDate);
            sql += ",@partner = " + FilterString(partner);
            sql += ",@user = " + FilterString(user);
            return ParseReportResult(sql);
        }
    }
}
