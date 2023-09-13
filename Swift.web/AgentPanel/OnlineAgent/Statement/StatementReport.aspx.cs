using Swift.web.Library;
using System;

namespace Swift.web.AgentPanel.Statement
{
    public partial class StatementReport : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20111600";
        private SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}