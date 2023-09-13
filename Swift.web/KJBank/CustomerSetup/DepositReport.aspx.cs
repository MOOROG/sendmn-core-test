using Swift.web.Library;
using System;

namespace Swift.web.KJBank.CustomerSetup
{
    public partial class DepositReport : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20134100";
        private RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                startDate.Text = DateTime.Today.AddDays(-1).ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}