using System;
using System.Collections.Generic;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.Remit.Transaction.BlockTransaction
{
    public partial class List : System.Web.UI.Page
    {
        SwiftLibrary sl = new SwiftLibrary();
        private const string GridName = "grdBlock";
        private const string viewFunctionId = "20121200";
        private const string addEditFunctionId = "20121210";
        private readonly SwiftGrid grid = new SwiftGrid();
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadGrid();
            if(!IsPostBack)
            {
                CheckAuthentication();
                GetStatic.PrintMessage(Page);
            }
        }

        private void CheckAuthentication()
        {
            sl.CheckAuthentication(viewFunctionId);
        }

        private void LoadGrid()
        {

            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("controlNo", "Control No.", "T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("controlNo", "Control No.", "", "T"),
                                      new GridColumn("senderName", "Sender Name", "", "T"),
                                      new GridColumn("sAddress", "S. Address", "", "T"),
                                      new GridColumn("sStateName", "S. Zone", "", "T"),
                                      new GridColumn("receiverName", "Receiver Name", "", "T"),
                                      new GridColumn("rAddress", "R. Address", "", "T"),
                                      new GridColumn("rStateName", "R. Zone", "", "T")
                                  };

            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.ShowAddButton = sl.HasRight(addEditFunctionId);
            grid.ShowFilterForm = true;
            grid.EnableFilterCookie = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "controlNo";
            grid.AddPage = "Manage.aspx";
            grid.AllowEdit = sl.HasRight(addEditFunctionId);
            
            grid.SetComma();
            grid.GridWidth = 880;
            grid.PageSize = 10000;
            grid.EnableCookie = true;

            var sql = @"EXEC proc_LockUnlockTransaction @flag = 'b'";
            rpt_grid.InnerHtml = grid.CreateGrid(sql);
            
        }
    }
}