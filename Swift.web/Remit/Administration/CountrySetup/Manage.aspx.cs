using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Component.Tab;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.Administration.CountrySetup
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "10111200";
        private const string AddEditFunctionId = "10111210";
        private readonly CountryDao _countryDao = new CountryDao();
        private readonly RemittanceLibrary _sl1 = new RemittanceLibrary();
        private readonly SwiftTab _tab = new SwiftTab();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                if (GetId() > 0)
                {
                    CountryNameDiv.Visible = true;
                    LoadTab();
                    PopulateDataById();
                    routingAget.Visible = true;
                }
                else
                {
                    PopulateDDL(null);
                    CountryNameDiv.Visible = false;
                }
            }
            Misc.MakeNumericTextbox(ref countryMobLength);
        }

        private void PopulateDDL(DataRow dr)
        {
            _sdd.SetDDL(ref timeZone, "exec proc_dropDownLists @flag='timeZone'", "TIMEZONE_ID", "TIMEZONE_NAME",
                      GetStatic.GetRowData(dr, "timeZoneId"), "Select");

            _sdd.SetDDL(ref defRoutingAgent, "exec proc_dropDownLists2 @flag='recAgent', @param=" + GetId(), "agentId", "agentName",
                      GetStatic.GetRowData(dr, "defaultRoutingAgent"), "Select");
        }

        protected void btnSumit_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected string GetCountryName()
        {
            return "Country :  " + _sl1.GetCountryName(GetId().ToString());
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("List.aspx");
        }

        #region Method

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("countryId");
        }

        protected string GetOperationType()
        {
            return GetStatic.ReadQueryString("opType", "");
        }

        private void Authenticate()
        {
            _sl1.CheckAuthentication(AddEditFunctionId);
        }

        private void LoadTab()
        {
            var countryId = GetId().ToString();
            var opType = GetOperationType();

            var queryStrings = "?countryId=" + countryId + "&opType=" + opType;
            _tab.NoOfTabPerRow = 8;

            _tab.TabList = new List<TabField>
                               {
                                   new TabField("Country Info", "", true),
                                   new TabField("State Setup", "StateSetup/List.aspx" + queryStrings),
                                   new TabField("Allowed Currency", "CountryCurrency.aspx" + queryStrings),
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

        private void PopulateDataById()
        {
            DataRow dr = _countryDao.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;
            countryName.Text = dr["countryName"].ToString();
            countryCode.Text = dr["countryCode"].ToString();
            isoAlpha3.Text = dr["isoAlpha3"].ToString();
            iocOlympic.Text = dr["iocOlympic"].ToString();
            isoNumeric.Text = dr["isoNumeric"].ToString();
            isOperativeCountry.SelectedValue = dr["isOperativeCountry"].ToString();
            operationType.Text = dr["operationType"].ToString();
            fatfRating.Text = dr["fatfRating"].ToString();
            agentOperationControlType.Text = dr["agentOperationControlType"].ToString();
            countryMobCode.Text = dr["countryMobCode"].ToString();
            countryMobLength.Text = dr["countryMobLength"].ToString();
            ShowHideOpType();
            DisableField();
            PopulateDDL(dr);
        }

        private void DisableField()
        {
            countryCode.Enabled = false;
            countryName.Enabled = false;
        }

        private void Update()
        {
            DbResult dbResult = _countryDao.Update(GetStatic.GetUser(), GetId().ToString(), countryCode.Text,
                                                   countryName.Text, isoAlpha3.Text, iocOlympic.Text, isoNumeric.Text,
                                                   isOperativeCountry.Text, operationType.Text, fatfRating.Text, timeZone.Text,
                                                   agentOperationControlType.Text, defRoutingAgent.Text, countryMobCode.Text, countryMobLength.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);

            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        #endregion Method

        protected void isOperativeCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            ShowHideOpType();
            isOperativeCountry.Focus();
        }

        private void ShowHideOpType()
        {
            if (isOperativeCountry.Text == "Y")
                opTypePanel.Visible = true;
            else
                opTypePanel.Visible = false;
        }
    }
}