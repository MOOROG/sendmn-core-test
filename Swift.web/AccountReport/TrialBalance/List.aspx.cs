using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.TrialBalance
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20101500";
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                fromDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}