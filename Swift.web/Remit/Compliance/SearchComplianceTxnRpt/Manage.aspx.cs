using Swift.web.Library;
using System;

namespace Swift.web.Remit.Compliance.SearchComplianceTxnRpt
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary obj = new RemittanceLibrary();
        private const string ViewFunctionId = "20197001";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            ShowTxnDetail();
        }

        private void Authenticate()
        {
            obj.CheckAuthentication(ViewFunctionId);
        }

        protected bool ShowCommentFlag()
        {
            return GetStatic.ReadQueryString("commentFlag", "Y") != "N";
        }

        protected bool ShowBankDetail()
        {
            return (GetStatic.ReadQueryString("showBankDetail", "N") != "Y" ? false : true);
        }

        protected bool ShowOfac()
        {
            return GetStatic.ReadQueryString("ShowOfac", "Y") != "N";
        }

        protected bool ShowComplaince()
        {
            return GetStatic.ReadQueryString("ShowComplaince", "Y") != "N";
        }

        protected bool ShowApproveButton()
        {
            return GetStatic.ReadQueryString("ShowApproveButton", "Y") != "N";
        }

        private void ShowTxnDetail()
        {
            string txnId = GetStatic.ReadQueryString("tranId", "");
            string cntNo = GetStatic.ReadQueryString("controlNo", "");
            if (txnId != "" || cntNo != "")
            {
                ucTran.ShowCommentBlock = ShowCommentFlag();
                ucTran.ShowBankDetail = ShowBankDetail();
                ucTran.ShowOfac = ShowOfac();
                ucTran.ShowCompliance = ShowComplaince();
                ucTran.SearchData(txnId, cntNo, "", "", "COMPLIANCE", "ADM: APPROVE OFAC/COMPLIANCE");
                divTranDetails.Visible = ucTran.TranFound;
            }
        }
    }
}