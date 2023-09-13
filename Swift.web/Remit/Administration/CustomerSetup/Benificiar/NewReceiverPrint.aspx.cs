using Swift.DAL.Remittance.Administration.ReceiverInformation;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.Remit.Administration.CustomerSetup.Benificiar
{
    public partial class NewReceiverPrint : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20193010";
        private const string PrintFunctionId = "20193020";
        private const string ViewFunctionIdAgent = "20900000";
        private const string PrintFunctionIdAgent = "20900010";
        private readonly ReceiverInformationDAO informationDAO = new ReceiverInformationDAO();
        private readonly RemittanceLibrary remittanceLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            remittanceLibrary.CheckSession();
            populateForm();
        }

        private void Authenticate()
        {
            remittanceLibrary.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId) + "," + GetFunctionIdByUserType(PrintFunctionIdAgent, PrintFunctionId));
        }

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }

        private void populateForm()
        {
            StringBuilder sb = new StringBuilder();
            var receiverIds = GetStatic.ReadSession("receiverIds", "");

            var data = informationDAO.GetAllReceiverSenderDataForPrint(receiverIds, GetStatic.GetUser());
            foreach (DataRow item in data.Rows)
            {
                sb.Append(ReceiverPageByReceiverId(item));
            }
            receiveTable.InnerHtml = sb.ToString();
        }

        private string ReceiverPageByReceiverId(DataRow item)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<div class=\"receiverPrint\"><table width=\"100%\"> <!--Header-->");
            sb.AppendLine("<tr><td><table width = \"100%\" class=\"header-info\">");
            sb.AppendLine("<tr><td colspan = \"2\"><h3> info@send.mn </h3><hr></td></tr>");
            sb.AppendLine("<tr><td width=\"20%\">From :</td><td width =\"80%\"> " + item["fullName"] + " <'" + item["email"] + "'></td></tr>");
            sb.AppendLine("<tr><td> Send :</td><td> " + item["createdDate"] + "</td></tr>");
            sb.AppendLine("<tr><td> To :</td><td>Admin</td></tr>");
            sb.AppendLine("<tr><td> Subject :</td><td> New Receiver</td></tr>");
            sb.AppendLine("</table></td></tr><!--End Header-->");
            sb.AppendLine("<!-- Logo --><tr><td><table width =\"100%\" style = \"margin-top: 25px;\">");
            sb.AppendLine("<tr><td width = \"60%;\"><div class=\"logo\">");
            sb.AppendLine("<img src = \"/Images/jme.png\"/></tr></table></td></tr><!--End Logo -->");

            //Body Start
            sb.AppendLine("<!--body--><tr valign = \"top\">");
            sb.AppendLine("<td width = \"80%\"><table width = \"100%\">");
            sb.AppendLine("<!--sender information--><tr><td><table width = \"100%\" class=\"info-data\">");
            sb.AppendLine("<!--sender information--><tr><td colspan = \"2\">");
            sb.AppendLine("<span class=\"highlight_info\"><center>Sender Details</center></span>");
            sb.AppendLine("</td></tr>");
            sb.AppendLine("<tr><td width = \"50%\"><label> NAME </label></td>");
            sb.AppendLine("<td width=\"50%\"><span class=\"info\">" + item["fullName"] + "</span></td>");
            sb.AppendLine("</tr><tr>");
            sb.AppendLine("<td><label>DOB</label></td>");
            sb.AppendLine("<td><span class=\"info\">" + item["dob"] + "</span></td></tr>");
            sb.AppendLine("<tr><td><label>PHONE</label></td><td><span class=\"info\">" + item["mobile"] + "</span></td></tr>");
            sb.AppendLine("<!--Receiver information-->");
            sb.AppendLine("<tr><td colspan = \"2\"><span class=\"highlight_info\"><center>Receiver Details</center></span></td></tr>");
            sb.AppendLine("<tr><td><label>NAME</label></td><td><span class=\"info\">" + item["receiverName"] + "</span></td></tr>");
            sb.AppendLine("<tr><td><label>ADDRESS</label></td><td><span class=\"info\">" + item["receiverAddress"] + "</span></td></tr>");
            sb.AppendLine("<tr><td><label>COUNTRY</label></td><td><span class=\"info\">" + item["country"] + "</span></td></tr>");
            sb.AppendLine("<tr><td><label>PHONE</label></td><td><span class=\"info\">" + item["receiverMobile"] + "</span></td></tr>");
            sb.AppendLine("<!--payment information-->");
            sb.AppendLine("<tr><td colspan = \"2\"><span class=\"highlight_info\"><center>Mode Of Receipt :" + item["paymentMode"] + "</center></span></td></tr>");
            sb.AppendLine("<tr><td><label>BANK NAME</label></td><td><span class=\"info\">" + item["bankName"] + "</span></td></tr>");
            sb.AppendLine("<tr><td><label>BRANCH NAME</label></td><td><span class=\"info\">" + item["bankName"] + "</span></td></tr>");
            sb.AppendLine("<tr><td><label>ACCOUNT NO</label></td><td><span class=\"info\">" + item["receiverAccountNo"] + "</span></td></tr>");
            sb.AppendLine("<tr><td><label>RELATIONSHIP TO BENEFICIARY</label></td><td><span class=\"info\">" + item["relationship"] + "</span></td></tr>");
            sb.AppendLine("<tr><td><label>PURPOSE OF REMITTANCE</label></td><td><span class=\"info\">" + item["purposeOfRemit"] + "</span></td></tr>");
            sb.AppendLine("<tr><td><label>DATE</label></td><td><span class=\"info\">" + item["createdDate"] + "</span></td></tr>");
            sb.AppendLine("</table></td></tr></table></td></tr><!--End body-->");
            //Body END

            //information section
            sb.AppendLine(" <!--information section-->");
            sb.AppendLine("<tr valign = \"top\"><td><table width = \"100%\">");
            sb.AppendLine("<tr><td><p class=\"tcenter\">" + item["fullName"] + "</p></td></tr>");
            sb.AppendLine("<tr><td><h1 class=\"tcenter\">" + item["remarks"] + "</h1></td></tr></table></td></tr><!--End information section--> ");

            //end information section

            sb.AppendLine("</table></div>");
            sb.AppendLine("<footer></footer>");
            return sb.ToString();
        }
    }
}