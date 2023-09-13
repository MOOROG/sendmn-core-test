using System;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.PayAcDepositV3.PostTransaction
{
    public partial class PostIntl : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly PayAcDepositDao _obj = new PayAcDepositDao();
        private const string ViewFunctionId = "20122600";
        private string _fromDate = "";
        private string _toDate = "";
        private string _fromTime = "";
        private string _toTime = "";
        protected void Page_Load(object sender, EventArgs e)
        {
            _fromDate = GetStatic.ReadQueryString("fromDate", "");
            _toDate = GetStatic.ReadQueryString("toDate", "");
            _fromTime = GetStatic.ReadQueryString("fromTime", "");
            _toTime = GetStatic.ReadQueryString("toTime", "");
            hdnPAgent.Value = GetStatic.ReadQueryString("pAgent", "");
            hdnTranId.Value = GetStatic.ReadQueryString("tranId", "");
            hdnPAgentName.Value = GetStatic.ReadQueryString("pAgentName", "");
            lblBankName.Text = hdnPAgentName.Value;
            if (!IsPostBack)
            {
                Authenticate();
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
            var dbResult = _obj.PostIntl(GetStatic.GetUser(), hdnTranId.Value, hdnPAgent.Value);
            if (dbResult.ErrorCode == "1")
            {
                GetStatic.AlertMessage(Page);
                return;
            }
            GetStatic.PrintMessage(Page, dbResult);
            Response.Redirect("PendingIntl.aspx?pAgent=" + hdnPAgent.Value + "&pAgentName=" + hdnPAgentName.Value + "&fromDate=" + _fromDate + "&toDate=" + _toDate + "&fromTime=" + _fromTime + "&toTime=" + _toTime);
        }

        protected void btnDontPay_Click(object sender, EventArgs e)
        {
            Response.Redirect("PendingIntl.aspx?pAgent=" + hdnPAgent.Value + "&pAgentName=" + hdnPAgentName.Value + "&fromDate=" + _fromDate + "&toDate=" + _toDate + "&fromTime=" + _fromTime + "&toTime=" + _toTime);
        }
    }
}