using Swift.web.Library;
using System;

namespace Swift.web.AgentNew.Reports.ReferralReport
{
    public partial class Search : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20203200";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                asOfDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}