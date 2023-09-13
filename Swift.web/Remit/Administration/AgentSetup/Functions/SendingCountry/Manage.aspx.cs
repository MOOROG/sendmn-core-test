using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;

namespace Swift.web.Remit.Administration.AgentSetup.Functions.SendingCountry
{
    public partial class ManageSendingList : System.Web.UI.Page
    {
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private StaticDataDdl _sl = new StaticDataDdl();
        private readonly CountryDao _countryDao = new CountryDao();
        private const string ViewFunctionId = "20101600";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                ShowHideTab();
                ShowHideDepositBankListTab();
                LoadDdl();
            }
        }

        private void LoadDdl()
        {
            // _sl.SetDDL(ref tranType, "exec proc_serviceTypeMaster @flag='l2'", "serviceTypeId",
            // "typeTitle", "", "All");
            _sl.SetDDL(ref sendingCountry, "exec proc_rsList1 @flag='aSC',@listType=" + _sl.FilterString(GetListType()) + ",@agentId=" + _sl.FilterString(GetAgent().ToString()), "countryId", "countryName", "", "Select");
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

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

        protected long GetAgent()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId");
        }

        protected long GetAgentType()
        {
            return GetStatic.ReadNumericDataFromQueryString("aType");
        }

        protected string GetListType()
        {
            return GetStatic.ReadQueryString("listType", "");
        }

        #endregion QueryString

        #region showhidetab

        protected void ShowHideTab()
        {
            string agentType = GetAgentType().ToString();

            SendingCountryList.Visible = true;
            SendingCountryList.InnerHtml = "<a href=\"List.aspx?agentId=" + GetAgent() + "&aType=" +
                                           GetAgentType() + "&actAsBranch=" + GetActasBranch() + "\">Sending Country</a>";

            if (agentType == "2902" || agentType == "2903" || GetActasBranch() == "Y")
            {
                ////SendingList.Visible = true;
                ////SendingList.InnerHtml = "<a href=\"../SendingList.aspx?agentId=" + GetAgent() + "&aType=" +
                ////                                 GetAgentType() + "&actAsBranch=" + GetActasBranch() + "\">Sending List </a>";
                ////businessFunctionTab.Visible = true;
                ////businessFunctionTab.InnerHtml = "<a href=\"../BusinessFunction.aspx?agentId=" + GetAgent() + "&aType=" +
                ////                           GetAgentType() + "&actAsBranch=" + GetActasBranch() + "\">Business Function </a>";
                ReceivingCountryList.Visible = true;
                ReceivingCountryList.InnerHtml = "<a href=\"..ReceivingCountry/List.aspx?agentId=" + GetAgent() + "&aType=" +
                                             GetAgentType() + "&actAsBranch=" + GetActasBranch() + "\">Receiving List </a>";
                AgentGroupMaping.Visible = true;
                AgentGroupMaping.InnerHtml = "<a href=\"../AgentGroupMapping.aspx?agentId=" + GetAgent() + "&aType=" +
                                             GetAgentType() + "&actAsBranch=" + GetActasBranch() + "\">Agent Group List</a>";
            }
            if (GetActasBranch() == "Y" || agentType == "2904")
            {
                RegionalBranchAccessSetup.Visible = true;
                RegionalBranchAccessSetup.InnerHtml = "<a href=\"../RegionalBranchAccessSetup.aspx?agentId=" + GetAgent() + "&aType=" +
                                             GetAgentType() + "&actAsBranch=" + GetActasBranch() + "\">Regional Access Setup</a>";
            }
        }

        protected string GetActasBranch()
        {
            return GetStatic.ReadQueryString("actAsBranch", "");
        }

        protected void ShowHideDepositBankListTab()
        {
            string enCashColl = GetEnableCashCollection();
            string agentRole = GetAgentRole();
            if (enCashColl == "Y")
            {
                depositBankListTab.Visible = true;
                depositBankListTab.InnerHtml = "<a href=\"../AgentDepositBank/List.aspx?agentId=" + GetAgent() + "&aType=" +
                                               GetAgentType() + "\">Deposit Bank List </a>";
            }
            else
            {
                depositBankListTab.Visible = false;
            }
            switch (agentRole)
            {
                case "B":
                    break;

                case "S":
                    ReceivingCountryList.Visible = false;
                    break;

                case "R":
                    break;

                default:
                    ReceivingCountryList.Visible = false;
                    break;
            }
        }

        #endregion showhidetab

        protected void sendingCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            _sl.SetDDL(ref sendingAgent, "SELECT agentId,agentName FROM agentMaster WHERE agentCountryId=" + _sl.FilterString(sendingCountry.Text), "agentId", "agentName", "", "All");
            _sl.SetDDL(ref tranType, "exec proc_rsList1 @flag='cST',@agentId=" + _sl.FilterString(GetAgent().ToString()) + ",@rsCountryId=" + _sl.FilterString(sendingCountry.Text), "serviceTypeId", "typeTitle", "", "All");
            sendingCountry.Focus();
        }

        private void Update()
        {
            DbResult dbResult = _countryDao.UpdateExcSendingCountry(GetStatic.GetUser(), GetAgent().ToString(), sendingAgent.Text, sendingCountry.Text, "s", GetListType(), tranType.Text);
            ManageMessage(dbResult);
        }

        protected void btnSumit_Click(object sender, EventArgs e)
        {
            Update();
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);

            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx?agentId=" + GetAgent() + "&aType=" + GetAgentType() + "&actAsBranch=" + GetActasBranch() + "&listType=" + GetListType());
            }
            else
            {
                //GetStatic.SetMessageBox(Page);
                GetStatic.AlertMessage(Page);
            }
        }
    }
}