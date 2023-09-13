using System;
using Swift.web.Library;
using System.Data;
using Swift.DAL.SwiftDAL;
using Swift.DAL.BL.System.GeneralSettings;

namespace Swift.web.SwiftSystem.GeneralSetting.FieldSetting
{
    public partial class Receive : System.Web.UI.Page
    {
        readonly RemittanceLibrary sl = new RemittanceLibrary();
        readonly FieldSettingDao fsd = new FieldSettingDao();
        private const string ViewFunctionId = "10112100";
        private const string AddEditFunctionId = "10112110";
        private const string DeleteFunctionId = "10112120";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if(!IsPostBack)
            {
                populateDdl();
                if (GetId() > 0)
                {
                    Populate();
                }
            }
        }

        private void populateDdl()
        {
            sl.SetDDL(ref country, "EXEC proc_dropDownLists2 @flag = 'countryPay'", "countryId", "countryName", "", "Select");
            sl.SetDDL(ref copyToCountry, "EXEC proc_dropDownLists2 @flag = 'countryPay'", "countryId", "countryName", "", "Select");
            
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rowId");
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected void Populate()
        {
            DataRow dr = fsd.SelectById(GetStatic.GetUser(), GetId().ToString(), "Pay");
            if (dr == null)
                return;
            //receivingCountry.Value = dr["countryId"].ToString();
            //receivingCountry.Text = dr["countryName"].ToString();
            //receivingAgent.Value = dr["agentId"].ToString();
            //receivingAgent.Text = dr["agentName"].ToString();

            copyPanel.Visible = true;
            country.SelectedValue = dr["countryId"].ToString();
            agent.SelectedValue = dr["agentId"].ToString();

            ddlId.Text = dr["id"].ToString();
            ddlDob.Text = dr["dob"].ToString();
            ddlAddress.Text = dr["address"].ToString();
            ddlCity.Text = dr["city"].ToString();
            ddlContact.Text = dr["contact"].ToString();
            ddlNativeCountry.Text = dr["nativeCountry"].ToString();
            ddlTxnHistory.Text = dr["txnHistory"].ToString();
        }

        protected void Upadate()
        {
            DbResult dbResult = fsd.Update(GetStatic.GetUser(), GetId().ToString(), country.Text, agent.Text, ddlId.Text, ddlDob.Text, ddlAddress.Text,
                ddlCity.Text, ddlContact.Text, ddlNativeCountry.Text, ddlTxnHistory.Text, "Pay");
            ManageMessage(dbResult);
        }


        private void CopySetting()
        {
            DbResult dbResult = fsd.CopySetting(GetStatic.GetUser(), "", copyToCountry.Text, copyToagent.Text, ddlId.Text, ddlDob.Text, ddlAddress.Text,
                ddlCity.Text, ddlContact.Text, ddlNativeCountry.Text, ddlTxnHistory.Text, "Pay");
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }

            GetStatic.PrintMessage(Page, dbResult);

        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Upadate();            
        }

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (country.Text != "")
                sl.SetDDL(ref agent, "EXEC proc_dropDownLists2 @flag = 'agentPay',@param=" + sl.FilterString(country.Text) + "", "agentId", "agentName", "", "All");
        }

        protected void copyToCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (copyToCountry.Text != "")
                sl.SetDDL(ref copyToagent, "EXEC proc_dropDownLists2 @flag = 'agentPay',@param=" + sl.FilterString(copyToCountry.Text) + "", "agentId", "agentName", "", "All");
        }

        protected void copySetting_Click(object sender, EventArgs e)
        {
            CopySetting();
        }

    }
}