using System;
using System.Web.UI;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.Notification.TroubleTicket
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "10121500";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                //_sl.SetDDL3(ref ticketBy, "	select distinct tranViewType as tranViewType from tranViewHistory where tranViewType is not null", "tranViewType", "tranViewType", "", "All");
                GetStatic.SetActiveMenu(ViewFunctionId);
            }
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}