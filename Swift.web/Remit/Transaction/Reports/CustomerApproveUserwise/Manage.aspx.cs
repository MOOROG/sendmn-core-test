using Swift.web.Library;
using System;

namespace Swift.web.Remit.Transaction.Reports.CustomerApproveUserwise
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20162400";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                PopulateDDL();
                startDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected void PopulateDDL()
        {
            _sdd.SetDDL(ref countryDDL, "EXEC [proc_dropDownLists] @flag='r-country-list'", "countryId", "countryName", "", "All");
            _sdd.SetDDL(ref userDDL, "EXEC [proc_dropDownLists] @flag='user-list'", "approvedBy", "approvedBy", "", "All");
        }
    }
}