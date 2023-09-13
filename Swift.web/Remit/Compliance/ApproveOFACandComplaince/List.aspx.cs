using Swift.DAL.Remittance.Compliance;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Compliance.ApproveOFACandComplaince
{
    public partial class InternationList : System.Web.UI.Page
    {
        private const string GridName = "grid_approveOFAC";
        private const string ViewFunctionId = "20193001";
        private const string AddEditFunctionId = "20193101";
        private const string ApproveFunctionId = "20193201";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SwiftLibrary swiftLibrary = new SwiftLibrary();
        private readonly ErroneousTrnPay _obj = new ErroneousTrnPay();

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
                                      new GridFilter("controlNo", "Control No", "T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                       new GridColumn("tranId",  "Tran Id", "", "T"),
                                      new GridColumn("controlNo", "Control No", "", "T"),
                                      new GridColumn("branchName", "Sending Branch", "", "T"),
                                      new GridColumn("type", "Type", "", "T"),
                                      new GridColumn("senderName", "Sender Name", "", "T"),
                                      new GridColumn("receiverName", "Receiver Name", "", "T"),
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.GridName = GridName;
            grid.ShowAddButton = false;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;

            grid.RowIdField = "tranId";
            grid.GridWidth = 800;
            grid.MultiSelect = false;
            grid.AllowEdit = false;
            grid.AllowDelete = false;
            grid.AllowApprove = true;
            grid.ApproveFunctionId = ApproveFunctionId;

            grid.AllowCustomLink = false;

            string sql = "[proc_approveOFACCompliance] @flag = 's'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;

            DbResult dbResult = _obj.Delete(GetStatic.GetUser(), id);
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

        #endregion method
    }
}