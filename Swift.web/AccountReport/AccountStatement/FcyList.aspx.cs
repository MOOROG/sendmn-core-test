using Swift.web.Library;
using System;

namespace Swift.web.AccountReport.AccountStatement
{
    public partial class FcyList : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20222460";
        private SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                startDate.Text = DateTime.Today.ToString("d");
                endDate.Text = DateTime.Today.ToString("d");
                startDate.ReadOnly = true;
                endDate.ReadOnly = true;
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}