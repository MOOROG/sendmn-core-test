using Swift.DAL.BL.Remit.Compliance;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Compliance.SendingAmountThreshold
{
    public partial class List : System.Web.UI.Page
    {
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly AmountThresholdSetupDao obj = new AmountThresholdSetupDao();
        private const string GridName = "grd_amtThreshold";

        private const string ViewFunctionId = "2019500";
        private const string AddEditFunctionId = "2019510";
        private const string ApproveFunctionId = "2019520";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();

            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                            {
                                new GridColumn("sCountryName", "Sending Country", "", "T"),
                                new GridColumn("rCountryName", "Receiving Country", "", "T")
                            };
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("sCountryName", "Sending Country", "", "T"),
                                      new GridColumn("rCountryName", "Receiving Country", "", "T"),
                                      new GridColumn("sAgent", "Agent", "", "T"),
                                      new GridColumn("Amount", "Amount", "", "T"),
                                      new GridColumn("isActive", "Is Active", "", "T"),
                                      //new GridColumn("createdDate", "Created Date", "", "z"),
                                      //new GridColumn("createdBy", "Created By", "", "T")
                                  };

            var allowAddEdit = _sl.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.GridType = 1;

            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New ";
            grid.RowIdField = "sAmtThresholdId";
            grid.AddPage = "Manage.aspx";
            grid.InputPerRow = 4;
            grid.InputLabelOnLeftSide = true;
            grid.ApproveFunctionId = ApproveFunctionId;
            grid.AllowApprove = _sl.HasRight(ApproveFunctionId);
            grid.AlwaysShowFilterForm = true;
            grid.AllowEdit = allowAddEdit;
            grid.DisableSorting = true;

            string sql = "EXEC proc_sendingAmtThreshold @flag = 's'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            var rowId = hdnRowId.Value;
            if (rowId != "")
            {
                var dbResult = obj.DeleteThreshold(rowId, GetStatic.GetUser());
                ManageMessage(dbResult);
            }
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode != "0")
            {
                GetStatic.PrintMessage(Page);
            }
            else
            {
                Response.Redirect("List.aspx");
            }
        }
    }
}