using Swift.web.Library;
using System;

namespace Swift.web.Agent
{
    public partial class Dashboard : System.Web.UI.Page
    {
        private RemittanceLibrary rl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            rl.CheckSession();
            Response.Redirect("Dashboard2.aspx");
        }
    }
}