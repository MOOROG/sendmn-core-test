using Swift.web.Library;
using System;

namespace Swift.web.AgentNew.Reports.CustomerStatementReport
{
    public partial class StatementReport : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20111600";
        private const string ViewFunctionIdAgent = "40120100";
        private SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(GetFunctionIdByUserType(ViewFunctionIdAgent, ViewFunctionId));
        }

        public string GetFunctionIdByUserType(string functionIdAgent, string functionIdAdmin)
        {
            return (GetStatic.GetUserType() == "HO") ? functionIdAdmin : functionIdAgent;
        }
    }
}