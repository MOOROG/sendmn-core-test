using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using Swift.DAL.Remittance.Transaction.ThirdParty.XPressMoney;

namespace Swift.web.Remit.Transaction.Restore
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "20123600";
        XpressPayDao xpd = new XpressPayDao();
        private const string GridName = "g_restore";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly SwiftGrid grid = new SwiftGrid();
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                //Authenticate();
            }
            DeleteRow();
            LoadGrid();
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void LoadGrid()
        {
            string ddlSql = "EXEC [proc_dropDownLists2] @flag = 'provider'";
            grid.FilterList = new List<GridFilter>
                                  {                                      
                                      new GridFilter("provider", "Sending Agent","1:" + ddlSql),
                                      new GridFilter("agentName", "Receiving Agent", "T"),
                                      new GridFilter("xpin", "PIN Number", "T")                                      
                                  };

            grid.ColumnList = new List<GridColumn>
                                  {                                      
                                      new GridColumn("agentName", "Agent Name", "", "T"),
                                      new GridColumn("provider", "Provider", "", "T"),
                                      new GridColumn("xpin", "PIN Number", "", "T"),
                                      new GridColumn("customer", "Sender", "", "T"),
                                      new GridColumn("customerAddress", "Sender Address", "", "T"),
                                      new GridColumn("beneficiary", "Receiver", "", "T"),
                                      new GridColumn("beneficiaryAddress", "Receiver Address", "", "T"),                                      
                                      new GridColumn("payoutAmount", "Amount", "", "M"),
                                      new GridColumn("payoutDate", "Date", "", "D")
                                  };

            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridType = 1;
            grid.AlwaysShowFilterForm = true;
            grid.EnableFilterCookie = false;
            grid.EditText = "<img border = \"0\" title = \"View Details\" alt = \"View Details\" src=\"" + GetStatic.GetUrlRoot() + "/Images/view-detail-icon.png\" />";
            grid.InputPerRow = 3;
            grid.ShowFilterForm = true;
            grid.AddPage = "Manage.aspx?provider=" + Request.Form["g_restore_provider"];
            grid.AllowCustomLink = true;
            grid.CustomLinkVariables = "rowId";
            grid.AllowEdit = true;
            grid.AllowDelete = true;
            grid.ShowPagingBar = true;
            grid.RowIdField = "rowId";
            grid.SetComma();

            var sql = @"EXEC proc_restore_V2 @flag = 's'";
            rpt_grid.InnerHtml = grid.CreateGrid(sql);

        }

        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);

            if (id == "")
                return;

            var dr = xpd.DeleteTransaction(id, GetStatic.GetUser());
            if (dr.ErrorCode != "0")
            {
                GetStatic.AlertMessage(Page, dr.Msg);
            }
        }
    }
}