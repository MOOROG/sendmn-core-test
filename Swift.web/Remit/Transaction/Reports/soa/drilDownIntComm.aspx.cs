using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.soa
{
    public partial class drilDownIntComm : System.Web.UI.Page
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
            var TRAN_TYPE = GetStatic.ReadQueryString("TRAN_TYPE", "");

            lblAgentName.Text = sl.GetAgentNameByMapCodeInt(agent);
            lblFrmDate.Text = fromDate;
            lbltoDate.Text = toDate;
            lblGeneratedDate.Text = DateTime.Now.ToString("MM/dd/yyyy");

            DataTable dt = rptDao.AgentSoaDrilldownReportIntComm(fromDate, toDate, agent, flag, TRAN_TYPE);

            int cols = dt.Columns.Count;
            var str = new StringBuilder("<div class='table-responcive'><table class='table table-responsive table-bordered table-striped' border=\"1\" cellspacing=0 cellpadding=\"3\">");

            str.Append("<tr>");
            str.Append("<th><div align=\"left\">SN</div></th>");
            str.Append("<th><div align=\"left\">Date</div></th>");
            str.Append("<th><div align=\"left\">Particulars</div></th>");
            str.Append("<th><div align=\"right\">Amount</div></th>");
            str.Append("</tr>");

            int cnt = 0;
            double BAL = 0.00;

            if (dt.Rows.Count == 0)
            {
                str.Append("<tr><td colspan='4'><b>No Record Found</td></tr></table>");
                rptDiv.InnerHtml = str.ToString();
                return;
            }
            foreach (DataRow dr in dt.Rows)
            {
                cnt = cnt + 1;

                str.Append("<tr>");
                str.Append("<td>" + cnt + "</td>");
                for (int i = 0; i < cols; i++)
                {
                    if (i == 4)
                    {
                        BAL = BAL + double.Parse(dr[i].ToString());
                        str.Append("<td><div align=\"right\">" + GetStatic.ShowDecimal(dr[i].ToString()) + "</div></td>");
                    }
                    else if (i == 0 || i == 2)
                        str.Append("<td><div align=\"left\">" + dr[i] + "</div></td>");
                }
                str.Append("</tr>");
            }

            str.Append("<tr>");
            str.Append("<td  colspan='3'><div align=\"right\"><b>Total</b> </div></td>");
            str.Append("<td><div align=\"right\"><b>" + GetStatic.ShowDecimal(BAL.ToString()) + "</b></div></td>");
            str.Append("</tr>");
            str.Append("</table></div>");
            rptDiv.InnerHtml = str.ToString();

        }
    }
}