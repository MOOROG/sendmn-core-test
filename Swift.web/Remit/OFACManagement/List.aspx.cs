using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.DAL.BL.Remit.OFACManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.OFACManagement
{
    public partial class List : Page
    {

        private const string ViewFunctionId = "20198001";
        private const string AddEditFunctionId = "20198101";
        private const string DeleteFunctionId = "20198201";
        private const string GridName = "grd_blacklist";

        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly OFACManagementDao obj = new OFACManagementDao();
        private readonly SwiftLibrary swiftLibrary = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            DeleteRow();
            LoadGrid();
        }
        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("name", "NAME","T"),
                                      new GridFilter("country", "Country","T"),
                                      new GridFilter("entNum", "Ent Num","T"),
                                      new GridFilter("dataSource", "Data Source", "T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("entNum", "Ent No.", "", "T"),
                                      new GridColumn("name", "Name", "", "T"),
                                      new GridColumn("vesselType", "vessel Type", "", "T"),
                                      new GridColumn("address", "Address", "", "T"),
                                      new GridColumn("city", "City", "", "T"),
                                      new GridColumn("state", "State", "", "T"),
                                      new GridColumn("country", "Country", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "z"),
                                      new GridColumn("createdBy", "Created By", "", "T")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridName = GridName;
            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New ";
            grid.RowIdField = "rowId";
            grid.AddPage = "Manage.aspx";
            grid.InputPerRow = 4;
            grid.AlwaysShowFilterForm = true;
            grid.AllowEdit = allowAddEdit;
            grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);
 

            string sql = "EXEC [proc_OFACManualEntry] @flag = 'a'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }
        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }
        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }

        }
    }
}