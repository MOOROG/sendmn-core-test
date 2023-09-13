using System;
using System.Collections.Generic;
using Swift.DAL.BL.System.DCManagement;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.DCManagement.DCPendingList
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20171000";
        private const string ApproveFunctionId = "20171010";

        private const string GridName = "grdDcPending";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly DcManagementDao _obj = new DcManagementDao();
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadGrid();
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + ApproveFunctionId);
            btnApprove.Visible = _sdd.HasRight(ApproveFunctionId);
        }

        private void LoadGrid()
        {

            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("userName", "User Name", "T"),
                                      new GridFilter("dcRequestId", "DC Id", "T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("dcRequestId", "DC Id", "", "T"),
                                      new GridColumn("userName", "User Name", "", "T"),
                                      new GridColumn("userFullName", "Full Name", "", "T"),
                                      new GridColumn("Address", "Address", "", "T"),
                                      new GridColumn("companyName", "Company Name", "", "T"),
                                      new GridColumn("requestedBy", "Requested By", "", "T"),
                                      new GridColumn("requestedDate", "Requested Date", "", "T")
                                  };
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.GridType = 1;
            grid.ShowFilterForm = true;
            grid.EnableFilterCookie = false;
            grid.ShowPagingBar = true;
            grid.RowIdField = "dcRequestId";
            grid.InputPerRow = 3;
            grid.ShowCheckBox = true;
            grid.MultiSelect = false;
            grid.SetComma();
            grid.GridWidth = 880;
            grid.PageSize = 10000;

            var sql = @"EXEC proc_dcManagement @flag = 's'";
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        protected void btnUnlock_Click(object sender, EventArgs e)
        {
            string tranIds = grid.GetRowId(GridName);
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            string requestId = grid.GetRowId(GridName);
            var url = GetStatic.GetUrlRoot() + "/certsrv/Approved.asp?user=" + GetStatic.GetUser() + "&id=" + requestId;
            Response.Redirect(GetStatic.GetUrlRoot() + "/certsrv/Approved.asp?user=" + GetStatic.GetUser() + "&id=" + requestId);

            /*
             * DbResult dbResult = _obj.Approve(GetStatic.GetUser(), requestId);
            GetStatic.SetMessage(dbResult);

            if(dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.SetMessageBox(Page);
            }
             */

        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            string requestId = grid.GetRowId(GridName);
            DbResult dbResult = _obj.Reject(GetStatic.GetUser(), requestId);
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