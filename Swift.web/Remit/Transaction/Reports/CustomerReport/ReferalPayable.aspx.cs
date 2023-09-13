using Swift.DAL.Remittance.Transaction;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.Reports.CustomerReport
{
    public partial class ReferalPayable : System.Web.UI.Page
    {
        private SwiftLibrary _sl = new SwiftLibrary();
        private TranReportDao1 st = new TranReportDao1();
        private const string PayableFuncId = "2021910";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                startDate.Value = GetStatic.ReadQueryString("s", "");
                endDate.Value = GetStatic.ReadQueryString("e", "");
            }
            GenerateReport();
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(PayableFuncId);
        }

        protected string ReferralCode()
        {
            return GetStatic.ReadQueryString("r", "");
        }
        private void GenerateReport()
        {
            var dt = st.GetPromotionalCampaign(GetStatic.GetUser(), startDate.Value, endDate.Value, ReferralCode());

            if (dt == null || dt.Rows.Count == 0)
            {
                tableBody.InnerHtml = "No record found!";
                return;
            }
            if (dt.Rows[0]["errorCode"].ToString() == "1")
            {
                tableBody.InnerHtml = dt.Rows[0]["msg"].ToString();
                return;
            } 
            var sb = new StringBuilder("");

            sb.AppendLine("  <div class=\"table-responsive\"><table class=\"table table-striped table-bordered\" width=\"100%\" cellspacing=\"0\" class=\"TBLReport\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<th nowrap='nowrap'>SN</th>");
            sb.AppendLine("<th nowrap='nowrap'>Referral Name</th>");
            sb.AppendLine("<th nowrap='nowrap'>Referral Code</th>");
            sb.AppendLine("<th nowrap='nowrap'>No of First Txn.</th>");
            sb.AppendLine("<th nowrap='nowrap'>No of Other Txn.</th>");
            sb.AppendLine("<th nowrap='nowrap'>Net Payable</th>");
            sb.AppendLine("<th nowrap='nowrap'>Action</th>");
            sb.AppendLine("</tr>");

            double BAlance = 0;
            int firstTxn = 0, otherTxn = 0;
            int sn = 1;
            foreach (DataRow item in dt.Rows)
            {
                BAlance += GetStatic.ParseDouble(item["NetPayable"].ToString());
                firstTxn += GetStatic.ParseInt(item["FirstTxn"].ToString());
                otherTxn += GetStatic.ParseInt(item["RestTxn"].ToString());

                sb.AppendLine("<tr>");

                sb.AppendLine("<td  >" + (sn > 0 ? sn.ToString() : "") + " </td>");
                sb.AppendLine("<td nowrap >" + item["ReferalName"] + " </td>");
                sb.AppendLine("<td >" + item["referelCode"] + " </td>");
                sb.AppendLine("<td  align='center' >" + item["FirstTxn"] + " </td>");
                sb.AppendLine("<td  align='center' >" + item["RestTxn"] + " </td>");
                sb.AppendLine("<td  align='right' >" + GetStatic.ShowAbsDecimal(item["NetPayable"].ToString()) + " </td>");

                var drLink = "<a class='btn btn-danger' onclick=PayAmount('" + item["referelCode"].ToString() + "') href='#' title='Transaction info' > Click To Pay </a>";

                sb.AppendLine("<td  >" + drLink + " </td>");

                sb.AppendLine("</tr>");
                sn++;
            }
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan='3' ><strong>TOTAL</strong></td>");
            sb.AppendLine("<td align='center' >" + firstTxn.ToString() + " </td>");
            sb.AppendLine("<td align='center' >" + otherTxn.ToString() + " </td>");
            sb.AppendLine("<td align='right' >" + GetStatic.ShowAbsDecimal(BAlance.ToString()) + " </td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table></div>");
            tableBody.InnerHtml = sb.ToString();
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            var dbResponse = st.PayPromotionalCampaign(GetStatic.GetUser(), startDate.Value, endDate.Value, ReferralCode());
        }
    }
}