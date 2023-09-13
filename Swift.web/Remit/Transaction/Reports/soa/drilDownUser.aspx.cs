using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.soa
{
    public partial class drilDownUser : System.Web.UI.Page
    {
        private readonly TranReportDao rptDao = new TranReportDao();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            string mode = GetStatic.ReadQueryString("mode", "").ToLower();
            if (mode == "download")
            {
                string format = "xls";
                string reportName = "soa";
                Response.Clear();
                Response.ClearContent();
                Response.ClearHeaders();
                Response.ContentType = "application/vnd.ms-excel";
                Response.AddHeader("Content-Disposition", "attachment; filename=" + reportName + "." + format);
                exportDiv.Visible = false;
            }
            LoadSoaHtml();
        }
        private void LoadSoaHtml()
        {
            var flag = GetStatic.ReadQueryString("flag", "");

            switch (flag)
            {
                case "PAY_DETAIL":
                    rptDetail.Text = " >> Paid Principal Detail";
                    break;
                case "PCOM_DETAIL":
                    rptDetail.Text = " >> Paid Commission Detail";
                    break;
                case "CNL_DETAIL":
                    rptDetail.Text = " >> Canceled Principal Detail";
                    break;
                case "CNLCOM_DETAIL":
                    rptDetail.Text = " >> Canceled Commission Detail";
                    break;
                case "SEND_DETAIL":
                    rptDetail.Text = " >> Send Principal Detail";
                    break;
                case "SCOM_DETAIL":
                    rptDetail.Text = " >> Send Commission Detail";
                    break;
                default:
                    break;
            }

            var fromDate = GetStatic.ReadQueryString("DATE1", "");
            var toDate = GetStatic.ReadQueryString("DATE2", "");
            var agent = GetStatic.ReadQueryString("AGENT", "");
            var branch = GetStatic.ReadQueryString("BRANCH", "");
            var agent2 = GetStatic.ReadQueryString("AGENT2", "");
            var tranType = GetStatic.ReadQueryString("TRAN_TYPE", "");

            lblAgentName.Text = sl.GetAgentNameByMapCodeInt(agent);
            lblFrmDate.Text = fromDate;
            lbltoDate.Text = toDate;
            lblGeneratedDate.Text = DateTime.Now.ToString("MM/dd/yyyy");

            DataTable dt = rptDao.AgentSoaDrilldownUserReport(fromDate, toDate, agent, branch, agent2, flag, tranType);

            int cols = dt.Columns.Count;
            var str = new StringBuilder("<div class='table-responcive'><table class='table table-responsive table-bordered table-striped' border=\"1\" cellspacing=0 cellpadding=\"3\">");

            str.Append("<tr>");
            for (int i = 0; i < cols; i++)
            {
                str.Append("<th><div align=\"left\">" + dt.Columns[i].ColumnName + "</div></th>");
            }
            str.Append("</tr>");
            if (dt.Rows.Count == 0)
            {
                str.Append("<tr><td colspan='" + cols + "'><b>No Record Found</td></tr></table>");
                rptDiv.InnerHtml = str.ToString();
                return;
            }
            double totAmt = 0.00;
            foreach (DataRow dr in dt.Rows)
            {
                str.Append("<tr>");
                for (int i = 0; i < cols; i++)
                {
                    if (i == 5)
                    {
                        totAmt = totAmt + double.Parse(dr[i].ToString());
                        str.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</div></td>");
                    }
                    else
                        str.Append("<td><div align=\"left\">" + dr[i] + "</div></td>");
                }
                str.Append("</tr>");
            }

            str.Append("<tr>");
            str.Append("<td  colspan='5'><div align=\"right\"><b>Total</b> </div></td>");
            str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(totAmt.ToString()) + "</b></div></td>");
            str.Append("<td>&nbsp;</td>");
            str.Append("</tr>");
            str.Append("</table></div>");
            rptDiv.InnerHtml = str.ToString();
        }
    }
}