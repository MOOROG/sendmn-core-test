using Swift.DAL.BL.LoadMoneyWalletDao;
using Swift.DAL.ExchangeSystem;
using Swift.DAL.SwiftDAL;
using Swift.DAL.VoucherReport;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Grid;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Reflection.Emit;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using static System.Windows.Forms.AxHost;

namespace Swift.web.Remit.InternationalOperation.ServiceCharge {
  public partial class FreeServiceCharge : System.Web.UI.Page {

    private readonly StaticDataDdl _sdd = new StaticDataDdl();
    private readonly RemittanceLibrary obj = new RemittanceLibrary();
    private const string ViewFunctionId = "10112203";
    WalletDao _dao = new WalletDao();
    private readonly SwiftLibrary _sl = new SwiftLibrary();
    private readonly SwiftGrid _grid = new SwiftGrid();
    private const string GridName = "grid_list";



    protected void Page_Load(object sender, EventArgs e) {
      if (!IsPostBack) {
        Authenticate();
        amountId.Text = "0";
        string sql = "EXEC proc_countryMaster @flag = 'ocl'";
        sql = sql + ",@countryType=" + _sdd.FilterString("sCountry");
        _sdd.SetDDL(ref sendCountry, sql, "countryId", "countryName", "", "All");
        //_sl.SetDDL(ref sendCountry, "exec [SendMnPro_Remit].dbo.[proc_agentMaster] @flag='sal'", "agentId", "agentName", "", "All");
        LoadGrid();
      }
    }

    private void Authenticate() {
      obj.CheckAuthentication(ViewFunctionId);
    }

    protected void add_Click(object sender, EventArgs e) {

      var dbResult = _dao.SetFreeServiceCharge(sendCountry.SelectedItem.Value, "N",fromDate.Text, toDate.Text, GetStatic.GetUser());
      GetStatic.AlertMessage(this, dbResult.Msg);
      LoadGrid();
      //Response.Redirect("/admin/Dashboard.aspx");
    }

    private void LoadGrid() {
      _grid.FilterList = new List<GridFilter>
                          {
                                       new GridFilter("searchCriteria", "Search By", "1:" + "EXEC [Proc_SetFreeScharge] @flag='searchCriteria'"),
                                       new GridFilter("searchValue", "Search Value", "T")
                                   };
      _grid.ColumnList = new List<GridColumn>
                          {
                                       new GridColumn("sn", "SN", "", "T"),
                                       new GridColumn("country", "Улс", "", "T"),
                                       new GridColumn("fromDate", "Эхлэх", "", "T"),
                                       new GridColumn("toDate", "Дуусах", "", "T"),
                                       new GridColumn("isFirst", "Эхний гүйлгээ", "", "T"),
                                       new GridColumn("agent", "Agent", "", "T"),
                                       new GridColumn("addBy", "Нэмсэн", "", "T")
                                   };

      _grid.GridType = 1;
      _grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
      _grid.GridName = GridName;
      _grid.ShowPagingBar = true;
      _grid.AlwaysShowFilterForm = true;
      _grid.ShowFilterForm = true;
      _grid.SortOrder = "ASC";
      _grid.RowIdField = "fromDate";
      _grid.ThisPage = "List.aspx";
      _grid.InputPerRow = 4;
      _grid.GridMinWidth = 700;
      _grid.GridWidth = 100;
      _grid.IsGridWidthInPercent = true;
      _grid.AllowCustomLink = false;

      _grid.SetComma();
      _grid.EnableFilterCookie = false;


      string sql = "EXEC [Proc_SetFreeScharge] @flag = 'get'";
      rpt_grid.InnerHtml = _grid.CreateGrid(sql);
    }



  }
}