using Swift.DAL.BL.Remit.Compliance;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Compliance.SendingAmountThreshold
{
    public partial class Manage : System.Web.UI.Page
    {
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly AmountThresholdSetupDao obj = new AmountThresholdSetupDao();

        private const string ViewFunctionId = "2019500";
        private const string AddEditFunctionId = "2019510";
        private const string ApproveFunctionId = "2019520";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                Misc.MakeNumericTextbox(ref Amount);
                LoadDdl();

                var id = GetID();
                if (id != "")
                {
                    loadData(id);
                }
            }
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private string GetID()
        {
            return GetStatic.ReadQueryString("sAmtThresholdId", "");
        }

        private void LoadDdl()
        {
            LoadCountry(ref sCountry, "sCountry");
            LoadCountry(ref rCountry, "rCountry");
            LoadAgent(ref sAgent, "");
        }

        private void LoadCountry(ref DropDownList ddl, string country)
        {
            var sql = "EXEC proc_countryMaster @flag = 'ocl'";
            sql = sql + ",@countryType=" + _sdd.FilterString(country);
            _sdd.SetDDL(ref ddl, sql, "countryId", "countryName", "", "Select");
        }

        private void LoadAgent(ref DropDownList ddl, string countryId)
        {
            var sql = "EXEC proc_agentMaster @flag = 'alc', @agentCountryId=" + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "agentId", "agentName", "", "All");
        }

        private void loadData(string Id)
        {
            var data = obj.SelectById(GetStatic.GetUser(), Id);
            if (data != null)
            {
                sCountry.SelectedValue = data["sCountryId"].ToString();
                rCountry.SelectedValue = data["rCountryId"].ToString();
                Amount.Text = data["Amount"].ToString();
                LoadAgent(ref sAgent, data["sCountryId"].ToString());
                sAgent.SelectedValue = data["sAgent"].ToString();
                Message.Text = data["MessageTxt"].ToString();
                chkActive.Checked = (data["isActive"].ToString() == "Y") ? true : false;
                Save.Text = "Update";
            }
        }

        protected void Save_Click(object sender, EventArgs e)
        {
            if (Save.Text == "Update")
            {
                var dbResult = obj.UpdateThresholdAmount(GetID(), sCountry.SelectedItem.Value, sCountry.SelectedItem.Text, rCountry.SelectedItem.Value, rCountry.SelectedItem.Text,
                    sAgent.SelectedItem.Value, Amount.Text.Trim(), Message.Text, (chkActive.Checked == true) ? "Y" : "N", GetStatic.GetUser());
                ManageMessage(dbResult);
            }
            else
            {
                var dbResult = obj.SaveThresholdAmount(sCountry.SelectedItem.Value, sCountry.SelectedItem.Text, rCountry.SelectedItem.Value, rCountry.SelectedItem.Text,
                    sAgent.SelectedItem.Value, Amount.Text.Trim(), Message.Text, (chkActive.Checked == true) ? "Y" : "N", GetStatic.GetUser());
                ManageMessage(dbResult);
            }
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.PrintMessage(Page);
            }
            else
            {
                Response.Redirect("List.aspx");
            }
        }

        protected void sCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadAgent(ref sAgent, sCountry.Text);
        }
    }
}