using Swift.DAL.net.inficare.kumari;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Transaction.ThirdPartyTXN.KumariBank.CheckStatus
{
    public partial class CheckStatus : System.Web.UI.Page
    {
        protected readonly RemittanceLibrary _remit = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                _remit.CheckSession();
            }
        }

        protected void SearchButton_Click(object sender, EventArgs e)
        {
            CheckStats();
        }
        protected void CheckStats()
        {
            Return_TXNStatus _response = new Return_TXNStatus();
            _response = daoKumari.GetStatus(GetStatic.GetUser(), controlNumberTextBox.Text, "status");
            if (_response.CODE != "0")
            {
                GetStatic.AlertMessage(this, "Error Code: " + _response.CODE + "Error Message: " + _response.MESSAGE);
                return;
            }

            StringBuilder sb = new StringBuilder("");
            sb.AppendLine("<tr>");
            sb.AppendLine("<td>" + _response.CODE + "</td>");
            sb.AppendLine("<td>" + _response.AGENT_SESSION_ID + "</td>");
            sb.AppendLine("<td>" + _response.MESSAGE + "</td>");
            sb.AppendLine("<td>" + _response.REFNO + "</td>");
            sb.AppendLine("<td>" + _response.SENDER_NAME + "</td>");
            sb.AppendLine("<td>" + _response.RECEIVER_NAME + "</td>");
            sb.AppendLine("<td>" + _response.PAYOUTAMT + "</td>");
            sb.AppendLine("<td>" + _response.PAYOUTCURRENCY + "</td>");
            sb.AppendLine("<td>" + _response.STATUS + "</td>");
            sb.AppendLine("<td>" + _response.STATUS_DATE + "</td>");
            sb.AppendLine("</tr>");
            statusCheckTableResult.InnerHtml = sb.ToString();
        }
    }
}