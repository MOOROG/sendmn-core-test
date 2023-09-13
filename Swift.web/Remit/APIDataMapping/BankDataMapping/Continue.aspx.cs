using Swift.web.Library;
using System;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.APIDataMapping.BankDataMapping
{
    public partial class Continue : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private const string ViewFunctionId = "20201800";
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateDDL();
                Authenticate();
            }
        }
        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
        private void PopulateDDL()
        {
            _sl.SetDDL(ref partnerDDL, "PROC_MAP_BANK_DATA @FLAG = 'PARTNER'", "AGENTID", "AGENTNAME", "", "Select Partner");
            _sl.SetDDL(ref countryDDL, "PROC_MAP_BANK_DATA @FLAG = 'COUNTRY'", "COUNTRYCODE", "COUNTRYNAME", "", "Select Country");
        }

        protected void countryDDL_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulatePayoutMode(countryDDL.SelectedValue, ref payoutMethodDDL);
        }

        private void PopulatePayoutMode(string selectedValue, ref DropDownList ddl)
        {
            if (string.IsNullOrEmpty(selectedValue))
            {
                ddl.Items.Clear();
                return;
            }
            string sql = "PROC_MAP_BANK_DATA @flag='PAYOUT-MODE', @COUNTRY_CODE = " + _sl.FilterString(selectedValue);
            _sl.SetDDL(ref ddl, sql, "serviceTypeId", "typeTitle", selectedValue, "All");
        }
    }
}