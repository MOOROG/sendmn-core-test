using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.RemittanceSystem.RemittanceReports.Mitasu
{
    public partial class MitasuReport : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20196010";
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                swiftLibrary.CheckAuthentication(ViewFunctionId);
            }
            fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }
    }
}