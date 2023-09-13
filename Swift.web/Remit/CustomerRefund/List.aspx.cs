using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Text;
using System.Web;

namespace Swift.web.Remit.CustomerRefund
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "CustomerRefund";
        private const string ViewFunctionId = "20195000";
        private const string AddEditFunctionId = "20195020";
        private const string DeleteFunctionId = "20195030";
        private const string ApproveFunctionId = "20195040";
        private readonly SwiftLibrary sl = new SwiftLibrary();
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly OnlineCustomerDao _cd = new OnlineCustomerDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            sl.CheckSession();
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
            }
            DeleteRow();
            LoadGrid();
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                   {
                                             new GridFilter("approvedOrNot", "Approval Type", "1:EXEC proc_customerRefund @flag='dropdownListApprovedUnapproved',@user='"+GetStatic.GetUser()+"'"),
                                       //new GridFilter("firstName", "First Name", "LT"),
                                       //new GridFilter("isLocked", "Lock Status", "2"),
                                       //new GridFilter("haschanged", "Change Status", "2")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("fullname", "Customer Name", "", "T"),
                                       new GridColumn("mobile", "Contact No", "", "T"),
                                       new GridColumn("refundAmount", "Refund Amount", "", "T"),
                                       new GridColumn("refundCharge", "Additional charge", "", "T"),
                                       new GridColumn("refundRemarks", "Refund Remarks", "", "T"),
                                       new GridColumn("refundChargeRemarks", "Refund charge Remarks", "", "T")
                                   };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);
            _grid.GridType = 1;
            _grid.LoadGridOnFilterOnly = false;
            _grid.GridName = GridName;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.ShowAddButton = allowAddEdit;
            _grid.ShowFilterForm = true;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New User";
            _grid.RowIdField = "rowId";
            _grid.MultiSelect = false;
            _grid.AllowDelete = sl.HasRight(DeleteFunctionId);
            _grid.AllowApprove = sl.HasRight(ApproveFunctionId);
            _grid.ApproveFunctionId = ApproveFunctionId;
            _grid.AddPage = "manage.aspx";
            var customLinkText = new StringBuilder();
            _grid.InputPerRow = 4;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            string sql = "[proc_customerRefund] @flag = 's'";

            _grid.SetComma();
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);

            if (id == "")
                return;
            var user = GetStatic.GetUser();
            DbResult dbResult = _cd.DeleteCustomerRefund(id, user);
            if (dbResult.ErrorCode == "0")
            {
                HttpContext.Current.Session["message"] = dbResult;
                Response.Redirect(Request.RawUrl);
            }
            else
            {
                HttpContext.Current.Session["message"] = dbResult;
                GetStatic.AlertMessage(this, dbResult.Msg);
            }
        }
    }
}