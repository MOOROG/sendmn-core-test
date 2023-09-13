using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;

namespace Swift.web.Remit.Administration.CurrencySetup
{
    public partial class PayoutRounding : System.Web.UI.Page
    {
        private const string ViewFunctionId = "10111500";
        private const string AddEditFunctionId = "10111510";
        private const string DeleteFunctionId = "10111520";

        protected const string GridName = "grid_currencyRound";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly CurrencyDao obj = new CurrencyDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Misc.MakeNumericTextbox(ref cDecimal);
                Authenticate();
                if (Convert.ToInt32((GetId() == "" ? "0" : GetId())) > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    PopulateDdl(null);
                }
            }
            DeleteRow();
            LoadGrid();
        }

        #region Method

        protected string GetCurrencyCode()
        {
            return "Currency Code : " + GetCurrCode();
        }

        protected string GetCurrCode()
        {
            return GetStatic.ReadQueryString("currencyCode", "");
        }

        protected long GetCurrencyId()
        {
            return GetStatic.ReadNumericDataFromQueryString("currencyId");
        }

        protected string GetId()
        {
            return grid.GetRowId();
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref tranType, "exec proc_serviceTypeMaster @flag='l2'", "serviceTypeId", "typeTitle", GetStatic.GetRowData(dr, "tranType"), "All");
            sdd.SetDDL2(ref place, "SELECT valueId,detailTitle FROM staticDataValue WHERE typeID=7100 AND isActive  = 'Y'", "detailTitle", GetStatic.GetRowData(dr, "place"), "0");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectCurrRoundById(GetStatic.GetUser(), countryCurrencyId.Value);
            if (dr == null)
                return;
            cDecimal.Text = dr["currDecimal"].ToString();
            cDecimal.ReadOnly = (place.Text != "" ? true : false);
            PopulateDdl(dr);
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateCurrRound(GetStatic.GetUser(), GetId(), GetCurrCode(),
                                                   place.Text, cDecimal.Text, tranType.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("currency", "Currency Code", "", "T"),
                                      new GridColumn("typeTitle", "Tran Type", "", "T"),
                                      new GridColumn("place", "Placing", "", "T"),
                                      new GridColumn("currDecimal", "Decimal", "", "T")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.GridWidth = 450;
            grid.RowIdField = "rowID";
            grid.CallBackFunction = "GridCallBack()";
            grid.DisableSorting = false;
            grid.ThisPage = "PayoutRounding.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = true;
            grid.SelectionCheckBoxList = grid.GetRowId();
            grid.AllowEdit = false;
            grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);

            string sql = "EXEC proc_currencyPayoutRound @flag = 's', @currency = " + grid.FilterString(GetCurrCode());

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.DeleteCurrRound(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
            LoadGrid();
        }

        private void Edit()
        {
            string id = grid.GetRowId();
            countryCurrencyId.Value = id;
            PopulateDataById();
        }

        #endregion Method

        #region Element Method

        protected void btnSumit_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            DbResult dbResult = obj.UpdateCurrRound(GetStatic.GetUser(), GetId(), GetCurrCode(),
                                                   place.Text, cDecimal.Text, tranType.Text);
            ManageMessage(dbResult);
            LoadGrid();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Edit();
        }

        #endregion Element Method

        protected void place_SelectedIndexChanged(object sender, EventArgs e)
        {
            cDecimal.ReadOnly = (place.Text != "");
            cDecimal.Text = (place.Text != "" ? "0" : cDecimal.Text);
            place.Focus();
        }
    }
}