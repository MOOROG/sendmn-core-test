using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.SettlementDetailReport
{
    public partial class DetailTxtReportDetail : System.Web.UI.Page
    {
        private SwiftLibrary _swiftLib = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateGrid();
            }
        }

        private void PopulateGrid()
        {
            string agentId = GetStatic.ReadQueryString("agentId", "");
            string fromDate = GetStatic.ReadQueryString("fromDate", "");
            string toDate = GetStatic.ReadQueryString("toDate", "");

            string sql = "Exec proc_settlementDetailRpt @flag='rpt',@fromDate=" + _swiftLib.FilterString(fromDate) + " ,@toDate=" + _swiftLib.FilterString(toDate) + ",@agentId=" + _swiftLib.FilterString(fromDate) + "";

            DataTable dt = _swiftLib.ExecuteDataTable(sql);
            if (dt.Rows.Count == 0 || dt.Rows == null)
            {
                return;
            }

            int sNo = 0;
            int grandPaidTxnCountIntl = 0;
            double grandPaidTxnAmtIntl = 0;
            int grandSendTxnCountDom = 0;
            double grandSendTxnAmtDom = 0;
            int grandPaidTxnCountDom = 0;
            double grandPaidTxnAmtDom = 0;
            int grandCancelTxnCountDom = 0;
            double grandCancelTxnAmtDom = 0;
            int grandEpTxnCount = 0;
            double grandEpTxnAmt = 0;
            int grandPoTxnCount = 0;
            double grandPoTxnAmt = 0;
            double grandTotAmt = 0;
            StringBuilder sb = new StringBuilder("");

            foreach (DataRow item in dt.Rows)
            {
                grandPaidTxnCountIntl += GetStatic.ParseInt(item["paidTxnCountIntl"].ToString());
                grandSendTxnCountDom += GetStatic.ParseInt(item["paidTxnCountIntl"].ToString());
                grandPaidTxnCountDom += GetStatic.ParseInt(item["paidTxnCountIntl"].ToString());
                grandCancelTxnCountDom += GetStatic.ParseInt(item["paidTxnCountIntl"].ToString());
                grandEpTxnCount += GetStatic.ParseInt(item["paidTxnCountIntl"].ToString());
                grandPoTxnCount += GetStatic.ParseInt(item["paidTxnCountIntl"].ToString());
                grandPaidTxnAmtIntl += GetStatic.ParseDouble(item["paidTxnAmtIntl"].ToString());
                grandSendTxnAmtDom += GetStatic.ParseDouble(item["paidTxnAmtIntl"].ToString());
                grandPaidTxnAmtDom += GetStatic.ParseDouble(item["paidTxnAmtIntl"].ToString());
                grandCancelTxnAmtDom += GetStatic.ParseDouble(item["paidTxnAmtIntl"].ToString());
                grandEpTxnAmt += GetStatic.ParseDouble(item["paidTxnAmtIntl"].ToString());
                grandPoTxnAmt += GetStatic.ParseDouble(item["paidTxnAmtIntl"].ToString());
                grandTotAmt += GetStatic.ParseDouble(item["paidTxnAmtIntl"].ToString());

                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + sNo + "</td>");
                sb.AppendLine("<td>" + item["Date"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["branchName"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["paidTxnCountIntl"].ToString() + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["paidTxnAmtIntl"].ToString()) + "</td>");
                sb.AppendLine("<td>" + item["sendTxnCountDom"].ToString() + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["sendTxnAmtDom"].ToString()) + "</td>");
                sb.AppendLine("<td>" + item["paidTxnCountDom"].ToString() + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["paidTxnAmtDom"].ToString()) + "</td>");
                sb.AppendLine("<td>" + item["cancelTxnCountDom"].ToString() + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["cancelTxnAmtDom"].ToString()) + "</td>");
                sb.AppendLine("<td>" + item["epTxnCount"].ToString() + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["epTxnAmt"].ToString()) + "</td>");
                sb.AppendLine("<td>" + item["poTxnCount"].ToString() + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["poTxnAmt"].ToString()) + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["totAmt"].ToString()) + "</td>");
                sb.AppendLine("<tr>");
            }
        }
    }
}