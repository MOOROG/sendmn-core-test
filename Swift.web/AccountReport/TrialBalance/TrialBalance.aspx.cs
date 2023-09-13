using Swift.DAL.AccountReport;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web;

namespace Swift.web.AccountReport.TrialBalance
{
    public partial class TrialBalance : System.Web.UI.Page
    {
        private string startDate = null;
        private string endDate = null;
        private string reportType = null;
        private SwiftLibrary _sl = new SwiftLibrary();
        private AccountStatementDAO st = new AccountStatementDAO();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                GenerateTrialBalance();
            }
        }

        protected string FromDate()
        {
            return GetStatic.ReadQueryString("fromDate", "");
        }

        protected string ToDate()
        {
            return GetStatic.ReadQueryString("toDate", "");
        }

        protected string ReportType()
        {
            return GetStatic.ReadQueryString("report_Type", "");
        }

        private void GenerateTrialBalance()
        {
            header.Text = GetStatic.getCompanyHead();
            startDate = FromDate();
            endDate = ToDate();
            reportType = ReportType();

            if (reportType == "d")
            {
                Response.Redirect("TrialBalanceAccWise.aspx?fromDate=" + startDate + "&toDate=" + endDate + "&report_Type=" + reportType + "");
            }
            fromDate.Text = startDate;
            toDate.Text = endDate;

            var dt = st.GetTrialBalance(startDate, endDate, reportType);
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }

            var sb = new StringBuilder();
            double drOpen = 0, crClose = 0;
            double crOpen = 0, drClose = 0;
            double crTurnOver = 0, drTurnOver = 0;
            int sNo = 1;

            foreach (DataRow item in dt.Rows)
            {
                sb.AppendLine("<tr>");

                drOpen += GetStatic.ParseDouble(item["dr_opening"].ToString());
                crOpen += GetStatic.ParseDouble(item["cr_opening"].ToString());
                drTurnOver += GetStatic.ParseDouble(item["dr_turnover"].ToString());
                crClose += GetStatic.ParseDouble(item["cr_closing"].ToString());
                drClose += GetStatic.ParseDouble(item["dr_closing"].ToString());
                crTurnOver += GetStatic.ParseDouble(item["cr_turnover"].ToString());

                sb.AppendLine("<td nowrap='nowrap' align='center' >" + sNo + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='left'> <a href='../BalanceSheet/SubLedger.aspx?dt=" + endDate + "&st=" + startDate + "&mapcode=" + item["gl"] + "&head=" + item["gl_name"] + "&treeSape=" + item["tree_sape"] + "' title='Account Statement'>" + item["gl_name"] + "</a></td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.ShowDecimal(item["dr_opening"].ToString()) + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.ShowDecimal(item["cr_opening"].ToString()) + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.ShowDecimal(item["dr_turnover"].ToString()) + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.ShowDecimal(item["cr_turnover"].ToString()) + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.ShowDecimal(item["dr_closing"].ToString()) + " </td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.ShowDecimal(item["cr_closing"].ToString()) + " </td>");
                sb.AppendLine("</tr>");
                sNo++;
            }
            trialSheet.InnerHtml = sb.ToString();
            crOpening.Text = GetStatic.ShowDecimal(crOpen.ToString());
            drOpening.Text = GetStatic.ShowDecimal(drOpen.ToString());
            drTurn.Text = GetStatic.ShowDecimal(drTurnOver.ToString());
            crTurn.Text = GetStatic.ShowDecimal(crTurnOver.ToString());
            drClosing.Text = GetStatic.ShowDecimal(drClose.ToString());
            crClosing.Text = GetStatic.ShowDecimal(crClose.ToString());
        }

        protected void pdf_Click(object sender, EventArgs e)
        {
            GetStatic.GetPDF(HttpUtility.UrlDecode(hidden.Value));
        }
    }
}