using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Web;

namespace Swift.web.Remit.Administration.OnlineCustomer
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grid_list";
        private const string ViewFunctionId = "20130000";
        private const string AddEditFunctionId = "20130010";
        private const string ApproveFunctionId = "20130010";
        private const string EditFunctionId = "20130040";
        private const string DeleteFunctionId = "20130050";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
            }
            LoadGrid();
            DeleteRow();
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [proc_online_approve_Customer] @flag = 'searchCriteria'"),
                                     new GridFilter("searchValue", "Search Value", "T"),
                                     new GridFilter("fromDate", "Registered From", "d"),
                                     new GridFilter("toDate", "Registered To", "d"),
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("email", "Email", "", "T"),
                                      new GridColumn("fullName", "Customer Name", "", "T"),
                                      new GridColumn("dob", "DOB", "", "D"),
                                      new GridColumn("nativeCountry", "Native Country", "", "T"),
                                      new GridColumn("idtype", "ID Type", "", "T"),
                                      new GridColumn("idNumber", "ID No", "", "T"),
                                      new GridColumn("createdBy","Created By","","T"),
                                      new GridColumn("createdDate","Regd. Date","","D"),
                                      //new GridColumn("branchName","Branch Name","","T"),
                                      //new GridColumn("verifiedDate","Verified Date","","D")  ,
                                      //new GridColumn("bankName","Bank Name","","T")  ,
                                      //new GridColumn("bankAccountNo","Account Number","","T")
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AllowEdit = false;
            _grid.AllowDelete = true;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "customerId";
            _grid.ThisPage = "List.aspx"; ;
            _grid.InputPerRow = 4;
            _grid.AllowCustomLink = true;
            //_grid.LoadGridOnFilterOnly = true;

            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            _grid.CustomLinkVariables = "customerId";
            var link = "";
            if (swiftLibrary.HasRight(ApproveFunctionId))
            {
                link += "&nbsp;<a class=\"btn btn-xs btn-success\" title=\"Approve\" href=\"Detail.aspx?customerId=@customerId&m=ap\"><i class=\"fa fa-check\"></i></a>";
                _grid.CustomLinkText = link;
            }
            if (swiftLibrary.HasRight(EditFunctionId))
            {
                link += "&nbsp;<a class=\"btn btn-xs btn-danger\" title=\"Edit\" href=\"/Remit/Administration/CustomerSetup/Manage.aspx?customerId=@customerId&callFrom=approveCustomer\"><i class=\"fa fa-edit\"></i></a>";
                _grid.CustomLinkText = link;
            }
            //if (swiftLibrary.HasRight(DeleteFunctionId))
            //{
            //    //link += "&nbsp;<a class=\"btn btn-xs btn-danger\" title=\"Delete\" href=\"List.aspx?customerId=@customerId&m=ap\"><i class=\"fa fa-trash\"></i></a>";
            //    link += "&nbsp;<a class=\"btn btn-xs btn-danger\" title=\"Delete\" onclick=DeleteData()><i class=\"fa fa-trash\"></i></a>";
            //    _grid.CustomLinkText = link;
            //}
            string sql = "EXEC [proc_online_approve_Customer] @flag = 'vl' ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }
        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);

            if (id == "")
                return;
            var user = GetStatic.GetUser();
            DbResult dbResult = _cd.DeleteCustomer(id, user);
            if (dbResult.ErrorCode == "0")
            {
                LoadGrid();
                GetStatic.AlertMessage(this, dbResult.Msg);
                //HttpContext.Current.Session["message"] = dbResult;
                //Response.Redirect(Request.RawUrl);
            }
            else
            {
                HttpContext.Current.Session["message"] = dbResult;
                GetStatic.AlertMessage(this, dbResult.Msg);
            }
        }

        protected void deleteBtn_Click(object sender, EventArgs e)
        {

        }
    }
}