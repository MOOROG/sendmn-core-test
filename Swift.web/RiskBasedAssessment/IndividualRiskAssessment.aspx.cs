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
    public partial class IndividualRiskAssessment : Page
    {
        private string ViewFunctionId = "2022000";
        private string AddEditFunctionId = "2022010";
        private readonly RemittanceLibrary _sdd = new RemittanceLibrary();
        RiskBasedAssessmentDao _rbaDao = new RiskBasedAssessmentDao();
        public string criteriaID;
        public string del;
        protected void Page_Load(object sender, EventArgs e)
        {
            Authenticate();
            criteriaID = Request.QueryString["criteriaId"];
            del = Request.QueryString["del"];
            if (del == "Y")
            {
                DeleteRow(criteriaID);
                return;
            }
            if (!IsPostBack)
            {
                
                CriteriaDetail.Visible = false;
                PopulateDDL();
                if (criteriaID != "" && criteriaID!=null)
                {
                    populateCriteria(criteriaID);
                }
            }
            
            
            
            
        }
        private void DeleteRow(string ID)
        {
            if (ID == "")
                return;

            DbResult dbResult = _rbaDao.DeleteRow("d", ID, GetStatic.GetUser());
            ManageMessage(dbResult);
        }
        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }
        private void populateCriteria(string criteriaID)
        {
            DataTable dt=_rbaDao.GetRiskAssessment("s", criteriaID);

            if(dt.Rows[0]["detailDesc"].ToString()=="P")
            {
                Response.Redirect("PeriodicRiskAssessment.aspx?criteriaId=" + criteriaID);
                return;
            }
            Criteria.SelectedValue=dt.Rows[0]["Criteria"].ToString();
            Condition.SelectedValue=dt.Rows[0]["Condition"].ToString();
            CriteriaDetail.Text = "";
            if (dt.Rows[0]["IsCountry"].ToString() == "Country")
            {
                CriteriaCountry.Visible = true;
                CriteriaDetail.Visible = false;
                CriteriaCountry.SelectedValue=dt.Rows[0]["CriteriaDetail"].ToString();
            }
            else
            {
                CriteriaCountry.Visible = false;
                CriteriaDetail.Visible = true;
                CriteriaDetail.Text = dt.Rows[0]["CriteriaDetail"].ToString();
            }
            
            Result.Text = dt.Rows[0]["Result"].ToString();
            Weight.Text = dt.Rows[0]["Weight"].ToString();
            

        }
        
        private void PopulateDDL()
        {
            _sdd.SetDDL(ref Criteria, "EXEC proc_dropDownLists2 @FLAG='criteria'", "value", "text", "", "");
            _sdd.SetDDL(ref Condition, "EXEC proc_dropDownLists2 @FLAG='condition'", "value", "text", "", "");
            _sdd.SetDDL(ref CriteriaCountry, "EXEC proc_dropDownLists2 @FLAG='criteriaCountry'", "value", "text", "", "");
            

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
            string criteriaDetail = CriteriaDetail.Text.ToString();
            string criteriaCountry = CriteriaCountry.SelectedValue.ToString();
            string result = Result.Text.ToString();
            string weight = Weight.Text.ToString();
            string user = GetStatic.GetUser();
            string flag;
            if (criteriaID != "" && criteriaID != null)
            {
                flag = "u";
            }
            else
            {
                flag = "i";
            }
            string strcriteria = string.Empty;
            if (criteriaDetail != "")
                strcriteria = criteriaDetail;
            else
                strcriteria= criteriaCountry;

            DbResult dbResult = _rbaDao.SaveRiskAssessment(flag, criteriaID, criteria, condition, strcriteria,null, result, weight, user);
            ManageMessage(dbResult);
            



        }
        private  bool Validation()
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
            if (Criteria.SelectedValue.ToString() == "11018" || Criteria.SelectedValue.ToString() == "11021"
                || Criteria.SelectedValue.ToString() == "11034" || Criteria.SelectedValue.ToString() == "11035"
                )
            {

                if (CriteriaCountry.SelectedValue.ToString() == "")
                {
                    GetStatic.AlertMessage(this, "Please enter valid Criteria! ");
                    CriteriaCountry.Focus();
                    return false;
                }
            }
            else
            {
                if (CriteriaDetail.Text.ToString() == "")
                {
                    GetStatic.AlertMessage(this, "Please enter valid Criteria! ");
                    CriteriaDetail.Focus();
                    return false;
                }
            }
            
            if (GetStatic.ParseDouble(Result.Text) <= 0)
            {
                GetStatic.AlertMessage(this, "Please enter valid Value! ");
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
        private void ManageMessage(DbResult dbResult)
        {
            GetStatic.SetMessage(dbResult);
            if (dbResult.ErrorCode == "0")
            {
                if(del=="Y")
                Response.Redirect("List.aspx");
                else
                Response.Redirect("List.aspx?Id=" + Criteria.SelectedValue.ToString() + "&condition=" + Condition.SelectedValue.ToString());
            }
            else
            {
                GetStatic.PrintMessage(Page);
            }
        }

        protected void Criteria_SelectedIndexChanged(object sender, EventArgs e)
        {
            CriteriaCountry.SelectedIndex = 0;
            CriteriaDetail.Text = "";
            if (Criteria.SelectedValue.ToString() == "11018" || Criteria.SelectedValue.ToString() == "11021" ||
                Criteria.SelectedValue.ToString() == "11035" || Criteria.SelectedValue.ToString() == "11034")
            {
               
                CriteriaCountry.Visible = true;
                CriteriaDetail.Visible = false;
            }
            else
            {
                CriteriaCountry.Visible = false;
                CriteriaDetail.Visible = true;
            }

        }
    }
}