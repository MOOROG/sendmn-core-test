using System;
using System.Web.UI;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.Notification.ApplicationLogRpt
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "10121400";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                _sl.SetDDL3(ref searchBy, "	select distinct tranViewType as tranViewType from tranViewHistory where tranViewType is not null", "tranViewType", "tranViewType", "", "All");
                GetStatic.SetActiveMenu(ViewFunctionId);
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}