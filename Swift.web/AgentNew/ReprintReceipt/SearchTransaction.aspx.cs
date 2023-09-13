using Swift.web.Library;
using System;

namespace Swift.web.AgentNew.ReprintReceipt
{
    public partial class SearchTransaction : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "40101900";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}