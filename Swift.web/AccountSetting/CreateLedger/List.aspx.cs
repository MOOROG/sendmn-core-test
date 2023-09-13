using Swift.web.Library;
using System;

namespace Swift.web.AccountSetting.CreateLedger
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20150300";
        private SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
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