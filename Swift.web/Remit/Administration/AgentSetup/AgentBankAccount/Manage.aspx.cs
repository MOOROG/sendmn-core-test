using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Swift.web.Remit.Administration.AgentSetup.AgentBankAccount
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20111000";
        private const string AddEditFunctionId = "20111010";
        private const string DeleteFunctionId = "20111020";
        private readonly AgentBankAccountDao obj = new AgentBankAccountDao();
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                pnl1.Visible = GetMode().ToString() == "1";
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
            }
        }

        protected void bntSubmit_Click(object sender, EventArgs e)
        {
            Update();
        }

        #region Method

        protected string GetAgentName()
        {
            return remitLibrary.GetAgentBreadCrumb(GetAgentId().ToString());
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("abaId");
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

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            bankName.Text = dr["bankName"].ToString();
            bankBranch.Text = dr["bankBranch"].ToString();
            accountNo.Text = dr["accountNo"].ToString();
            accountName.Text = dr["accountName"].ToString();
            swiftCode.Text = dr["swiftCode"].ToString();
            routingNo.Text = dr["routingNo"].ToString();
            bankNameB.Text = dr["bankNameB"].ToString();
            bankBranchB.Text = dr["bankBranchB"].ToString();
            accountNoB.Text = dr["accountNoB"].ToString();
            accountNameB.Text = dr["accountNameB"].ToString();
            swiftCodeB.Text = dr["swiftCodeB"].ToString();
            routingNoB.Text = dr["routingNoB"].ToString();
            isDefault.SelectedValue = dr["isDefault"].ToString();
        }

        private void Update()
        {
            try
            {
                DbResult dbResult = obj.Update(
                                                 GetStatic.GetUser()
                                               , GetId().ToString()
                                               , GetAgentId().ToString()
                                               , bankName.Text
                                               , bankBranch.Text
                                               , accountNo.Text
                                               , accountName.Text
                                               , swiftCode.Text
                                               , routingNo.Text
                                               , bankNameB.Text
                                               , bankBranchB.Text
                                               , accountNoB.Text
                                               , accountNameB.Text
                                               , swiftCodeB.Text
                                               , routingNoB.Text
                                               , isDefault.Text);
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

        #endregion Method
    }
}