using Swift.DAL.GridAutoDemo;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.GridAutoDemo
{
    public partial class List : System.Web.UI.Page
    {
        public const string GridName = "employeeGrid";
        private const string ViewFunctionId = "40120000";
        private const string AddEditFunctionId = "40120010";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly EmployeeDetailsDao detailsDao = new EmployeeDetailsDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            LoadGrid();
            DeleteRow();
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
            {
                new GridFilter("Name", "Name", "T"),
                new GridFilter("MobileNo", "Mobile", "T"),
                new GridFilter("Email", "Email", "T"),
                new GridFilter("DepartName", "Native Country", "T")
            };

            _grid.ColumnList = new List<GridColumn>
            {
                new GridColumn("Name", "Name", "", "T"),
                new GridColumn("Address", "Address", "", "T"),
                new GridColumn("Email", "Email", "", "T"),
                new GridColumn("MobileNo", "Mobile", "", "T"),
                new GridColumn("DepartName", "Depart Name", "", "T"),
                new GridColumn("DOB", "DOB", "", "D"),
                new GridColumn("CompanyJoinDate", "Join Date", "", "D")
            };
            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowFilterForm = true;
            _grid.AlwaysShowFilterForm = false;
            _grid.EnableFilterCookie = false;
            _grid.ShowPagingBar = true;
            _grid.SortOrder = "desc";
            _grid.RowIdField = "Id";
            _grid.InputPerRow = 2;
            _grid.AllowEdit = true;
            _grid.AllowDelete = true;
            _grid.ShowAddButton = true;
            _grid.AddPage = "InsertDemo.aspx";
            _grid.AllowCustomLink = true;
            string sql = "EXEC Pro_EmployeeDetails @flag = 'Employee-List'";
            _grid.CustomLinkVariables = "id";
            var link = "&nbsp;<a href=\"DirectApprove.aspx?customerId=@id&verify=y\" class=\"btn btn-xs btn-success\"><i class=\"fa fa-check\"></i></a>&nbsp;<a href=\"PrintForm.aspx?customerId=@id&class=\"btn btn-xs btn-success\"><i class=\"fa fa-print\" aria-hidden=\"true\"></i></a>";
            _grid.CustomLinkText = link;
            _grid.SetComma();
            employeeGrid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = detailsDao.Delete(id);
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }
    }
}