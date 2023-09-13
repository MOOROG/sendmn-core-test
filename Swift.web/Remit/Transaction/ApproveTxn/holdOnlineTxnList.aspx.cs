using Swift.API.ThirdPartyApiServices;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Drawing;
using System.Text;
using System.Threading.Tasks;

namespace Swift.web.Remit.Transaction.ApproveTxn
{
    public partial class holdOnlineTxnList : System.Web.UI.Page
    {
        private ApproveTransactionDao at = new ApproveTransactionDao();
        private const string ViewFunctionId = "20201001";
        private const string ModifyFunctionId = "20201102";
        private const string ApproveSingleFunctionId = "20201203";
        private const string ApproveMultipleFunctionId = "20201304";
        private const string RejectFuntionId = "20201405";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.AttachConfirmMsg(ref btnApprove, "Are you sure to APPROVE this transaction?");
            GetStatic.AttachConfirmMsg(ref btnApproveAll, "Are you sure to APPROVE ALL this transaction?");
            if (!IsPostBack)
            {
                Authenticate();
                LoadDdl();
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
            _sdd.SetDDL(ref rCountry, sql, "countryName", "countryName", "", "Select");
        }

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref amt);
        }

        private void LoadApproveGrid(string sCountry)
        {
            bool allowApprove = _sdd.HasRight(ApproveSingleFunctionId);
            bool allowMultiple = _sdd.HasRight(ApproveMultipleFunctionId);
            bool allowReject = _sdd.HasRight(RejectFuntionId);
            bool allowModify = _sdd.HasRight(ModifyFunctionId);

            if (sCountry != "")
                country.SelectedItem.Text = sCountry;

            if (country.SelectedItem.Text == "" || country.SelectedItem.Text == "Select")
                country.SelectedItem.Text = "SOUTH KOREA";

            var ds = at.GetHoldedTXNListAdmin(GetStatic.GetUser(), branch.Text, tranNo.Text, rCountry.Text, sender.Text, receiver.Text
                , amt.Text, GetStatic.GetBranch(), GetStatic.GetUserType()
                , "s-admin-online", txnDate.Text, user.Text, ControlNo.Text, "I", country.SelectedItem.Text, agent.Text, branch.Text);

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

                sb.Append("<th>Tran No</th>");
                sb.Append("<th>Country</th>");
                sb.Append("<th>Sender</th>");
                sb.Append("<th>Receiver</th>");
                sb.Append("<th>Coll Amt</th>");
                if (allowApprove)
                {
                    colspanCount++;
                    sb.Append("<th></th>");
                }
                sb.Append("<th>Voucher Detail</th>");
                sb.Append("<th nowrap='nowrap'>Tran Date</th>");
                sb.Append("<th>User</th>");

                if (allowApprove)
                {
                    colspanCount++;
                    sb.Append("<th></th>");
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
                    sb.Append("<td>" + dr["country"].ToString() + "</td>");
                    sb.Append("<td>" + dr["sender"].ToString() + "</td>");
                    sb.Append("<td>" + dr["receiver"].ToString() + "</td>");
                    sb.Append("<td style=\"font-weight: bold; font-style: italic; text-align: right;\">");
                    sb.Append(GetStatic.FormatData(dr["amt"].ToString(), "M"));

                    if (allowApprove || allowReject)
                    {
                        sb.Append("<td nowrap = \"nowrap\">");
                        var tb = Misc.MakeNumericTextbox("amt_" + dr["id"].ToString(), "amt_" + dr["id"].ToString(), "", "style='width:60px ! important'", "CheckAmount(" + dr["id"].ToString() + ", " + dr["amt"].ToString() + ");");
                        sb.Append(tb);

                        if (allowApprove)
                            sb.Append("&nbsp;<input type = 'button' class='btn btn-primary m-t-25' onclick = \"Approve(" + dr["id"].ToString() + ");\" value = 'Approve' id = 'btn_" + dr["id"].ToString() + "' disabled='disabled' />");
                        if (allowReject)
                            sb.Append("&nbsp;<input type = 'button' class='btn btn-primary m-t-25' onclick = \"Reject(" + dr["id"].ToString() + ");\" value = 'Reject' id = 'btn_r_" + dr["id"].ToString() + "'  disabled='disabled'/>");
                            sb.Append("&nbsp;<input type = 'button' class='btn btn-primary m-t-25' onclick = \"testApprove(" + dr["id"].ToString() + ");\" value = 'testApprove' id = 'btn_a" + dr["id"].ToString() + "'  />");

            sb.Append("</td>");
                    }

                    sb.Append("<td>" + dr["voucherDetail"].ToString() + "</td>");
                    sb.Append("<td>" + GetStatic.FormatData(dr["txnDate"].ToString(), "D") + "</td>");
                    sb.Append("<td>" + dr["txncreatedBy"].ToString() + "</td>");

                    if (allowApprove)
                        sb.Append("<td><img style='cursor:pointer' title = 'View Details' alt = 'View Details' src = '" + GetStatic.GetUrlRoot() + "/images/view-detail-icon.png' onclick = 'ViewDetails(" + dr["id"].ToString() + ");' /></td>");
          //if (allowModify)
          //    sb.Append("<td><img style='cursor:pointer' title = 'Modify Transaction' alt = 'Modify Transaction' src = '" + GetStatic.GetUrlRoot() + "/images/edit.gif' onclick = 'Modify(" + dr["id"].ToString() + ");' /></td>");

          sb.Append("</tr>");
                }

                btnApproveAll.Visible = false;
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

                // SendApprovalMailToCustomers();
            }
        }

        private void SendApprovalMailToCustomers()
        {
            Task.Factory.StartNew(() => { SendEmail(); });
        }

        private void SendEmail()
        {
            DataTable mailDetails = at.GetMailDetails("system");

            if (mailDetails.Rows.Count == 0 || mailDetails == null)
            {
                return;
            }
            foreach (DataRow item in mailDetails.Rows)
            {
                string res = SendEmailNotification(item);

                if (res != "Mail Send")
                {
                    at.ErrorEmail("system", item["rowId"].ToString());
                }
            }
        }

        private string SendEmailNotification(DataRow item)
        {
            string msgSubject = GetStatic.ReadWebConfig("jmeName", "")+" Control No.: " + item["controlNoDec"].ToString();
            string toEmailId = item["createdBy"].ToString();
            string msgBody = "Dear " + item["SenderName"];
            msgBody += "<br/><br/>This is to acknowledge that you have successfully completed your transaction through "+ GetStatic.ReadWebConfig("jmeName", "") + " Online Remit System.";
            msgBody += "<br/><br/>Kindly take a note of the following transaction details for your record.";

            msgBody += "<br/><br/>"+ GetStatic.ReadWebConfig("jmeName", "") + " Number: " + item["controlNoDec"].ToString();
            msgBody += "<br/>Amount sent: " + item["collCurr"].ToString() + " " + GetStatic.ShowDecimal(item["tAmt"].ToString());
            msgBody += "<br/>Payment method: " + item["paymentMethod"].ToString();
            msgBody += "<br/>Pay-out country: " + item["pcountry"].ToString();
            msgBody += "<br/>Account holding bank Name: " + item["payountBankOrAgent"].ToString();
            msgBody += "<br/>Account number: " + item["accNo"].ToString();
            msgBody += "<br/>Account holder’s name: " + item["receiverName"].ToString();
            msgBody += "<br/>Payout Amount: " + item["payoutCurr"].ToString() + " " + GetStatic.ShowDecimal(item["pAmt"].ToString());

            msgBody += "<br/><br/>You can keep track of your payment status by https://online.gmeremit.com/.";
            msgBody +=
               "<br><br>If you need further assistance kindly email us at support@jme.com.np or call us at 03-5475-3913. or visit our website <a href=\"http://japanremit.com/\">japanremit.com</a>";
            msgBody +=
                "<br><br><br>We look forward to provide you excellent service.";
            msgBody +=
               "<br><br>Thank You.";
            msgBody +=
               "<br><br><br>Regards,";
            msgBody +=
               "<br>GME Online Team";
            msgBody +=
               "<br>Seoul, Korea ";
            msgBody +=
               "<br>Phone number 15886864 ";

            SmtpMailSetting mail = new SmtpMailSetting
            {
                MsgBody = msgBody,
                MsgSubject = msgSubject,
                ToEmails = toEmailId
            };

            return mail.SendSmtpMail(mail);
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
            DbResult dbResult = at.ApproveHoldedTXN(GetStatic.GetUser(), hddTranNo.Value);
            //SendApprovalMailToCustomers();

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
            var ds = at.GetHoldAdminTransactionSummaryOnline(GetStatic.GetUser(), GetStatic.GetBranch(), GetStatic.GetUserType());
            if (ds == null || ds.Tables.Count == 0)
                return;
            var dt = ds.Tables[0];
            var sbHead = new StringBuilder();
            int count = 0;
            if (dt.Rows.Count > 0)
            {
                sbHead.Append("<table class = 'table table-responsive table-bordered table-bordered'>");
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
                    sbHead.Append("<td><a href='holdOnlineTxnList.aspx?country=" + dr["country"] + "'>" + dr["country"] + "</a></td>");
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
    protected void testBtn_Click(object sender, EventArgs e) {
      SendTransactionServices _tpSend = new SendTransactionServices();
      var result = _tpSend.SendHoldlimitTransaction(GetStatic.GetUser(), hddTranNo.Value);
      GetStatic.PrintMessage(Page, result.ResponseCode, result.Msg);
      return;
    }

  }
}