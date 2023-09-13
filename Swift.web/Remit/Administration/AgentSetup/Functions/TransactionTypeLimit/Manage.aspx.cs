using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.Administration.AgentSetup.Functions.TransactionTypeLimit
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
                ShowHideDepositBankListTab();
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

        #region showhidetab

        protected void ShowHideDepositBankListTab()
        {
            string enCashColl = GetEnableCashCollection();
            string agentRole = GetAgentRole();
            if (enCashColl == "Y")
            {
                depositBankListTab.Visible = true;
                depositBankListTab.InnerHtml = "<a href=\"../AgentDepositBank/List.aspx?agentId=" + GetAgent() +
                                               "&aType=" +
                                               GetAgentType() + "\">Deposit Bank List </a>";
            }
            else
            {
                depositBankListTab.Visible = false;
            }
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

        protected string GetAgentPageTab()
        {
            return "Agent Name : " + swiftLibrary.GetAgentName(GetAgent().ToString());
        }

        protected string GetEnableCashCollection()
        {
            return swiftLibrary.GetEnableCashCollection(GetAgent().ToString());
        }

        protected string GetAgentRole()
        {
            return swiftLibrary.GetAgentRole(GetAgent().ToString());
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentTranTypeLimitId");
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
            _sl.SetDDL(ref serviceType, "EXEC proc_serviceTypeMaster @flag = 'l2'", "serviceTypeId", "typeTitle",
                       GetStatic.GetRowData(dr, "serviceType"), "Select");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectTtlById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;
            serviceType.SelectedValue = dr["serviceType"].ToString();
            tranLimitMax.Text = dr["tranLimitMax"].ToString();
            tranLimitMin.Text = dr["tranLimitMin"].ToString();
            isDefaultDepositMode.SelectedValue = dr["isDefaultDepositMode"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateTtl(GetStatic.GetUser(), GetId().ToString(), GetAgent().ToString(),
                                              serviceType.SelectedValue, tranLimitMax.Text, tranLimitMin.Text,
                                              isDefaultDepositMode.SelectedValue);
            ManageMessage(dbResult);
        }

        private void Delete()
        {
            DbResult dbResult = obj.DeleteTtl(GetStatic.GetUser(), GetId().ToString());
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

        #endregion Element Method
    }
}