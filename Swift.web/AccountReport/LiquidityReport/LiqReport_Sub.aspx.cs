using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AccountReport.LiquidityReport
{
    public partial class LiqReport_Sub : System.Web.UI.Page
    {
        private SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                PopulateGrid();
        }

        private void PopulateGrid()
        {
            string fromDate = GetStatic.ReadQueryString("dt", "");
            string company_id = GetStatic.ReadQueryString("company_id", "");
            string mapCode = GetStatic.ReadQueryString("mapcode", "");
            string treeSape = GetStatic.ReadQueryString("tree_sape", "");
            string sql = "Exec balancesheetDrilldown2 @flag=2" + ",@date2=" + sl.FilterString(fromDate) + ",@mapcode=" + sl.FilterString(mapCode) + ",@company_id=" + sl.FilterString(company_id) + ",@tree_sape=" + sl.FilterString(treeSape) + "";

            StringBuilder sb = new StringBuilder("<table class=\"table table-striped table-bordered\" cellspacing=\"0\"><tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td nowrap><strong>SN</strong></td>");
            sb.AppendLine("<td nowrap><strong>Sub Group Name </strong></td>");
            sb.AppendLine("<td nowrap><div align=\"right\"><strong>DR&nbsp;</strong></div></td>");
            sb.AppendLine("<td nowrap><div align=\"right\"><strong>CR</strong></div></td>");
            sb.AppendLine("<td nowrap><div align=\"right\"><strong>Balance&nbsp;</strong></div></td>");
            sb.AppendLine("</tr>");
            DataTable dt = sl.ExecuteDataTable(sql);
            if (dt.Rows.Count == 0 || dt.Rows == null)
            {
                sb.AppendLine("<tr><td colspan=\"12\" align=\"center\">No Data to display</td></tr></table>");
                tblRpt.InnerHtml = sb.ToString();
                return;
            }
            int count = 1;
            int i = 0;
            int balance = 0;
            int dr = 0;
            int cr = 0;
            while (i != dt.Rows.Count)
            {
                balance += Convert.ToInt32(dt.Rows[i]["Total"]);
                dr += Convert.ToInt32(dt.Rows[i]["DR"]);
                cr += Convert.ToInt32(dt.Rows[i]["CR"]);

                sb.AppendLine("<tr>");
                sb.AppendLine("<td nowrap>" + count + "</td>");
                sb.AppendLine("<td nowrap>" + dt.Rows[i]["acct_name"] + "</td>");
                sb.AppendLine("<td nowrap><div align=\"right\">" + dt.Rows[i]["DR"] + "</div></td>");
                sb.AppendLine("<td nowrap><div align=\"right\">" + dt.Rows[i]["CR"] + "</div></td>");
                sb.AppendLine("<td nowrap>");
                sb.AppendLine("<div align=\"right\"><a href=\"LiqReport_Sub.aspx?company_id=" + sl.FilterString(company_id) + "&dt=" + sl.FilterString(fromDate) + "&mapcode=" + sl.FilterString(dt.Rows[i]["acct_num"].ToString()) + "&head=" + sl.FilterString(dt.Rows[i]["acct_name"].ToString()) + "&tree_sape=" + sl.FilterString(dt.Rows[i]["tree_sape"].ToString()) + "&title=\"Account Statement\">" + dt.Rows[i]["Total"] + "</a></div></td>");
                sb.AppendLine("</tr>");
                count++;
                i++;
            }
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"2\" nowrap><div align=\"right\"><strong>TOTAL:</strong></div></td>");
            sb.AppendLine("<td nowrap><div align=\"right\"><strong>" + dr + "</strong></div></td>");
            sb.AppendLine("<td nowrap><div align=\"right\"><strong>" + cr + "</strong></div></td>");
            sb.AppendLine("<td nowrap><div align=\"right\"><strong>" + balance + "</strong></div></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            tblRpt.InnerHtml = sb.ToString();

            ///

            string sql2 = "Exec balancesheetDrilldown2 @flag=3" + ",@date2=" + sl.FilterString(fromDate) + ",@mapcode=" + sl.FilterString(mapCode) + ",@company_id=" + sl.FilterString(company_id) + ",@tree_sape=" + sl.FilterString(treeSape) + "";

            StringBuilder sb2 = new StringBuilder("<table class=\"table table-striped table-bordered\" cellspacing=\"0\"><tr>");
            sb2.AppendLine("<tr>");
            sb2.AppendLine("<td nowrap ><strong>SN</strong></td>");
            sb2.AppendLine("<td  nowrap><strong>AC Num </strong></td>");
            sb2.AppendLine("<td  nowrap ><strong>AC Name </strong></td>");
            sb2.AppendLine("<td  nowrap ><strong>DR Closing </strong></td>");
            sb2.AppendLine("<td  nowrap ><strong>CR Closing&nbsp;</strong></td>");
            sb2.AppendLine("<td  nowrap ><div align=\"right\"><strong>Balance&nbsp;</strong></div></td>");
            sb2.AppendLine("</tr>");

            DataTable dt2 = sl.ExecuteDataTable(sql2);
            if (dt2.Rows.Count == 0 || dt2.Rows == null)
            {
                sb.AppendLine("<tr><td colspan=\"12\" align=\"center\">No Data to display</td></tr></table>");
                tblSecRpt.InnerHtml = sb.ToString();
                return;
            }

            int sn = 1;
            int j = 0;
            int balance2 = 0;
            int dr_closing = 0;
            int cr_closing = 0;
            int acBalance = 0;
            while (j != dt2.Rows.Count)
            {
                acBalance += Convert.ToInt32(dt2.Rows[j]["Total"]);
                balance2 += Convert.ToInt32(dt2.Rows[j]["Total"]);
                dr_closing += Convert.ToInt32(dt2.Rows[j]["dr_closing"]);
                cr_closing += Convert.ToInt32(dt2.Rows[j]["cr_closing"]);
                sb2.AppendLine("<tr>");
                sb2.AppendLine("<td nowrap>" + sn + "</td>");
                sb2.AppendLine("<td nowrap><a href=\"LiquidityStatementResult.aspx?company_id=" + sl.FilterString(company_id) + "&end_date=" + sl.FilterString(fromDate) + "&ac_num=" + sl.FilterString("acct_num") + "@title=\"Account Statement\" >" + dt2.Rows[j]["acct_num"] + "</a></td>");
                sb2.AppendLine("<td>" + dt2.Rows[j]["acct_name"] + "</td>");
                sb2.AppendLine("<td nowrap><div align=\"right\">" + dt2.Rows[j]["dr_closing"] + "</div></td>");
                sb2.AppendLine("<td nowrap><div align=\"right\">" + dt2.Rows[j]["cr_closing"] + "</div></td>");
                sb2.AppendLine("<td nowrap><div align=\"right\">" + dt2.Rows[j]["total"] + "</div></td>");
                sb2.AppendLine("</tr>");
                sn++;
                j++;
            }

            sb2.AppendLine("<tr>");
            sb2.AppendLine("<td colspan=\"3\" nowrap><div align=\"right\"><strong>TOTAL:</strong></div></td>");
            sb2.AppendLine("<td nowrap><div align=\"right\"><strong>" + dr_closing + "</strong></div></td>");
            sb2.AppendLine("<td nowrap><div align=\"right\"><strong>" + cr_closing + "</strong></div></td>");
            sb2.AppendLine("<td nowrap><div align=\"right\"><strong>" + acBalance + "</strong></div></td>");
            sb2.AppendLine("</tr>");
            sb2.AppendLine("</table>");
            tblSecRpt.InnerHtml = sb2.ToString();
        }
    }
}