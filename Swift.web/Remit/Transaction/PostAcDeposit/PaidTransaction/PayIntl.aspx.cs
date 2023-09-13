using System;
using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.PostAcDeposit.PaidTransaction
{
    public partial class PayIntl : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly PayAcDepositDao _obj = new PayAcDepositDao();
        private const string ViewFunctionId = "20122500";
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
            hdnIsApi.Value = GetStatic.ReadQueryString("isApi", "");
            hdnRowId.Value = GetStatic.ReadQueryString("rowId", "");
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
                ucTran.SearchData(hdnTranId.Value, "", "", "", "SEARCH", "ADM: VIEW TXN (SEARCH TRANSACTION)");
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            PayAcDeposit("Y");
        }

        private void PayAcDeposit(string IsHoPaid)
        {
            var dbResult = _obj.PayIntl(GetStatic.GetUser(), hdnTranId.Value, hdnPAgent.Value, IsHoPaid);
            if (dbResult.ErrorCode == "1")
            {
                GetStatic.AlertMessage(Page);
                return;
            }
            GetStatic.PrintMessage(Page, dbResult);
            Response.Redirect("PendingIntl.aspx?pAgent=" + hdnPAgent.Value + "&pAgentName=" + hdnPAgentName.Value + "&fromDate="+_fromDate+"&toDate="+_toDate+"&fromTime="+_fromTime+"&toTime="+_toTime);
        }

        protected void btnDontPay_Click(object sender, EventArgs e)
        {
            Response.Redirect("PendingIntl.aspx?pAgent=" + hdnPAgent.Value + "&pAgentName=" + hdnPAgentName.Value + "&fromDate=" + _fromDate + "&toDate=" + _toDate + "&fromTime=" + _fromTime + "&toTime=" + _toTime);
        }
   
        
    }
}