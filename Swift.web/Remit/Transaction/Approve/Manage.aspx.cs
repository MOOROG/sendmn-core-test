using System;
using System.Data;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System.Text;

namespace Swift.web.Remit.Transaction.Approve
{
    public partial class Manage : System.Web.UI.Page
    {
        protected const string GridName = "grdAppDomTxn";
        ApproveTransactionDao at = new ApproveTransactionDao();
        private const string ViewFunctionId = "20121700";
        private const string ApproveSingleFunctionId = "20121730";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.AttachConfirmMsg(ref btnApprove, "Are you sure to APPROVE this transaction?");

            if (!IsPostBack)
            {
               // Authenticate();
                MakeNumericTextBox();

                if (!string.IsNullOrEmpty(GetAgent()))
                    LoadGrid(GetAgent());
                LoadHoldSummary();
            }
            GetStatic.ResizeFrame(Page);
        }

        private string GetAgent()
        {
            return GetStatic.ReadQueryString("sAgent", "");
        }

        private string GetAgentName()
        {
            return GetStatic.ReadQueryString("sAgentName", "");
        }

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref amt);
        }

        private void LoadGrid(string agentId)
        {
            bool allowApprove = _sdd.HasRight(ApproveSingleFunctionId);
            if (agentId != "")
            {
                agent.Value = agentId;
                agent.Text = GetAgentName();
            }
            var ds = at.GetHoldTxnDetailDomestic(GetStatic.GetUser(), agent.Value, sender.Text, receiver.Text
                ,ControlNo.Text, amt.Text, txnDate.Text, user.Text);

            var dt = ds.Tables[0];
            var sb = new StringBuilder();
            var sbHead = new StringBuilder();
            var colspanCount = 0;
            int cols = dt.Columns.Count;
            int cnt = 0;
            sbHead.Append("<table class = 'TBLData' style = 'width:100%' >");
            if (dt.Rows.Count > 0)
            {
                sb.Append("<tr>");
                sb.Append("<th>S.N.</th>");
                sb.Append("<th>Tran Id</th>");
                sb.Append("<th>Control No</th>");
                sb.Append("<th>Amount</th>");
                if (allowApprove)
                {
                    colspanCount++;
                    sb.Append("<th></th>");
                }
                sb.Append("<th nowrap='nowrap'>Txn Date</th>");
                sb.Append("<th>User</th>");
                sb.Append("<th>Sender Id</th>");
                sb.Append("<th nowrap='nowrap'>Sender Name</th>");
                sb.Append("<th>Sender Address</th>");
                sb.Append("<th>Receiver Name</th>");
                sb.Append("</tr>");

                foreach (DataRow dr in dt.Rows)
                {
                    cnt = cnt + 1;
                    sb.AppendLine(cnt % 2 == 1
                                       ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                                       : "<tr class=\"evenbg\"  onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
                    sb.Append("<td>" + dr["S.N."].ToString() + "</td>");
                    sb.Append("<td>" + dr["Tran Id"].ToString() + "</td>");
                    sb.Append("<td>" + dr["Control No"].ToString() + "</td>");
                    sb.Append("<td style=\"font-weight: bold; font-style: italic; text-align: right;\">");
                    sb.Append(GetStatic.FormatData(dr["Amount"].ToString(), "M"));

                    if (allowApprove)
                    {
                        sb.Append("<td nowrap = \"nowrap\">");
                        var tb = Misc.MakeNumericTextbox("amt_" + dr["Tran Id"].ToString(), "amt_" + dr["Tran Id"].ToString(), "", "style='width:60px ! important'", "CheckAmount(" + dr["Tran Id"].ToString() + ", " + dr["Amount"].ToString() + ");");
                        sb.Append(tb);

                        if (allowApprove)
                            sb.Append("<input type = 'button' onclick = \"Approve(" + dr["Tran Id"].ToString() + ");\" value = 'Approve' id = 'btn_" + dr["Tran Id"].ToString() + "' disabled='disabled' />");
                        sb.Append("</td>");
                    }
                    sb.Append("<td>" + GetStatic.FormatData(dr["Txn Date"].ToString(), "D") + "</td>");
                    sb.Append("<td>" + dr["User"].ToString() + "</td>");
                    sb.Append("<td>" + dr["Sender Id"].ToString() + "</td>");
                    sb.Append("<td>" + dr["Sender Name"].ToString() + "</td>");
                    sb.Append("<td>" + dr["Sender Address"].ToString() + "</td>");
                    sb.Append("<td>" + dr["Receiver Name"].ToString() + "</td>");
                    sb.Append("</tr>");
                }
            }

            sbHead.Append("<tr><td colspan='" + cols + "' id='appCnt' nowrap='nowrap'>");
            sbHead.Append("<b>" + dt.Rows.Count.ToString() + "  Transaction(s) found : <b>Approve Transaction List</b> </b></td>");
            sbHead.Append("</tr>");
            sbHead.Append(sb.ToString());
            sbHead.Append("</table>");
            rptGrid.InnerHtml = sbHead.ToString();
            approveList.Visible = true;
            selfTxn.Visible = false;
            GetStatic.ResizeFrame(Page);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadGrid("");
        }

        private void ApproveSingle()
        {
            DbResult dbResult = at.ApproveSingleDom(GetStatic.GetUser(), hddTranNo.Value);

            if (dbResult.ErrorCode == "0")
            {
                LoadGrid("");
                LoadHoldSummary();
                GetStatic.PrintMessage(Page, dbResult);
                return;
            }
            else
            {
                GetStatic.PrintMessage(Page, dbResult);
                return;
            }
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            ApproveSingle();
        }

        private void LoadHoldSummary()
        {
            var ds = at.GetHoldTxnSummaryDomestic(GetStatic.GetUser());
            if (ds == null || ds.Tables.Count == 0)
                return;
            var dt = ds.Tables[0];
            var sbHead = new StringBuilder();
            int count = 0;
            if (dt.Rows.Count > 0)
            {
                sbHead.Append("<table class = 'TBLData' style = 'width:500px'>");
                sbHead.Append("<tr>");
                sbHead.Append("<th colspan='3'>HOLD Transaction Summary</th>");
                sbHead.Append("</tr>");

                sbHead.Append("<tr>");
                sbHead.Append("<th>S.N.</th>");
                sbHead.Append("<th>Sending Agent</th>");
                sbHead.Append("<th>Count</th>");
                sbHead.Append("</tr>");

                foreach (DataRow dr in dt.Rows)
                {
                    sbHead.Append("<tr>");
                    sbHead.Append("<td>" + dr["S.N."] + "</td>");
                    sbHead.Append("<td><a href='Manage.aspx?sAgent=" + dr["sAgent"] + "&sAgentName=" + dr["Agent"] + "'>" + dr["Agent"] + "</a></td>");
                    sbHead.Append("<td align=\"center\">" + dr["TXN Count"] + "</td>");
                    sbHead.Append("</tr>");
                    count = count + int.Parse(dr["TXN Count"].ToString());
                }
                sbHead.Append("<tr><td colspan='2'><b>Total</b></td>");
                sbHead.Append("<td align=\"center\"><b>" + count.ToString() + "</b></td>");
                sbHead.Append("</tr>");
                sbHead.Append("</table>");
                txnSummary.InnerHtml = sbHead.ToString();
            }
        }
    }
}