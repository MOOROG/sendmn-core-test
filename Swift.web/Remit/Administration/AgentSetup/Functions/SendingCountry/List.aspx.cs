using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI;

namespace Swift.web.Remit.Administration.AgentSetup.Functions.SendingCountry
{
    public partial class List : Page
    {
        private const string GridName = "grd_sendCountry";
        private const string ViewFunctionId = "20101600";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.AlertMessage(Page);
                ShowHideTab();
                ShowHideDepositBankListTab();
            }
            DeleteRow();
            ShowInExList();
        }

        private void ShowInExList()
        {
            StringBuilder sb = new StringBuilder("");
            sb.AppendLine("<ul>");
            if (GetStatic.ReadQueryString("type", "in") == "in")
            {
                LoadInGrid();
                sb.AppendLine("<li><a href='#' class='selected'>Inclusive List</a> </li>");
                sb.AppendLine("<li><a href='List.aspx?agentId=" + GetAgent() + "&aType=" + GetAgentType() + "&actAsBranch=" + GetActasBranch() + "&type=ex' >Exclusive List</a> </li>");
            }
            else
            {
                LoadExGrid();
                sb.AppendLine("<li><a href='List.aspx?agentId=" + GetAgent() + "&aType=" + GetAgentType() + "&actAsBranch=" + GetActasBranch() + "&type=in' >Inclusive List</a> </li>");
                sb.AppendLine("<li><a href='#' class='selected'>Exclusive List</a> </li>");
            }
            sb.AppendLine("</ul>");
            listDiv.InnerHtml = sb.ToString();
        }

        #region showhidetab

        protected void ShowHideTab()
        {
            string agentType = GetAgentType().ToString();

            if (agentType == "2902" || agentType == "2903" || GetActasBranch() == "Y")
            {
                ReceivingCountry.Visible = true;
                ReceivingCountry.InnerHtml = "<a href=\"../ReceivingCountry/List.aspx?agentId=" + GetAgent() + "&aType=" +
                                           GetAgentType() + "&actAsBranch=" + GetActasBranch() +
                                           "\">Receiving Country List </a>";
                ////sendingList.Visible = true;
                ////sendingList.InnerHtml = "<a href=\"../SendingList.aspx?agentId=" + GetAgent() + "&aType=" +
                ////                           GetAgentType() + "&actAsBranch=" + GetActasBranch() +
                ////                           "\">Sending List </a>";
                businessFunctionTab.Visible = true;
                businessFunctionTab.InnerHtml = "<a href=\"../BusinessFunction.aspx?agentId=" + GetAgent() + "&aType=" +
                                           GetAgentType() + "&actAsBranch=" + GetActasBranch() + "\">Business Function </a>";
                ////receivingListTab.Visible = true;
                ////receivingListTab.InnerHtml = "<a href=\"../ReceivingList.aspx?agentId=" + GetAgent() + "&aType=" +
                ////                             GetAgentType() + "&actAsBranch=" + GetActasBranch() + "\">Receiving List </a>";
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
                depositBankListTab.InnerHtml = "<a href=\"AgentDepositBank/List.aspx?agentId=" + GetAgent() + "&aType=" +
                                               GetAgentType() + "\">Deposit Bank List </a>";
            }
            else
            {
                depositBankListTab.Visible = false;
            }
            ////switch (agentRole)
            ////{
            ////    case "B":
            ////        break;
            ////    case "S":
            ////        ReceivingCountry.Visible = false;
            ////        break;
            ////    case "R":
            ////        break;
            ////    default:
            ////        ReceivingCountry.Visible = false;
            ////        break;
            ////}
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

        private void LoadInGrid()
        {
            string ddlSql = "EXEC [proc_staticDataValue] @flag = 'l', @typeID = 2900";
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("agentType", "Type", "1:" + ddlSql),
                                      new GridFilter("CountryName", "Receiving Country Name", "LT"),
                                      new GridFilter("agentName", "Agent Name", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("CountryName", "Receiving Coutry Name", "", "T"),
                                      new GridColumn("agentName", "Agent Name", "", "T"),
                                      new GridColumn("tranType", "Service Type", "", "T"),
                                      new GridColumn("agentType", "Type", "", "T")
                                  };

            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.DeleteText =
                "<img class = \"showHand\" border = \"0\" title = \"Delete Key\" src=\"../../../../../images/delete.gif\" />";
            grid.ShowAddButton = true;
            //grid.AddPage = "FilterList.aspx?agentId=" + GetAgent() + "&role=s&listType=ex&aType=" + GetAgentType();
            grid.AddPage = "Manage.aspx?agentId=" + GetAgent() + "&role=s&listType=in&aType=" + GetAgentType();
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "rowId";
            grid.ThisPage = "List.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = false;
            grid.AllowDelete = true;

            string sql = "[proc_rsList1] @flag = 'sA', @roleType = 's',@listType = 'in', @agentId=" + GetAgent();
            grid.SetComma();

            rpt_inGrid.InnerHtml = grid.CreateGrid(sql);
        }

        private void LoadExGrid()
        {
            string ddlSql = "EXEC [proc_staticDataValue] @flag = 'l', @typeID = 2900";
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("agentType", "Type", "1:" + ddlSql),
                                      new GridFilter("CountryName", "Receiving Country Name", "LT"),
                                      new GridFilter("agentName", "Agent Name", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("CountryName", "Receiving Coutry Name", "", "T"),
                                      new GridColumn("agentName", "Agent Name", "", "T"),
                                      new GridColumn("tranType", "Service Type", "", "T"),
                                      new GridColumn("agentType", "Type", "", "T")
                                  };

            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.DeleteText =
                "<img class = \"showHand\" border = \"0\" title = \"Delete Key\" src=\"../../../../../images/delete.gif\" />";
            grid.ShowAddButton = true;
            //grid.AddPage = "FilterList.aspx?agentId=" + GetAgent() + "&role=s&listType=ex&aType=" + GetAgentType();
            grid.AddPage = "Manage.aspx?agentId=" + GetAgent() + "&role=s&listType=ex&aType=" + GetAgentType();
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "rowId";
            grid.ThisPage = "List.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = false;
            grid.AllowDelete = true;

            string sql = "[proc_rsList1] @flag = 'sA', @roleType = 's',@listType = 'ex', @agentId=" + GetAgent();
            grid.SetComma();

            rpt_inGrid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void DeleteRow()
        {
            var abf = new CountryDao();
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = abf.DeleteSendingCountry(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.AlertMessage(Page);
        }

        #endregion Method
    }
}