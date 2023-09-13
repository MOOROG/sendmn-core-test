using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentNew.Reports.CustomerStatementReport
{
    public partial class TxnStatement : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20111600";
        private SwiftLibrary _sl = new SwiftLibrary();
        private readonly CustomersDao _obj = new CustomersDao();
        protected int rowSpan = 23;

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            GenerateReport();
        }

        protected string StartDate()
        {
            return GetStatic.ReadQueryString("startDate", "");
        }

        protected string EndDate()
        {
            return GetStatic.ReadQueryString("endDate", "");
        }

        protected string IdNumber()
        {
            return GetStatic.ReadQueryString("acNum", "");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void GenerateReport()
        {
            startDate.Text = StartDate();
            endDate.Text = EndDate();
            lblToday.Text = DateTime.Now.ToString("yyyy-MM-dd");
            idNumber.Text = IdNumber();
            var dt = _obj.GetCustomerTxnStatement(IdNumber(), StartDate(), EndDate(), GetStatic.GetUser());
            if (dt == null || dt.Rows.Count == 0)
            {
                return;
            }
            senderName.Text = dt.Rows[0]["senderName"].ToString();
            var sb = new StringBuilder("");

            sb.AppendLine("  <div class=\"table-responsive\" style='font-size:11px !important;'><table class=\"table table-striped table-bordered\" >");
            sb.AppendLine("<tr>");
            sb.AppendLine("<th nowrap='nowrap'>Tran Date</th>");
            sb.AppendLine("<th nowrap='nowrap'>"+ GetStatic.ReadWebConfig("jmeName", "") + " Number</th>");
            sb.AppendLine("<th nowrap='nowrap'>Receiver's Name</th>");
            sb.AppendLine("<th nowrap='nowrap'>Sending Amount<br>(JPY)</th>");
            sb.AppendLine("<th nowrap='nowrap'>Paying Amount</th>");
            sb.AppendLine("</tr>");

            double sending = 0, paying = 0;

            foreach (DataRow item in dt.Rows)
            {
                rowSpan--;
                sending += GetStatic.ParseDouble(item["cAmt"].ToString());
                paying += GetStatic.ParseDouble(item["pAmt"].ToString());

                sb.AppendLine("<tr>");
                sb.AppendLine("<td nowrap='nowrap'>" + item["createdDate"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap'>" + item["controlNo"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap'>" + item["receiverName"].ToString() + "</td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.GetNegativeFigureOnBrac(item["cAmt"].ToString()) + "</td>");
                sb.AppendLine("<td nowrap='nowrap' align='right'>" + GetStatic.GetNegativeFigureOnBrac(item["pAmt"].ToString()) + " (" + item["payoutCurr"].ToString() + ")</td>");
                sb.AppendLine("</tr>");
            }
            string br = "";
            for (int i = 0; i < rowSpan; i++)
            {
                br += "<br/>";
            }
            rowSpanDiv.InnerHtml = br;
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan='3' align='right'><strong>Total : </td>");
            sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac(sending.ToString()) + "</td>");
            //sb.AppendLine("<td align='right'>" + GetStatic.GetNegativeFigureOnBrac(paying.ToString()) + "</td>");
            sb.AppendLine("<td>&nbsp;</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table></div>");

            divStmt.InnerHtml = sb.ToString();
        }
    }
}