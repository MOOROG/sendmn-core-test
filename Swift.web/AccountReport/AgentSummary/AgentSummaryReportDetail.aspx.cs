using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.AgentSummary
{
    public partial class AgentSummaryReportDetail : System.Web.UI.Page
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
            string agentGrp = GetStatic.ReadQueryString("agentGrp", "");
            string agentId = GetStatic.ReadQueryString("agentId", "");
            string date = GetStatic.ReadQueryString("date", "");
            string tranType = GetStatic.ReadQueryString("tranType", "");

            string sql = "Exec  proc_agentDebitBalance_weekly  @FLAG ='RPT',@agentGrp=" + _swiftLib.FilterString(agentGrp) + ",@agentId=" + _swiftLib.FilterString(agentId) + " ,@date=" + _swiftLib.FilterString(date) + " ,@trantype=" + _swiftLib.FilterString(tranType) + "";

            StringBuilder sb = new StringBuilder("<table class=\"table table-striped table-bordered\" cellspacing=\"0\"><tr>");
            sb.AppendLine("<th><strong>SN.</strong></th>");
            sb.AppendLine("<th><strong>Agent Name</strong></th>");
            sb.AppendLine("<th><strong>Agent Group </strong></th>");
            sb.AppendLine("<th><strong>Type </strong></th>");
            sb.AppendLine("<th><strong></strong></th>");
            sb.AppendLine("<th><strong></strong></th>");
            sb.AppendLine("<th><strong></strong></th>");
            sb.AppendLine("<th><strong></strong></th>");
            sb.AppendLine("<th><strong></strong></th>");
            sb.AppendLine("<th><strong></strong></th>");
            sb.AppendLine("<th><strong></strong></th>");
            sb.AppendLine("<th><strong>Total</strong></td>");
            sb.AppendLine("</tr>");

            DataTable dt = _swiftLib.ExecuteDataTable(sql);
            if (dt.Rows.Count == 0 || dt.Rows == null)
            {
                sb.AppendLine("<tr><td colspan=\"12\" align=\"center\">No Data to display</td></tr></table>");
                tblMain.InnerHtml = sb.ToString();
                return;
            }

            int sNo = 1;
            double firstSum = 0;
            double secondSum = 0;
            double thirdSum = 0;
            double fourthSum = 0;
            double fifthSum = 0;
            double sixthSum = 0;
            double seventhSum = 0;
            double totalBal = 0;

            foreach (DataRow item in dt.Rows)
            {
                firstSum += GetStatic.ParseDouble(item["First"].ToString());
                secondSum += GetStatic.ParseDouble(item["Second"].ToString());
                thirdSum += GetStatic.ParseDouble(item["Third"].ToString());
                fourthSum += GetStatic.ParseDouble(item["Fourth"].ToString());
                fifthSum += GetStatic.ParseDouble(item["Fifth"].ToString());
                sixthSum += GetStatic.ParseDouble(item["Sixth"].ToString());
                seventhSum += GetStatic.ParseDouble(item["Seventh"].ToString());
                totalBal += GetStatic.ParseDouble(item["Sum Balance"].ToString());

                sb.AppendLine("<tr>");
                sb.AppendLine("<td>" + sNo + "</td>");
                sb.AppendLine("<td>" + item["acct_name"].ToString() + "</td>");
                sb.AppendLine("<td>" + item["Agent Group"].ToString() + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["First"].ToString()) + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["Second"].ToString()) + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["Third"].ToString()) + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["Fourth"].ToString()) + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["Fifth"].ToString()) + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["Sixth"].ToString()) + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["Seventh"].ToString()) + "</td>");
                sb.AppendLine("<td>" + GetStatic.ShowDecimal(item["Sum Balance"].ToString()) + "</td>");
                sb.AppendLine("</tr>");
                sNo++;
            }

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"4\" align=\"right\">Total</td>");
            sb.AppendLine("<td align=\"right\">" + GetStatic.ShowDecimal(firstSum.ToString()) + "</td>");
            sb.AppendLine("<td align=\"right\">" + GetStatic.ShowDecimal(secondSum.ToString()) + "</td>");
            sb.AppendLine("<td align=\"right\">" + GetStatic.ShowDecimal(thirdSum.ToString()) + "</td>");
            sb.AppendLine("<td align=\"right\">" + GetStatic.ShowDecimal(fourthSum.ToString()) + "</td>");
            sb.AppendLine("<td align=\"right\">" + GetStatic.ShowDecimal(fifthSum.ToString()) + "</td>");
            sb.AppendLine("<td align=\"right\">" + GetStatic.ShowDecimal(sixthSum.ToString()) + "</td>");
            sb.AppendLine("<td align=\"right\">" + GetStatic.ShowDecimal(seventhSum.ToString()) + "</td>");
            sb.AppendLine("<td align=\"right\">" + GetStatic.ShowDecimal(totalBal.ToString()) + "</td>");
            sb.AppendLine("</tr></table>");

            tblMain.InnerHtml = sb.ToString();
        }

        protected void pdf_Click(object sender, EventArgs e)
        {
        }
    }
}