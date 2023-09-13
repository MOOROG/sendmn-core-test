using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.DomesticOperation.UserWiseTxnLimit
{
    public partial class History : Page
    {
        private const string GridName = "grid_userwiseTxnHistory";
        private const string ViewFunctionId = "20181100";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                userName.Text = sdd.GetLoginUserName(GetUserId().ToString());
            }
            LoadGrid();
        }

        #region method

        protected long GetUserId()
        {
            return GetStatic.ReadNumericDataFromQueryString("userId");
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("createdBy", "Created By", "T"),
                                      new GridFilter("approvedBy", "Approved By", "T")
                                  };
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("sendPerDay", "Send Per Day", "", "M"),
                                      new GridColumn("sendPerTxn", "Send Per Txn", "", "M"),

                                      new GridColumn("payPerDay", "Pay Per Day", "", "M"),
                                      new GridColumn("payPerTxn", "Pay Per Txn", "", "M"),

                                      new GridColumn("cancelPerDay", "Cancel Per Day", "", "M"),
                                      new GridColumn("cancelPerTxn", "Cancel Per Txn", "", "M"),

                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "D"),

                                      new GridColumn("approvedBy", "Approved By", "", "T"),
                                      new GridColumn("approveddate", "Approved Date", "", "D"),
                                  };

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowFilterForm = true;
            grid.EnableFilterCookie = false;
            grid.ShowPagingBar = true;
            grid.SortBy = "rowid";
            grid.RowIdField = "rowid";
            string sql = "[proc_userWiseTxnLimit] @flag = 's1',@userId=" + GetUserId() + "";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion method
    }
}