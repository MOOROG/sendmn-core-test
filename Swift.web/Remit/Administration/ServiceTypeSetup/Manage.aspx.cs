using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.Administration.ServiceTypeSetup
{
    public partial class Manage : Page
    {
        //put your code to create dao object
        private const string ViewFunctionId = "10111600";

        private const string AddEditFunctionId = "10111610";
        private const string DeleteFunctionId = "10111620";
        private readonly ServiceTypeDao obj = new ServiceTypeDao();
        private readonly RemittanceLibrary swiftLibrary = new RemittanceLibrary();

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
                    //Your code goes here
                }
            }
        }

        #region Method

        private long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("serviceTypeId");
        }

        private void Authenticate()
        {
            swiftLibrary.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            //btnDelete.Visible = swiftLibrary.HasRight(DeleteFunctionId);
            bntSubmit.Visible = swiftLibrary.HasRight(AddEditFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;
            serviceCode.Text = dr["serviceCode"].ToString();
            typeTitle.Text = dr["typeTitle"].ToString();
            typeDesc.Text = dr["typeDesc"].ToString();
            isActive.Text = dr["isActive"].ToString();

            DisableField();
        }

        private void DisableField()
        {
            typeTitle.Enabled = false;
            serviceCode.Enabled = false;
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), GetId().ToString(), serviceCode.Text, typeTitle.Text,
                                           typeDesc.Text, isActive.Text);
            ManageMessage(dbResult);
        }

        private void Delete()
        {
            DbResult dbResult = obj.Delete(GetStatic.GetUser(), GetId().ToString());
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

        #region Element Method

        protected void bntSubmit_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            Delete();
        }

        protected void btnBack_Click(object sender, EventArgs e)
        {
            Response.Redirect("List.aspx");
        }

        #endregion Element Method
    }
}