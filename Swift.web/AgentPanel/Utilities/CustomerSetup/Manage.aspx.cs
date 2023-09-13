using Swift.DAL.BL.AgentPanel.Administration.Customer;
using Swift.DAL.BL.AgentPanel.Send;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.Script.Serialization;

namespace Swift.web.AgentPanel.Utilities.CustomerSetup
{
    public partial class Manage : System.Web.UI.Page
    {
        private SendTranIRHDao st = new SendTranIRHDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "40132500";
        private const string AddEditFunctionId = "40132500";
        private readonly CustomerSetupDao cd = new CustomerSetupDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            string methodName = Request.Form["methodName"];
            Misc.DisableInput(ref txtCustIdValidDate);
            Misc.DisableInput(ref txtCustDOB);
            if (!IsPostBack)
            {
                //Authenticate();
                GetRequiredField();
                if (Convert.ToInt32(GetCustId()) > 0)
                {
                    LoadData();
                    hddId.Value = GetCustId();
                }
                else
                {
                    PopulateDdl(null);
                }

                if (methodName == "update")
                {
                    Update();
                }
                isMemberIssued.Attributes.Add("onclick", "return ShowHide(this);");
            }

            MakeNumericTextbox();
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
        }

        protected string GetCustId()
        {
            return Request.QueryString["customerId"];
        }

        private void GetRequiredField()
        {
            var dt = st.GetRequiredField(GetStatic.GetCountryId(), GetStatic.GetAgent());
            if (dt == null)
                return;
            var dr = dt.Tables[0].Rows[0];

            //Sender ID
            ddCustIdType_err.Visible = false;
            txtCustIdNo_err.Visible = false;
            switch (dr["id"].ToString())
            {
                case "H":
                    trCustId.Attributes.Add("style", "display: none;");
                    break;

                case "M":
                    ddCustIdType.Attributes.Add("Class", "required");
                    txtCustIdNo.Attributes.Add("Class", "required");
                    ddCustIdType_err.Visible = true;
                    txtCustIdNo_err.Visible = true;
                    break;
            }

            //Sender ID Expiry Date
            txtCustIdValidDate_err.Visible = false;
            switch (dr["iDValidDate"].ToString())
            {
                case "H":
                    tdCustExpDateLbl.Attributes.Add("style", "display: none;");
                    tdCustExpDateTxt.Attributes.Add("style", "display: none;");

                    //Sender DOB
                    txtCustDOB_err.Visible = false;
                    switch (dr["dob"].ToString())
                    {
                        case "H":
                            tdCustDobLbl.Attributes.Add("style", "display: none;");
                            tdCustDobTxt.Attributes.Add("style", "display: none;");
                            break;

                        case "M":
                            lblcDOB.Visible = true;
                            txtCustDOB.Attributes.Add("Class", "required");
                            txtCustDOB_err.Visible = true;
                            break;
                    }
                    break;

                case "M":
                    txtCustIdValidDate.Attributes.Add("Class", "required");
                    txtCustIdValidDate_err.Visible = true;

                    //Sender DOB
                    txtCustDOB_err.Visible = false;
                    switch (dr["dob"].ToString())
                    {
                        case "H":
                            tdCustDobLbl.Attributes.Add("style", "display: none;");
                            tdCustDobTxt.Attributes.Add("style", "display: none;");
                            break;

                        case "M":
                            lblcDOB.Visible = true;
                            txtCustDOB.Attributes.Add("Class", "required");
                            txtCustDOB_err.Visible = true;
                            break;
                    }
                    break;

                default:
                    //Sender DOB
                    txtCustDOB_err.Visible = false;
                    switch (dr["dob"].ToString())
                    {
                        case "H":
                            tdCustDobLbl.Attributes.Add("style", "display: none;");
                            tdCustDobTxt.Attributes.Add("style", "display: none;");
                            break;

                        case "M":
                            lblcDOB.Visible = true;
                            txtCustDOB.Attributes.Add("Class", "required");
                            txtCustDOB_err.Visible = true;
                            break;
                    }
                    break;
            }

            //Sender Mobile
            txtCustMobile_err.Visible = false;
            switch (dr["contact"].ToString())
            {
                case "H":
                    trCustContactNo.Attributes.Add("style", "display: none;");
                    break;

                case "M":
                    txtCustMobile.Attributes.Add("Class", "required");
                    txtCustMobile_err.Visible = true;
                    break;
            }

            //Sender City
            txtCustCity_err.Visible = false;
            switch (dr["city"].ToString())
            {
                case "H":
                    tdCustCityLbl.Attributes.Add("style", "display: none;");
                    tdCustCityTxt.Attributes.Add("style", "display: none;");
                    break;

                case "M":
                    lblcCity.Visible = true;
                    txtCustCity.Attributes.Add("Class", "required");
                    txtCustCity_err.Visible = true;
                    break;
            }

            //Sender Address1
            txtCustAdd1_err.Visible = false;
            switch (dr["address"].ToString())
            {
                case "H":
                    trCustAddress1.Attributes.Add("style", "display: none;");
                    trCustAddress2.Attributes.Add("style", "display: none;");
                    break;

                case "M":
                    txtCustAdd1.Attributes.Add("class", "required");
                    txtCustAdd1_err.Visible = true;
                    break;
            }

            occupation_err.Visible = false;
            switch (dr["occupation"].ToString())
            {
                case "H":
                    trOccupation.Attributes.Add("style", "display: none;");
                    break;

                case "M":
                    lblOccupation.Visible = true;
                    occupation.Attributes.Add("Class", "required");
                    occupation_err.Visible = true;
                    break;
            }

            companyName_err.Visible = false;
            switch (dr["company"].ToString())
            {
                case "H":
                    trCustCompany.Attributes.Add("style", "display: none;");
                    break;

                case "M":
                    companyName.Attributes.Add("Class", "required");
                    lblCompName.Visible = true;
                    companyName_err.Visible = true;
                    break;
            }

            //Sender Salary
            ddlSalary_err.Visible = false;
            switch (dr["salaryRange"].ToString())
            {
                case "M":
                    lblSalaryRange.Visible = true;
                    ddlSalary.Attributes.Add("Class", "required");
                    ddlSalary_err.Visible = true;
                    break;

                case "H":
                    ddlSalary.Attributes.Add("Class", "HideControl");
                    lblSalaryRange.Visible = false;
                    break;
            }
        }

