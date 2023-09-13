using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.AgentSetup.AgentContactPerson
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20111000";
        private const string AddEditFunctionId = "20111010";
        private const string DeleteFunctionId = "20111020";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly AgentContactPersonDao obj = new AgentContactPersonDao();
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                pnl1.Visible = GetMode().ToString() == "1";
                LoadTab();
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    PopulateDdl(null);
                }
            }
        }

        private void LoadTab()
        {
            divTab.Visible = true;
            var html = new StringBuilder();
            var agentId = GetAgentId();
            var mode = GetMode();
            var parentId = GetParentId();
            var sParentId = GetParentId();
            var aType = GetAgentType();
            var actAsBranch = GetActAsBranchFlag();
            html.Append(
                "<table class=\"table table-condensed\">" +
                "<tr><td height=\"10\"><div class=\"listtabs row\">");
            html.Append("<ul class=\"nav nav-tabs\" role=\"tablist\"><li> <a href=\"../Manage.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\">Agent Information </a></li>" +
                            "<li> <a href=\"../AgentCurrency.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\">Allowed Currency </a></li>" +
                            "<li> <a href=\"../AgentBusinessHistory.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\">Business History </a></li>" +
                            "<li> <a href=\"../AgentFinancialService.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\">Financial Services</a></li>" +
                            "<li> <a href=\"../OwnerInf/List.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\">Owners</a></li>" +
                            "<li> <a href=\"../Document/List.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\">Required Document</a></li>" +
                            "<li> <a href=\"List.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\">Contact Person</a></li>" +
                            "<li> <a href=\"../AgentBankAccount/List.aspx?agentId=" + agentId + "&mode=" + mode + "&parent_id=" + parentId + "&sParentId=" + sParentId + "&aType=" + aType + "&actAsBranch=" + actAsBranch + "\">Bank Account</a></li>" +
                            "<li class=\"active\"> <a href=\"#\" class=\"selected\">Manage</a></li>" +
                                            "</ul> ");
            html.Append("</div></td></tr></table>");
            divTab.InnerHtml = html.ToString();
        }

        private void PullDefaultValueById()
        {
            DataRow dr = obj.PullDefaultValueById(GetStatic.GetUser(), GetAgentId().ToString());
            if (dr == null)
                return;

            country.Text = dr["countryId"].ToString();
            LoadState(ref state, country.Text, "");
            _sdd.SelectByTextDdl(ref state, dr["state"].ToString());
            city.Text = dr["city"].ToString();
            zip.Text = dr["zip"].ToString();
            address.Text = dr["address"].ToString();
            phone.Text = dr["phone1"].ToString();
            mobile1.Text = dr["mobile1"].ToString();
            mobile2.Text = dr["mobile2"].ToString();
            email.Text = dr["email"].ToString();
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
            return GetStatic.ReadNumericDataFromQueryString("acpId");
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
            _sdd.SetStaticDdl(ref contactPersonType, "5300", GetStatic.GetRowData(dr, "contactPersonType"), "Select");
            _sdd.SetDDL(ref country, "EXEC proc_countryMaster @flag = 'l'", "countryId", "countryName",
                        GetStatic.GetRowData(dr, "country"), "Select");
            LoadState(ref state, country.Text, GetStatic.GetRowData(dr, "state"));
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            name.Text = dr["name"].ToString();
            address.Text = dr["address"].ToString();
            city.Text = dr["city"].ToString();
            zip.Text = dr["zip"].ToString();
            phone.Text = dr["phone"].ToString();
            fax.Text = dr["fax"].ToString();
            mobile1.Text = dr["mobile1"].ToString();
            mobile2.Text = dr["mobile2"].ToString();
            email.Text = dr["email"].ToString();
            post.Text = dr["post"].ToString();
            contactPersonType.Text = dr["contactPersonType"].ToString();
            isPrimary.Text = dr["isPrimary1"].ToString();
            PopulateDdl(dr);
        }

        private void Update()
        {
            try
            {
                DbResult dbResult = obj.Update(GetStatic.GetUser()
                                               , GetId().ToString()
                                               , GetAgentId().ToString()
                                               , name.Text
                                               , country.Text
                                               , state.Text
                                               , city.Text
                                               , zip.Text
                                               , address.Text
                                               , phone.Text
                                               , mobile1.Text
                                               , mobile2.Text
                                               , fax.Text
                                               , email.Text
                                               , post.Text
                                               , contactPersonType.Text
                                               , isPrimary.Text);
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
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), GetAgentId().ToString());
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

        protected void btnCopyDetails_Click(object sender, EventArgs e)
        {
            PullDefaultValueById();
        }
    }
}