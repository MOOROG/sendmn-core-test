using Swift.DAL.Remittance.Transaction;
using Swift.web.Library;
using System;

namespace Swift.web.Remit.ThirdPartyTXN.APILog
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly ApiLogDao _apiLog = new ApiLogDao();
        private const string ViewFunctionId = "20172000";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            LoadMessage();
        }
        
        private void LoadMessage()
        {
            var id = GetStatic.ReadNumericDataFromQueryString("id").ToString();
            var res = _apiLog.GetApiLogRecord(id);
            if (res != null)
            {
                provider.Text = res["providerName"].ToString();
                Method.Text = res["methodName"].ToString();
                ControlNo.Text = res["controlNo"].ToString();
                User.Text = res["requestedBy"].ToString();
                RequestDate.Text = res["requestedDate"].ToString();
                ResponseDate.Text = res["responseDate"].ToString();
                Code.Text = res["errorCode"].ToString();
                Message.Text = res["errorMessage"].ToString();
                reqXml.Text = res["requestXml"].ToString();
                resXml.Text = res["responseXml"].ToString();
            }
        }
    }
}