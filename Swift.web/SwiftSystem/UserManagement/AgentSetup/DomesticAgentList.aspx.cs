using System;
using System.Collections.Generic;
using System.Text;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using Swift.DAL.BL.SwiftSystem;

namespace Swift.web.SwiftSystem.UserManagement.AgentSetup
{
    public partial class DomesticAgentList : System.Web.UI.Page
    {
        private string _gridName;

        private const string ViewFunctionId = "20111000";
        private const string AddEditFunctionId = "20101010";
        private const string ApproveFunctionId = "20111030";
        private const string ViewUserFunctionId = "10101100";
        private const string AgentFunctionFid = "20111040";
        private const string AgentInfoFid = "20111050";

        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        private string agentTitle = "";
        private string agentImg = "";
        private string _branchLink = "";
        private string _agentFunctionLink = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
            }
            LoadTab();
            DeleteRow();
            LoadGrid();
        }

        #region QueryString

        protected string GetSuperAgentId()
        {
            return GetAgentType() == "2901" ? GetStatic.GetDomesticSuperAgentId() : "";
        }
        protected string GetAgentId()
        {
            return GetStatic.ReadQueryString("agentId", GetStatic.GetHoAgentId());
        }

        protected string GetParentId()
        {
            return GetStatic.ReadQueryString("parentId", "");
        }

        protected string GetActAsBranchFlag()
        {
            return GetStatic.ReadQueryString("actAsBranch", "N");
        }

        protected string GetAgentType()
        {
            return GetStatic.ReadQueryString("agentType", "2901");
        }

        private string GetChildAgentType()
        {
            var agentType = GetAgentType();
            switch (agentType)
            {
                case "2900":
                    return "2901";
                case "2901":
                    return "2902";
                case "2902":
                    return "2903";
                case "2903":
                    return "2904";
            }
            return "";
        }

        #endregion
        #region method

        private void LoadTab()
        {
            var urlRoot = GetStatic.GetUrlRoot();
            var agentType = GetAgentType();
            switch (agentType)
            {
                case "2901":
                    superAgent.InnerHtml = "<a href=\"#\" class=\"selected\">Super Agent</a>";
                    agent.InnerHtml = "";
                    branch.InnerHtml = "";
                    agentTitle = "Agents";
                    agentImg = "<img src=\"" + urlRoot + "/Images/agents.png\" border=0 />";
                    _branchLink = "<a href=\"DomesticAgentList.aspx?actAsBranch=Y&agentId=@agentId&parentId=@parentId&agentType=" + GetChildAgentType() + "\" title=\"" + agentTitle + "\"><img src=\"" + urlRoot + "/Images/branch.png\" border=0 />Branches</a>";
                    _agentFunctionLink = "<a href=\"#\" onclick=\"ManageAgentFunction(@agentId, @agentType,'" + GetActAsBranchFlag() + "')\"><img src = \"" + urlRoot + "/images/function.png\" border=0 alt = \"Functions\" title=\"Functions\" /></a>&nbsp;&nbsp;";
                    _gridName = "grd_superAgent";

                break;
                case "2902":
                    superAgent.InnerHtml = "<a href=\"DomesticAgentList.aspx\">Super Agent</a>";
                    if (GetActAsBranchFlag() == "Y")
                    {
                        agent.InnerHtml = "";
                        branch.InnerHtml = "<a href=\"#\" class=\"selected\">Branch</a>";
                        agentTitle = "";
                        agentImg = "";
                    }
                    else
                    {
                        agent.InnerHtml = "<a href=\"#\" class=\"selected\">Agent</a>";
                        branch.InnerHtml = "";
                        agentTitle = "Branches";
                        agentImg = "<img src=\"" + urlRoot + "/Images/branch.png\" border=0 />";
                    }
                    _agentFunctionLink = "<a href=\"#\" onclick=\"ManageAgentFunction(@agentId, @agentType,'" + GetActAsBranchFlag() + "')\"><img src = \"" + urlRoot + "/images/function.png\" border=0 alt = \"Functions\" title=\"Functions\" /></a>&nbsp;&nbsp;";
                    _gridName = "grd_agent";
                    break;

                case "2903":
                    superAgent.InnerHtml = "<a href=\"DomesticAgentList.aspx\">Super Agent</a>";
                    agent.InnerHtml = "<a href=\"DomesticAgentList.aspx?agentId=" + GetParentId() + "&agentType=2902\">Agent</a>";
                    branch.InnerHtml = "<a href=\"#\" class=\"selected\">Branch</a>";
                    _agentFunctionLink = "<a href=\"#\" onclick=\"ManageAgentFunction(@agentId, @agentType,'" + GetActAsBranchFlag() + "')\"><img src = \"" + urlRoot + "/images/function.png\" border=0 alt = \"Functions\" title=\"Functions\" /></a>&nbsp;&nbsp;";
                    _gridName = "grd_domesticAgent";
                    break;
            }
            spnName.InnerHtml = sl.GetAgentBreadCrumb(GetAgentId());
        }

        private void LoadGrid()
        {
            string ddlSql2 = "EXEC [proc_staticDataValue] @flag = 'l', @typeId = 4300";

            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("haschanged", "Change Status", "1:EXEC [proc_agentMaster] @flag = 'hc'"),
                                      new GridFilter("businessType", "Business Type", "1:EXEC proc_staticDataValue @flag = 'l', @typeId = '6200'"),
                                      new GridFilter("businessOrgType", "Agent Type", "1:EXEC proc_staticDataValue @flag = 'l', @typeId = '4500'"),
                                      new GridFilter("agentCountry", "Country", "LT"),
                                      new GridFilter("agentName", "Name", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("agentName", "Name", "", "T"),
                                      new GridColumn("agentType1", "Type", "", "T"),
                                      new GridColumn("countryName", "Country", "", "T")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridName = _gridName;
            grid.ShowAddButton = true;
            grid.ShowPopUpWindowOnAddButtonClick = true;
            grid.PopUpParam = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.SortBy = "countryName";
            grid.SortOrder = "ASC";
            grid.DisableSorting = false;
            grid.AddButtonTitleText = "Add New Record";
            grid.RowIdField = "agentId";
            grid.ThisPage = "List.aspx";

            grid.InputPerRow = 2;
            grid.AllowEdit = false;
            grid.AllowApprove = sl.HasRight(ApproveFunctionId);
            grid.ApproveFunctionId = ApproveFunctionId;

            grid.AddPage = "Manage.aspx?aType=" + GetChildAgentType() +
                           "&parent_id=" + GetAgentId() +
                           "&sParentId=" + GetParentId() +
                           "&actAsBranch=" + GetActAsBranchFlag() +
                           "&mode=2";

            grid.AllowCustomLink = allowAddEdit;

            _agentFunctionLink = "<a href=\"#\" onclick=\"ManageAgentFunction(@agentId, @agentType,'" + GetActAsBranchFlag() + "')\"><img src = \"" + GetStatic.GetUrlRoot() + "/images/function.png\" border=0 alt = \"Functions\" title=\"Functions\" /></a>&nbsp;&nbsp;";

            var customLinkText = new StringBuilder();
            if (allowAddEdit)
                customLinkText.Append("<a href=\"#\" onclick=\"ManageAgent(@agentId, @agentType, @parentId,'" +
                                      GetActAsBranchFlag() +
                                      "')\"><img src = \"" + GetStatic.GetUrlRoot() +
                                      "/images/edit.gif\" border=0 alt = \"Edit\" title=\"Edit\" /></a>&nbsp;&nbsp;");
            if (sl.HasRight(AgentInfoFid))
                customLinkText.Append("<a href=\"#\" onclick=\"ManageAgentInfo(@agentId)\"><img src = \"" +
                                      GetStatic.GetUrlRoot() +
                                      "/images/info.gif\" border=0 alt = \"Info\" title=\"Info\" /></a>&nbsp;&nbsp;");
            if (sl.HasRight(ViewUserFunctionId))
                customLinkText.Append("<a href=\"#\" onclick=\"ManageUser(@agentId)\"><img src = \"" +
                                      GetStatic.GetUrlRoot() +
                                      "/images/user_icon.gif\" border=0 alt = \"Users\" title=\"Users\" /></a>&nbsp;&nbsp;");
            if (sl.HasRight(AgentFunctionFid))
                customLinkText.Append(_agentFunctionLink);
            customLinkText.Append("<a href=\"DomesticAgentList.aspx?agentId=@agentId&parentId=@parentId&agentType=" +
                                  GetChildAgentType() + "\" title=\"" + agentTitle + "\">" + agentImg + agentTitle +
                                  "</a>" + _branchLink);
            grid.CustomLinkText = customLinkText.ToString();
                
            grid.CustomLinkVariables = "agentId,agentType,parentId,agentName";
            grid.GridWidth = 800;

            //?actAsBranch=Y&agentId=3&parentId=2&agentType=2902
            string sql = "[proc_agentMaster] @flag = 's'" +
                         ", @parentId = " + grid.FilterString(GetAgentId()) +
                         ", @agentId = " + grid.FilterString(GetSuperAgentId()) +
                         ", @agentType = " + grid.FilterString(GetChildAgentType()) +
                         ", @actAsBranch = " + grid.FilterString(GetActAsBranchFlag());

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void DeleteRow()
        {
            var abf = new AgentDao();
            string id = grid.GetCurrentRowId(_gridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = abf.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        #endregion

        protected void btnLoadGrid_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }
    }
}