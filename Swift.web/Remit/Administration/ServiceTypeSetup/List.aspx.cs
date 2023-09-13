using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web.UI;

namespace Swift.web.Remit.Administration.ServiceTypeSetup
{
    public partial class List : Page
    {
        private const string GridName = "grdStm";
        private const string ViewFunctionId = "10111600";
        private const string AddEditFunctionId = "10111610";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly ServiceTypeDao obj = new ServiceTypeDao();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

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
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("serviceTypeId", "Row Id", "", "T"),
                                      new GridColumn("serviceCode", "Service Code", "", "T"),
                                      new GridColumn("typeTitle", "Service Type", "", "LT"),
                                      new GridColumn("typeDesc", "Type Description", "", "LT")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 2;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
            grid.AddButtonTitleText = "Add New Service Type";
            grid.EnableCookie = false;
            grid.RowIdField = "serviceTypeId";
            grid.MultiSelect = true;
            grid.AllowEdit = swiftLibrary.HasRight(AddEditFunctionId);
            grid.AllowDelete = false;

            //grid.AllowGridFieldEdit = true;
            grid.AddPage = "manage.aspx";
            //grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);
            //grid.AllowCustomLink = true;
            //grid.CustomLinkText = "<a href=\"ManageAddress.aspx?customerId=@customerId\"><img  height = \"12px\" width = \"12px\" border = \"0\" title = \"Assign Function\" src=\"../../../images/function.png\"/>";
            //grid.CustomLinkVariables = "customerId";

            string sql = "SELECT * FROM serviceTypeMaster WHERE ISNULL(isDeleted, 'N') <> 'Y'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
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
            GetStatic.PrintMessage(Page);
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }
    }
}