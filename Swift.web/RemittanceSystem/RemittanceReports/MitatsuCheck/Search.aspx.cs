using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.RemittanceSystem.RemittanceReports.MitatsuCheck
{
    public partial class Search : System.Web.UI.Page
    {
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private string ViewFunctionId = "20316000";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                from.Text = DateTime.Now.ToString("yyyy-MM-dd");
                to.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }
        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }
    }
}