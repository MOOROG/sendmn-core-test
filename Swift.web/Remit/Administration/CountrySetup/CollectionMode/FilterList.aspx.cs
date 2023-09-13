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
    public partial class FilterList : System.Web.UI.Page
    {
        private const string GridName = "gCcmFl";
        private const string ViewFunctionId = "10111200";
        private readonly SwiftGrid grid = new SwiftGrid();
        private readonly SwiftTab _tab = new SwiftTab();
        private readonly RemittanceLibrary _sl = new RemittanceLibrary();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                LoadTab();
            }
            LoadGrid();
        }

        #region QueryString

        public string GetCountryName()
        {
            return "Country : " + _sl.GetCountryName(GetCountryId());
        }

        protected string GetCountryId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryId").ToString();
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
                    _tab.TabList.Add(new TabField("Collection Mode", "List.aspx" + queryStrings, true));
                    _tab.TabList.Add(new TabField("Receiving Mode", "../ReceivingMode/List.aspx" + queryStrings));
                    break;

                case "S":
                    _tab.TabList.Add(new TabField("Collection Mode", "List.aspx" + queryStrings, true));
                    break;

                case "R":
                    _tab.TabList.Add(new TabField("Receiving Mode", "../ReceivingMode/List.aspx" + queryStrings));
                    break;
            }
            _tab.TabList.Add(new TabField("Event", "../EventSetup/List.aspx" + queryStrings));
            _tab.TabList.Add(new TabField("Filter List", "", true));
            divTab.InnerHtml = _tab.CreateTab();
        }

        private void LoadGrid()
        {
            grid.ColumnList = new List<GridColumn>
                                  {
                                      new GridColumn("detailTitle", "Collection Mode", "", "T"),
                                      new GridColumn("detailDesc", "Description", "", "T")
                                  };

            grid.GridType = 1;
            grid.GridName = GridName;
            grid.GridDataSource = SwiftGrid.GridDS.RemittanceDB;
            grid.ShowFilterForm = false;
            grid.ShowPagingBar = true;
            grid.RowIdField = "valueId";
            grid.ThisPage = "FilterList.aspx";
            grid.MultiSelect = true;
            grid.ShowCheckBox = true;
            grid.AllowEdit = false;
            grid.AllowDelete = false;

            string sql = "EXEC proc_countryCollectionMode @flag = 'fl', @countryId = " + _sl.FilterString(GetCountryId());
            grid.SetComma();

            rpt_grid.InnerHtml = grid.CreateGrid(sql);
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            var obj = new CountryDao();
            string collModes = grid.GetRowId(GridName);
            DbResult dbResult = obj.AddCcm(GetStatic.GetUser(), GetCountryId(), collModes);
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx?countryId=" + GetCountryId() + "&opType=" + GetOperationType());
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        #endregion method
    }
}