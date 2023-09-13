using System;
using System.Collections.Generic;
using Swift.DAL.BL.Remit.Compliance;
using Swift.web.Library;
using System.Text;
using System.Data;

namespace Swift.web.Remit.RiskBaseAnalysis
{
    public partial class cusRBACalcDetails : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            ShowCalculationDetail();
        }

        private void ShowCalculationDetail()
        {
            var obj = new RBACustomerDao();
            var ds = obj.GetCustomerRBACalculationDetail(GetStatic.GetUser(), GetStatic.ReadQueryString("customerId", ""), GetStatic.ReadQueryString("tranId", ""), GetStatic.ReadQueryString("dt", ""));            
            if (ds == null)
                return;

            if (ds.Tables.Count > 0)
            {


                if (ds.Tables[0].Rows.Count > 0)
                {
                    var dr = ds.Tables[0].Rows[0];

                    fullName.Text = dr["fullName"].ToString();
                    dob.Text = dr["dob"].ToString();
                    gender.Text = dr["gender"].ToString();
                    nativeCountry.Text = dr["nativeCountry"].ToString();
                    country.Text = dr["country"].ToString();
                    idType.Text = dr["idType"].ToString();
                    idNumber.Text = dr["idNumber"].ToString();
                    state.Text = dr["state"].ToString();
                    city.Text = dr["city"].ToString();
                    address.Text = dr["address"].ToString();
                    mobileNo.Text = dr["mobile"].ToString();
                    email.Text = dr["email"].ToString();
                    rbaLevel.Text = dr["type"].ToString();
                    rbaRating.Text = dr["rba"].ToString();
                }
                try
                {
                    

                    if (ds.Tables[1].Rows.Count>0)
                    {
                        var drRBA = ds.Tables[1].Rows[0];

                        tblCusRBA.Visible = true;
                        tblRBASummary.Visible = true;

                        rbaLevel.Text = drRBA["RBACustomer"].ToString();
                        rbaRating.Text = drRBA["RBACustomerCalculated"].ToString();

                        Rating.Text = drRBA["RBACustomer"].ToString().ToUpper();
                        Rating.CssClass = drRBA["RBACustomer"].ToString().ToLower();

                        ScoreTotal.Text = drRBA["RBACustomerCalculated"].ToString();

                        txnCountRating.Text = drRBA["txnCountRating"].ToString();
                        txnCountWeight.Text = drRBA["txnCountWeight"].ToString();
                        txnCountScore.Text = drRBA["txnCountScore"].ToString();

                        txnAmountRating.Text = drRBA["txnAmountRating"].ToString();
                        txnAmountWeight.Text = drRBA["txnAmountWeight"].ToString();
                        txnAmountScore.Text = drRBA["txnAmountScore"].ToString();

                        outletsUsedRating.Text = drRBA["outletsUsedRating"].ToString();
                        outletsUsedWeight.Text = drRBA["outletsUsedWeight"].ToString();
                        outletsUsedScore.Text = drRBA["outletsUsedScore"].ToString();

                        bnfcountrycountRating.Text = drRBA["bnfcountrycountRating"].ToString();
                        bnfcountrycountWeight.Text = drRBA["bnfcountrycountWeight"].ToString();
                        bnfcountrycountScore.Text = drRBA["bnfcountrycountScore"].ToString();

                        bnfcountRating.Text = drRBA["bnfcountRating"].ToString();
                        bnfcountWeight.Text = drRBA["bnfcountWeight"].ToString();
                        bnfcountScore.Text = drRBA["bnfcountScore"].ToString();

                        taRating.Text = drRBA["txnrbaRating"].ToString();
                        taWeight.Text = drRBA["txnrbaWeight"].ToString(); ;
                        taScore.Text = drRBA["txnrbaScore"].ToString(); ;

                        paRating.Text = drRBA["custPeriodicRbaRating"].ToString();
                        paWeight.Text = drRBA["custPeriodicRbaWeight"].ToString();
                        paScore.Text = drRBA["custPeriodicRbaScore"].ToString();

                        rbaSummaryTotal.Text = drRBA["finalrba"].ToString();
                        rbaSummaryRating.Text = drRBA["finalRbaCatagory"].ToString().ToUpper();
                        rbaSummaryRating.CssClass = drRBA["finalRbaCatagory"].ToString().ToLower();
                    }
                    else
                    {
                        tblCusRBA.Visible = false;
                        tblRBASummary.Visible = false;
                    }
                }
                catch (Exception ex)
                {
                    tblCusRBA.Visible = false;
                    tblRBASummary.Visible = false;

                }

            }
        }
    }
}