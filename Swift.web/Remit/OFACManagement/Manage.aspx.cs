using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System.Data;
using Swift.DAL.BL.Remit.OFACManagement;

namespace Swift.web.Remit.OFACManagement
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "20198001";
        private const string AddEditFunctionId = "20198101";
        private const string DeleteFunctionId = "20198201";
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private readonly OFACManagementDao obj = new OFACManagementDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            if(!IsPostBack)
            {
                Authenticate();
                if (GetOfacId() > 0)
                    PopulateDataById();
                else  
                   PopulateDdl(null);
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
            bntSubmit.Visible = _sdd.HasRight(AddEditFunctionId);
        }
        protected long GetOfacId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rowId");
        }

        private void PopulateDdl(DataRow dr)
        {
            LoadCountry(ref Country, GetStatic.GetRowData(dr, "Country"));
        }
        private void LoadCountry(ref DropDownList ddl, string defaultValue)
        {
            string sql = "EXEC proc_countryMaster @flag = 'l'";

            _sdd.SetDDL(ref ddl, sql, "countryName", "countryName", defaultValue, "Select");
        }
        protected void bntSubmit_Click(object sender, EventArgs e)
        {
            Update();

        }
        private void Update()
        {
                DbResult dbResult = obj.Update(GetStatic.GetUser()
                                                , GetOfacId().ToString()
                                                , entNum.Text
                                                , Name.Text
                                                , vesselType.SelectedValue
                                                , Address.Text
                                                , City.Text
                                                , State.Text 
                                                , Zip.Text
                                                , Country.SelectedItem.Text
                                                , Remarks.Text
                                                , DataSource.Text
                                                );
                lblMsg.Text = dbResult.Msg;
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


        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetOfacId().ToString());
            if (dr == null)
                return;
            entNum.Text = dr["entNum"].ToString();
            Name.Text = dr["name"].ToString();
            vesselType.SelectedValue = dr["vesselType"].ToString();
            Address.Text = dr["address"].ToString();
            City.Text = dr["city"].ToString();
            State.Text = dr["state"].ToString();
            Zip.Text = dr["zip"].ToString();
          
            Remarks.Text = dr["remarks"].ToString();
            DataSource.Text = dr["dataSource"].ToString();
            PopulateDdl(dr);
        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            Response.Redirect("List.aspx");
        }
    }
}