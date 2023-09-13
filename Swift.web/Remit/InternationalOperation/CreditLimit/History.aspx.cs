using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.InternationalOperation.CreditLimit
{
    public partial class History : System.Web.UI.Page
    {
        private const string GridName = "grid_userwiseTxnHistory";
        private const string ViewFunctionId = "30011000";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

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

            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
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

        #endregion
    }
}