        private void PopulateDdl(DataRow dr)
        {
            _sdd.SetGenderDDL(ref ddlCustGender, GetStatic.GetRowData(dr, "gender"), "Select");
            _sdd.SetDDL(ref ddCustIdType, "exec proc_sendPageLoadData @flag='idTypeBySCountry',@countryId='" + GetStatic.GetCountryId() + "'", "valueId", "detailTitle", GetStatic.GetRowData(dr, "idType1"), "Select");
            _sdd.SetDDL(ref txtCustNativeCountry, "EXEC proc_dropDownLists @flag='country'", "countryId", "countryName", GetStatic.GetRowData(dr, "nativeCountry"), "Select");
            _sdd.SetStaticDdl(ref ddlSalary, "8100", GetStatic.GetRowData(dr, "salaryRange"), "Select");
            _sdd.SetDDL(ref occupation, "exec proc_sendPageLoadData @flag='loadOccupation'", "occupationId", "detailTitle", GetStatic.GetRowData(dr, "occupation"), "Select");
        }

        protected void Update()
        {
            string firstName = Request.Form["firstName"];
            string middleName = Request.Form["middleName"];
            string lastName = Request.Form["lastName"];
            string lastName1 = Request.Form["secondLastName"];
            string idType = Request.Form["idType"];
            string idNo = Request.Form["idNo"];
            string validDate = Request.Form["validDate"];
            string dob = Request.Form["dob"];
            string telNo = Request.Form["telNo"];
            string mobile = Request.Form["mobile"];
            string city = Request.Form["city"];
            string postalCode = Request.Form["postalCode"];
            string companyName = Request.Form["companyName"];
            string address1 = Request.Form["address1"];
            string address2 = Request.Form["address2"];
            string nativeCountry = Request.Form["nativeCountry"];
            string email = Request.Form["email"];
            string gender = Request.Form["gender"];
            string salary = Request.Form["salary"];
            string memberId = Request.Form["memberId"];
            string occupation = Request.Form["occupation"];
            string id = Request.Form["id"];

            var isMemberIssue = Request.Form["imi"];

            DataTable dt = new DataTable();
            if (isMemberIssue == "Y" && string.IsNullOrWhiteSpace(memberId))
            {
                dt.Columns.Add("erroCode");
                dt.Columns.Add("msg");
                dt.Columns.Add("id");

                DataRow row = dt.NewRow();
                row[0] = "1";
                row[1] = "Member Id should not be blank";
                row[2] = "";
                dt.Rows.Add(row);
            }
            else
            {
                dt = cd.Update(GetStatic.GetUser(), id, firstName, middleName, lastName, lastName1, GetStatic.GetCountryId(), idType, idNo, validDate, dob, telNo, mobile, city, postalCode,
                companyName, address1, address2, nativeCountry, email, gender, salary, memberId, occupation, isMemberIssue, GetStatic.GetAgent(), GetStatic.GetBranch());
            }
            Response.ContentType = "text/plain";
            var json = DataTableToJson(dt);
            Response.Write(json);
            Response.End();
        }

