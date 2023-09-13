using Swift.DAL.BL.Remit.Administration.Customer;
using Swift.DAL.BL.Remit.Compliance;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.OFACManagement.ManualComplianceSetup
{
    public partial class Manage : System.Web.UI.Page
    {
        private complianceDao obj = new complianceDao();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly string ViewFunctionId = "20601400";
        private readonly SwiftDao _swiftDao = new SwiftDao();
        private CustomersDao cd = new CustomersDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                if (GetId() > 0)
                    PopulateDataById();
                else
                {
                    // GetStatic.CallJSFunction(this, "LoadCalender()");
                    PopulateDdl(null);
                }

                #region Ajax methods

                string reqMethod = Request.Form["MethodName"];
                switch (reqMethod)
                {
                    case "getdate":
                        GetDateADVsBS();
                        break;

                    case "idissuedplace":
                        GetIdIssuedPlace();
                        break;
                }

                #endregion Ajax methods

                // dob.Attributes.Add("onchange", "GetADVsBSDate('ad','dob')");
                // dobBs.Attributes.Add("onchange", "GetADVsBSDate('bs','dobBs')");
            }
        }

        private void GetIdIssuedPlace()
        {
            var IdType = Request.Form["IdType"];
            var dt = cd.LoadIdIssuedPlace(GetStatic.GetUser(), IdType);
            Response.ContentType = "text/plain";
            var json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }

        private void GetDateADVsBS()
        {
            var date = Request.Form["date"];
            var type = Request.Form["type"];
            type = (type == "ad") ? "e" : "bs";
            var dt = cd.LoadCalender(GetStatic.GetUser(), date, type);
            Response.ContentType = "text/plain";
            var json = DataTableToJSON(dt);
            Response.Write(json);
            Response.End();
        }

        public static string DataTableToJSON(DataTable table)
        {
            List<Dictionary<string, object>> list = new List<Dictionary<string, object>>();
            foreach (DataRow row in table.Rows)
            {
                Dictionary<string, object> dict = new Dictionary<string, object>();
                foreach (DataColumn col in table.Columns)
                {
                    dict[col.ColumnName] = row[col];
                }
                list.Add(dict);
            }
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            return serializer.Serialize(list);
        }

        private void PopulateDataById()
        {
            var dr = obj.GetComplianceById(GetId().ToString(), GetStatic.GetUser());
            GetStatic.CallJSFunction(this, "GetADVsBSDate('ad','dob')");
            if (dr["membershipId"] == null || dr["membershipId"].ToString() == "")
            {
                //GetStatic.CallJSFunction(this, "LoadCalender()");
                EnableFields(true);
            }
            else
            {
                EnableFields(false);
            }

            cardNo.Text = dr["membershipId"].ToString();
            name.Text = dr["Name"].ToString();
            address.Text = dr["Address"].ToString();
            IdNumber.Text = dr["IdNumber"].ToString();
            dob.Text = dr["Dob"].ToString();
            relativesName.Text = dr["FatherName"].ToString();
            remarks.Text = dr["Remarks"].ToString();
            isActive.Checked = dr["isActive"].ToString().Equals("Y");
            contact.Text = dr["contact"].ToString();
            entNum.Text = dr["entNum"].ToString();
            DataSource.Text = dr["dataSource"].ToString();
            vesselType.SelectedValue = dr["vesselType"].ToString();
            hddidPlaceIssue.Value = dr["idPlaceIssue"].ToString();

            hddIdType.Value = dr["idType1"].ToString();
            PopulateDdl(dr);
        }

        protected void save_Click(object sender, EventArgs e)
        {
            Update();
        }

        public long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rowId");
        }

        private void Update()
        {
            var dbResult = obj.Update1(GetId().ToString(), GetStatic.GetUser(), entNum.Text, vesselType.Text, cardNo.Text, name.Text, address.Text,
                    country.Text, Zone.SelectedItem.Text, District.Text, IdType.SelectedItem.Text, IdNumber.Text, dob.Text,
                    relativesName.Text, DataSource.Text, remarks.Text, isActive.Checked ? "Y" : "N", contact.Text, idPlaceIssue.SelectedValue);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            GetStatic.AlertMessage(Page, dbResult.Msg);
            if (dbResult.ErrorCode == "0")
                Response.Redirect("List.aspx");
            else
                GetStatic.PrintMessage(Page);
        }

        private void PopulateDdl(DataRow dr)
        {
            LoadCountry(ref country, "");
            // _sdd.SetDDL(ref country, "EXEC proc_countryMaster @flag = 'ocl'", "countryName",
            // "countryName", "", "All"); LoadState(ref Zone, "151", GetStatic.GetRowData(dr,
            // "state")); LoadDistrict(ref District, Zone.Text, GetStatic.GetRowData(dr, "district"));
            LoadIdType(ref IdType, GetStatic.GetRowData(dr, "IdType"));
            LoadIdIssuePlace(ref idPlaceIssue, GetStatic.GetRowData(dr, "idPlaceIssue"));
        }

        private void LoadCountry(ref DropDownList ddl, string defaultValue)
        {
            string sql = "EXEC Proc_dropdown_remit @flag='country'";

            _sdd.SetDDL3(ref ddl, sql, "countryId", "countryName", defaultValue, "Select");
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        protected void Back_Click(object sender, EventArgs e)
        {
            Response.Redirect("List.aspx");
        }

        private void LoadState(ref DropDownList ddl, string countryId, string defaultValue)
        {
            //string sql = "EXEC proc_countryStateMaster @flag = 'csl', @countryId = " + _sdd.FilterString(countryId);
            //_sdd.SetDDL3(ref ddl, sql, "stateId", "stateName", defaultValue, "Select");
            string sql = "exec proc_dropdown_remit @flag='filterState', @countryId = '" + country.SelectedValue + "'";
            _sdd.SetDDL3(ref ddl, sql, "stateId", "stateName", defaultValue, "select");
        }

        private void LoadDistrict(ref DropDownList ddl, string zone, string defaultValue)
        {
            string sql = "EXEC proc_zoneDistrictMap @flag = 'l', @zone = " + _sdd.FilterString(zone);
            _sdd.SetDDL3(ref ddl, sql, "districtName", "districtName", defaultValue, "Select");
        }

        private void LoadIdType(ref DropDownList ddl, string defaultValue)
        {
            string sql = "EXEC proc_countryIdType @flag = 'il', @countryId='113', @spFlag = '5201'";
            _sdd.SetDDL3(ref ddl, sql, "valueId", "detailTitle", defaultValue, "Select");
        }

        private void LoadIdIssuePlace(ref DropDownList ddl, string defaultValue)
        {
            var IdType = hddIdType.Value;
            string sql = "EXEC proc_IdIssuedPlace ";
            sql += " @user = '" + GetStatic.GetUser() + "'";
            sql += ", @idType = '" + IdType + "'";
            _sdd.SetDDL3(ref ddl, sql, "valueId", "detailTitle", defaultValue, "Select");
        }

        private void PopulateByMembershipId()
        {
            DataTable dt = obj.SelectByMemId(GetStatic.GetUser(), cardNo.Text.Trim());
            if (dt == null || dt.Rows.Count == 0)
            {
                GetStatic.AlertMessage(Page, "Invalid Membership ID.");
                return;
            }

            name.Text = dt.Rows[0]["fullName"].ToString();
            address.Text = dt.Rows[0]["address"].ToString();
            dob.Text = dt.Rows[0]["dobEng"].ToString();
            dobBs.Text = dt.Rows[0]["dobNep"].ToString();
            IdNumber.Text = dt.Rows[0]["citizenshipNo"].ToString();
            relativesName.Text = dt.Rows[0]["fatherName"].ToString();
            contact.Text = dt.Rows[0]["mobile"].ToString();
            country.Text = dt.Rows[0]["pCountry"].ToString();
            hddidPlaceIssue.Value = dt.Rows[0]["placeOfIssue"].ToString();

            LoadState(ref Zone, "151", dt.Rows[0]["pZone"].ToString());
            LoadDistrict(ref District, Zone.Text, dt.Rows[0]["pDistrict"].ToString());

            hddIdType.Value = dt.Rows[0]["idType1"].ToString().Split('|')[0];

            LoadIdType(ref IdType, dt.Rows[0]["idType"].ToString());
            LoadIdIssuePlace(ref idPlaceIssue, dt.Rows[0]["placeOfIssue"].ToString());
            EnableFields(false);
        }

        private void EnableFields(bool doEnable)
        {
            cardNo.ReadOnly = !doEnable;
            name.ReadOnly = !doEnable;
            address.ReadOnly = !doEnable;
            dob.ReadOnly = !doEnable;
            dobBs.ReadOnly = !doEnable;
            IdNumber.ReadOnly = !doEnable;
            relativesName.ReadOnly = !doEnable;
            contact.ReadOnly = !doEnable;
            country.Enabled = doEnable;
            Zone.Enabled = doEnable;
            District.Enabled = doEnable;
            IdType.Enabled = doEnable;
            idPlaceIssue.Enabled = doEnable;
        }

        private void DoClear()
        {
            name.Text = "";
            address.Text = "";
            dob.Text = "";
            dobBs.Text = "";
            IdNumber.Text = "";
            relativesName.Text = "";
            contact.Text = "";
            cardNo.Text = "";
            remarks.Text = "";
            DataSource.Text = "";
            PopulateDdl(null);
            cardNo.Focus();
            // GetStatic.CallJSFunction(this, "LoadCalender()");
        }

        protected void btnFind_Click(object sender, EventArgs e)
        {
            PopulateByMembershipId();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            EnableFields(true);
            DoClear();
        }

        protected void IdType_SelectedIndexChanged(object sender, EventArgs e)
        {
            // GetStatic.CallJSFunction(this, "LoadCalender()");

            if (!string.IsNullOrEmpty(IdType.Text))
                hddIdType.Value = IdType.Text;

            // LoadIdIssuePlace(ref idPlaceIssue, "");
        }

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadState(ref Zone, country.SelectedValue, "");
        }

        protected void Zone_SelectedIndexChanged(object sender, EventArgs e)
        {
            // GetStatic.CallJSFunction(this, "LoadCalender()");
            //if (!string.IsNullOrEmpty(Zone.Text))
            //    LoadDistrict(ref District, Zone.Text, "");
            //else
            //    District.Text = "";

            LoadDistrict(ref District, Zone.SelectedValue, "");
        }
    }
}