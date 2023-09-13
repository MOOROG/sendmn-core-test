using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.Administration.CountrySetup
{
    public partial class CountryIdSetup : System.Web.UI.Page
    {
        private const string AddEditFunctionId = "20101210";
        private const string DeleteFunctionId = "20101220";
        protected const string GridName = "grd_countryid";
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SwiftTab _tab = new SwiftTab();
        private readonly CountryDao obj = new CountryDao();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PopulateDdl(null);
                LoadTab();
            }
            DeleteRow();
            LoadGrid();
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(DeleteFunctionId + "," + AddEditFunctionId);
        }

        #region Data Population parts

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryId");
        }

        private string GetOperationType()
        {
            return GetStatic.ReadQueryString("opType", "");
        }

        private void PopulateDdl(DataRow dr)
        {
            sdd.SetDDL(ref idType, "EXEC proc_currencyMaster @flag = 'id'", "valueId", "detailTitle",
                       GetStatic.GetRowData(dr, "currencyId"), "Select");
            //sdd.SetStaticDdl(ref spFlag, "5200", GetStatic.GetRowData(dr, "spFlag"), "Both");
            switch (GetOperationType())
            {
                case "B":
                    spFlag.Items.Add(new ListItem("Both", ""));
                    spFlag.Items.Add(new ListItem("Send", "5200"));
                    spFlag.Items.Add(new ListItem("Receive", "5201"));
                    break;

                case "S":
                    spFlag.Items.Add(new ListItem("Send", "5200"));
                    break;

                case "R":
                    spFlag.Items.Add(new ListItem("Receive", "5201"));
                    break;
            }
        }

        protected string GetCountryName()
        {
            return "Country : " + swiftLibrary.GetCountryName(GetId().ToString());
        }

        private void LoadTab()
        {
            var countryId = GetId().ToString();
            var opType = GetOperationType();

            var queryStrings = "?countryId=" + countryId + "&opType=" + opType;
            _tab.NoOfTabPerRow = 8;

            _tab.TabList = new List<TabField>
                               {
                                   new TabField("Country Info", "Manage.aspx" + queryStrings),
                                   new TabField("State Setup", "StateSetup/List.aspx" + queryStrings),
                                   new TabField("Allowed Currency", "CountryCurrency.aspx" + queryStrings),
                                   new TabField("Mobile Format", "MobileFormat.aspx" + queryStrings),
                                   new TabField("Valid ID Setup", "", true),
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

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("IdType", "Identity Type", "", "T"),
                                      new GridColumn("spFlag", "Applies For", "", "T"),
                                       new GridColumn("expiryType", "Expiry Type", "", "T")
                                  };

            bool allowAddEdit = swiftLibrary.HasRight(AddEditFunctionId);

            grid.GridType = 1;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.GridName = GridName;
            grid.ShowAddButton = allowAddEdit;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = false;
            grid.GridWidth = 450;
            grid.RowIdField = "countryIdtypeId";
            grid.CallBackFunction = "GridCallBack()";
            grid.DisableSorting = false;
            grid.ThisPage = "CountryIdSetup.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = true;
            grid.SelectionCheckBoxList = grid.GetRowId();
            grid.AllowEdit = false;
            grid.AllowDelete = swiftLibrary.HasRight(DeleteFunctionId);

            string sql = "EXEC proc_countryIdType @flag = 's', @countryId = " + GetId();

            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectIdentypeById(GetStatic.GetUser(), countryIdtypeId.Value);
            if (dr == null)
                return;

            idType.Text = dr["IdtypeId"].ToString();
            spFlag.Text = dr["spFlag"].ToString();
        }

        #endregion Data Population parts

        #region Operational parts

        protected void btnSave_Click(object sender, EventArgs e)
        {
            DbResult dbResult = obj.UpdateCurrencyIdtype(GetStatic.GetUser(), countryIdtypeId.Value,
                                                   GetId().ToString(), idType.Text, spFlag.Text, expiryType.Text);
            lblMsg.Text = dbResult.Msg;
            LoadGrid();
        }

        private void Edit()
        {
            string id = grid.GetRowId();
            countryIdtypeId.Value = id;
            PopulateDataById();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            Edit();
        }

        private void DeleteRow()
        {
            var obj = new CountryDao();
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.DeleteIdentype(GetStatic.GetUser(), id);
            lblMsg.Text = dbResult.Msg;
            LoadGrid();
        }

        #endregion Operational parts
    }
}