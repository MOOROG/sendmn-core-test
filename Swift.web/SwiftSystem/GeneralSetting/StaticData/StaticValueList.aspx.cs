using System;
using System.Collections.Generic;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.StaticData
{
    public partial class StaticValueList : Page
    {
        private const string GridName = "grid_sdv";
        private const string ViewFunctionId = "10111000";
        private const string AddEditFunctionId = "10111010";
        private const string DeleteFunctionId = "10111020";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();
        private readonly StaticDataDao obj = new StaticDataDao();
        protected long RowId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
            }
            LoadGrid();
            DeleteRow();
            RowId = (GetId() == 0 ? Id() : GetId());
        }

        protected string GetTypeTitle()
        {
            return "Type : " + _sl.GetTypeTitle(GetId().ToString());
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("typeId");
        }

        protected long Id()
        {
            return GetStatic.ReadNumericDataFromQueryString("Id");
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("detailTitle", "Value Title", "LT")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("valueId", "Id", "", "T"),
                                       new GridColumn("detailTitle", "Value Title", "", "T"),
                                       new GridColumn("detailDesc", "Value Description", "", "T"),
                                       new GridColumn("isActive", "Is Active", "", "T")
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridType = 1;
            _grid.GridName = GridName;
            _grid.ShowAddButton = allowAddEdit;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New Static Data Value";
            _grid.RowIdField = "valueId";
            _grid.MultiSelect = true;
            _grid.AllowEdit = allowAddEdit;
            _grid.AllowDelete = _sl.HasRight(DeleteFunctionId);
            _grid.EditText = "<img src = \"/images/edit.gif\" border=0 alt = \"Edit\" />";
            _grid.AddPage = "manage.aspx?Id=" + (GetId() == 0 ? Id() : GetId()) + "";
            //grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);
            //grid.AllowCustomLink = true;
            //grid.CustomLinkText = "<a href=\"ManageAddress.aspx?customerId=@customerId\"><img  height = \"12px\" width = \"12px\" border = \"0\" title = \"Assign Function\" src=\"../../../images/function.png\"/>";
            //grid.CustomLinkVariables = "customerId";

            string sql = "EXEC [proc_staticDataValue] @flag = 's', @typeId = " + GetId();
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);
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
                Response.Redirect("StaticValueList.aspx?typeId=" + GetId());
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }
        
        private void Authenticate()
        {
            //swiftLibrary.CheckAuthentication(ViewFunctionId);
        }
    }
}