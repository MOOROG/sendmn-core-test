using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Compliance.ApproveOFACandComplaince
{
    public partial class PayTranCompliance : System.Web.UI.Page
    {
        private const string GridName = "grid_paycomp_txn";
        private const string ViewFunctionId = "20193001";
        private const string ApproveFunctionId = "20193201";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("controlNo", "Control No", "T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("provider", "Provider Name", "", "T"),
                                      new GridColumn("controlNo", "Control No", "", "T"),
                                      new GridColumn("pBranchName", "Payout Branch", "", "T"),
                                      new GridColumn("type", "Type", "", "T"),
                                      //new GridColumn("senderName", "Sender Name", "", "T"),
                                      new GridColumn("receiverName", "Receiver Name", "", "T"),
                                      //new GridColumn("pAmt", "Payout Amount", "", "M"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "D")
                                  };

            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "tranId";
            grid.GridWidth = 800;
            string sql = "[proc_payCompliance] @flag = 'txn_list'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }
    }
}