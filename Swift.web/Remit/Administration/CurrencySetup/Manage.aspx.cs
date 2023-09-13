using Swift.DAL.BL.Remit.Administration;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Data;
using System.Web.UI;

namespace Swift.web.Remit.Administration.CurrencySetup
{
    public partial class Manage : Page
    {
        private const string ViewFunctionId = "10111500";
        private const string AddEditFunctionId = "10111510";
        private readonly CurrencyDao obj = new CurrencyDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Authenticate();
                if (GetId() > 0)
                {
                    CurrencyCodeDiv.Visible = true;
                    pnl1.Visible = true;
                    PopulateDataById();
                }
                else
                {
                    //Your code goes here
                }
            }
        }

        #region Method

        protected long GetId()
        {
            return GetStatic.ReadNumericDataFromQueryString("currencyId");
        }

        protected string GetCurrCode()
        {
            return GetStatic.ReadQueryString("currencyCode", "");
        }

        protected string GetCurrencyCode()
        {
            return "Currency Code : " + GetStatic.ReadQueryString("currencyCode", "");
        }

        private void Authenticate()
        {
            sdd.CheckAuthentication(ViewFunctionId + "," + AddEditFunctionId);
            btnSumit.Visible = sdd.HasRight(AddEditFunctionId);
            //btnDelete.Visible = sdd.HasRight(DeleteFunctionId);
        }

        private void PopulateDataById()
        {
            DataRow dr = obj.SelectById(GetStatic.GetUser(), GetId().ToString());
            if (dr == null)
                return;

            currencyCode.Text = dr["currencyCode"].ToString();
            currencyName.Text = dr["currencyName"].ToString();
            currencyDesc.Text = dr["currencyDesc"].ToString();
            currencyDecimalName.Text = dr["currencyDecimalName"].ToString();
            countAfterDecimal.Text = dr["countAfterDecimal"].ToString();
            roundNoDecimal.Text = dr["roundNoDecimal"].ToString();
            isoNumeric.Text = dr["isoNumeric"].ToString();
            factor.Text = dr["factor"].ToString();
            rateMin.Text = dr["rateMin"].ToString();
            rateMax.Text = dr["rateMax"].ToString();
            DisableField();
        }

        private void DisableField()
        {
            currencyCode.Enabled = false;
            isoNumeric.Enabled = false;
        }

        private void Update()
        {
            DbResult dbResult = obj.Update(GetStatic.GetUser(), GetId().ToString(), currencyCode.Text, isoNumeric.Text, currencyName.Text,
                                           currencyDesc.Text, currencyDecimalName.Text, countAfterDecimal.Text,
                                           roundNoDecimal.Text, factor.Text, rateMin.Text, rateMax.Text);
            ManageMessage(dbResult);
        }

        private void DeleteRow()
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

        protected void btnSumit_Click(object sender, EventArgs e)
        {
            Update();
        }

        #endregion Element Method
    }
}