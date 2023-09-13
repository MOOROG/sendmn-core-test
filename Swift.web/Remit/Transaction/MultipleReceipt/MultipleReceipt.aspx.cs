using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.Transaction.MultipleReceipt
{
    public partial class MultipleReceipt : System.Web.UI.Page
    {
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private readonly ReceiptDao obj = new ReceiptDao();
        public const string GridName = "MultipleReceipt";
        private const string ViewFunctionId = "20191000";

        private const string ViewFunctionIdAgent = "40112000";
        string[] transactionIds;
      
        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            FetchData();
        }
        private void Authenticate()
        {
            sl.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
        }
        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
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
            DataTable tranData = obj.GetMultipleReceiptData(GetStatic.GetUser(), tranId);
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
            foreach (DataRow dr in tranData.Rows)
            {
                sb.AppendLine((GenerateReceipt(dr)));
            }

            rpt_grid.InnerHtml = sb.ToString();
        }
        public string GenerateReceipt(DataRow dr)
        {
            var sb = new StringBuilder("");

            sb.AppendLine("<table border=\"0\" width=\"100%\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td>");
            sb.AppendLine("<table width=\"100%;\" border=\"0\">");
            sb.AppendLine("<!--Header-->");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td>");
            sb.AppendLine("<table width=\"100%\" border=\"0\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td width=\"20%;\">");
            sb.AppendLine("<div class=\"logo\">");
            sb.AppendLine("<img src=\"/images/jme.png\"/>");
            sb.AppendLine("</div>");
            sb.AppendLine("<p>Kanto Finance Bureau License</p>");
            sb.AppendLine("<p>Number:<span>0006</span></p>");
            sb.AppendLine("</td>");
            sb.AppendLine("<td width=\"80%;\">");
            sb.AppendLine("<h3>"+ GetStatic.ReadWebConfig("jmeName", "") + " Japan</h3>");
            sb.AppendLine("<p>169-0073,Omori Building 4F(AB), Hyakunincho 1-10-07<p>");
            sb.AppendLine("<p>Shinjuku-ku, Tokyo, japan<p>");
            sb.AppendLine("<p>Tel:03-5475-3913,<span>Fax:03-5475-3913 </span><p>");
            sb.AppendLine("<p>email:info @japanremit.com<p>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");
            sb.AppendLine("<td>");
            sb.AppendLine("<table width=\"100%;\" border=\"0\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"2\" class=\"copy\" width=\"100%;\">");
            sb.AppendLine("<p style=\"text-decoration: underline;\">Customer Copy</p>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<!--body-->");
            sb.AppendLine("<tr valign=\"top\">");
            sb.AppendLine("<td width=\"80%;\">");
            sb.AppendLine("<table width=\"100%;\">");
            sb.AppendLine("<!--sender information-->");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td>");
            sb.AppendLine("<table width=\"100%;\" style=\"border: 1px solid #ccc; padding:5px;\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"4\"  class=\"details\"><h4>SENDER INFORMATION</h4></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td width=\"16%\" valign=\"top\"><label>Sender Name</label></td>");
            sb.AppendLine("<td width=\"28%\" valign=\"top\"><span class=\"sender-value\">" + dr["senderName"].ToString() + "</span></td>");
            sb.AppendLine("<td width=\"18%\" valign=\"top\"><label>Membership Card</label></td>");
            sb.AppendLine("<td width=\"28%\"><span class=\"sender-value\">" + dr["sMemId"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Address</label></td>");
            sb.AppendLine("<td colspan=\"3\"><span class=\"sender-value\">"+dr["sAddress"].ToString()+"</span></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Nationality</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">"+dr["sNativeCountry"].ToString()+"</span></td>");
            sb.AppendLine("<td><label>Purpose</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["purpose"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Date of birth</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["sDob"].ToString() + "</span></td>");
            sb.AppendLine("<td><label>Mobile No.</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["sContactNo"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<!--Receiver information-->");

            sb.AppendLine("<tr style=\" \">");
            sb.AppendLine("<td>");
            sb.AppendLine("<table width=\"100%;\" style=\"border:1px solid #ccc; padding:5px;\">");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"4\" class=\"details\"><h4>RECEIVER INFORMATION</h4></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Payout Country</label></ td >");
            sb.AppendLine("<td colspan=\"3\"><span class=\"sender-value\">"+dr["pAgentCountry"].ToString()+"</span></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td width=\"16%\" valign=\"top\"><label>Receiver's Name</label></td>");
            sb.AppendLine("<td width=\"38%\" valign=\"top\"><span class=\"sender-value\">" + dr["receiverName"].ToString()+"</span></td>");
            sb.AppendLine("<td width=\"18%\"><label>Payment Mode</label></td>");
            sb.AppendLine("<td width=\"28%\"><span class=\"sender-value\">"+dr["paymentMode"].ToString()+"</span></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Contact No</label></ td >");
            sb.AppendLine("<td><span class=\"sender-value\">"+dr["rContactNo"].ToString()+"</span></td>");
            sb.AppendLine("<td><label>Correspondent</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["pAgent"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Address</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">"+dr["rAddress"].ToString()+"</span></td>");
            sb.AppendLine("<td><label>Bank Name</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">"+dr["pBankName"].ToString()+"</span></td>");
            sb.AppendLine("</tr>");
            
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"2\"><label> &nbsp;</label></td>");
            sb.AppendLine("<td><label> Branch </label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["pBranchName"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"2\"><label> &nbsp;</label></td>");
            sb.AppendLine("<td><label>Account No</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["accountNo"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"4\"><p><em>Receive Amount NPR: <span>"+GetStatic.NumberToWord(dr["pAmt"].ToString()) + "</em></span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");

            sb.AppendLine("<td width=\"20%\" class=\"amount-info\">");
            sb.AppendLine("<table width=\"100%;\" border=\"1\" cellspacing=\"0\" cellpadding=\"0\">");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td><h2>PINNO:<span>" + dr["controlNo"].ToString() + "</span></h2></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>User:<span>" + dr["createdBy"].ToString() + "</span></p><p><span>" + dr["approvedDate"].ToString() + "</span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Collected Amount</p><h3><span>" + GetStatic.ShowWithoutDecimal(dr["cAmt"].ToString()) + " "+dr["collCurr"].ToString()+"</span></h3></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Service Charge</p><p><span>" + GetStatic.ShowWithoutDecimal(dr["serviceCharge"].ToString()) + "  " + dr["collCurr"].ToString() + "</span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Transfer Amount</p><p><span>" + GetStatic.ShowWithoutDecimal(dr["tAmt"].ToString()) + "  " + dr["collCurr"].ToString() + "</span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Exchange Rate</p><p><span> " + dr["exRate"].ToString() + " " + dr["payoutCurr"].ToString() + " </span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Receive Amount</p><h3><span>" + GetStatic.ShowDecimal(dr["pAmt"].ToString()) + " " + dr["payoutCurr"].ToString() + "</span></h3></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Serial:<span>315631</span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Deposite Type</p><p><span>Cash</span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");


            sb.AppendLine("<!--information section-->");
            sb.AppendLine("<tr valign=\"top\">");
            sb.AppendLine("<td colspan=\"2\">");
            sb.AppendLine("<table width=\"100%;\" style=\"border:1px solid #ccc; padding:5px;\">");
            sb.AppendLine("<tr valign=\"top\" style=\"height:30px;\">");
            sb.AppendLine("<td colspan=\"4\"><p>THE ABOVE INFORMATION IS CORRECT AND I DECLARE THAT I READ TERMS AND CONDITIONS</p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Customer's Signature</label></td>");
            sb.AppendLine("<td>..................................................</td>");
            sb.AppendLine("<td><label>Operator:("+dr["createdBy"].ToString()+")</label></td>");
            sb.AppendLine("<td>..................................................</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("<table width=\"100%;\" style=\"margin:15px 0;\">");
            sb.AppendLine("<tr><td><center>-----------------------------------------------------------------Cut From Here-----------------------------------------------------------------</center></td></tr>");
            sb.AppendLine("</table>");

            sb.AppendLine("<table border=\"0\" width=\"100%\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td>");
            sb.AppendLine("<table width=\"100%;\" border=\"0\">");
            sb.AppendLine("<!--Header-->");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td>");
            sb.AppendLine("<table width=\"100%\" border=\"0\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td width=\"20%;\">");
            sb.AppendLine("<div class=\"logo\">");
            sb.AppendLine("<img src=\"/images/jme.png\"/>");
            sb.AppendLine("</div>");
            sb.AppendLine("<p>Kanto Finance Bureau License</p>");
            sb.AppendLine("<p>Number:<span>0006</span></p>");
            sb.AppendLine("</td>");
            sb.AppendLine("<td width=\"80%;\">");
            sb.AppendLine("<h3>"+ GetStatic.ReadWebConfig("jmeName", "") + " Japan</h3>");
            sb.AppendLine("<p>169-0073,Omori Building 4F(AB), Hyakunincho 1-10-07<p>");
            sb.AppendLine("<p>Shinjuku-ku, Tokyo, japan<p>");
            sb.AppendLine("<p>Tel:03-5475-3913,<span>Fax:03-5475-3913 </span><p>");
            sb.AppendLine("<p>email:info @japanremit.com<p>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");
            sb.AppendLine("<td>");
            sb.AppendLine("<table width=\"100%;\" border=\"0\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"2\" class=\"copy\" width=\"100%;\">");
            sb.AppendLine("<p style=\"text-decoration: underline;\">Office Copy</p>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<!--body-->");
            sb.AppendLine("<tr valign=\"top\">");
            sb.AppendLine("<td width=\"80%;\">");
            sb.AppendLine("<table width=\"100%;\">");
            sb.AppendLine("<!--sender information-->");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td>");
            sb.AppendLine("<table width=\"100%;\" style=\"border: 1px solid #ccc; padding:5px;\">");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"4\"  class=\"details\"><h4>SENDER INFORMATION</h4></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td width=\"16%\" valign=\"top\"><label>Sender Name</label></td>");
            sb.AppendLine("<td width=\"28%\" valign=\"top\"><span class=\"sender-value\">" + dr["senderName"].ToString() + "</span></td>");
            sb.AppendLine("<td width=\"18%\" valign=\"top\"><label>Membership Card</label></td>");
            sb.AppendLine("<td width=\"28%\"><span class=\"sender-value\">" + dr["sMemId"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Address</label></td>");
            sb.AppendLine("<td colspan=\"3\"><span class=\"sender-value\">" + dr["sAddress"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Nationality</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["sNativeCountry"].ToString() + "</span></td>");
            sb.AppendLine("<td><label>Purpose</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["purpose"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Date of birth</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["sDob"].ToString() + "</span></td>");
            sb.AppendLine("<td><label>Mobile No.</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["sContactNo"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<!--Receiver information-->");

            sb.AppendLine("<tr style=\" \">");
            sb.AppendLine("<td>");
            sb.AppendLine("<table width=\"100%;\" style=\"border:1px solid #ccc; padding:5px;\">");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"4\" class=\"details\"><h4>RECEIVER INFORMATION</h4></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Payout Country</label></ td >");
            sb.AppendLine("<td colspan=\"3\"><span class=\"sender-value\">" + dr["pAgentCountry"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td width=\"16%\" valign=\"top\"><label>Receiver's Name</label></td>");
            sb.AppendLine("<td width=\"38%\" valign=\"top\"><span class=\"sender-value\">" + dr["receiverName"].ToString() + "</span></td>");
            sb.AppendLine("<td width=\"18%\"><label>Payment Mode</label></td>");
            sb.AppendLine("<td width=\"28%\"><span class=\"sender-value\">" + dr["paymentMode"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Contact No</label></ td >");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["rContactNo"].ToString() + "</span></td>");
            sb.AppendLine("<td><label>Correspondent</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["pAgent"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Address</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["rAddress"].ToString() + "</span></td>");
            sb.AppendLine("<td><label>Bank Name</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["pBankName"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"2\"><label> &nbsp;</label></td>");
            sb.AppendLine("<td><label> Branch </label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["pBranchName"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"2\"><label> &nbsp;</label></td>");
            sb.AppendLine("<td><label>Account No</label></td>");
            sb.AppendLine("<td><span class=\"sender-value\">" + dr["accountNo"].ToString() + "</span></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td colspan=\"4\"><p><em>Receive Amount NPR: <span>" + GetStatic.NumberToWord(dr["pAmt"].ToString()) + "</em></span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");

            sb.AppendLine("<td width=\"20%\" class=\"amount-info\">");
            sb.AppendLine("<table width=\"100%;\" border=\"1\" cellspacing=\"0\" cellpadding=\"0\">");

            sb.AppendLine("<tr>");
            sb.AppendLine("<td><h2>PINNO:<span>" + dr["controlNo"].ToString() + "</span></h2></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>User:<span>" + dr["createdBy"].ToString() + "</span></p><p><span>" + dr["approvedDate"].ToString() + "</span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Collected Amount</p><h3><span>" + GetStatic.ShowWithoutDecimal(dr["cAmt"].ToString()) + " " + dr["collCurr"].ToString() + "</span></h3></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Service Charge</p><p><span>" + GetStatic.ShowWithoutDecimal(dr["serviceCharge"].ToString()) + "  " + dr["collCurr"].ToString() + "</span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Transfer Amount</p><p><span>" + GetStatic.ShowWithoutDecimal(dr["tAmt"].ToString()) + "  " + dr["collCurr"].ToString() + "</span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Exchange Rate</p><p><span> " + dr["exRate"].ToString() + " " + dr["payoutCurr"].ToString() + " </span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Receive Amount</p><h3><span>" + GetStatic.ShowDecimal(dr["pAmt"].ToString()) + " " + dr["payoutCurr"].ToString() + "</span></h3></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Serial:<span>315631</span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><p>Deposite Type</p><p><span>Cash</span></p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");


            sb.AppendLine("<!--information section-->");
            sb.AppendLine("<tr valign=\"top\">");
            sb.AppendLine("<td colspan=\"2\">");
            sb.AppendLine("<table width=\"100%;\" style=\"border:1px solid #ccc; padding:5px;\">");
            sb.AppendLine("<tr valign=\"top\" style=\"height:30px;\">");
            sb.AppendLine("<td colspan=\"4\"><p>THE ABOVE INFORMATION IS CORRECT AND I DECLARE THAT I READ TERMS AND CONDITIONS</p></td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td><label>Customer's Signature</label></td>");
            sb.AppendLine("<td>..................................................</td>");
            sb.AppendLine("<td><label>Operator:(" + dr["createdBy"].ToString() + ")</label></td>");
            sb.AppendLine("<td>..................................................</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("</td>");
            sb.AppendLine("</tr>");
            sb.AppendLine("</table>");
            sb.AppendLine("<footer></footer>");
          
            return sb.ToString();
        }
    }
}