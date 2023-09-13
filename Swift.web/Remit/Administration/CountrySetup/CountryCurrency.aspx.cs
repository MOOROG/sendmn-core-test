using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.CountrySetup
{
    public partial class CountryCurrency : Page
    {
        private const string ViewFunctionId = "20101200";
        private const string AddEditFunctionId = "20101210";
        private const string DeleteFunctionId = "20101220";

        protected const string GridName = "grd_cc";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SwiftTab _tab = new SwiftTab();
        private readonly CountryDao obj = new CountryDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                PopulateDdl(null);
                if (GetCountryId() > 0)
                {
                    //PopulateDataById();
                }
                else
                {
                    //Your code goes here
                }
                LoadTab();
            }
            DeleteRow();
            LoadGrid();
        }

        #region Method

        protected string GetCountryName()
        {
            return "Country : " + swiftLibrary.GetCountryName(GetCountryId().ToString());
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryCurrencyId");
        }

        protected long GetCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryId");
        }

        private string GetOperationType()
        {
            return GetStatic.ReadQueryString("opType", "");
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        private void LoadTab()
        {
            var countryId = GetCountryId().ToString();
            var opType = GetOperationType();

            var queryStrings = "?countryId=" + countryId + "&opType=" + opType;
            _tab.NoOfTabPerRow = 8;

            _tab.TabList = new List<TabField>
                               {
                                   new TabField("Country Info", "Manage.aspx" + queryStrings),
                                   new TabField("State Setup", "StateSetup/List.aspx" + queryStrings),
                                   new TabField("Allowed Currency", "", true),
                                   new TabField("Mobile Format", "MobileFormat.aspx" + queryStrings),
                                   new TabField("Valid ID Setup", "CountryIdSetup.aspx" + queryStrings),
                               };
            switch (opType)
            {
                case "B":
                    _tab.TabList.Add(new TabField("Collection Mode", "CollectionMode/List.aspx" + queryStrings));
                    _tab.TabList.Add(new TabField("Receiving Mode", "ReceivingMode/List.aspx" + queryStrings));
                    break;

                case "S":
                    _tab.TabList.Add(new TabField("Collection Mode", "CollectionMode/List.aspx" + queryStrings));
                    break;

                case "R":
                    _tab.TabList.Add(new TabField("Receiving Mode", "ReceivingMode/List.aspx" + queryStrings));
                    break;
            }
            _tab.TabList.Add(new TabField("Event", "EventSetup/List.aspx" + queryStrings));
            divTab.InnerHtml = _tab.CreateTab();
        }

        private void PopulateDdl(DataRow dr)
        {
            spFlag.Items.Add(new ListItem("Select", ""));
            //switch (GetOperationType())
            //{
            //    case "B":
            //        spFlag.Items.Add(new ListItem("Both", "B"));
            //        spFlag.Items.Add(new ListItem("Send", "S"));
            //        spFlag.Items.Add(new ListItem("Receive", "R"));
            //        break;
            //    case "S":
            //        spFlag.Items.Add(new ListItem("Send", "S"));
            //        break;
            //    case "R":
            //        spFlag.Items.Add(new ListItem("Receive", "R"));
            //        break;
            //}
            spFlag.Items.Add(new ListItem("Both", "B"));
            spFlag.Items.Add(new ListItem("Send", "S"));
            spFlag.Items.Add(new ListItem("Receive", "R"));
            sdd.SetDDL(ref currency, "EXEC proc_currencyMaster @flag = 'l'", "currencyId", "currencyCode",
                       GetStatic.GetRowData(dr, "currencyId"), "Select");
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectCurrencyById(GetStatic.GetUser(), countryCurrencyId.Value);
            if (dr == null)
                return;

            currency.Text = dr["currencyId"].ToString();
            var spFl = dr["spFlag"].ToString();
            spFlag.SelectedValue = dr["spFlag"].ToString();
            isDefault.Text = GetStatic.GetRowData(dr, "isDefault");
        }

        private void Update()
        {
            DbResult dbResult = obj.UpdateCurrency(GetStatic.GetUser(), GetId().ToString(), GetCountryId().ToString(),
                                                   currency.Text, spFlag.Text, isDefault.Text);
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
                                      new GridColumn("currencyCode", "Currency Code", "", "T"),
                                      new GridColumn("currencyName", "Currency Name", "", "T"),
                                      new GridColumn("isDefault", "Is Default", "", "T"),
                                      new GridColumn("spFlag", "Applies For", "", "T")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.GridWidth = 450;
            grid.RowIdField = "countryCurrencyId";
            grid.CallBackFunction = "GridCallBack()";
            grid.DisableSorting = false;
            grid.ThisPage = "CountryCurrency.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = true;
            grid.SelectionCheckBoxList = grid.GetRowId();
            grid.AllowEdit = false;
            grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);

            string sql = "EXEC proc_countryCurrency @flag = 's', @countryId = " + GetCountryId();

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void DeleteRow()
        {
            var obj = new CountryDao();
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.DeleteCurrency(GetStatic.GetUser(), id);
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
            if (!isRefresh)
                Save();
        }

        private void Save()
        {
            DbResult dbResult = obj.UpdateCurrency(GetStatic.GetUser(), countryCurrencyId.Value,
                                                   GetCountryId().ToString(), currency.Text, spFlag.Text, isDefault.Text);
            ManageMessage(dbResult);
            LoadGrid();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Edit();
        }

        #endregion Element Method

        #region Browser Refresh

        private bool refreshState;
        private bool isRefresh;

        protected override void LoadViewState(object savedState)
        {
            object[] AllStates = (object[])savedState;
            base.LoadViewState(AllStates[0]);
            refreshState = bool.Parse(AllStates[1].ToString());
            if (Session["ISREFRESH"] != null && Session["ISREFRESH"] != "")
                isRefresh = (refreshState == (bool)Session["ISREFRESH"]);
        }

        protected override object SaveViewState()
        {
            Session["ISREFRESH"] = refreshState;
            object[] AllStates = new object[3];
            AllStates[0] = base.SaveViewState();
            AllStates[1] = !(refreshState);
            return AllStates;
        }

        #endregion Browser Refresh
    }
}