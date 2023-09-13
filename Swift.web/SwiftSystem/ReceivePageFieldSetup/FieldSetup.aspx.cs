using Swift.DAL.BL.System.GeneralSettings;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.UI;
using System.Xml.Serialization;

namespace Swift.web.SwiftSystem.ReceivePageFieldSetup
{
    public partial class FieldSetup : Page
    {
        private readonly RemittanceLibrary sl = new RemittanceLibrary();
        private readonly FieldSettingDao fsd = new FieldSettingDao();
        private const string ViewFunctionId = "10112200";
        private const string AddEditFunctionId = "10112210";
        private const string DeleteFunctionId = "10112220";

        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                populateDdl();
                GetData();
            }
        }

        private void Populate(DataTable dt)
        {
            int i = 0;
            ddlLocalName.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinLocalName.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxLocalName.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddlLocalNameKeyword.SelectedValue = dt.Rows[i]["KeyWord"].ToString();

            i = i + 1;
            ddlFirstNameInlocal.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinLocalFirstName.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxLocalFirstName.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddlLocalFirstNameKeyword.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
            i = i + 1;

            ddMiddleNameInlocal.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinMiddleNameInlocal.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxMiddleNameInlocal.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddlLocalMiddleNameKeyword.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
            i = i + 1;

            ddlLastNameINLocal.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinLastNameINLocal.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxLastNameINLocal.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddlLastNameINLocalKeyword.SelectedValue = dt.Rows[i]["KeyWord"].ToString();

            i = i + 1;
            ddlFullName.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinFullName.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxFullName.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddlFullnameKeyword.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
            i = i + 1;

            ddlFirstName.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinfistName.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxFirstName.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddLFirstNameKeyWord.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
            i = i + 1;

            dllMiddleName.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinMiddleName.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxMiddleName.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddlMiddleNameKeyword.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
            i = i + 1;

            ddlLastName.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinlastName.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxlastName.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddlLatNameKeyWord.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
            i = i + 1;

            ddlNativeCountry.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            i = i + 1;

            ddlProvince.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            i = i + 1;

            ddlState.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            i = i + 1;

            ddlAddress.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinAdress.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxAdress.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddlAddressKeyword.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
            i = i + 1;

            ddlCity.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinCity.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxCity.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddlCityKeyword.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
            i = i + 1;

            ddlIdType.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();

            i = i + 1;

            ddlIdNumber.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinIdnumber.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxIdnumber.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddlIdnumberKeyWord.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
            i = i + 1;

            ddlMobile.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinMobile.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxMobile.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddlMobileKeyWord.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
            i = i + 1;

            ddlRealation.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            i = i + 1;
            ddlTransferReason.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();

            i = i + 1;
            ddlBank.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();

            i = i + 1;
            ddlBranch.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();

            i = i + 1;
            ddlAccount.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
            txtMinAccount.Text = dt.Rows[i]["minFieldlength"].ToString();
            txtMaxAccount.Text = dt.Rows[i]["maxFieldlength"].ToString();
            ddlAccountKeyWord.SelectedValue = dt.Rows[i]["KeyWord"].ToString();

      #region
      if (dt.Rows.Count > i + 1) {
        i = i + 1;
        ddlBankAccountType.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
        i = i + 1;
        ddlBicSwift.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
        bicSwiftMin.Text = dt.Rows[i]["minFieldlength"].ToString();
        bicSwiftMax.Text = dt.Rows[i]["maxFieldlength"].ToString();
        ddlBicSwiftKeyword.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
        i = i + 1;
        ddlBankRoutingCode.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
        bankRoutingCodeMin.Text = dt.Rows[i]["minFieldlength"].ToString();
        bankRoutingCodeMax.Text = dt.Rows[i]["maxFieldlength"].ToString();
        ddlBankRoutingCodeKeyword.SelectedValue = dt.Rows[i]["KeyWord"].ToString();

        i = i + 1;
        ddlBeneZipCode.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
        beneZipCodeMin.Text = dt.Rows[i]["minFieldlength"].ToString();
        beneZipCodeMax.Text = dt.Rows[i]["maxFieldlength"].ToString();
        ddlBeneZipCodeKeyword.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
      }
      #endregion
      i = i + 1;
      isOrgOrIndi.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
      i = i + 1;
      invoiceImageDDL.SelectedValue = dt.Rows[i]["fieldRequired"].ToString();
      invoiceMin.Text = dt.Rows[i]["minFieldlength"].ToString();
      invoiceMax.Text = dt.Rows[i]["maxFieldlength"].ToString();
      invoiceTypeDDL.SelectedValue = dt.Rows[i]["KeyWord"].ToString();
    }

    private void populateDdl()
        {
            sl.SetDDL(ref country, "EXEC Proc_ReceiverPageFieldSetup @flag = 'countryPay'", "countryId", "countryName", "", "");
            sl.SetDDL(ref ddlServiceType, "EXEC Proc_ReceiverPageFieldSetup @flag = 'servicetype'", "valueField", "textField", "", "");
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            sl.CheckAuthentication(AddEditFunctionId);
            List<Fieldsetting> _fieldsetting = new List<Fieldsetting>();
            _fieldsetting.Add(new Fieldsetting() { field = "Local Name", fieldRequired = ddlLocalName.SelectedValue.ToString(), minFieldlength = txtMinLocalName.Text, maxFieldlength = txtMaxLocalName.Text, KeyWord = ddlLocalNameKeyword.SelectedValue.ToString() });
            _fieldsetting.Add(new Fieldsetting() { field = "First Name in Local", fieldRequired = ddlFirstNameInlocal.SelectedValue.ToString(), minFieldlength = txtMinLocalFirstName.Text, maxFieldlength = txtMaxLocalFirstName.Text, KeyWord = ddlLocalFirstNameKeyword.SelectedValue.ToString() });
            _fieldsetting.Add(new Fieldsetting() { field = "Middle Name in Local", fieldRequired = ddMiddleNameInlocal.SelectedValue.ToString(), minFieldlength = txtMinMiddleNameInlocal.Text, maxFieldlength = txtMaxMiddleNameInlocal.Text, KeyWord = ddlLocalMiddleNameKeyword.SelectedValue.ToString() });
            _fieldsetting.Add(new Fieldsetting() { field = "Last Name in Local", fieldRequired = ddlLastNameINLocal.SelectedValue.ToString(), minFieldlength = txtMinLastNameINLocal.Text, maxFieldlength = txtMaxLastNameINLocal.Text, KeyWord = ddlLastNameINLocalKeyword.SelectedValue.ToString() });

            _fieldsetting.Add(new Fieldsetting() { field = "Full Name", fieldRequired = ddlFullName.SelectedValue.ToString(), minFieldlength = txtMinFullName.Text, maxFieldlength = txtMaxFullName.Text, KeyWord = ddlFullnameKeyword.SelectedValue.ToString() });
            _fieldsetting.Add(new Fieldsetting() { field = "First Name", fieldRequired = ddlFirstName.SelectedValue.ToString(), minFieldlength = txtMinfistName.Text, maxFieldlength = txtMaxFirstName.Text, KeyWord = ddLFirstNameKeyWord.SelectedValue });
            _fieldsetting.Add(new Fieldsetting() { field = "Middle Name", fieldRequired = dllMiddleName.SelectedValue.ToString(), minFieldlength = txtMinMiddleName.Text, maxFieldlength = txtMaxMiddleName.Text, KeyWord = ddlMiddleNameKeyword.SelectedValue });
            _fieldsetting.Add(new Fieldsetting() { field = "Last Name", fieldRequired = ddlLastName.SelectedValue.ToString(), minFieldlength = txtMinlastName.Text, maxFieldlength = txtMaxlastName.Text, KeyWord = ddlLatNameKeyWord.SelectedValue });
            _fieldsetting.Add(new Fieldsetting() { field = "Native Country", fieldRequired = ddlNativeCountry.SelectedValue.ToString(), minFieldlength = "", maxFieldlength = "", KeyWord = "" });
            _fieldsetting.Add(new Fieldsetting() { field = "Province", fieldRequired = ddlProvince.SelectedValue.ToString(), minFieldlength = "", maxFieldlength = "", KeyWord = "" });
            _fieldsetting.Add(new Fieldsetting() { field = "District", fieldRequired = ddlState.SelectedValue.ToString(), minFieldlength = "", maxFieldlength = "", KeyWord = "" });
            _fieldsetting.Add(new Fieldsetting() { field = "Address", fieldRequired = ddlAddress.SelectedValue.ToString(), minFieldlength = txtMinAdress.Text, maxFieldlength = txtMaxAdress.Text, KeyWord = ddlAddressKeyword.SelectedValue });
            _fieldsetting.Add(new Fieldsetting() { field = "City", fieldRequired = ddlCity.SelectedValue.ToString(), minFieldlength = txtMinCity.Text, maxFieldlength = txtMaxCity.Text, KeyWord = ddlCityKeyword.SelectedValue });
            _fieldsetting.Add(new Fieldsetting() { field = "Id Type", fieldRequired = ddlIdType.SelectedValue.ToString(), minFieldlength = "0", maxFieldlength = "0", KeyWord = "" });
            _fieldsetting.Add(new Fieldsetting() { field = "ID Number", fieldRequired = ddlIdNumber.SelectedValue.ToString(), minFieldlength = txtMinIdnumber.Text, maxFieldlength = txtMaxIdnumber.Text, KeyWord = ddlIdnumberKeyWord.SelectedValue });
            _fieldsetting.Add(new Fieldsetting() { field = "Mobile Number", fieldRequired = ddlMobile.SelectedValue.ToString(), minFieldlength = txtMinMobile.Text, maxFieldlength = txtMaxMobile.Text, KeyWord = ddlMobileKeyWord.SelectedValue });
            _fieldsetting.Add(new Fieldsetting() { field = "Realation Group", fieldRequired = ddlRealation.SelectedValue.ToString(), minFieldlength = "", maxFieldlength = "", KeyWord = "" });
            _fieldsetting.Add(new Fieldsetting() { field = "Transfer Reason", fieldRequired = ddlTransferReason.SelectedValue.ToString(), minFieldlength = "", maxFieldlength = "", KeyWord = "" });

            _fieldsetting.Add(new Fieldsetting() { field = "Bank Name", fieldRequired = ddlBank.SelectedValue.ToString(), minFieldlength = "0", maxFieldlength = "0", KeyWord = "" });
            _fieldsetting.Add(new Fieldsetting() { field = "Branch Name", fieldRequired = ddlBranch.SelectedValue.ToString(), minFieldlength = "0", maxFieldlength = "0", KeyWord = "" });
            _fieldsetting.Add(new Fieldsetting() { field = "Account No.", fieldRequired = ddlAccount.SelectedValue.ToString(), minFieldlength = txtMinAccount.Text, maxFieldlength = txtMaxAccount.Text, KeyWord = ddlAccountKeyWord.SelectedValue });

      _fieldsetting.Add(new Fieldsetting() { field = "Bank Account Type", fieldRequired = ddlBankAccountType.SelectedValue.ToString(), minFieldlength = "0", maxFieldlength = "0", KeyWord = "" });
      _fieldsetting.Add(new Fieldsetting() { field = "Bic Swift", fieldRequired = ddlBicSwift.SelectedValue.ToString(), minFieldlength = bicSwiftMin.Text, maxFieldlength = bicSwiftMax.Text, KeyWord = ddlBicSwiftKeyword.SelectedValue });
      _fieldsetting.Add(new Fieldsetting() { field = "Bank Routing Code", fieldRequired = ddlBankRoutingCode.SelectedValue.ToString(), minFieldlength = bankRoutingCodeMin.Text, maxFieldlength = bankRoutingCodeMax.Text, KeyWord = ddlBankRoutingCodeKeyword.SelectedValue });
      _fieldsetting.Add(new Fieldsetting() { field = "Beneficiary Zipcode", fieldRequired = ddlBeneZipCode.SelectedValue.ToString(), minFieldlength = beneZipCodeMin.Text, maxFieldlength = beneZipCodeMax.Text, KeyWord = ddlBeneZipCodeKeyword.SelectedValue });

      string xmldata = ObjectToXML(_fieldsetting);
            var Result = fsd.UpdateReceiverPageFieldSetup(GetStatic.GetUser(), xmldata, country.SelectedValue.ToString(), ddlServiceType.SelectedValue.ToString());
            GetStatic.PrintMessage(Page, Result);
            if (Result.ErrorCode == "0")
            {
                country.SelectedValue = null;
                ddlServiceType.SelectedValue = null;
                PopulateDeFaultData();
                PageFieldSetup.Visible = false;
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            sl.CheckAuthentication(DeleteFunctionId);
            var Result = fsd.DeleteReceiverPageFieldSetup(GetStatic.GetUser(), country.SelectedValue.ToString(), ddlServiceType.SelectedValue.ToString());
            GetStatic.PrintMessage(Page, Result);
            if (Result.ErrorCode == "0")
            {
                country.SelectedValue = null;
                ddlServiceType.SelectedValue = null;
                PopulateDeFaultData();
                PageFieldSetup.Visible = false;
            }
        }

        public string ObjectToXML(object input)
        {
            try
            {
                var stringwriter = new StringWriter();
                var serializer = new XmlSerializer(input.GetType());
                serializer.Serialize(stringwriter, input);
                return stringwriter.ToString();
            }
            catch (Exception ex)
            {
                if (ex.InnerException != null)
                    ex = ex.InnerException;
                return "Could not convert: " + ex.Message;
            }
        }

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            GetData();
        }

        protected void Local_SelectedIndexChanged(object sender, EventArgs e)
        {
            ShowHide();
        }

        protected void ServiceType_SelectedIndexChanged(object sender, EventArgs e)
        {
            GetData();
        }

        public void GetData()
        {
            PageFieldSetup.Visible = true;
            DataTable dt = fsd.Getdata(country.SelectedValue, ddlServiceType.SelectedValue);
            if (dt.Rows.Count > 0)
            {
                Populate(dt);
                ShowHide();
            }
            else
            {
                PopulateDeFaultData();
            }
        }

        public void PopulateDeFaultData()
        {
            ddlLocalName.SelectedValue = "H";
            txtMinLocalName.Text = "0";
            txtMaxLocalName.Text = "50";
            ddlLocalNameKeyword.SelectedValue = "AN";

            ddlFirstNameInlocal.SelectedValue = "H";
            txtMinLocalFirstName.Text = "1";
            txtMaxLocalFirstName.Text = "50";
            ddlLocalFirstNameKeyword.SelectedValue = "AN";

            ddlLastNameINLocal.SelectedValue = "H";
            txtMinLastNameINLocal.Text = "0";
            txtMaxLastNameINLocal.Text = "50";
            ddlLastNameINLocalKeyword.SelectedValue = "AN";

            ddMiddleNameInlocal.SelectedValue = "H";
            txtMinMiddleNameInlocal.Text = "0";
            txtMaxMiddleNameInlocal.Text = "50";
            ddlLocalMiddleNameKeyword.SelectedValue = "AN";

            ddlFullName.SelectedValue = "M";
            txtMinFullName.Text = "0";
            txtMaxFullName.Text = "50";
            ddlFullnameKeyword.SelectedValue = "AN";

            ddlFirstName.SelectedValue = "M";
            txtMinfistName.Text = "0";
            txtMaxFirstName.Text = "50";
            ddLFirstNameKeyWord.SelectedValue = "AN";

            dllMiddleName.SelectedValue = "M";
            txtMinMiddleName.Text = "0";
            txtMaxMiddleName.Text = "50";
            ddlMiddleNameKeyword.SelectedValue = "AN";

            ddlLastName.SelectedValue = "M";
            txtMinlastName.Text = "0";
            txtMaxlastName.Text = "50";
            ddlLatNameKeyWord.SelectedValue = "AN";

            ddlNativeCountry.SelectedValue = "M";
            ddlProvince.SelectedValue = "M";
            ddlState.SelectedValue = "M";

            ddlAddress.SelectedValue = "M";
            txtMinAdress.Text = "0";
            txtMaxAdress.Text = "50";
            ddlAddressKeyword.SelectedValue = "ANS";

            ddlCity.SelectedValue = "M";
            txtMinCity.Text = "0";
            txtMaxCity.Text = "50";
            ddlCityKeyword.SelectedValue = "AN";

            ddlIdType.SelectedValue = "M";

            ddlIdNumber.SelectedValue = "M";
            txtMinIdnumber.Text = "0";
            txtMaxIdnumber.Text = "50";
            ddlIdnumberKeyWord.SelectedValue = "N";

            ddlMobile.SelectedValue = "M";
            txtMinMobile.Text = "0";
            txtMaxMobile.Text = "15";
            ddlMobileKeyWord.SelectedValue = "N";

            ddlRealation.SelectedValue = "M";
            ddlTransferReason.SelectedValue = "M";

            ddlBank.SelectedValue = "H";

            ddlBranch.SelectedValue = "H";

            ddlAccount.SelectedValue = "M";
            txtMinAccount.Text = "0";
            txtMaxAccount.Text = "50";
            ddlAccountKeyWord.SelectedValue = "N";
      
      ddlBankAccountType.SelectedValue = "H";
      ddlBicSwift.SelectedValue = "H";
      bicSwiftMin.Text = "0";
      bicSwiftMax.Text = "20";
      ddlBicSwiftKeyword.SelectedValue = "N";

      ddlBankRoutingCode.SelectedValue = "H";
      bankRoutingCodeMin.Text = "0";
      bankRoutingCodeMax.Text = "20";
      ddlBankRoutingCodeKeyword.SelectedValue = "N";

      ShowHide();
        }

        public void ShowHide()
        {
            if (ddlLocalName.SelectedValue == "H")
            {
                LocalFirstName.Visible = false;
                LocalLastName.Visible = false;
                LocalMiddleName.Visible = false;
                txtMinLocalFirstName.Text = "0";
                txtMaxLocalFirstName.Text = "0";
                txtMaxLastNameINLocal.Text = "0";
                txtMinLastNameINLocal.Text = "0";
                ddlLastNameINLocalKeyword.SelectedValue = "AN";
                ddlLocalMiddleNameKeyword.SelectedValue = "AN";
                txtMaxMiddleNameInlocal.Text = "0";
                txtMinMiddleNameInlocal.Text = "0";
            }
            else
            {
                LocalFirstName.Visible = true;
                LocalLastName.Visible = true;
                LocalMiddleName.Visible = true;
            }
        }
    }
}