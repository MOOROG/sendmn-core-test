using System;
using System.Collections.Generic;
using Swift.DAL.BL.Remit.Transaction;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.Notification.TroubleTicket
{
    public partial class UnResolvedList : System.Web.UI.Page
    {
        private const string ViewFunctionId = "10121600";
        private const string UnlockFunctionId = "10121610";
        private const string GridName = "grdResolveComplain";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftGrid grid = new SwiftGrid();
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
            _sdd.CheckAuthentication(ViewFunctionId + "," + UnlockFunctionId);
            btnUnlock.Visible = _sdd.HasRight(UnlockFunctionId);
        }

        private void LoadGrid()
        {

            grid.FilterList = new List<GridFilter>
                                  {
                                      new GridFilter("controlNo", "Control No.", "T"),
                                      new GridFilter("complainUser", "User Name", "T")
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("id", "Ticket Id", "", "T"),
                                      new GridColumn("controlNo", "Control No.", "", "T"),
                                      new GridColumn("userAgent", "User Agent", "", "T"),
                                      new GridColumn("complainUser", "User", "", "T"),
                                      new GridColumn("complainDate", "Date", "", "T"),
                                      new GridColumn("remarks", "Remarks", "", "T")
                                  };
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.GridType = 1;
            grid.ShowFilterForm = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "id";
            grid.InputPerRow = 2;
            grid.ShowCheckBox = true;
            grid.MultiSelect = true;
            grid.SetComma();
            grid.GridWidth = 880;
            grid.PageSize = 10000;

            var sql = @"EXEC proc_tranComplainRpt @flag = 's'";
            rpt_grid.InnerHtml = grid.CreateGrid(sql);

        }

        protected void btnUnlock_Click(object sender, EventArgs e)
        {
            var obj = new TranViewDao();
            string tranIds = grid.GetRowId(GridName);

            if (tranIds != "")
            {

                DbResult dbResult = obj.ResolveTxnComplain(GetStatic.GetUser(), tranIds);
                GetStatic.SetMessage(dbResult);

                if (dbResult.ErrorCode == "0")
                {
                    Response.Redirect("UnResolvedList.aspx");
                }
                else
                {
                    GetStatic.PrintMessage(Page);
                }
            }

            return;
        }
    }
}