using Swift.DAL.BL.AgentPanel.Send;
using Swift.web.Library;
using System;
using System.Text;
using System.Web.UI;

namespace Swift.web.AgentPanel.International.SendOnBehalf.TxnHistory
{
    public partial class ReceiverHistoryBySender : System.Web.UI.Page
    {
        private readonly SwiftLibrary sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            sname.Text = GetSenderName();
            if (!IsPostBack)
                LoadGrid();
        }

        #region method

        private void Authenticate()
        {
            sl.CheckSession();
        }

        protected string GetSenderId()
        {
            return GetStatic.ReadQueryString("senderId", "");
        }

        protected string GetSenderName()
        {
            return GetStatic.ReadQueryString("sname", "");
        }

        private void LoadGrid()
        {
            SendTranIRHDao dao = new SendTranIRHDao();
            var dt = dao.SenderRecentRecList(GetSenderId().ToString(), txtSearch.Text);
            if (dt == null || dt.Rows.Count == 0)
            {
                rpt_grid.InnerHtml = "";
                ManageMessage("1", "History not found for respected Sender.");
                if (!Page.IsPostBack)
                {
                    GetStatic.CallBackJs1(Page, "Close", "window.close();");
                }
                return;
            }

            int cnt = 0;
            StringBuilder sb = new StringBuilder("<div class='table table-responsive'><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" align=\"left\" class=\"table table-bordered table-condensed\">");
            sb.AppendLine("<tr >");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'></th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Membership ID</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Sender Name</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Receiver Name</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Pay Mode</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Bank</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>Bank Branch</th>");
            sb.AppendLine("<th class='frmTitle' nowrap='nowrap'>AC No</th>");

            sb.AppendLine("</tr>");

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                ++cnt;
                sb.AppendLine("<tr onclick='CheckTR(" + cnt + ")'; class=" + (cnt % 2 == 0 ? "'oddbg'" : "'evenbg'") + ">");
                sb.AppendLine("<td><input type='radio' name='rdoId' id='rdoId' value=" + dt.Rows[i]["ID"] + "></td>");
                sb.AppendLine("<td>" + dt.Rows[i]["membershiId"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["senderName"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["receiverName"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["payMode"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["bank"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["bankBranch"] + "</td>");
                sb.AppendLine("<td>" + dt.Rows[i]["acNo"] + "</td>");
                sb.AppendLine("</tr>");
            }
            sb.AppendLine("</table>");
            rpt_grid.InnerHtml = sb.ToString();
        }

        private void ManageMessage(string res, string msg)
        {
            GetStatic.CallBackJs1(Page, "Call Back", "alert('" + msg + "');");
        }

        #endregion method

        protected void btnOk_Click(object sender, EventArgs e)
        {
            string id = Request.Form["rdoId"];
            GetStatic.CallBackJs1(Page, "Call Back", "CallBack('" + id + "');");
        }

        protected void BtnSave2_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }
    }
}