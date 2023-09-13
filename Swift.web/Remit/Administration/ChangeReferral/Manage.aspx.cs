using Swift.DAL.Remittance.APIPartner;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;

namespace Swift.web.Remit.Administration.ChangeReferral
{
    public partial class Manage : System.Web.UI.Page
    {
        private string ViewFunctionId = "20202700";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly APIPartnerDao _dao = new APIPartnerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.HasRight(ViewFunctionId);
            var MethodName = Request.Form["MethodName"];
            if (MethodName == "SearchTransaction")
                SearchTransactionDetails();

            if (MethodName == "SaveReferral")
                SaveReferral();

            if (!IsPostBack)
            {

            }
        }

        private void SaveReferral()
        {
            var referralCode = Request.Form["NewReferral"];
            var controlNo = Request.Form["ControlNo"];
            var _dbRes = _dao.UpdateReferral(GetStatic.GetUser(), controlNo, referralCode);

            GetStatic.JsonResponse(_dbRes, this);
        }

        private void SearchTransactionDetails()
        {
            var controlNo = Request.Form["ControlNo"];
            DataRow dr = _dao.GetTransactionDetails(GetStatic.GetUser(), controlNo);

            TxnResponse _resp = new TxnResponse();
            if (dr == null)
            {
                _resp.ErrorCode = "1";
                _resp.Msg = "Internal error occured!";
            }
            else
            {
                _resp.ErrorCode = dr["ErrorCode"].ToString();
                _resp.Msg = dr["Msg"].ToString();
                if (dr["ErrorCode"].ToString().Trim() == "0")
                {
                    _resp.ControlNo = controlNo;
                    _resp.TranId = dr["ID"].ToString();
                    _resp.SenderName = dr["SENDERNAME"].ToString();
                    _resp.ReceiverName = dr["RECEIVERNAME"].ToString();
                    _resp.ReferralName = dr["REFERRAL_NAME"].ToString();
                    _resp.ReferralCode = dr["REFERRAL_CODE"].ToString();
                    _resp.CollectAmount = dr["CAMT"].ToString();
                    _resp.TransferAmount = dr["TAMT"].ToString();
                    _resp.PayoutAmount = dr["PAMT"].ToString();
                    _resp.PayoutCountry = dr["PCOUNTRY"].ToString();
                    _resp.CollMode = dr["COLLMODE"].ToString();
                    _resp.PayoutCurr = dr["PAYOUTCURR"].ToString();
                }
            }

            GetStatic.JsonResponse(_resp, this);
        }

        public class TxnResponse : DbResult
        {
            public string ControlNo { get; set; }
            public string TranId { get; set; }
            public string SenderName { get; set; }
            public string ReceiverName { get; set; }
            public string ReferralName { get; set; }
            public string ReferralCode { get; set; }
            public string CollectAmount { get; set; }
            public string TransferAmount { get; set; }
            public string PayoutAmount { get; set; }
            public string PayoutCountry { get; set; }
            public string CollMode { get; set; }
            public string PayoutCurr { get; set; }
        }
    }
}