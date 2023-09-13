using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.AgentPanel.Utilities.ModifyRequest
{
    public partial class Search : System.Web.UI.Page
    {
        private const string ViewFunctionId = "40112800";
        protected const string GridName = "grdPenAgntTxnModify";
        private RemittanceLibrary sd = new RemittanceLibrary();
        private readonly SwiftGrid grid = new SwiftGrid();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                controlNo.Focus();
            }
            LoadGrid();
            GetStatic.ResizeFrame(Page);
        }

        private void Authenticate()
        {
            sd.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                        {
                            new GridFilter("controlNo", "Control No", "LT"),
                        };
            grid.ColumnList = new List<GridColumn>
                        {
                            new GridColumn("sAgentName", "Agent", "80", "T"),
                            new GridColumn("sBranchName", "Branch", "80", "T"),
                            new GridColumn("createdBy", "User", "", "T"),
                            new GridColumn("controlNo", "Control No", "", "T"),
                            new GridColumn("cAmt", "Coll. Amt", "", "M"),
                            new GridColumn("createdDate", "Request Date", "", "D")
                        };

            grid.GridType = 1;
            grid.InputPerRow = 4;
            grid.GridName = GridName;
            grid.ShowAddButton = false;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            //grid.EnableProcessBar = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "filterControlNo";
            string sql = "[proc_modifyTranRequest] @flag = 's',@branchId=" + GetStatic.GetBranch();
            grid.SetComma();
            grd_tran.InnerHtml = grid.CreateGrid(sql);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            err.Visible = false;
            spantranId.Visible = false;
            spancontrolNo.Visible = false;
            if (string.IsNullOrWhiteSpace(controlNo.Text) && string.IsNullOrWhiteSpace(tranId.Text))
            {
                err.Visible = true;
                spantranId.Visible = true;
                spancontrolNo.Visible = true;
                return;
            }
            Response.Redirect("TransactionDetail.aspx?controlNo=" + sd.FilterString(controlNo.Text) + "&tranId=" + sd.FilterString(tranId.Text));
        }
    }
}