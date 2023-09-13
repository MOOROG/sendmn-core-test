using System;
using System.Web.UI;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports
{
    public partial class TranReport : Page
    {
        private const string ViewFunctionId = "20161000";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
       
        protected void Page_Load(object sender, EventArgs e)
        {
            toDate.ReadOnly = true;
            fromDate.ReadOnly = true;
            if (!IsPostBack)
            {
                Authenticate();
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}