        protected void MakeNumericTextbox()
        {
            Misc.MakeNumericTextbox(ref txtCustTel);
            Misc.MakeNumericTextbox(ref txtCustMobile);
        }

        public static string DataTableToJson(DataTable table)
        {
            if (table == null)
                return "";
            var list = new List<Dictionary<string, object>>();

            foreach (DataRow row in table.Rows)
            {
                var dict = new Dictionary<string, object>();

                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = string.IsNullOrEmpty(row[col].ToString()) ? "" : row[col];
                }
                list.Add(dict);
            }
            var serializer = new JavaScriptSerializer();
            return serializer.Serialize(list);
        }

        protected void LoadData()
        {
            var dr = cd.SelectById(GetStatic.GetUser(), GetCustId());
            if (dr == null)
                return;
            txtCustFirstName.Text = dr["firstName"].ToString();
            txtCustMidName.Text = dr["middleName"].ToString();
            txtCustLastName.Text = dr["lastName1"].ToString();
            txtCustSecondLastName.Text = dr["lastName2"].ToString();
            txtCustIdNo.Text = dr["idNumber"].ToString();
            txtCustIdValidDate.Text = dr["idExpiryDate"].ToString();
            txtCustDOB.Text = dr["dob"].ToString();
            txtCustTel.Text = dr["telNo"].ToString();
            txtCustMobile.Text = dr["mobile"].ToString();
            txtCustCity.Text = dr["city"].ToString();
            txtCustPostal.Text = dr["postalCode"].ToString();
            companyName.Text = dr["companyName"].ToString();
            txtCustAdd1.Text = dr["address"].ToString();
            txtCustAdd2.Text = dr["address2"].ToString();
            txtCustEmail.Text = dr["email"].ToString();
            memberId.Text = dr["memberShipId"].ToString();

            if (!string.IsNullOrWhiteSpace(dr["memberShipId"].ToString()))
            {
                lblMem.Attributes.CssStyle.Add("display", "block");
                txtMem.Attributes.CssStyle.Add("display", "block");
                memberId.ReadOnly = true;
                isMemberIssued.Visible = false;
                isMemberIssued.Checked = false;
            }
            else
            {
                memberId.ReadOnly = false;
                lblMem.Attributes.CssStyle.Add("display", "none");
                txtMem.Attributes.CssStyle.Add("display", "none");
                isMemberIssued.Visible = true;
                isMemberIssued.Checked = false;
            }

            PopulateDdl(dr);
            custIdImg.Visible = true;
            dr = cd.GetCustImageFileName(GetStatic.GetUser(), GetCustId());
            SetCustIdImage(dr);
        }

        protected void SetCustIdImage(DataRow dr)
        {
            var imgPath = "";
            if (dr != null)
            {
                var custId = dr["customerId"].ToString() == null ? "0" : dr["customerId"].ToString();
                var fileName = dr["fileName"].ToString();

                var filePath = GetStatic.GetAppRoot() + "\\doc\\" + fileName;

                if (File.Exists(filePath))
                    imgPath = GetStatic.GetUrlRoot() + "/doc/" + fileName;
                else
                    imgPath = GetStatic.GetUrlRoot() + "/Images/na.gif";
            }
            else
                imgPath = GetStatic.GetUrlRoot() + "/Images/na.gif";

            custIdImg.InnerHtml = "<div style=\"float:left;width:170px;\">Customer Id Image: </div> <img alt = \"Customer Identity\" title = \"Click to Add Document\" onclick = \"ViewImage(" + GetCustId() + ",'N');\" style=\"height:50px;width:50px;margin-left:10px; margin-bottom:10px;\" src=\"" + imgPath + "\" />";

            upladImage.InnerHtml = "<input type=\"button\" id=\"idimgUpload\" value=\"Upload Id Image\" onclick = \"ViewImage(" + GetCustId() + ");\" />";
        }
    }
}