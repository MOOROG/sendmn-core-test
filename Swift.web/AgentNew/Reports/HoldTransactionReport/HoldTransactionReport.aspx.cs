using Swift.web.Library;
using System;

namespace Swift.web.AgentNew.Reports.HoldTransactionReport
{
    public partial class HoldTransactionReport : System.Web.UI.Page
    {
        private RemittanceLibrary sl = new RemittanceLibrary();
        private StaticDataDdl sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20214000";
        private const string ViewBranchFunctionId = "20214010";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                startDate.Text = DateTime.Now.AddDays(-1).ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected string HasRight()
        {
            var a = sl.HasRight(ViewBranchFunctionId).ToString().ToLower();
            return a;
        }
    }
}