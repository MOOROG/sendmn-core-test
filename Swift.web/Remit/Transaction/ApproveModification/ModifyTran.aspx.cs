using System;
using System.Data;
using System.Text;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.ApproveModification
{
    public partial class ModifyTran : System.Web.UI.Page
    {
        readonly StaticDataDdl sd = new StaticDataDdl();
        private ModifyTransactionDao dao=new ModifyTransactionDao();
        private const string ViewFunctionId = "20122000";
        private const string ProcessFunctionId = "20122010";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            LoadByControlNo(GetControlNo());
        }

        protected string GetControlNo()
        {
            return GetStatic.ReadQueryString("filterControlNo", "");
        }

        private void Authenticate()
        {
            sd.CheckAuthentication(ViewFunctionId );
        }

        private void LoadByControlNo(string cNo)
        {
            if (sd.HasRight(ProcessFunctionId))
                ucTran.SearchData("", cNo, "u", "N", "MODIFY", "ADM: MODIFY TXN");
            else
                ucTran.SearchData("", cNo, "", "N", "MODIFY", "ADM: MODIFY TXN");
            if (!ucTran.TranFound)
            {
                PrintMessage("Transaction not found!");
                return;
            }
            divTranDetails.Visible = ucTran.TranFound;
            TXNRequestDeatil();
        }

        private void PrintMessage(string msg)
        {
            var dbResult=new DbResult {ErrorCode = "1", Msg = msg,Id=""};
            ManageMessage(dbResult);

        }

        private void ManageMessage(DbResult dbResult)
        {
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.AlertMessage(Page, dbResult.Msg);
                return;
            }
            Response.Redirect("Summary.aspx?controlNo=" + GetControlNo() + "&email=" + dbResult.Id + "&payStatus="+ucTran.PayStatus);
        }

        protected void btnReloadDetail_Click(object sender, EventArgs e)
        {
            LoadByControlNo(ucTran.CtrlNo);
        }

        private void TXNRequestDeatil()
        {
            pnlCompliance.Visible = false;
            DataTable dt = dao.TXNSelectComment(GetStatic.GetUser(), GetControlNo());
            if (dt != null && dt.Rows.Count != 0)
            {
                pnlCompliance.Visible = true;
                dispRequest.Visible = true;
                StringBuilder sb = new StringBuilder("");
                sb.AppendLine("<table class='table table-bordered' border='1' cellspacing='0' cellpadding='3'>");
                sb.AppendLine("<tr><th class='frmTitle'>SN</th>");
                sb.AppendLine("<th class='frmTitle'>User</th>");
                sb.AppendLine("<th class='frmTitle'>Date</th>");
                sb.AppendLine("<th class='frmTitle'>Message - New Modification</th>");

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    if (hdTranId.Value == "")
                        hdTranId.Value = dt.Rows[i]["tranId"].ToString();
                    sb.AppendLine("<tr><td>" + (i + 1) + "</td>");
                    sb.AppendLine("<td nowrap='nowrap'>" + dt.Rows[i]["createdBy"] + "</td>");
                    sb.AppendLine("<td nowrap='nowrap'>" + dt.Rows[i]["createdDate"] + "</td>");
                    sb.AppendLine("<td nowrap='nowrap'>" + dt.Rows[i]["message"] + "</td>");
                }
                sb.AppendLine("</table>");
                dispRequest.InnerHtml = sb.ToString();
                return;
            }
            dispRequest.Visible = false;
        }

        protected void btnApproveAll_Click(object sender, EventArgs e)
        {
            var sendSmsEmail = "";           
            if(chkEmail.Checked && chkSms.Checked==true)
                sendSmsEmail = "both";
            else if (chkSms.Checked == true)
                sendSmsEmail = "sms";
            else if (chkEmail.Checked == true)
                sendSmsEmail = "email";
            var dbResult = dao.Approve(GetStatic.GetUser(), hdTranId.Value,sendSmsEmail);
            ManageMessage(dbResult);
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {

            var dbResult = dao.Reject(GetStatic.GetUser(), hdTranId.Value);
            ManageMessageReject(dbResult);
        }

        private void ManageMessageReject(DbResult dbResult)
        {
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.AlertMessage(Page, dbResult.Msg);
                return;
            }
            Response.Redirect("List.aspx");
        }
    }
}