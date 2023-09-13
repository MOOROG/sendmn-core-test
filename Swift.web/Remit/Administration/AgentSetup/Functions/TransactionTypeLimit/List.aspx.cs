using Swift.DAL.BL.Remit.Administration.Agent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.Administration.AgentSetup.Functions.TransactionTypeLimit
{
    public partial class List : Page
    {
        private const string GridName = "grid_tranTypeLimitList";
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
                ShowHideDepositBankListTab();
            }
            DeleteRow();
            LoadGrid();
        }

        #region showhidetab

        protected void ShowHideBusinessFunctionTab()
        {
            long aType = GetAgentType();
            if (aType == 2902 || aType == 2903)
            {
                tranTypeLimitTab.Visible = true;
                tranTypeLimitTab.InnerHtml = "<a href=\"#\" class=\"selected\">Transaction Type Limit </a>";
            }
            else
            {
                tranTypeLimitTab.Visible = false;
                Response.Redirect("../../../../../Error.aspx");
            }
        }

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

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        protected string GetAgentPageTab()
        {
            return "Agent Name : " + swiftLibrary.GetAgentName(GetAgent());
        }

        protected string GetEnableCashCollection()
        {
            return swiftLibrary.GetEnableCashCollection(GetAgent());
        }

        protected string GetAgentRole()
        {
            return swiftLibrary.GetAgentRole(GetAgent());
        }

        protected string GetAgent()
        {
            return GetStatic.ReadNumericDataFromQueryString("agentId").ToString();
        }

        protected long GetAgentType()
        {
            return GetStatic.ReadNumericDataFromQueryString("aType");
        }

        #endregion QueryString

        #region Method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("typeTitle", "Service Type", "T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("typeTitle", "Service Type", "", "T"),
                                      new GridColumn("tranLimitMin", "Min", "", "T"),
                                      new GridColumn("tranLimitMax", "Max", "", "T")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 2;
            grid.GridName = GridName;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add Transaction Type Limit";
            grid.RowIdField = "agentTranTypeLimitId";
            grid.MultiSelect = true;
            grid.AllowEdit = true;
            grid.AllowDelete = true;
            grid.EditText = "<img src = \"/images/edit.gif\" border=0 alt = \"Edit\" />";
            grid.DeleteText = "<img src = \"/images/delete.gif\" border=0 alt = \"Delete\" />";
            grid.AddPage = "Manage.aspx?agentId=" + GetAgent() + "&aType=" + GetAgentType();
            //grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);
            //grid.AllowCustomLink = true;
            //grid.CustomLinkText = "<a href=\"ManageAddress.aspx?customerId=@customerId\"><img  height = \"12px\" width = \"12px\" border = \"0\" title = \"Assign Function\" src=\"../../../images/function.png\" />";
            //grid.CustomLinkVariables = "customerId";

            string sql =
                "SELECT stm.typeTitle, attl.* FROM agentTranTypeLimit attl INNER JOIN serviceTypeMaster stm ON attl.serviceType =  stm.serviceTypeId WHERE attl.agentId = " +
                GetAgent();
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
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

        #endregion Method
    }
}