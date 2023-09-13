using Swift.DAL.BL.Remit.Transaction;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.AgentNew.UnpostTransaction
{
    public partial class List : System.Web.UI.Page
    {

        private readonly SwiftGrid _grid = new SwiftGrid();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();
        private const string ViewFunctionIdAgent = "20310000";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                LoadGrid();
            }
           
        }
        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionIdAgent);
        }
        private void LoadGrid()
        {
            _grid.FilterList = new List<GridFilter>
            {
 
            };



            _grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("SN", "SN", "", "T"),
                                      new GridColumn("controlno", "Control No", "", "T"),
                                      new GridColumn("createddate", "UnPost Since", "", "T"),
                                      new GridColumn("paymentmethod", "Payment Method", "", "T"),
                                      new GridColumn("pcountry", "Country", "", "T"),
                                      new GridColumn("pbankname", "Bank Name", "", "T"),
                                  };

            _grid.GridType = 1;
            _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            _grid.ShowPagingBar = true;
            _grid.AllowEdit = false;
            _grid.AlwaysShowFilterForm = false;
            _grid.ShowFilterForm = false;
            _grid.SortOrder = "ASC";
            _grid.RowIdField = "id";
            _grid.ThisPage = "List.aspx";
            _grid.InputPerRow = 4;
            _grid.GridMinWidth = 700;
            _grid.GridWidth = 100;
            _grid.IsGridWidthInPercent = true;
            _grid.CustomLinkVariables = "receiverId,customerId";
            string sql = "EXEC [proc_DailyTxnRpt] @flag = 'unPostTransaction'";
            _grid.SetComma();

            rpt_grid.InnerHtml = _grid.CreateGrid(sql);
        }

    }
}