using Swift.DAL.OnlineAgent;
using Swift.web.Library;
using System;

namespace Swift.web.Remit.Administration.BalanceTransferFromKjBank
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFuntionId = "20178000";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly OnlineCustomerDao _sd = new OnlineCustomerDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                var method = Request.Form["MethodName"];
                var receiverAccountNo = Request.Form["body"];
                if (method != null && method.Equals("GetAccountDetailKJBank"))
                {
                    var result = KJBankAPIConnection.GetAccountDetailKJBank(receiverAccountNo,"");
                    var json = "{\"result\":\"" + result + "\"}";
                    Response.ContentType = "text/plain";
                    Response.Write(json);
                    Response.End();
                }
            }
            txtReceiverAccountNo.Attributes.Add("onchange", "AccountDetailKJBank();");

        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFuntionId);
        }
        protected void btnTransfer_Click(object sender, EventArgs e)
        {
            KJBankAPIConnection.AccountTransferKJBank(txtAmount.Text);
        }
    }
}