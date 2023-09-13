using System;
using System.Collections.Generic;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.ApproveModification
{
    public partial class List : System.Web.UI.Page
    {
        private readonly RemittanceLibrary remitLibrary = new RemittanceLibrary();
        private readonly SwiftGrid grid = new SwiftGrid();
        private const string GridName = "grid_PendingtxnList";
        private const string ViewFunctionId = "20122000";
        private const string AddEditFunctionId = "20122010";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            LoadGrid();
        }
        private void Authenticate()
        {
            remitLibrary.CheckAuthentication(ViewFunctionId);
        }
        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("controlNo", "Control No", "LT"),
                                      new GridFilter("createdBy", "Request By", "1: exec proc_modifyTranRequest @flag='reqUser'")
                                  };
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("sCountry", "Country", "80", "T"),
                                      new GridColumn("sAgentName", "Agent", "80", "T"),
                                      new GridColumn("sBranchName", "Branch", "80", "T"),
                                      new GridColumn("createdBy", "User", "", "T"),
                                      new GridColumn("filterControlNo", "Control No", "", "T"),
                                      new GridColumn("cAmt", "Coll. Amt", "", "M"),
                                      new GridColumn("requestedDate", "Requested Date", "", "T"),
                                      new GridColumn("pCountry", "Rec Country", "80", "T"),
                                      new GridColumn("pAgentName", "Rec. Agent", "80", "T"),
                                      new GridColumn("payStatus", "Pay Status", "80", "T")

                                  };

            bool allowAddEdit = remitLibrary.HasRight(AddEditFunctionId);
            grid.GridType = 1;
            grid.InputPerRow = 3;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.AlwaysShowFilterForm = true;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "filterControlNo";
            grid.MultiSelect = false;
            grid.AddPage = "ModifyTran.aspx";

            grid.AllowEdit = allowAddEdit;
            grid.EditText = "Approve";

            string sql = "[proc_modifyTranRequest] @flag = 's'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }
    }
}