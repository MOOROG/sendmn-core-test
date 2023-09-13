using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;

namespace Swift.web.Remit.Administration.CountrySetup.EventSetup
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string AddEditFunctionId = "20101210";
        private readonly CountryDao _countryDao = new CountryDao();
        private readonly RemittanceLibrary _swiftLibrary = new RemittanceLibrary();
        private readonly SwiftTab _tab = new SwiftTab();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                LoadTab();
            }
        }

        protected void btnSumit_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected string GetCountryName()
        {
            return "Country : " + _swiftLibrary.GetCountryName(GetCountryId().ToString());
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rowId");
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
            _swiftLibrary.CheckAuthentication(AddEditFunctionId);
        }

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
                    _tab.TabList.Add(new TabField("Collection Mode", "../CollectionMode/List.aspx" + queryStrings));
                    _tab.TabList.Add(new TabField("Receiving Mode", "../ReceivingMode/List.aspx" + queryStrings));
                    break;

                case "S":
                    _tab.TabList.Add(new TabField("Collection Mode", "../CollectionMode/List.aspx" + queryStrings));
                    break;

                case "R":
                    _tab.TabList.Add(new TabField("Receiving Mode", "../ReceivingMode/List.aspx" + queryStrings));
                    break;
            }
            _tab.TabList.Add(new TabField("Event", "List.aspx" + queryStrings, true));
            _tab.TabList.Add(new TabField("Manage", "", true));
            divTab.InnerHtml = _tab.CreateTab();
        }

        private void PopulateDataById()
        {
            DataRow dr = _countryDao.SelectCountryHolidayById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;
            eventDate.Text = dr["eventDate"].ToString();
            eventName.Text = dr["eventName"].ToString();
            eventDesc.Text = dr["eventDesc"].ToString();
        }

        private void Update()
        {
            DbResult dbResult = _countryDao.UpdateCountryHoliday(GetStatic.GetUser(), GetId().ToString(), GetCountryId().ToString(),
                                                   eventDate.Text, eventName.Text, eventDesc.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
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
    }
}