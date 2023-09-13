using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.Reports.UnpaidTxnReport
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly string ViewFunctionId="20167500";
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                _sl.SetDDL(ref countryDDL, "EXEC [proc_dropDownLists] @flag='r-country-list'", "countryId", "countryName", "", "All");
                Authenticate();
                fromDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}