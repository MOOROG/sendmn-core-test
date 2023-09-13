using System;
using Swift.web.Library;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.web.SwiftSystem.GeneralSetting.FieldSetting
{
    public partial class Send : System.Web.UI.Page
    {
        readonly RemittanceLibrary sl = new RemittanceLibrary();
        readonly FieldSettingDao fsd = new FieldSettingDao();
        private const string ViewFunctionId = "10112100";
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            if (!IsPostBack)
            {
                populateDdl();
                if (GetId() > 0)
                {
                    Populate();
                }
            }
        }

        private void populateDdl()
        {
            sl.SetDDL(ref country, "EXEC proc_dropDownLists2 @flag = 'countrySend'", "countryId", "countryName", "", "Select");
            sl.SetDDL(ref copyToCountry, "EXEC proc_dropDownLists2 @flag = 'countrySend'", "countryId", "countryName", "", "Select");
        }

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("rowId");
        }

        private void Authenticate()
        {
            sl.CheckAuthentication(ViewFunctionId);
        }

        protected void Populate()
        {
            DataRow dr = fsd.SelectById(GetStatic.GetUser(), GetId().ToString(), "Send");
            if (dr == null)
                return;
            copyPanel.Visible = true;
            country.SelectedValue = dr["countryId"].ToString();
            sl.SetDDL(ref agent, "EXEC proc_dropDownLists2 @flag = 'agentSend',@param=" + sl.FilterString(dr["countryId"].ToString()) + "", "agentId", "agentName", "", "All");
            agent.SelectedValue = dr["agentId"].ToString();

            ddlCustomerReg.Text = dr["customerRegistration"].ToString();
            ddlNewCustomer.Text = dr["newCustomer"].ToString();
            ddlCollection.Text = dr["collection"].ToString();
            ddlId.Text = dr["id"].ToString();
            ddlIdIssueDate.Text = dr["idIssueDate"].ToString();
            ddlIdValidDate.Text = dr["iDValidDate"].ToString();
            ddlDob.Text = dr["dOB"].ToString();
            ddlAddress.Text = dr["address"].ToString();
            ddlCity.Text = dr["city"].ToString();
            ddlContact.Text = dr["contact"].ToString();
            ddlOccupation.Text = dr["occupation"].ToString();
            ddlCompany.Text = dr["company"].ToString();
            ddlSalRange.Text = dr["salaryRange"].ToString();
            ddlPurpose.Text = dr["purposeofRemittance"].ToString();
            ddlSource.Text = dr["sourceofFund"].ToString();
            nativeCountry.Text = dr["nativeCountry"].ToString();
            tXNHistory.Text = dr["tXNHistory"].ToString();
            ddlRevId.Text = dr["rId"].ToString();
            ddlPlace.Text = dr["rPlaceOfIssue"].ToString();
            ddlRevAdd.Text = dr["raddress"].ToString();
            ddlRevCity.Text = dr["rcity"].ToString();
            ddlRevContact.Text = dr["rContact"].ToString();
            ddlRelationship.Text = dr["rRelationShip"].ToString();
            rDOB.Text = dr["rDOB"].ToString();
            rIdValidDate.Text = dr["rIdValidDate"].ToString();
            
        }

        protected void Upadate()
        {
            DbResult dbResult = fsd.Update(GetStatic.GetUser(), GetId().ToString(), country.Text, agent.Text, ddlCustomerReg.Text,ddlNewCustomer.Text,
                            ddlCollection.Text,ddlId.Text, ddlIdIssueDate.Text,ddlIdValidDate.Text,ddlDob.Text,ddlAddress.Text,ddlCity.Text,ddlContact.Text, ddlOccupation.Text,ddlCompany.Text,
                            ddlSalRange.Text,ddlPurpose.Text,ddlSource.Text,ddlRevId.Text,ddlPlace.Text,ddlRevAdd.Text, ddlRevCity.Text, ddlRevContact.Text,ddlRelationship.Text,
                            rDOB.Text, rIdValidDate.Text, nativeCountry.Text, tXNHistory.Text,"Send");
            ManageMessage(dbResult);
        }

        private void  CopySetting()
        {
            DbResult dbResult = fsd.CopySetting(GetStatic.GetUser(), "", copyToCountry.Text, copyToagent.Text, ddlCustomerReg.Text, ddlNewCustomer.Text,
                         ddlCollection.Text, ddlId.Text, ddlIdIssueDate.Text, ddlIdValidDate.Text, ddlDob.Text, ddlAddress.Text, ddlCity.Text, ddlContact.Text, ddlOccupation.Text, ddlCompany.Text,
                         ddlSalRange.Text, ddlPurpose.Text, ddlSource.Text, ddlRevId.Text, ddlPlace.Text, ddlRevAdd.Text, ddlRevCity.Text, ddlRevContact.Text, ddlRelationship.Text,
                         rDOB.Text, rIdValidDate.Text, nativeCountry.Text, tXNHistory.Text, "Send");
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx");
            }

            GetStatic.PrintMessage(Page, dbResult);

        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            Upadate();
        }

        protected void country_SelectedIndexChanged(object sender, EventArgs e)
        {
            if(country.Text!="")
                sl.SetDDL(ref agent, "EXEC proc_dropDownLists2 @flag = 'agentSend',@param="+sl.FilterString(country.Text)+"", "agentId", "agentName", "", "All");
        }


        protected void copySetting_Click(object sender, EventArgs e)
        {
            CopySetting();
        }

        protected void copyToCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (copyToCountry.Text != "")
                sl.SetDDL(ref copyToagent, "EXEC proc_dropDownLists2 @flag = 'agentSend',@param=" + sl.FilterString(copyToCountry.Text) + "", "agentId", "agentName", "", "All");
        }
    }
}