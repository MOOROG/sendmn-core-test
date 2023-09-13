using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Grid;
using Swift.web.Component.Grid.gridHelper;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;

namespace Swift.web.Remit.Administration.CountrySetup.CollectionMode
{
    public partial class List : System.Web.UI.Page
    {
        private const string ViewFunctionId = "10111200";
        private const string GridName = "gCcm";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SwiftTab _tab = new SwiftTab();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                GetStatic.PrintMessage(Page);
                LoadTab();
            }
            DeleteRow();
            LoadGrid();
        }

        #region QueryString

        protected string GetCountryName()
        {
            return "Country : " + _sl.GetCountryName(GetCountryId().ToString());
        }

        protected long GetCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryId");
        }

        private string GetOperationType()
        {
            return GetStatic.ReadQueryString("opType", "");
        }

        #endregion QueryString

        #region method

        private void LoadTab()
        {
            var countryId = GetCountryId().ToString();
            var opType = GetOperationType();

            var queryStrings = "?countryId=" + countryId + "&opType=" + opType;
            _tab.NoOfTabPerRow = 8;

            _tab.TabList = new List<TabField>
                               {
                                   new TabField("Country Info", "../Manage.aspx" + queryStrings),
                                   new TabField("State Setup", "../StateSetup/List.aspx" + queryStrings),
                                   new TabField("Allowed Currency", "../CountryCurrency.aspx" + queryStrings),
                                   new TabField("Mobile Format", "../MobileFormat.aspx" + queryStrings),
                                   new TabField("Valid ID Setup", "../CountryIdSetup.aspx" + queryStrings),
                               };
            switch (opType)
            {
                case "B":
                    _tab.TabList.Add(new TabField("Collection Mode", "", true));
                    _tab.TabList.Add(new TabField("Receiving Mode", "../ReceivingMode/List.aspx" + queryStrings));
                    break;

                case "S":
                    _tab.TabList.Add(new TabField("Collection Mode", "", true));
                    break;

                case "R":
                    _tab.TabList.Add(new TabField("Receiving Mode", "../ReceivingMode/List.aspx" + queryStrings));
                    break;
            }
            _tab.TabList.Add(new TabField("Event", "../EventSetup/List.aspx" + queryStrings));
            divTab.InnerHtml = _tab.CreateTab();
        }

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("collMode", "Collection Mode", "", "T"),
                                      new GridColumn("collModeDesc", "Description", "", "T"),
                                      new GridColumn("createdBy", "Created By", "", "T"),
                                      new GridColumn("createdDate", "Created Date", "", "DT")
                                  };

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowAddButton = true;
            grid.AddPage = "FilterList.aspx?countryId=" + GetCountryId() + "&opType=" + GetOperationType();
            grid.ShowPagingBar = true;
            grid.RowIdField = "ccmId";
            grid.ThisPage = "List.aspx";
            grid.MultiSelect = false;
            grid.ShowCheckBox = false;
            grid.AllowDelete = true;

            string sql = "[proc_countryCollectionMode] @flag = 's', @countryId=" + GetCountryId();
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        private void DeleteRow()
        {
            var obj = new CountryDao();
            string id = grid.GetCurrentRowId(GridName);
            if (string.IsNullOrEmpty(id))
                return;
            DbResult dbResult = obj.DeleteCcm(GetStatic.GetUser(), id);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.PrintMessage(Page);
        }

        #endregion method
    }
}