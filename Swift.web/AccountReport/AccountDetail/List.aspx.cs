using Swift.DAL.AccountReport;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.AccountReport.AccountDetail
{
    public partial class List : System.Web.UI.Page
    {
        protected const string GridName = "grdRole";
        private const string ViewFunctionId = "20150500";
        private const string AddEditFunctionId = "20150510";
        private const string DeleteEditFunctionId = "20150520";
        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly DayBookReportDAO _roleDao = new DayBookReportDAO();
        private readonly SwiftLibrary _sl = new SwiftLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            if (!IsPostBack)
            {
                GetStatic.PrintMessage(Page);
                Authenticate();
            }
            DeleteRow();
            LoadGrid();
        }

        private void LoadGrid()
        {
            var agentId = Convert.ToInt32(Request.QueryString["agentId"]);
            _grid.FilterList = new List<GridFilter>
                                   {
                                       new GridFilter("gl_code", "GL Code", "a", "", "gl_code", true),
                                       new GridFilter("acct_name", "AC Name", "LT"),
                                       new GridFilter("acct_num", "AC Number", "T")
                                   };

            _grid.ColumnList = new List<GridColumn>
                                   {
                                       new GridColumn("acct_num", "AC Number", "", "T"),
                                       new GridColumn("acct_name", "AC Name", "", "T"),
                                       new GridColumn("clr_bal_amt", "AC BAL", "", "M"),
                                       new GridColumn("flc_amt", "FCY BAL", "", "M"),
                                       new GridColumn("created_date", "Created Date", "", "DT"),
                                       new GridColumn("modified_date", "Modified Date", "", "DT"),
                                       new GridColumn("acct_cls_flg", " Status", "", "T"),
                                   };

            bool allowAddEdit = _sl.HasRight(AddEditFunctionId);

            _grid.GridType = 1;
            _grid.InputPerRow = 2;
            _grid.GridName = GridName;
            _grid.ShowAddButton = allowAddEdit;
            _grid.AllowDelete = _sl.HasRight(DeleteEditFunctionId);
            _grid.ShowFilterForm = true;
            _grid.EnableFilterCookie = false;
            _grid.ShowPagingBar = true;
            _grid.AddButtonTitleText = "Add New";
            _grid.RowIdField = "acct_id";
            _grid.AlwaysShowFilterForm = true;

            _grid.AllowEdit = allowAddEdit;

            _grid.CustomLinkVariables = "acct_id";
            _grid.AddPage = "Manage.aspx";
            _grid.ThisPage = "List.aspx";
            _grid.SetComma();
            _grid.InputLabelOnLeftSide = true;

            string sql = "EXEC [proc_accountStatement] @flag = 's'" + (agentId > 0 ? ", @agentID ='" + agentId + "'" : "");
            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = _grid.GetCurrentRowId(GridName);

            if (id == "")
                return;

            DbResult dbResult = _roleDao.DeleteAcctDetail(id, GetStatic.GetUser());
            ManageMessage(dbResult);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }
    }
}