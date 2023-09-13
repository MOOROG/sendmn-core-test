using Swift.DAL.Remittance.CustomerReceivers;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.AddCutomer_sReceiver
{
    public partial class Manage : System.Web.UI.Page
    {
        private const string ViewFunctionId = "2019300";
        private readonly RemittanceLibrary remLibrary = new RemittanceLibrary();
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        ReceiveCustomerDao rdao = new ReceiveCustomerDao();



        protected void Page_Load(object sender, EventArgs e)
        {
            // Authenticate();
            if (!IsPostBack)
            {
                PopulateDdl(null);
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
            }
        }

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("receiverId");
        }

        private void PopulateDataById()
        {
            DataRow dr = rdao.SelectById(GetId().ToString());
            LoadState(ref rState, dr["countryId"].ToString(), "");
            if (dr == null)
                return;
            hfdReceiverId.Value = dr["receiverId"].ToString();
            customerId.Value = dr["customerId"].ToString();
            customerId.Text = dr["customerName"].ToString();
            rFirstName.Text = dr["firstName"].ToString();
            rCity.Text = dr["city"].ToString();
            RAddress.Text = dr["address"].ToString();
            rState.SelectedValue= dr["state"].ToString();
            receiverrelation.SelectedValue = dr["valueId"].ToString();
            rTelephone.Text = dr["homePhone"].ToString();
            receiverMobile.Text = dr["mobile"].ToString();
            receiverEmail.Text = dr["email"].ToString();
            receiveCountry.SelectedValue = dr["countryId"].ToString();
        }
        private void Authenticate()
        {
            remLibrary.CheckAuthentication(ViewFunctionId);
        }
        private void PopulateDdl(DataRow dr)
        {
            LoadCountry(ref receiveCountry, "");
            _sdd.SetStaticDdl(ref receiverrelation, "2100", "", "Select");
        }
        private void LoadCountry(ref DropDownList ddl, string defaultValue)
        {
            string sql = "EXEC Proc_dropdown_remit @flag='country'";

            _sdd.SetDDL3(ref ddl, sql, "countryId", "countryName", defaultValue, "Select");
        }
        protected void receiveCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadState(ref rState, receiveCountry.SelectedValue, "");
        }

        private void LoadState(ref DropDownList ddl, string countryId, string defaultValue)
        {
            string sql = "exec proc_dropdown_remit @flag='filterState', @countryId = '" + countryId + "'";
            _sdd.SetDDL3(ref ddl, sql, "stateId", "stateName", defaultValue, "select");
        }

        protected void save_Click(object sender, EventArgs e)
        {
            ReceiverModel receiverModel = new ReceiverModel();
            GetReceiverDetailInfo(ref receiverModel);

            var result = rdao.Update(receiverModel,GetId().ToString());
            GetStatic.SetMessage(result);
            if (result.ErrorCode != "0")
            {
                GetStatic.PrintMessage(this);
                return;
            }
            Response.Redirect("List.aspx");
        }

        protected void back_Click(object sender, EventArgs e)
        {

        }

        protected void GetReceiverDetailInfo(ref ReceiverModel receiverModel)
        {
            if (!string.IsNullOrWhiteSpace(hfdReceiverId.Value))
            {
                receiverModel.ReceiverId = Convert.ToInt64(hfdReceiverId.Value);
            }
            receiverModel.CustomerId = Convert.ToInt64(customerId.Value);
            receiverModel.FirstName = rFirstName.Text;
            receiverModel.City = rCity.Text;
            receiverModel.Address = RAddress.Text;
            receiverModel.State = rState.SelectedItem.Text;
            receiverModel.Relation = receiverrelation.SelectedItem.Text;
            receiverModel.TelephoneNo = rTelephone.Text;
            receiverModel.MobileNo = receiverMobile.Text;
            receiverModel.Email = receiverEmail.Text;
            receiverModel.Country = receiveCountry.SelectedItem.Text;
        }
    }
}