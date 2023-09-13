using System;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.ModifyPayoutLocation
{
    public partial class ManageSearch : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20122400";
        private readonly SwiftLibrary _sl = new SwiftLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            GetStatic.ResizeFrame(Page);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSearchDetail_Click(object sender, EventArgs e)
        {
            ShowTxnDetail(controlNo.Text);
        }

        private void ShowTxnDetail(string cNo)
        {
            ucTran.SearchData("", cNo, "u", "", "MODIFY", "ADM: MODIFY PAYOUT LOCATION");
            divTranDetails.Visible = ucTran.TranFound;
            divSearch.Visible = !ucTran.TranFound;
            if (!ucTran.TranFound)
            {
                PrintMessage("Transaction not found!");
                return;
            }

            if (ucTran.TranStatus != "Payment")
            {
                divSearch.Visible = true;
                divTranDetails.Visible = false;
                PrintMessage("Payout Location not authorised for modification; Status:" + ucTran.TranStatus + "!");
                return;
            }
        }

        private void PrintMessage(string msg)
        {
            GetStatic.CallBackJs1(Page, "Msg", "alert('" + msg + "');");
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            
        }

        protected void btnCallBack_Click(object sender, EventArgs e)
        {
            ShowTxnDetail(ucTran.CtrlNo);
        }
    }
}