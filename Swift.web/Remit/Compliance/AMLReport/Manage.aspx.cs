using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.Remit.Compliance.AMLReport
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private readonly RemittanceDao sd = new RemittanceDao();
        private const string ViewFunctionId = "20196000";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                LoadDDL();
            }
            sCountry.Attributes.Add("onchange", "SCountryCallBack();");
            rCountry.Attributes.Add("onchange", "RCountryCallBack();");
            sAgent.Attributes.Add("onchange", "SAgentCallBack();");
            rAgent.Attributes.Add("onchange", "RAgentCallBack();");
            Misc.DisableInput(ref frmDate, DateTime.Today.ToString("yyyy-MM-dd"));
            Misc.DisableInput(ref toDate, DateTime.Today.ToString("yyyy-MM-dd"));
            //Misc.MakeNumericTextbox(ref idNumber, false, true);
            Misc.MakeNumericTextbox(ref tcNo, false, true);
            Misc.MakeNumericTextbox(ref fromAmt, false, true);
            Misc.MakeNumericTextbox(ref toAmt, false, true);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadDDL()
        {
            sl.SetDDL(ref sCountry, "EXEC proc_dropDownListAML @flag='AMLsCountry',@user = " + sd.FilterString(GetStatic.GetUser()) + ",@userType = " + sd.FilterString(GetStatic.GetUserType()) + ",@agentId =" + sd.FilterString(GetStatic.GetAgent()) + "", "countryName", "countryName", "", "All");
            sl.SetDDL(ref rCountry, "EXEC proc_dropDownListAML @flag='AMLpCountry',@user = " + sd.FilterString(GetStatic.GetUser()) + ",@userType = " + sd.FilterString(GetStatic.GetUserType()) + ",@agentId =" + sd.FilterString(GetStatic.GetAgent()) + "", "countryName", "countryName", "", "All");
            sl.SetDDL(ref rMode, "EXEC proc_dropDownListAML @flag='AMLrMode'", "typeTitle", "typeTitle", "", "All");
            sl.SetDDL(ref sAgent, "EXEC proc_dropDownListAML @flag='AMLSAgent'", "agentId", "agentName", "", "All");
        }

        protected void rCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            sl.SetDDL(ref rAgent, "EXEC proc_dropDownListAML @flag='AMLRagent',@country=" + sd.FilterString(rCountry.Text), "agentId", "agentName", "", "All");
        }

        protected void searchBy_SelectedIndexChanged(object sender, EventArgs e)
        {
            sl.SetDDL(ref saerchType, "EXEC proc_dropDownListAML @flag='IdNoFor', @searchBy=" + sl.FilterString(searchBy.SelectedValue), "value", "text", "mid", "");
        }
    }
}