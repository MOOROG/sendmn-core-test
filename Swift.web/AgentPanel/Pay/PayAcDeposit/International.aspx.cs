using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;
using System;

namespace Swift.web.AgentPanel.Pay.PayAcDeposit
{
    public partial class International : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly PayAcDepositDao _obj = new PayAcDepositDao();
        private const string ViewFunctionId = "40131500";

        protected void Page_Load(object sender, EventArgs e)
        {
            _sdd.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                hdnTranId.Value = GetStatic.ReadQueryString("tranId", "");
                LoadByControlNo();
            }
            GetStatic.ResizeFrame(Page);
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void LoadByControlNo()
        {
            if (!string.IsNullOrEmpty(hdnTranId.Value))
            {
                ucTran.SearchData(hdnTranId.Value, "", "", "", "SEARCH", "ADM: VIEW TXN (SEARCH TRANSACTION)");
            }
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            PayAcDeposit();
        }

        private void PayAcDeposit()
        {
            var dbResult = _obj.PayAcDepositIntlAgent(GetStatic.GetUser(), hdnTranId.Value, GetStatic.GetAgent());
            if (dbResult.ErrorCode == "1")
            {
                GetStatic.AlertMessage(Page);
                return;
            }
            GetStatic.PrintMessage(Page, dbResult);
            Response.Redirect("PendingList.aspx");
        }

        protected void btnDontPay_Click(object sender, EventArgs e)
        {
            Response.Redirect("PendingList.aspx");
        }
    }
}