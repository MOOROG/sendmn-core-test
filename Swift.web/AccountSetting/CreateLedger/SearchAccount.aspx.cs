using Swift.web.Library;
using System;

namespace Swift.web.AccountSetting.CreateLedger
{
    public partial class SearchAccount : System.Web.UI.Page
    {
        private SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
        }
    }
}