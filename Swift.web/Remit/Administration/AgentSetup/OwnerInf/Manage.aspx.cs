using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.AgentSetup.OwnerInf
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20111000";
        private const string AddEditFunctionId = "20111010";
        private const string DeleteFunctionId = "20111020";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly AgentOwnershipInfDao obj = new AgentOwnershipInfDao();
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //Authenticate();
                GetStatic.SetActiveMenu(ViewFunctionId);
                pnl1.Visible = GetMode().ToString() == "1";
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    PopulateDdl(null);
                    PullDefaultValueById();
                }
            }
        }

        private void PullDefaultValueById()
        {
            DataRow dr = obj.PullDefaultValueById(GetStatic.GetUser(), GetParentId().ToString());
            if (dr == null)
                return;

            city.Text = dr["city"].ToString();
            zip.Text = dr["zip"].ToString();

            PopulateDdl(dr);
        }

        protected void bntSubmit_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadState(ref state, country.Text, "");
        }

        #region Method

        protected string GetAgentName()
        {
            return remitLibrary.GetAgentBreadCrumb(GetAgentId().ToString());
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("aoiId");
        }

        protected long GetAgentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected long GetMode()
        {
            return GetStatic.ReadNumericDataFromQueryString("mode");
        }

        protected long GetParentId()
        {
            return GetStatic.ReadNumericDataFromQueryString("parent_id");
        }

        protected string GetAgentType()
        {
            return GetStatic.ReadNumericDataFromQueryString("aType").ToString();
        }

        protected string GetActAsBranchFlag()
        {
            return GetStatic.ReadQueryString("actAsBranch", "");
        }

        private void Authenticate()
        {
            remitLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            bntSubmit.Visible = remitLibrary.HasRight(AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            _sdd.SetStaticDdl(ref idType, "1300", GetStatic.GetRowData(dr, "idType"), "Select");
            _sdd.SetDDL(ref country, "EXEC proc_countryMaster @flag = 'l'", "countryId", "countryName",
                        GetStatic.GetRowData(dr, "country"), "Select");
            _sdd.SetDDL(ref issuingCountry, "EXEC proc_countryMaster @flag = 'l'", "countryId", "countryName",
                        GetStatic.GetRowData(dr, "issuingCountry"), "Select");
            LoadState(ref state, _sdd.FilterString(country.Text), GetStatic.GetRowData(dr, "state"));
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            ownerName.Text = dr["ownerName"].ToString();
            ssn.Text = dr["ssn"].ToString();
            idType.SelectedValue = dr["idType"].ToString();
            idNumber.Text = dr["idNumber"].ToString();
            expiryDate.Text = dr["expiryDate"].ToString();
            permanentAddress.Text = dr["permanentAddress"].ToString();
            city.Text = dr["city"].ToString();
            zip.Text = dr["zip"].ToString();
            phone.Text = dr["phone"].ToString();
            fax.Text = dr["fax"].ToString();
            mobile1.Text = dr["mobile1"].ToString();
            mobile2.Text = dr["mobile2"].ToString();
            email.Text = dr["email"].ToString();
            position.Text = dr["position"].ToString();
            shareHolding.Text = dr["shareHolding"].ToString();
            PopulateDdl(dr);
        }

        private void Update()
        {
            try
            {
                DbResult dbResult = obj.Update(GetStatic.GetUser()
                                               , GetId().ToString()
                                               , GetAgentId().ToString()
                                               , ownerName.Text
                                               , ssn.Text
                                               , idType.SelectedValue
                                               , idNumber.Text
                                               , issuingCountry.SelectedValue
                                               , expiryDate.Text
                                               , permanentAddress.Text
                                               , country.SelectedValue
                                               , city.Text
                                               , state.SelectedValue
                                               , zip.Text
                                               , phone.Text
                                               , fax.Text
                                               , mobile1.Text
                                               , mobile2.Text
                                               , email.Text
                                               , position.Text
                                               , shareHolding.Text);
                lblMsg.Text = dbResult.Msg;
                ManageMessage(dbResult);
            }
            catch (SqlException ex)
            {
                lblMsg.Text = "Cannot save data : " + ex;
            }
        }

        private void DeleteRow()
        {
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), GetId().ToString());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx?agentId=" + GetAgentId() + "&mode=" + GetMode() + "&parent_id=" +
                                  GetParentId() + "&aType=" + GetAgentType());
            }
            else
            {
                if (GetMode() == 2)
                    GetStatic.AlertMessage(Page);
                else
                    GetStatic.PrintMessage(Page);
            }
        }

        private void LoadState(ref DropDownList ddl, string countryId, string defaultValue)
        {
            string sql = "EXEC proc_countryStateMaster @flag = 'csl', @countryId = " + _sdd.FilterString(countryId);
            _sdd.SetDDL(ref ddl, sql, "stateId", "stateName", defaultValue, "Select");
        }

        #endregion Method
    }
}