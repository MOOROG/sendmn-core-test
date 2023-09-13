using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentPanel.Send.SendApprove
{
    public partial class holdTxnList : System.Web.UI.Page
    {
        private ApproveTransactionDao at = new ApproveTransactionDao();
        private const string ViewFunctionId = "40101100";
        private const string ApproveFunctionId = "40101110";
        private const string ApproveSingleFunctionId = "40101120";
        private const string ApproveAllFunctionId = "40101130";
        private const string RejectFuntionId = "40101140";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            GetStatic.AttachConfirmMsg(ref btnApprove, "Are you sure to APPROVE this transaction?");
            GetStatic.AttachConfirmMsg(ref btnApproveAll, "Are you sure to APPROVE ALL this transaction?");
            Authenticate();
            if (!IsPostBack)
            {
                LoadDdl();
                LoadGrid();
                MakeNumericTextBox();
            }
            GetStatic.ResizeFrame(Page);
        }

        private string GetCountry()
        {
            return GetStatic.ReadQueryString("country", "");
        }

        private string GetFlag()
        {
            return GetStatic.ReadQueryString("flag", "");
        }

        private void LoadDdl()
        {
            var sql = "";
            sql = "EXEC proc_sendPageLoadData @flag='pCountry',@countryId='" + GetStatic.GetCountryId() + "',@agentid='" + GetStatic.GetAgentId() + "'";
            _sdd.SetDDL(ref rCountry, sql, "countryName", "countryName", "", "");

            sql = "EXEC proc_dropDownLists @flag = 'rh-branch', @userType =" + _sdd.FilterString(GetStatic.GetUserType()) + ", @branchId=" + _sdd.FilterString(GetStatic.GetBranch()) + " , @user=" + _sdd.FilterString(GetStatic.GetUser());
            var label = "";
            if (GetStatic.GetUserType().ToLower() == "rh" || GetStatic.GetUserType().ToLower() == "ah")
                label = "All";
            else
                label = "";

            _sdd.SetDDL(ref branch, sql, "agentId", "agentName", "", label);
        }

        private void MakeNumericTextBox()
        {
            Misc.MakeNumericTextbox(ref amt);
        }

        private void LoadGrid()
        {
            string pCountry = GetCountry();
            string flag = GetFlag();
            string isB2B = "";
            if (pCountry.Contains("B2B"))
                isB2B = "Y";
            else
                isB2B = "N";

            if (pCountry != "" && flag == "A" && isB2B == "N") //Load non b2b txn for approve
                LoadApproveGrid(pCountry);
            if (pCountry != "" && flag == "S" && isB2B == "N") // Load non b2b txn for self
                LoadSelfTxn(pCountry);
            LoadHoldSummary();
        }

        private void LoadSelfTxn(string country)
        {
            if (country != "")
                rCountry.SelectedValue = country;
            var ds = at.GetHoldedTXNList(GetStatic.GetUser(), branch.Text, tranNo.Text, rCountry.Text, sender.Text, receiver.Text
                             , amt.Text, GetStatic.GetBranch(), GetStatic.GetUserType()
                             , "s-agent-self-txn", txnDate.Text, user.Text, ControlNo.Text, "I");

            var dt = ds.Tables[0];
            var sb = new StringBuilder();
            var sbHead = new StringBuilder();
            sbHead.Append("<table class = 'TBLData' style = 'width:100%' >");
            if (dt.Rows.Count > 0)
            {
                sb.Append("<th>Tran No No</th>");
                sb.Append("<th>Country</th>");
                sb.Append("<th>Sender</th>");
                sb.Append("<th>Receiver</th>");
                sb.Append("<th>Coll Amt</th>");

                sb.Append("<th>Coll.Mode</th>");
                sb.Append("<th>Voucher No</th>");
                sb.Append("<th nowrap='nowrap'>Tran Date</th>");
                sb.Append("<th>User</th>");
                sb.Append("<th>Edit</th>");
                sb.Append("</tr>");

                foreach (DataRow dr in dt.Rows)
                {
                    sb.Append("<tr>");
                    sb.Append("<td>" + dr["id"].ToString() + "</td>");
                    sb.Append("<td>" + dr["country"].ToString() + "</td>");
                    sb.Append("<td>" + dr["sender"].ToString() + "</td>");
                    sb.Append("<td>" + dr["receiver"].ToString() + "</td>");
                    sb.Append("<td style=\"font-weight: bold; font-style: italic; text-align: right;\">");
                    sb.Append(dr["amt"].ToString());

                    sb.Append("<td>" + dr["CollMode"].ToString() + "</td>");
                    sb.Append("<td>" + dr["voucherNo"].ToString() + "</td>");
                    sb.Append("<td>" + GetStatic.FormatData(dr["txnDate"].ToString(), "D") + "</td>");
                    sb.Append("<td>" + dr["txncreatedBy"].ToString() + "</td>");
                    sb.Append("<td><img style='cursor:pointer' title = 'Modify Transaction' alt = 'Modify Transactio' src = '" + GetStatic.GetUrlRoot() + "/images/edit.gif' onclick = 'Modify(" + dr["id"].ToString() + ");' /></td>");
                    sb.Append("</tr>");
                }
            }

            sbHead.Append("<tr><td colspan='5'>");
            sbHead.Append("<b>" + dt.Rows.Count.ToString() + "  Transaction(s) found : <b>Self Transaction List</b></td>");
            sbHead.Append("</tr>");
            sbHead.Append(sb.ToString());
            sbHead.Append("</table>");
            selfTxn.InnerHtml = sbHead.ToString();
            selfTxn.Visible = true;
            approveList.Visible = false;
        }

        private void LoadApproveGrid(string country)
        {
            bool allowApprove = _sdd.HasRight(ApproveFunctionId);
            bool allowSingle = _sdd.HasRight(ApproveSingleFunctionId);
            bool allowMultiple = _sdd.HasRight(ApproveAllFunctionId);
            bool allowReject = _sdd.HasRight(RejectFuntionId);
            if (country != "")
                rCountry.SelectedValue = country;

            var ds = at.GetHoldedTXNList(GetStatic.GetUser(), branch.Text, tranNo.Text, rCountry.Text, sender.Text, receiver.Text
                , amt.Text, GetStatic.GetBranch(), GetStatic.GetUserType()
                , "s-agent", txnDate.Text, user.Text, ControlNo.Text, "I");

            var dt = ds.Tables[0];
            var sb = new StringBuilder();
            var sbHead = new StringBuilder();
            var colspanCount = 0;
            int cols = dt.Columns.Count;
            sbHead.Append("<table class = 'TBLData' style = 'width:100%' >");
            if (dt.Rows.Count > 0)
            {
                sb.Append("<tr>");
                if (allowMultiple)
                {
                    colspanCount++;
                    sb.Append("<th>");
                    if (dt.Rows.Count > 0)
                    {
                        sb.Append("<input type = 'checkbox' id = 'tgcb' onclick = 'ToggleCheckboxes(this,false);' />");
                    }
                    sb.Append("</th>");
                }

                sb.Append("<th>Tran No</th>");
                sb.Append("<th>Country</th>");
                sb.Append("<th>Sender</th>");
                sb.Append("<th>Receiver</th>");
                sb.Append("<th>Coll Amt</th>");
                if (allowSingle)
                {
                    colspanCount++;
                    sb.Append("<th></th>");
                }
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
                sb.Append("</tr>");

                foreach (DataRow dr in dt.Rows)
                {
                    sb.Append("<tr>");
                    if (allowMultiple)
                    {
                        sb.Append("<td><input onclick = 'CallBackGrid(this,false);'  type='checkbox' name='rowId' value=\"" + dr["id"].ToString() + "\"></td>");
                    }

                    sb.Append("<td>" + dr["id"].ToString() + "</td>");
                    sb.Append("<td>" + dr["country"].ToString() + "</td>");
                    sb.Append("<td>" + dr["sender"].ToString() + "</td>");
                    sb.Append("<td>" + dr["receiver"].ToString() + "</td>");
                    sb.Append("<td style=\"font-weight: bold; font-style: italic; text-align: right;\">");
                    sb.Append(dr["amt"].ToString());

                    if (allowSingle || allowReject)
                    {
                        sb.Append("<td nowrap = \"nowrap\">");
                        var tb = Misc.MakeNumericTextbox("amt_" + dr["id"].ToString(), "amt_" + dr["id"].ToString(), "", "style='width:60px ! important'", "CheckAmount(" + dr["id"].ToString() + ", " + dr["amt"].ToString() + ");");
                        sb.Append(tb);

                        if (allowSingle)
                            sb.Append("<input type = 'button' onclick = \"Approve(" + dr["id"].ToString() + ");\" value = 'Approve' id = 'btn_" + dr["id"].ToString() + "' disabled='disabled' />");
                        if (allowReject && GetStatic.GetAgentId() != "13410")
                            sb.Append("<input type = 'button' onclick = \"Reject(" + dr["id"].ToString() + ");\" value = 'Reject' id = 'btn_r_" + dr["id"].ToString() + "'  disabled='disabled'/>");

                        sb.Append("</td>");
                    }

                    sb.Append("<td>" + dr["collMode"].ToString() + "</td>");
                    sb.Append("<td>" + dr["voucherNo"].ToString() + "</td>");
                    sb.Append("<td>" + GetStatic.FormatData(dr["txnDate"].ToString(), "D") + "</td>");
                    sb.Append("<td>" + dr["txncreatedBy"].ToString() + "</td>");

                    if (allowApprove)
                    {
                        sb.Append("<td><img style='cursor:pointer' title = 'View Details' alt = 'View Details' src = '" + GetStatic.GetUrlRoot() + "/images/view-detail-icon.png' onclick = 'ViewDetails(" + dr["id"].ToString() + ");' /></td>");
                        sb.Append("<td><img style='cursor:pointer' title = 'Modify Transaction' alt = 'Modify Transactio' src = '" + GetStatic.GetUrlRoot() + "/images/edit.gif' onclick = 'Modify(" + dr["id"].ToString() + ");' /></td>");
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
            var ds = at.GetHoldTransactionSummary(GetStatic.GetUser(), GetStatic.GetBranch(), GetStatic.GetUserType());
            var dt = ds.Tables[0];
            var sbHead = new StringBuilder();
            int count = 0;
            int countHold = 0;
            if (dt.Rows.Count > 0)
            {
                sbHead.Append("<table class = 'TBLData' style = 'width:500px'>");
                sbHead.Append("<tr>");
                sbHead.Append("<th colspan='3'>HOLD Transaction(s) Summary</th>");
                sbHead.Append("</tr>");

                sbHead.Append("<tr>");
                sbHead.Append("<th align=\"left\">Country</th>");
                sbHead.Append("<th>Approve Txn(s)</th>");
                sbHead.Append("<th>Self Txn(s)</th>");
                sbHead.Append("</tr>");

                foreach (DataRow dr in dt.Rows)
                {
                    sbHead.Append("<tr>");
                    sbHead.Append("<td>" + dr["country"].ToString() + "</td>");
                    sbHead.Append("<td align=\"center\"><a href='holdTxnList.aspx?country=" + dr["country"] + "&flag=A'>" + dr["txnCount"].ToString() + "</a></td>");
                    sbHead.Append("<td align=\"center\"><a href='holdTxnList.aspx?country=" + dr["country"] + "&flag=S'>" + dr["txnHoldCount"].ToString() + "</a></td>");
                    sbHead.Append("</tr>");
                    count = count + int.Parse(dr["txnCount"].ToString());
                    countHold = countHold + int.Parse(dr["txnHoldCount"].ToString());
                }

                sbHead.Append("<tr><td><b>Total</b></td>");
                sbHead.Append("<td align=\"center\"><b>" + count.ToString() + "</b></td>");
                sbHead.Append("<td align=\"center\"><b>" + countHold.ToString() + "</b></td>");
                sbHead.Append("</tr>");
                sbHead.Append("</table>");
                txnSummary.InnerHtml = sbHead.ToString();
            }
        }

        protected void btnSearchHold_Click(object sender, EventArgs e)
        {
            LoadSelfTxn("");
        }
    }
}