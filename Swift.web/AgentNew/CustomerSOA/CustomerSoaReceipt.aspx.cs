using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.CustomerSOA
{
    public partial class CustomerSoaReceipt : System.Web.UI.Page
    {
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private readonly CustomersDao obj = new CustomersDao();
        public const string GridName = "CustomerSoa";
        private const string ViewFunctionId = "20308000";
        private string[] transactionIds;
        private string toDate;
        private string fromDate;

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            if (!IsPostBack)
            {
                //Authenticate();
                GetStatic.PrintMessage(Page);
            }
            FetchData();
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        public void FetchData()
        {
            string tranId = GetStatic.ReadSession("tranIds", "");

            //if (string.IsNullOrEmpty(tranId))
            //{
            //    DbResult dbRes = new DbResult
            //    {
            //        ErrorCode = "1",
            //        Msg = "No transaction selected"
            //    };
            //    GetStatic.SetMessage(dbRes);
            //    Response.Redirect("");
            //}
            DataTable tranData = obj.GetCustomerSoaData(GetStatic.GetUser(), tranId, "");
            PrepareHtml(tranData);
        }

        public void PrepareHtml(DataTable tranData)
        {
            var sb = new StringBuilder("");
            if (tranData.Rows.Count <= 0 || tranData.Rows == null)
            {
                sb.AppendLine("<tr>");
                sb.AppendLine("<td colspan='6' align='center'>");
                sb.AppendLine("No Data To Display ");
                sb.AppendLine("</td>");
                sb.AppendLine("</tr>");
                // tblMain.InnerHtml = sb.ToString();
                return;
            }

            sb.AppendLine((GenerateReceipt(tranData)));
            //foreach (DataRow dr in tranData.Rows)
            //{
            //    sb.AppendLine((GenerateReceipt(dr)));
            //}

            rpt_grid.InnerHtml = sb.ToString();
        }

        public string GenerateReceipt(DataTable dt)
        {
            DataRow firstRow = dt.Rows[0];
            var sb = new StringBuilder("");
          
            txtperiod.InnerText = GetStatic.ReadQueryString("fromDate", "-") + " TO " + GetStatic.ReadQueryString("toDate", "-");
            txtPrintDate.InnerText = firstRow["PrintTime"].ToString();
            txtName.InnerText = firstRow["senderName"].ToString();
            txtCustomerId.InnerText = firstRow["sCustomerId"].ToString();
            txtAddress.InnerText = firstRow["sAddress"].ToString();
            txtDob.InnerText = firstRow["sdob"].ToString();
            int sNo = 1;
            double totalAmt = 0;
            foreach (DataRow dr in dt.Rows)
            {
                totalAmt += Convert.ToDouble(dr["tAmt"].ToString());
                DateTime date = DateTime.Parse(dr["approvedDate"].ToString());
                string approvedDate = date.ToString("yyyy-MM-dd");
                sb.AppendLine("<tr class=\"table-info\">");
                sb.AppendLine("<td style=\"white-space:nowrap\">" + sNo + "</td>");
                sb.AppendLine("<td style=\"white-space:nowrap\">" + approvedDate + "</td>");
                sb.AppendLine("<td style=\"white-space:nowrap\">" + dr["receiverName"].ToString() + "</td>");
                sb.AppendLine("<td style=\"white-space:nowrap\">生活費支援<br> (" + dr["purpose"].ToString() + ")</td>");
                sb.AppendLine("<td class=\"tright\" style=\"white-space:nowrap\">" + GetStatic.ShowDecimal(dr["tAmt"].ToString()) + "" + dr["collCurr"].ToString() + "</td>");
                sb.AppendLine("<td class=\"tright\" style=\"white-space:nowrap\">" + dr["exRate"].ToString() + "</td>");
                sb.AppendLine("<td class=\"tright\" style=\"white-space:nowrap\">" + GetStatic.ShowDecimal(dr["pAmt"].ToString()) + "  " + dr["payoutCurr"].ToString() + " </td>");
                sb.AppendLine("</tr>");
                sNo++;
            }

            sb.AppendLine("<tr class=\"total\">");
            sb.AppendLine("<td>&nbsp;</td>");
            sb.AppendLine("<td colspan=\"3\" class=\"tright\">TOTAL</td>");
            sb.AppendLine(" <td class=\"tright\">" + GetStatic.ShowDecimal(totalAmt.ToString()) + "</td>");
            sb.AppendLine("<td>&nbsp;</td>");
            sb.AppendLine("<td>&nbsp;</td>");

            return sb.ToString();
        }
    }
}