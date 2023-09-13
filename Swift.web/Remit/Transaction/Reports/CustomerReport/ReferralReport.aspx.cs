using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.web.Library;
namespace Swift.web.Remit.Transaction.Reports.CustomerReport
{
    public partial class ReferralReport : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "2021900";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                startDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                toDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                PopulateDdl();
            }
        }
        private void PopulateDdl()
        {
            _sl.SetDDL(ref ddlCountry, "EXEC proc_online_dropDownList @flag='allCountrylist'", "countryName", "countryName", "", "Select..");
        }
        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

    }
}