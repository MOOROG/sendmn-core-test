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
    public partial class List : System.Web.UI.Page
    {
        private string _gridName;
        private const string ViewFunctionId = "20111000";
        private const string AddEditFunctionId = "20111010";
        private const string ApproveFunctionId = "20111030";
        private const string ViewUserFunctionId = "20111000";
        private const string AgentFunctionFid = "20111040";
        private const string AgentInfoFid = "20111050";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        private string agentTitle = "";
        private string agentImg = "";
        private string _branchLink = "";
        private string _agentFunctionLink = "";
        private string _sortBy = "countryName";
        private string _fileFormatLink = "";


        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                //LoadTotalNoOfAgents();
            }
            LoadTab();
            DeleteRow();
            LoadGrid();
        }

        #region QueryString

        protected string GetAgentId()
        {
            return GetStatic.ReadQueryString("agentId", GetStatic.GetHoAgentId());
        }

        protected string GetParentId()
        {
            return GetStatic.ReadQueryString("parentId", GetStatic.GetHoAgentId());
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
        //private void LoadTotalNoOfAgents()
        //{
        //    var obj = new AgentDao();
        //    totalAgents.Text = obj.GetTotalNoOfAgents().ToString();
        //}

        private void LoadTab()
        {
            var urlRoot = GetStatic.GetUrlRoot();
            var hoAgentId = GetStatic.GetHoAgentId();
            var agentType = GetAgentType();
            switch (agentType)
            {
                case "2901":
                    superAgent.InnerHtml = "<a href=\"#\" class=\"selected\">Super Agent</a>";
                    superAgent.Attributes.Add("class", "active");
                    agent.InnerHtml = "";
                    branch.InnerHtml = "";
                    agentTitle = "Agents";
                    agentImg = "<img src=\"" + urlRoot + "/Images/agents.png\" border=0 />";
                    _branchLink = "&nbsp;&nbsp;<a href=\"List.aspx?actAsBranch=Y&agentId=@agentId&parentId=@parentId&agentType=" + GetChildAgentType() + "\" title=\"" + agentTitle + "\"><span class=\"action-icon\"><btn class=\"btn btn-xs btn-success\" data-placement=\"top\" data-toggle=\"tooltip\" data-original-title=\"Branches\" title=\"Branches\"><i class=\"fa fa-building-o\"></i></btn></span></a>";
                    _agentFunctionLink = "&nbsp;&nbsp;<a href=\"#\" onclick=\"ManageAgentFunction(@agentId, @agentType,'" + GetActAsBranchFlag() + "')\"><span class=\"action-icon\"><btn class=\"btn btn-xs btn-default\" data-placement=\"top\" data-toggle=\"tooltip\" data-original-title=\"Functions\" title=\"Functions\"><i class=\"fa fa-cogs\"></i></btn></span></a>";
                    _gridName = "grdSuperAgent";
                    _sortBy = "countryName";
                    break;
                case "2902":
                    superAgent.InnerHtml = "<a href=\"List.aspx?agentId=" + hoAgentId + "&agentType=2901\">Super Agent</a>";
                    if (GetActAsBranchFlag() == "Y")
                    {
                        agent.InnerHtml = "";
                        branch.InnerHtml = "<a href=\"#\" class=\"selected\">Branch</a>";
                        branch.Attributes.Add("class", "active");
                        agentTitle = "";
                        agentImg = "";
                        _gridName = "grdAgent";
                    }
                    else
                    {
                        agent.InnerHtml = "<a href=\"#\" class=\"selected\">Agent</a>";
                        agent.Attributes.Add("class", "active");
                        branch.InnerHtml = "";
                        agentTitle = "Branches";
                        agentImg = "<img src=\"" + urlRoot + "/Images/branch.png\" border=0 />";
                        _gridName = "grdBank";
                    }
                    _agentFunctionLink = "&nbsp;&nbsp;<a href=\"#\" onclick=\"ManageAgentFunction(@agentId, @agentType,'" + GetActAsBranchFlag() + "')\"><span class=\"action-icon\"><btn class=\"btn btn-xs btn-info\" data-placement=\"top\" data-toggle=\"tooltip\" data-original-title=\"Settings\" title=\"Settings\"><i class=\"fa fa-cogs\"></i></btn></span></a>";
                    _sortBy = "agentName";
                    _fileFormatLink = "&nbsp;&nbsp;" + Misc.GetIcon("file-format", "ManageFileFormat(@agentId);");

                    break;
                case "2903":
                    superAgent.InnerHtml = "<a href=\"List.aspx?agentId=" + hoAgentId + "&agentType=2901\">Super Agent</a>";
                    agent.InnerHtml = "<a href=\"List.aspx?agentId=" + GetParentId() + "&agentType=2902\">Agent</a>";
                    branch.InnerHtml = "<a href=\"#\" class=\"selected\">Branch</a>";
                    branch.Attributes.Add("class", "active");
                    _agentFunctionLink = "&nbsp;&nbsp;<a href=\"#\" onclick=\"ManageAgentFunction(@agentId, @agentType,'" + GetActAsBranchFlag() + "')\"><span class=\"action-icon\"><btn class=\"btn btn-xs btn-info\" data-placement=\"top\" data-toggle=\"tooltip\" data-original-title=\"Settings\" title=\"Settings\"><i class=\"fa fa-cogs\"></i></btn></span></a>";
                    _gridName = "grdBranch";
                    _sortBy = "agentName";
                    break;
            }
            //  spnName.InnerHtml = sl.GetAgentBreadCrumb(GetAgentId());
        }

        private void LoadGrid()
        {
            var urlRoot = GetStatic.GetUrlRoot();
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("haschanged", "Change Status:", "2"),
                                      new GridFilter("isActive", "Is Active:", "2"),
                                      new GridFilter("agentBlock", "Is Blocked:", "2"),
                                      new GridFilter("agentCode", "Code:", "LT"),
                                      new GridFilter("agentName", "Name:", "LT"),
                                      new GridFilter("agentCountry", "Country:", "LT"),
                                      //new GridFilter("isInternal", "Is Internal Agent/Branch:", "2")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("AgentCode", "Code", "", "T"),
                                      new GridColumn("mapCodeInt", "Map Code(I)", "", "T"),
                                      new GridColumn("agentName", "Name", "", "T"),
                                      new GridColumn("agentPhone1", "Contact No.", "", "T"),
                                      new GridColumn("agentLocation", "Location", "", "T"),
                                      new GridColumn("agentDistrict", "District", "", "T"),
                                      new GridColumn("agentState", "State", "", "T"),
                                      new GridColumn("countryName", "Country", "", "T")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);

            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = _gridName;
            grid.ShowAddButton = true;
            grid.ShowPopUpWindowOnAddButtonClick = false;
            grid.PopUpParam = "dialogHeight:600px;dialogWidth:940px;dialogLeft:300;dialogTop:100;center:yes";
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.SortBy = _sortBy;
            grid.SortOrder = "ASC";
            grid.DisableSorting = false;
            grid.AddButtonTitleText = "Add New Record";
            grid.RowIdField = "agentId";
            grid.ThisPage = "List.aspx";
            grid.IsGridWidthInPercent = true;
            grid.GridWidth = 100;
            grid.InputPerRow = 3;
            grid.AllowEdit = false;
            grid.AllowApprove = sl.HasRight(ApproveFunctionId);
            grid.ApproveFunctionId = ApproveFunctionId;
            grid.RowColoredByColValue = "IsActive:N";

            grid.AddPage = "Manage.aspx?aType=" + GetChildAgentType() +
                           "&parent_id=" + GetAgentId() +
                           "&sParentId=" + GetParentId() +
                           "&actAsBranch=" + GetActAsBranchFlag() +
                           "&mode=2";
            grid.AllowCustomLink = allowAddEdit;
            var customLinkText = new StringBuilder();
            if (allowAddEdit)
                customLinkText.Append
                    ("&nbsp;&nbsp;<a href=\"#\" onclick=\"ManageAgent(@agentId, @agentType, @parentId,'" + GetActAsBranchFlag() + "')\"><span class=\"action-icon\"><btn class=\"btn btn-xs btn-primary\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"Edit\"><i class=\"fa fa-pencil\"></i></btn></span></a>");
            //if (sl.HasRight(AgentInfoFid))
            //    customLinkText.Append("<a href=\"#\" onclick=\"ManageAgentInfo(@agentId)\"><span class=\"action-icon\"><btn class=\"btn btn-xs btn-info\" data-placement=\"top\" data-toggle=\"tooltip\" data-original-title=\"Info\" title=\"Info\"><i class=\"fa fa-info-circle\"></i></btn></span></a>&nbsp;&nbsp;");
            if (sl.HasRight(ViewUserFunctionId) && GetChildAgentType() != "2902")
                customLinkText.Append("&nbsp;&nbsp;<a href=\"#\" onclick=\"ManageUser(@agentId)\")><span class=\"action-icon\"><btn class=\"btn btn-xs btn-danger \" data-placement=\"top\" data-toggle=\"tooltip\" data-original-title=\"User\" title=\"Users\"><i class=\"fa fa-user\"></i></btn></span></a>");
            if (sl.HasRight(AgentFunctionFid) &&  GetChildAgentType() != "2902")
                customLinkText.Append(_agentFunctionLink);

            if (GetAgentType() == "2901")
                customLinkText.Append("&nbsp;&nbsp;<a href=\"List.aspx?agentId=@agentId&parentId=@parentId&agentType=" + GetChildAgentType() + "\" title=\"" + agentTitle + "\"><span class=\"action-icon\"><btn class=\"btn btn-xs btn-primary \" data-placement=\"top\" data-toggle=\"tooltip\" data-original-title=\"Agent\" title=\"Agent\"><i class=\"fa fa-users\"></i></btn></span></a>" + _branchLink);
            else if (GetActAsBranchFlag() == "N")
                customLinkText.Append("&nbsp;&nbsp;<a href=\"List.aspx?agentId=@agentId&parentId=@parentId&agentType=" + GetChildAgentType() + "\" title=\"" + agentTitle + "\"><span class=\"action-icon\"><btn class=\"btn btn-xs btn-success \" data-placement=\"top\" data-toggle=\"tooltip\" data-original-title=\"Branch\" title=\"Branch\"><i class=\"fa fa-building-o\"></i></i></btn></span></a>");

            if (GetAgentType() != "2901")
                customLinkText.Append("&nbsp;&nbsp;<a href=\"../../../AccountReport/AccountDetail/List.aspx?agentId=@agentId\"><span class=\"action-icon\"><btn class=\"btn btn-xs btn-primary \" data-placement=\"top\" data-toggle=\"tooltip\" data-original-title=\"Search\" title=\"Search\"><i class=\"fa  fa-search-plus\"></i></i></btn></span></a>");
            //customLinkText.Append(_fileFormatLink);

            grid.CustomLinkText = customLinkText.ToString();
            grid.CustomLinkVariables = "agentId,agentType,parentId,agentName";

            string sql = "[proc_agentMaster] @flag = 's'" +
                         ", @parentId = " + grid.FilterString(GetAgentId()) +
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