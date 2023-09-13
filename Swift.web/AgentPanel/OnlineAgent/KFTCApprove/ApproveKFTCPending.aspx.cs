using Swift.API.TPAPIs.KFTC;
using Swift.DAL.OnlineAgent;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;

namespace Swift.web.AgentPanel.OnlineAgent.KFTCApprove
{
    public partial class ApproveKFTCPending : System.Web.UI.Page
    {
        private const string GridName = "grid_list";
        private const string ViewFunctionId = "20111800";
        private const string ApproveRejectFunctionId = "20111810";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
            }
            LoadGrid();
            GetStatic.PrintMessage(Page);
        }

        private void Authenticate()
        {
            swiftLibrary.CheckSession();
        }

        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
                                  {
                                     new GridFilter("email", "CUSTOMER_EMAIL", "T"),
                                     new GridFilter("IDNUMBER", "CUSTOMER_ID_NUMBER", "T")
                                  };

            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("email", "CUSTOMER_EMAIL", "", "T"),
                                      //new GridColumn("address", "Address", "", "T"),
                                      new GridColumn("IDNUMBER", "CUSTOMER_ID_NUMBER", "", "T"),
                                      new GridColumn("COUNTRYNAME", "CUSTOMER_COUNTRY", "", "T"),
                                      new GridColumn("firstName", "GME_NAME", "", "T"),
                                      new GridColumn("userName", "KFTC_NAME", "", "T")
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.GridName = GridName;
            _grid.ShowPagingBar = true;
            _grid.AllowEdit = false;
            _grid.AllowDelete = false;
            _grid.AlwaysShowFilterForm = true;
            _grid.ShowFilterForm = true;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "CUSTOMERID";
            _grid.ThisPage = "ManageList.aspx"; ;
            _grid.InputPerRow = 4;
            _grid.AllowCustomLink = true;
            //_grid.LoadGridOnFilterOnly = true;

            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;

            _grid.CustomLinkVariables = "CUSTOMERID";

            //if (swiftLibrary.HasRight(ViewFunctionId))
            //{
            var link = "&nbsp;<a class=\"btn btn-xs btn-success\" title=\"Approve\" href=\"javascript:void(0);\" onclick=\"ApproveReject('@CUSTOMERID', 'approve')\"><i class=\"fa fa-check\"></i></a>";
            link += "&nbsp;<a class=\"btn btn-xs btn-danger\" title=\"Reject\" href=\"javascript:void(0);\" onclick=\"ApproveReject('@CUSTOMERID', 'reject')\"><i class=\"fa fa-times\"></i></a>";
            _grid.CustomLinkText = link;
            //}
            string sql = "EXEC [PROC_KFTC_APPROVE_REJECT] @flag = 'S' ";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        protected void buttonApproveReject_Click(object sender, EventArgs e)
        {
            IKFTCAccountCancel _cancelKFTC = new KFTCAccountCancel();
            DbResult _dbRes = new DbResult();
            if (string.IsNullOrEmpty(hddType.Value) && string.IsNullOrEmpty(hddCustomerId.Value))
            {
                GetStatic.AlertMessage(this, "Error occured while Approve/Reject, please contact JME HQ!");
            }
            OnlineCustomerDao _cd = new OnlineCustomerDao();

            //if reject then delete into system first
            DataSet ds = _cd.ApproveReject(GetStatic.GetUser(), hddType.Value, hddCustomerId.Value);

            //if (hddType.Value.Trim().ToString() == "reject")
            //{
            //    //cancel in KFTC(call to thirdpart API and then to KFTC)
            //    _cancelKFTC.CancelAccount(ds.Tables[1]);
            //}

            _dbRes = SetDBResult(ds.Tables[0]);

            GetStatic.SetMessage(_dbRes);

            ManageDbResult();
        }

        private DbResult SetDBResult(DataTable dataTable)
        {
            return new DbResult
            {
                Id = dataTable.Rows[0]["Id"].ToString(),
                Msg = dataTable.Rows[0]["Msg"].ToString()
            };
        }

        private void ManageDbResult()
        {
            GetStatic.PrintMessage(Page);
            LoadGrid();
        }
    }
}