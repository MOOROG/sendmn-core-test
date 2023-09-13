using System;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Agent.ReprintReceipt
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40112000";
        private readonly ReceiptDao _obj = new ReceiptDao();
        private readonly RemittanceLibrary _rl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
        }

        private void Authenticate()
        {
            _rl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            //INSERTING TXN VOEW LOG @DIPESH
            DbResult dbResult = _obj.TranViewLog(GetStatic.GetUser(), "", controlNo.Text, "ADM: REPRINT TXN RECEIPT", "REPRINT RECEIPT");
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.CallBackJs1(Page, "Result", "alert('" + dbResult.Msg + "')");
                return;
            }

            if (receiptType.Text == "SD")
                SendReceipt();
            else if (receiptType.Text == "SI")
                InternationalSendReceipt();
            else if (receiptType.Text == "PD")
                PayReceipt();
            else if (receiptType.Text == "PI")
                InternationalPayReceipt();
            else if (receiptType.Text == "CD")
                CancelTransaction();
        }

        private void SendReceipt()
        {
            DbResult dbResult = _obj.SearchSentTxn(GetStatic.GetUser(), controlNo.Text);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.PrintMessage(Page, dbResult);
                return;
            }
            string url = "SendReceipt.aspx?controlNo=" + controlNo.Text;
            RedirectUrl(url);
            //GetStatic.CallBackJs1(Page, "Generate Receipt", "GenerateReceipt('" + url + "')");
        }

        private void InternationalSendReceipt()
        {
            DbResult dbResult = _obj.SearchSentIntlTxn(GetStatic.GetUser(), controlNo.Text);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.PrintMessage(Page, dbResult);
                return;
            }
            string url = "SendIntlReceipt.aspx?controlNo=" + controlNo.Text;
            RedirectUrl(url);
            //GetStatic.CallBackJs1(Page, "Generate Receipt", "GenerateReceipt('" + url + "')");
        }

        private void PayReceipt()
        {
            DbResult dbResult = _obj.SearchPaidTxn(GetStatic.GetUser(), controlNo.Text);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.PrintMessage(Page, dbResult);
                return;
            }
            string url = "PayReceipt.aspx?controlNo=" + controlNo.Text;
            RedirectUrl(url);
            //GetStatic.CallBackJs1(Page, "Generate Receipt", "GenerateReceipt('" + url + "')");
        }

        private void InternationalPayReceipt()
        {
            DbResult dbResult = _obj.SearchPaidIntlTxn(GetStatic.GetUser(), controlNo.Text);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.PrintMessage(Page, dbResult);
                return;
            }
            string url = "PayIntlReceipt.aspx?controlNo=" + controlNo.Text;
            RedirectUrl(url);
            //GetStatic.CallBackJs1(Page, "Generate Receipt", "GenerateReceipt('" + url + "')");
        }
        private void CancelTransaction()
        {
            DbResult dbResult = _obj.SearchCancleTxn(GetStatic.GetUser(), controlNo.Text, GetStatic.GetAgentId());
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.PrintMessage(Page, dbResult);
                return;
            }

            if (dbResult.Extra.ToLower().Equals("d"))
            {
                var url = "CancelReceipt.aspx?receiptType=duplicate&tranId=" + dbResult.Extra2;
                RedirectUrl(url);
            }
            else
            {
                GetStatic.AlertMessage(Page, "Invalid Transaction");
            }
        }
        private void RedirectUrl(string url)
        {
            Response.Redirect(url);
        }
    }
}