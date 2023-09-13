using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.BillVoucher.VoucherSetting
{
    public partial class List : System.Web.UI.Page
    {
        private SwiftLibrary _sl = new SwiftLibrary();
        private const string ViewFunctionId = "20232700";
        private const string AddEditFunctionId = "20232710";
        private readonly SwiftGrid _grid = new SwiftGrid();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(this);
            }
            LoadGrid();
        }

        private void LoadGrid()
        {
            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("V_TYPE", "Voucher Type", "", "T"),
                                       new GridColumn("Approval_mode", "Approval Mode", "", "T"),
                                       new GridColumn("created_by", "Created By", "", "T"),
                                       new GridColumn("created_date", "Created Date", "", "DT"),
                                       new GridColumn("modified_by", "Modified By", "", "T"),
                                       new GridColumn("modified_date", "Modified Date", "", "DT"),
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);
            _grid.GridType = 1;
            _grid.InputPerRow = 2;
            _grid.GridName = "grdVoucherSetting";
            _grid.EnableFilterCookie = false;
            _grid.ShowPagingBar = true;
            _grid.RowIdField = "id";
            _grid.AllowEdit = allowAddEdit;

            _grid.CustomLinkVariables = "id";
            _grid.AddPage = "Manage.aspx";
            _grid.ThisPage = "List.aspx";
            _grid.SetComma();
            _grid.InputLabelOnLeftSide = true;

            const string sql = "EXEC proc_voucherSetting @flag = 's'";

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }
    }
}