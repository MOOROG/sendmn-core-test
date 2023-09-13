using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Swift.web.Library;
using Swift.DAL.SwiftDAL;
using Swift.DAL.RiskBasedAssessment;
using Swift.web.Component.Grid;
using System.Data;

namespace Swift.web.RiskBasedAssessment
{
    public partial class PeriodicRiskAssessment : Page
    {
        private string ViewFunctionId = "2022000";
        private string AddEditFunctionId = "2022010";
        private readonly RemittanceLibrary _sdd = new RemittanceLibrary();
        RiskBasedAssessmentDao _rbaDao = new RiskBasedAssessmentDao();
        public string criteriaID;
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            criteriaID = Request.QueryString["criteriaId"];
            if (!IsPostBack)
            {
                
                PopulateDDL();
                
                if (criteriaID != "" && criteriaID != null)
                {
                    populateCriteria(criteriaID);
                }
            }
            
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        private void PopulateDDL()
        {
            _sdd.SetDDL(ref Criteria, "EXEC	proc_dropDownLists2 @FLAG='pcriteria'", "value", "text", "", "");
            _sdd.SetDDL(ref Condition, "EXEC proc_dropDownLists2 @FLAG='condition'", "value", "text", "", "");

        }
        
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (Validation())
            {
                Save();
            }
            else
            {
                GetStatic.AlertMessage(Page);
            }
           
        }
        private void Save()
        {
            string criteria = Criteria.SelectedValue.ToString();
            string condition = Condition.SelectedValue.ToString();
            string minValue = MinValue.Text.ToString();
            string maxValue = MaxValue.Text.ToString();
            string result = Result.Text.ToString();
            string weight = Weight.Text.ToString();
            string user = GetStatic.GetUser();
            string flag;
            if (criteriaID!="" && criteriaID != null)
            {
                flag = "u";
            }
            else
            {
                flag = "i";
            }
             
            DbResult dbResult = _rbaDao.SaveRiskAssessment(flag, criteriaID, criteria, condition, minValue, maxValue, result, weight, user);
            ManageMessage(dbResult);


        }
        private bool Validation()
        {
            if (Criteria.SelectedValue.ToString() == "")
            {
                GetStatic.AlertMessage(this, "Please select valid Criteria! ");
                Criteria.Focus();
                return false;
            }
            if (Condition.SelectedValue.ToString() == "")
            {
                GetStatic.AlertMessage(this, "Please select valid Condition! ");
                Condition.Focus();
                return false;
            }
            if (string.IsNullOrEmpty(MinValue.Text) == true)
            {
                GetStatic.AlertMessage(this, "Please enter valid Min Value! ");
                MinValue.Focus();
                return false;
            }
            if (string.IsNullOrEmpty(MaxValue.Text)==true)
            {
                GetStatic.AlertMessage(this, "Please enter valid Max Value! ");
                MaxValue.Focus();
                return false;
            }
            if (GetStatic.ParseDouble(MinValue.Text)> GetStatic.ParseDouble(MaxValue.Text))
            {
                GetStatic.AlertMessage(this, "Max Value must be Greater Than Min Value! ");
                MaxValue.Focus();
                return false;
            }
            if (GetStatic.ParseDouble(Result.Text) <= 0)
            {
                GetStatic.AlertMessage(this, "Please enter valid Result! ");
                Result.Text = "";
                Result.Focus();
                return false;
            }
            if (GetStatic.ParseDouble(Weight.Text) <= 0)
            {
                GetStatic.AlertMessage(this, "Please enter valid Weight! ");
                Weight.Text = "";
                Weight.Focus();
                return false;
            }
            return true;
        }
        private void populateCriteria(string criteriaID)
        {
            DataTable dt = _rbaDao.GetRiskAssessment("s", criteriaID);
            Criteria.SelectedValue=dt.Rows[0]["Criteria"].ToString();
            Condition.SelectedValue=dt.Rows[0]["Condition"].ToString();
            MinValue.Text=dt.Rows[0]["CriteriaDetail"].ToString();
            MaxValue.Text = dt.Rows[0]["CriteriaDetail2"].ToString();
            Result.Text = dt.Rows[0]["Result"].ToString();
            Weight.Text = dt.Rows[0]["Weight"].ToString();


        }
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                Response.Redirect("List.aspx?Id=" + Criteria.SelectedValue.ToString() + "&condition=" + Condition.SelectedValue.ToString());
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

    }
}