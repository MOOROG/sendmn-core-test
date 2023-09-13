using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.Administration.AgentSetup.Functions.AgentDepositBank
{
    public partial class List : Page
    {
        private const string GridName = "grid_depositBankList";
        private const string ViewFunctionId = "20101600";
        private const string AddEditFunctionId = "20101610";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                ShowHideBusinessFunctionTab();
            }
            DeleteRow();
            LoadGrid();
        }

        #region ShowHideTab

        protected void ShowHideBusinessFunctionTab()
        {
            long aType = GetAgentType();
            string agentRole = GetAgentRole();
            if (aType == 2902 || aType == 2903)
            {
                depositBankListTab.Visible = true;
                depositBankListTab.InnerHtml = "<a href=\"#\" class=\"selected\">Deposit Bank List </a>";
            }
            else
            {
                depositBankListTab.Visible = false;
                Response.Redirect("../../../../Error.aspx");
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

        #endregion ShowHideTab

        #region QueryString

        protected long GetAgentType()
        {
            return GetStatic.ReadNumericDataFromQueryString("aType");
        }

        protected string GetAgentRole()
        {
            return swiftLibrary.GetAgentRole(GetAgent());
        }

        #endregion QueryString

        #region method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("detailTitle", "Bank Name", "T"),
                                      new GridFilter("bankAcctNum", "Account No.", "LT")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("detailTitle", "Bank Name", "", "T"),
                                      new GridColumn("bankAcctNum", "Account Number", "", "T"),
                                      new GridColumn("description", "Description", "", "LT")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 2;
            grid.GridName = GridName;
            grid.ShowAddButton = true;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add Bank Account";
            grid.RowIdField = "agentDepositBankId";
            grid.MultiSelect = true;
            grid.AllowEdit = true;
            grid.AllowDelete = true;
            grid.EditText = "<img src = \"../../../images/edit.gif\" border=0 alt = \"Edit\" />";
            grid.DeleteText = "<img src = \"../../../images/delete.gif\" border=0 alt = \"Delete\" />";
            grid.AddPage = "Manage.aspx?agentId=" + GetAgent() + "&aType=" + GetAgentType();
            //grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);
            //grid.AllowCustomLink = true;
            //grid.CustomLinkText = "<a href=\"ManageAddress.aspx?customerId=@customerId\"><img  height = \"12px\" width = \"12px\" border = \"0\" title = \"Assign Function\" src=\"../../../images/function.png\"../../../>";
            //grid.CustomLinkVariables = "customerId";

            string sql =
                "SELECT sdv.detailTitle,adb.* FROM agentDepositBank adb INNER JOIN staticDataValue sdv ON adb.bankName = sdv.valueId WHERE (adb.isDeleted IS NULL OR isDeleted = '') AND adb.agentId = " +
                GetAgent();
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        protected string GetAgent()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId").ToString();
        }

        private void DeleteRow()
        {
            var abf = new AgentBusinessFunctionDao();
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = abf.DeleteAdb(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        protected string GetAgentPageTab()
        {
            return "Agent Name : " + swiftLibrary.GetAgentName(GetAgent());
        }

        #endregion method
    }
}