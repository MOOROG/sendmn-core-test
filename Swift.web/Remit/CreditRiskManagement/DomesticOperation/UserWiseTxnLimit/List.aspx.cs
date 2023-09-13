using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI;

namespace Swift.web.Remit.DomesticOperation.UserWiseTxnLimit
{
    public partial class List : Page
    {
        private const string GridName = "gridUserWiseTxnLimit";
        private const string ViewFunctionId = "20181100";
        private const string AddEditFunctionId = "20181110";
        private const string ApproveFunctionId = "20181130";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        #region method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("userName", "User Name", "T"),
                                      new GridFilter("haschanged", "Change Status", "2")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("name", "Name", "", "T"),
                                      new GridColumn("userName", "User Name", "", "T"),
                                      new GridColumn("sendPerDay", "Send Per Day", "", "M"),
                                      new GridColumn("sendPerTxn", "Send Per Txn", "", "M"),
                                      new GridColumn("sendTodays", "Send Todays", "", "M"),

                                      new GridColumn("payPerDay", "Pay Per Day", "", "M"),
                                      new GridColumn("payPerTxn", "Pay Per Txn", "", "M"),
                                      new GridColumn("payTodays", "Pay Todays", "", "M"),

                                      new GridColumn("cancelPerDay", "Cancel Per Day", "", "M"),
                                      new GridColumn("cancelPerTxn", "Cancel Per Txn", "", "M"),
                                      new GridColumn("cancelTodays", "Cancel Todays", "", "M")
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.AlwaysShowFilterForm = true;
            grid.LoadGridOnFilterOnly = true;
            grid.EnableFilterCookie = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.SortBy = "name";
            grid.RowIdField = "limitId";
            grid.InputPerRow = 2;
            grid.AddPage = "Manage.aspx";
            grid.AllowApprove = sl.HasRight(ApproveFunctionId);
            grid.AllowCustomLink = allowAddEdit;

            var customLinkText = new StringBuilder();
            if (sl.HasRight(AddEditFunctionId))
                customLinkText.Append("<a href = '#' onclick = \"OpenLink('" + GetStatic.GetUrlRoot() + "/Remit/DomesticOperation/UserWiseTxnLimit/Manage.aspx?userId=@userId&limitId=@limitId')\"><img src=\"" + GetStatic.GetUrlRoot() + "/Images/edit.gif\" border=0 title = \"Edit\"/></a>");
            customLinkText.Append(
                "<a href = '#' onclick=\"OpenInNewWindow('" + GetStatic.GetUrlRoot() + "/Remit/DomesticOperation/UserWiseTxnLimit/History.aspx?userId=@userId&limitId=@limitId')\"><img src=\"" + GetStatic.GetUrlRoot() + "/Images/view-detail-icon.png\" border=0 title = \"View History\" /></a>");
            grid.CustomLinkText = customLinkText.ToString();

            grid.CustomLinkVariables = "userId,limitId";
            grid.ApproveFunctionId = ApproveFunctionId;
            grid.GridWidth = 100;
            grid.IsGridWidthInPercent = true;

            string sql = "[proc_userWiseTxnLimit] @flag = 's'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnCallBack_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }

        #endregion method
    }
}