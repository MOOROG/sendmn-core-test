using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentNew.Transaction.ApproveTxn
{
    public partial class holdTxnList : System.Web.UI.Page
    {
        private ApproveTransactionDao at = new ApproveTransactionDao();
        private const string ViewFunctionId = "40101800";
        private const string ModifyFunctionId = "40101810";
        private const string ApproveSingleFunctionId = "40101820";
        private const string ApproveMultipleFunctionId = "40101830";
        private const string RejectFuntionId = "40101840";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.AttachConfirmMsg(ref btnApprove, "Are you sure to APPROVE this transaction?");
            GetStatic.AttachConfirmMsg(ref btnApproveAll, "Are you sure to APPROVE ALL this transaction?");

            if (!IsPostBack)
            {
                Authenticate();
                LoadDdl();
                LoadSendingAgent();
                LoadApproveGrid("");
                MakeNumericTextBox();

                if (!string.IsNullOrEmpty(GetCountry()))
                    LoadApproveGrid(GetCountry());
                LoadHoldSummary();
            }
            GetStatic.ResizeFrame(Page);
        }

        private string GetCountry()
        {
            return GetStatic.ReadQueryString("country", "");
        }

        private void LoadDdl()
        {
            _sdd.SetDDL(ref country, "EXEC proc_dropDownLists @flag = 'a-countrySend'", "countryId", "countryName", "", "");

            var sql = "EXEC proc_dropDownLists @flag = 'a-countryPay'";
            _sdd.SetDDL(ref rCountry, sql, "countryName", "countryName", "", "All");
        }

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref amt);
        }

        private void LoadApproveGrid(string sCountry)
        {
            bool allowApprove = _sdd.HasRight(ApproveSingleFunctionId);
            bool allowMultiple = false/* _sdd.HasRight(ApproveMultipleFunctionId)*/;
            bool allowReject = _sdd.HasRight(RejectFuntionId);
            bool allowModify = _sdd.HasRight(ModifyFunctionId);

            if (sCountry != "")
            {
                country.SelectedItem.Text = sCountry;
                // LoadSendingAgent();
            }

            if (country.SelectedItem.Text == "" || country.SelectedItem.Text == "Select")
            {
                country.SelectedItem.Text = "JAPAN";
            }

            var ds = at.GetHoldedTXNListAgent(GetStatic.GetUser(), tranNo.Text, rCountry.Text, sender.Text, receiver.Text
                , amt.Text, GetStatic.GetBranch(), GetStatic.GetUserType()
                , "getTxnForApproveByAgent", txnDate.Text, user.Text, ControlNo.Text, "I", country.SelectedItem.Text
                , GetStatic.GetSettlingAgent());

            var dt = ds.Tables[0];
            var sb = new StringBuilder();
            var sbHead = new StringBuilder();
            var colspanCount = 0;
            int cols = dt.Columns.Count;
            int cnt = 0;
            sbHead.Append("<table class = 'table table-responsive table-striped table-bordered' >");
            if (dt.Rows.Count > 0)
            {
                sb.Append("<tr>");
                if (allowMultiple)
                {
                    colspanCount++;
                    sb.Append("<th>");
                    if (dt.Rows.Count > 0)
                        sb.Append("<input type = 'checkbox' id = 'tgcb' onclick = 'ToggleCheckboxes(this,false);' />");
                    sb.Append("</th>");
                }

                sb.Append("<th>PIN No.</th>");
                sb.Append("<th>Country</th>");
                sb.Append("<th>Sender</th>");
                sb.Append("<th>Receiver</th>");
                sb.Append("<th>Coll Amt</th>");

                sb.Append("<th>Coll.Mode</th>");
                sb.Append("<th>Voucher No</th>");
                sb.Append("<th nowrap='nowrap'>Tran Date</th>");
                sb.Append("<th>User</th>");

                if (allowApprove)
                {
                    colspanCount++;
                    sb.Append("<th></th>");
                    sb.Append("<th></th>");
                }
                if (allowApprove)
                {
                    colspanCount++;
                    sb.Append("<th></th>");
                }
                sb.Append("</tr>");

                foreach (DataRow dr in dt.Rows)
                {
                    cnt = cnt + 1;
                    sb.AppendLine(cnt % 2 == 1
                                       ? "<tr class=\"oddbg\" onMouseOver=\"this.className='GridOddRowOver'\" onMouseOut=\"this.className='oddbg'\" >"
                                       : "<tr class=\"evenbg\"  onMouseOver=\"this.className='GridEvenRowOver'\" onMouseOut=\"this.className='evenbg'\">");
                    if (allowMultiple)
                        sb.Append("<td><input onclick = 'CallBackGrid(this,false);'  type='checkbox' name='rowId' value=\"" + dr["id"].ToString() + "\"></td>");

                    sb.Append("<td>" + dr["id"].ToString() + "</td>");
                    sb.Append("<td>" + dr["controlNo"].ToString() + "</td>");
                    sb.Append("<td>" + dr["country"].ToString() + "</td>");
                    sb.Append("<td>" + dr["sender"].ToString() + "</td>");
                    sb.Append("<td>" + dr["receiver"].ToString() + "</td>");
                    sb.Append("<td style=\"font-weight: bold; font-style: italic; text-align: right;\">");
                    sb.Append(GetStatic.FormatData(dr["amt"].ToString(), "M"));

                    sb.Append("<td>" + dr["paymentMethod"].ToString() + "</td>");
                    sb.Append("<td>" + dr["voucherNo"].ToString() + "</td>");
                    sb.Append("<td>" + GetStatic.FormatData(dr["txnDate"].ToString(), "D") + "</td>");
                    sb.Append("<td>" + dr["txncreatedBy"].ToString() + "</td>");

                    if (allowApprove)
                        sb.Append("<td><img style='cursor:pointer' title = 'View Details' alt = 'View Details' src = '" + GetStatic.GetUrlRoot() + "/images/view-detail-icon.png' onclick = 'ViewDetails(" + dr["id"].ToString() + ");' /></td>");

                    //if (allowModify)
                    //    sb.Append("<td><img style='cursor:pointer' title = 'Modify Transaction' alt = 'Modify Transaction' src = '" + GetStatic.GetUrlRoot() + "/images/edit.gif' onclick = 'Modify(" + dr["id"].ToString() + ");' /></td>");
                    if (allowApprove || allowReject)
                    {
                        sb.Append("<td nowrap = \"nowrap\">");
                        //var tb = Misc.MakeNumericTextbox("amt_" + dr["id"].ToString(), "amt_" + dr["id"].ToString(), "", "style='width:60px ! important'", "CheckAmount(" + dr["id"].ToString() + ", " + dr["amt"].ToString() + ");");
                        //sb.Append(tb);

                        if (allowApprove)
                            sb.Append("&nbsp;<input type = 'button' class='btn btn-primary m-t-25' onclick = \"Approve(" + dr["id"].ToString() + ");\" value = 'Approve' id = 'btn_" + dr["id"].ToString() + "'  />");
                        if (allowReject)
                            sb.Append("&nbsp;<input type = 'button' class='btn btn-primary m-t-25' onclick = \"Reject(" + dr["id"].ToString() + ");\" value = 'Reject' id = 'btn_r_" + dr["id"].ToString() + "'  />");

                        sb.Append("</td>");
                    }
                    sb.Append("</tr>");
                }

                btnApproveAll.Visible = allowMultiple;
            }
            else
            {
                btnApproveAll.Visible = false;
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
            LoadApproveGrid("");
        }

        protected void btnApproveAll_Click(object sender, EventArgs e)
        {
            var dr = ApproveAllTxn();
            GetStatic.PrintMessage(Page, dr);
            if (dr.ErrorCode.Equals("0"))
            {
                LoadApproveGrid("");
                LoadHoldSummary();
            }
        }

        private DbResult ApproveAllTxn()
        {
            var idList = GetStatic.ReadFormData("rowId", "");

            if (string.IsNullOrWhiteSpace(idList))
            {
                var dr = new DbResult();
                dr.SetError("1", "Please select one or more transaction approve", "");
                return dr;
            }
            return at.ApproveAllHoldedTXN(GetStatic.GetUser(), idList);
        }

        private void ApproveTxn()
        {
            //string newSession = Guid.NewGuid().ToString().Replace("-", "");
            //var result = at.GetHoldedTxnForApprovedByAdmin(GetStatic.GetUser(), hddTranNo.Value, newSession);
            //if (!result.ResponseCode.Equals("NotForTPAPI"))
            //{
            //    if (!result.ResponseCode.Equals("0"))
            //    {
            //        LoadApproveGrid("");
            //        GetStatic.PrintMessageAPI(Page, result);
            //    }
            //    else
            //    {
            //        LoadApproveGrid("");
            //        LoadHoldSummary();
            //        GetStatic.PrintMessageAPI(Page, result);
            //    }
            //    return;
            //}
            DbResult dbResult = at.ApproveHoldedTXN(GetStatic.GetUser(), hddTranNo.Value);

            if (dbResult.ErrorCode == "0")
            {
                LoadApproveGrid("");
                LoadHoldSummary();
                GetStatic.PrintMessage(Page, dbResult);
                return;
            }
            else if (dbResult.ErrorCode == "11")
            {
                string url = "../NewReceiptIRH.aspx?printType=&controlNo=" + dbResult.Id;
                Response.Redirect(url);
            }
            else
            {
                LoadApproveGrid("");
                GetStatic.PrintMessage(Page, dbResult);
                return;
            }
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            ApproveTxn();
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            RejectTxn();
        }

        private void RejectTxn()
        {
            var dr = at.RejectHoldedTXN(GetStatic.GetUser(), hddTranNo.Value);
            GetStatic.PrintMessage(Page, dr);
            if (dr.ErrorCode.Equals("0"))
            {
                LoadApproveGrid("");
                LoadHoldSummary();
            }
        }

        private void LoadHoldSummary()
        {
            var ds = at.GetHoldAdminTransactionSummary(GetStatic.GetUser(), GetStatic.GetBranch(), GetStatic.GetUserType());
            if (ds == null || ds.Tables.Count == 0)
                return;
            var dt = ds.Tables[0];
            var sbHead = new StringBuilder();
            int count = 0;
            if (dt.Rows.Count > 0)
            {
                sbHead.Append("<table class = 'table table-responsive table-bordered table-striped'>");
                sbHead.Append("<tr>");
                sbHead.Append("<th colspan='3'>HOLD Transaction Summary</th>");
                sbHead.Append("</tr>");

                sbHead.Append("<tr>");
                sbHead.Append("<th>S.N.</th>");
                sbHead.Append("<th>Sending Country</th>");
                sbHead.Append("<th>Count</th>");
                sbHead.Append("</tr>");

                foreach (DataRow dr in dt.Rows)
                {
                    sbHead.Append("<tr>");
                    sbHead.Append("<td>" + dr["sn"] + "</td>");
                    sbHead.Append("<td><a href='holdTxnList.aspx?country=" + dr["country"] + "'>" + dr["country"] + "</a></td>");
                    sbHead.Append("<td align=\"center\">" + dr["txnCount"] + "</td>");
                    sbHead.Append("</tr>");
                    count = count + int.Parse(dr["txnCount"].ToString());
                }
                sbHead.Append("<tr><td colspan='2'><b>Total</b></td>");
                sbHead.Append("<td align=\"center\"><b>" + count.ToString() + "</b></td>");
                sbHead.Append("</tr>");
                sbHead.Append("</table>");
                txnSummary.InnerHtml = sbHead.ToString();
            }
        }

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSendingAgent();
        }

        private void LoadSendingAgent()
        {
            if (!string.IsNullOrEmpty(country.Text))
                _sdd.SetDDL(ref agent, "EXEC proc_dropDownLists2 @flag = 'agentSend',@param=" + _sdd.FilterString(country.Text) + "", "agentId", "agentName", "", "All");
        }

        protected void agent_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(agent.Text))
            {
                var sql = "EXEC proc_dropDownLists @flag = 'branch', @agentId=" + _sdd.FilterString(agent.Text) + " , @user=" + _sdd.FilterString(GetStatic.GetUser());
                _sdd.SetDDL(ref branch, sql, "agentId", "agentName", "", "All");
            }
            else
            {
                branch.Items.Clear();
            }
        }
    }
}