using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.Administration.CountrySetup.StateSetup
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20101200";
        private const string AddEditFunctionId = "20101210";
        private const string DeleteFunctionId = "20101220";
        private readonly RemittanceLibrary _sl1 = new RemittanceLibrary();
        private readonly StateDao obj = new StateDao();
        private readonly SwiftTab _tab = new SwiftTab();
        private StaticDataDdl _sl = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    PopulateDdl(null);
                }
                LoadTab();
            }
        }

        #region QueryString

        protected string GetCountryName()
        {
            return "Country : " + _sl1.GetCountryName(GetCountryId().ToString());
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("stateId");
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

        #region Method

        private void Authenticate()
        {
            _sl1.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnDelete.Visible = _sl1.HasRight(DeleteFunctionId);
            btnSave.Visible = _sl1.HasRight(AddEditFunctionId);
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
                                   new TabField("State Setup", "List.aspx" + queryStrings, true),
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
            _tab.TabList.Add(new TabField("Event", "../EventSetup/List.aspx" + queryStrings));
            _tab.TabList.Add(new TabField("Manage", "", true));
            divTab.InnerHtml = _tab.CreateTab();
        }

        private void PopulateDdl(DataRow dr)
        {
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            stateCode.Text = dr["stateCode"].ToString();
            stateName.Text = dr["stateName"].ToString();
        }

        private void Update()
        {
            var dbResult = obj.Update(GetStatic.GetUser(), GetId().ToString(), GetCountryId().ToString(),
                                           stateCode.Text, stateName.Text);
            ManageMessage(dbResult);
        }

        private void DeleteRow()
        {
            var dbResult = obj.Delete(GetStatic.GetUser(), GetId().ToString());
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

        #endregion Method

        #region Element Method

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            DeleteRow();
        }

        #endregion Element Method
    }
}