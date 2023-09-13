using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.Administration.AgentSetup.Functions.AgentDepositBank
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20101600";
        private const string AddEditFunctionId = "20101610";
        private const string DeleteFunctionId = "20101620";
        private readonly StaticDataDdl _sl = new StaticDataDdl();
        private readonly AgentBusinessFunctionDao obj = new AgentBusinessFunctionDao();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDdl(null);
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    //Your code goes here
                }
            }
        }

        protected string GetAgentPageTab()
        {
            return "Agent Name : " + swiftLibrary.GetAgentName(GetAgent().ToString());
        }

        #region showhidetab

        protected void ShowHideDepositBankListTab()
        {
            string agentRole = GetAgentRole();

            switch (agentRole)
            {
                case "B":
                    sendingListTab.Visible = true;
                    sendingListTab.InnerHtml = "<a href=\"../SendingList.aspx?agentId=" + GetAgent() + "&aType=" +
                                               GetAgentType() + "\">Sending List </a>";
                    receivingListTab.Visible = true;
                    receivingListTab.InnerHtml = "<a href=\"../ReceivingList.aspx?agentId=" + GetAgent() + "&aType=" +
                                                 GetAgentType() + "\">Receiving List </a>";
                    break;

                case "S":
                    sendingListTab.Visible = true;
                    sendingListTab.InnerHtml = "<a href=\"../SendingList.aspx?agentId=" + GetAgent() + "&aType=" +
                                               GetAgentType() + "\">Sending List </a>";
                    receivingListTab.Visible = false;
                    break;

                case "R":
                    receivingListTab.Visible = true;
                    receivingListTab.InnerHtml = "<a href=\"../ReceivingList.aspx?agentId=" + GetAgent() + "&aType=" +
                                                 GetAgentType() + "\">Receiving List </a>";
                    sendingListTab.Visible = false;
                    break;

                default:
                    sendingListTab.Visible = false;
                    receivingListTab.Visible = false;
                    break;
            }
        }

        #endregion showhidetab

        #region QueryString

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentDepositBankId");
        }

        protected string GetAgentRole()
        {
            return swiftLibrary.GetAgentRole(GetAgent().ToString());
        }

        protected long GetAgent()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected long GetAgentType()
        {
            return GetStatic.ReadNumericDataFromQueryString("aType");
        }

        #endregion QueryString

        #region Method

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnDelete.Visible = swiftLibrary.HasRight(DeleteFunctionId);
            bntSubmit.Visible = swiftLibrary.HasRight(AddEditFunctionId);
        }

        protected void PopulateDdl(DataRow dr)
        {
            _sl.SetStaticDdl(ref bankName, "3600", GetStatic.GetRowData(dr, "bankName"), "Select");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectAdbById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;
            bankName.SelectedValue = dr["bankName"].ToString();
            bankAcctNum.Text = dr["bankAcctNum"].ToString();
            description.Text = dr["description"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateAdb(GetStatic.GetUser(), GetId().ToString(), GetAgent().ToString(),
                                              bankName.SelectedValue, bankAcctNum.Text, description.Text);
            ManageMessage(dbResult);
        }

        private void Delete()
        {
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), GetId().ToString());
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx?agentId=" + GetAgent() + "&aType=" + GetAgentType());
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        #endregion Method

        #region Element Method

        protected void bntSubmit_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            Delete();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("DepositBankList.aspx");
        }

        #endregion Element Method
    }
}