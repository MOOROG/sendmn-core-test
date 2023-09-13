﻿using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Text;

namespace Swift.web.AgentNew.AgentSend
{
    public partial class VerifyTxn : System.Web.UI.Page
    {
        private ApproveTransactionDao at = new ApproveTransactionDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "40201600";
        private const string ViewDetailsFunctionId = "40201630";
        private const string ModifyFunctionId = "20122810";
        private const string ApproveSingleFunctionId = "40201610";
        private const string ApproveMultipleFunctionId = "20122830";
        private const string RejectFuntionId = "40201620";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
            }
            PopulateList();
            Authenticate();
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateList()
        {
            bool allowApprove = _sdd.HasRight(ApproveSingleFunctionId); ;
            bool allowMultiple = false;/* _sdd.HasRight(ApproveMultipleFunctionId);*/

            bool allowReject = _sdd.HasRight(RejectFuntionId);
            bool allowViewDetails = _sdd.HasRight(ViewDetailsFunctionId);
            var ds = at.GetAllTxnDataForVerifyCreatedFromSendTabPage(GetStatic.GetAgent(), GetStatic.GetUser());
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
                    sb.Append("<th>View</th>");
                }
                if (allowReject)
                {
                    colspanCount++;
                    sb.Append("<th>Actions</th>");
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

                    if (allowViewDetails)
                        sb.Append("<td><button class='btn btn-xs btn-primary' style='cursor:pointer' title = 'View Details' alt = 'View Details'  onclick = 'ViewDetails(" + dr["id"].ToString() + ");'> <i class='fa fa-eye'></i> </button></td>");

                    if (allowApprove || allowReject)
                    {
                        sb.Append("<td nowrap = \"nowrap\">");

                        if (allowApprove)
                            sb.Append("&nbsp;<input type = 'button' class='btn btn-xs btn-primary m-t-25' onclick = \"Approve(" + dr["id"].ToString() + ");\" value = 'Approve' id = 'btn_" + dr["id"].ToString() + "'  />");
                        if (allowReject)
                            sb.Append("&nbsp;<input type = 'button' class='btn btn-xs btn-primary m-t-25' onclick = \"Reject(" + dr["id"].ToString() + ");\" value = 'Reject' id = 'btn_r_" + dr["id"].ToString() + "'  />");

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
            rptGrid.Visible = true;
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            DbResult dbResult = at.VerifyTransaction(hddTranNo.Value, GetStatic.GetUser());
            GetStatic.PrintMessage(Page, dbResult);
            PopulateList();
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            var dr = at.RejectHoldedTXN(GetStatic.GetUser(), hddTranNo.Value);
            GetStatic.PrintMessage(Page, dr);
            PopulateList();
        }
    }
}