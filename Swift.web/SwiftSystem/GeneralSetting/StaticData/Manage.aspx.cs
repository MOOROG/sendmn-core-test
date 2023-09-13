using System;
using System.Data;
using System.Web.UI;
using Swift.DAL.BL.System.GeneralSettings;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;

namespace Swift.web.SwiftSystem.GeneralSetting.StaticData
{
    public partial class Manage : Page
    {
        //put your code to create dao object
        private const string ViewFunctionId = "10111000";
        private const string AddEditFunctionId = "10111010";
        private const string DeleteFunctionId = "10111020";
        private readonly StaticDataDao _obj = new StaticDataDao();
        private readonly StaticDataDdl _sl = new StaticDataDdl();

        protected long RowId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                typeID.Enabled = false;
                GetStatic.SetActiveMenu(ViewFunctionId);
                if (GetId() > 0)
                {
                    PopulateDataById();
                }
                else
                {
                    PopulateDdl(null);
                }
            }
        }

        #region Method

        protected string GetTypeTitle()
        {
            return "Type : " + _sl.GetTypeTitle(Id().ToString());
        }

        private static long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("valueId");
        }

        protected long Id()
        {
            return GetStatic.ReadNumericDataFromQueryString("Id");
        }

        private void Authenticate()
        {
            _sl.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId + "," + DeleteFunctionId);
            btnDelete.Visible = _sl.HasRight(DeleteFunctionId);
            btnSumit.Visible = _sl.HasRight(AddEditFunctionId);
        }

        private void PopulateDdl(DataRow dr)
        {
            _sl.SetDDL(ref typeID, "SELECT typeID,typeTitle FROM staticDataType WHERE typeID=" + Id() + "", "typeID",
                       "typeTitle", Id().ToString(), "");
        }

        private void PopulateDataById()
        {
            DataRow dr = _obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            detailTitle.Text = dr["detailTitle"].ToString();
            detailDesc.Text = dr["detailDesc"].ToString();
            ddlStatus.Text = dr["isActive"].ToString();
            PopulateDdl(dr);
        }

        private void Update()
        {
            DbResult dbResult = _obj.Update(GetStatic.GetUser(), GetId().ToString(), Id().ToString(), detailTitle.Text,
                                            detailDesc.Text, ddlStatus.Text);
            ManageMessage(dbResult);
        }

        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("StaticValueList.aspx?typeId=" + Id() + "");
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }
        #endregion

        #region Element Method

        protected void btnSumit_Click(object sender, EventArgs e)
        {
            Update();
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            _obj.Delete(GetStatic.GetUser(), GetId().ToString());
        }

        #endregion
    }
}