using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.InternationalOperation.UserTopUp
{
    public partial class List : System.Web.UI.Page
    {
        private const string GridName = "grdtint";
        private const string ViewFunctionId = "30011300";
        private const string AddEditFunctionId = "30011310 ";
        private const string ApproveFunctionId = "30011320";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly RemittanceLibrary sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                WriteCookie();
                Authenticate();
                GetStatic.PrintMessage(Page);
            }
            LoadGrid();
        }

        private void WriteCookie()
        {
            string key = GridName + "_hasLimit" + "_c_" + GetStatic.GetUser();
            string value = "Y";
            var httpCookie = new HttpCookie(key, value);
            httpCookie.Expires = DateTime.Now.AddDays(1);
            HttpContext.Current.Response.Cookies.Add(httpCookie);
        }

        #region method

        private void LoadGrid()
        {
            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("userName", "User Name", "T"),
                                      new GridFilter("haschanged", "Change Status", "2"),
                                      new GridFilter("hasLimit", "Has Limit", "2")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("name", "Name", "", "T"),
                                      new GridColumn("userName", "User Name", "", "T"),
                                      new GridColumn("currencyName", "Currency", "", "T"),
                                      new GridColumn("limitPerDay", "Limit per day", "", "T"),
                                      new GridColumn("perTopUpLimit", "Per Top-Up Limit", "", "T"),
                                  };

            bool allowAddEdit = sl.HasRight(AddEditFunctionId);
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.InputPerRow = 3;
            grid.GridName = GridName;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.SortBy = "name";
            grid.RowIdField = "tulId";
            grid.AddPage = "Manage.aspx";
            grid.AllowApprove = sl.HasRight(ApproveFunctionId);
            grid.AllowCustomLink = allowAddEdit;
            grid.CustomLinkText = "<a href = \"Manage.aspx?userId=@userId&tulId=@tulId\">Setup</a>";
            grid.CustomLinkVariables = "userId,tulId";
            grid.ApproveFunctionId = ApproveFunctionId;

            string sql = "[proc_topUpLimitInt] @flag = 's'";
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        #endregion
    }
}