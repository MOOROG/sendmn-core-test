using Swift.web.Library;
using System;

namespace Swift.web.Remit.Administration.CustomerSetup.Statement
{
    public partial class StatementReport : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20111600";
        private SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                startDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                endDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}