using System;
using System.Collections.Generic;
using Swift.DAL.BL.Remit.Compliance;
using Swift.web.Library;
using System.Text;
using System.Data;

namespace Swift.web.Remit.RiskBaseAnalysis
{
    public partial class txnRBACalcDetails : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            ShowCalculationDetail();
        }

        private void ShowCalculationDetail()
        {
            var obj = new RBACustomerDao();
            var ds = obj.GetTXNRBACalculationDetail(GetStatic.GetUser(), GetStatic.ReadQueryString("customerId", ""), GetStatic.ReadQueryString("tranId", ""), GetStatic.ReadQueryString("dt", ""));            
            if (ds == null)
                return;

            if (ds.Tables.Count > 0)
            {
               

                if (ds.Tables[0].Rows.Count>0)
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

               
                if (ds.Tables[1].Rows.Count>0)
                {
                    var drRBA = ds.Tables[1].Rows[0];

                    rbaLevel.Text = drRBA["RBATxn"].ToString();
                    rbaRating.Text = drRBA["RBATxnCalculated"].ToString();

                    Rating.Text = drRBA["RBATxn"].ToString().ToUpper();
                    Rating.CssClass = drRBA["RBATxn"].ToString().ToLower();
                    ScoreTotal.Text = drRBA["RBATxnCalculated"].ToString();

                    //customerRating.Text = drRBA["RBACustomer"].ToString().ToUpper();
                    //customerRating.CssClass = drRBA["RBACustomer"].ToString().ToLower();
                    //customerScoreTotal.Text = drRBA["RBAscoreCustomer"].ToString();



                    FATFReceivingCountryScore.Text = drRBA["FATFReceivingCountryScore"].ToString();
                    FATFReceivingCountryWeight.Text = drRBA["FATFReceivingCountryWeight"].ToString();
                    FATFReceivingCountryRating.Text = drRBA["FATFReceivingCountryRating"].ToString();
                    txnToNonNativeCountryScore.Text = drRBA["txnToNonNativeCountryScore"].ToString();
                    txnToNonNativeCountryWeight.Text = drRBA["txnToNonNativeCountryWeight"].ToString();
                    txnToNonNativeCountryRating.Text = drRBA["txnToNonNativeCountryRating"].ToString();
                    cAmtScore.Text = drRBA["cAmtScore"].ToString();
                    cAmtWeight.Text = drRBA["cAmtWeight"].ToString();
                    cAmtRating.Text = drRBA["cAmtRating"].ToString();
                    paymentModeScore.Text = drRBA["paymentModeScore"].ToString();
                    paymentModeWeight.Text = drRBA["paymentModeWeight"].ToString();
                    paymentModeRating.Text = drRBA["paymentModeRating"].ToString();
                    residencyScore.Text = drRBA["residencyScore"].ToString();
                    residencyWeight.Text = drRBA["residencyWeight"].ToString();
                    residencyRating.Text = drRBA["residencyRating"].ToString();
                    FATFCustomerNativeCountryScore.Text = drRBA["FATFCustomerNativeCountryScore"].ToString();
                    FATFCustomerNativeCountryWeight.Text = drRBA["FATFCustomerNativeCountryWeight"].ToString();
                    FATFCustomerNativeCountryRating.Text = drRBA["FATFCustomerNativeCountryRating"].ToString();
                    senderOccupationScore.Text = drRBA["senderOccupationScore"].ToString();
                    senderOccupationWeight.Text = drRBA["senderOccupationWeight"].ToString();
                    senderOccupationRating.Text = drRBA["senderOccupationRating"].ToString();

                    //PEPReceiverScore.Text = drRBA["PEPReceiverScore"].ToString();
                    //PEPReceiverWeight.Text = drRBA["PEPReceiverWeight"].ToString();
                    //PEPReceiverRating.Text = drRBA["PEPReceiverRating"].ToString();
                    //PEPSenderScore.Text = drRBA["PEPSenderScore"].ToString();
                    //PEPSenderWeight.Text = drRBA["PEPSenderWeight"].ToString();
                    //PEPSenderRating.Text = drRBA["PEPSenderRating"].ToString();
                }
                try
                {
                   

                    if (ds.Tables[2].Rows.Count>0)
                    {
                        var drCustomerRBA = ds.Tables[2].Rows[0];

                        tblCusRBA.Visible = true;
                        tblRBASummary.Visible = true;

                        customerRating.Text = drCustomerRBA["RBACustomer"].ToString().ToUpper();
                        customerRating.CssClass = drCustomerRBA["RBACustomer"].ToString().ToLower();

                        customerScoreTotal.Text = drCustomerRBA["RBACustomerCalculated"].ToString();

                        txnCountRating.Text = drCustomerRBA["txnCountRating"].ToString();
                        txnCountWeight.Text = drCustomerRBA["txnCountWeight"].ToString();
                        txnCountScore.Text = drCustomerRBA["txnCountScore"].ToString();

                        txnAmountRating.Text = drCustomerRBA["txnAmountRating"].ToString();
                        txnAmountWeight.Text = drCustomerRBA["txnAmountWeight"].ToString();
                        txnAmountScore.Text = drCustomerRBA["txnAmountScore"].ToString();

                        outletsUsedRating.Text = drCustomerRBA["outletsUsedRating"].ToString();
                        outletsUsedWeight.Text = drCustomerRBA["outletsUsedWeight"].ToString();
                        outletsUsedScore.Text = drCustomerRBA["outletsUsedScore"].ToString();

                        bnfcountrycountRating.Text = drCustomerRBA["bnfcountrycountRating"].ToString();
                        bnfcountrycountWeight.Text = drCustomerRBA["bnfcountrycountWeight"].ToString();
                        bnfcountrycountScore.Text = drCustomerRBA["bnfcountrycountScore"].ToString();

                        bnfcountRating.Text = drCustomerRBA["bnfcountRating"].ToString();
                        bnfcountWeight.Text = drCustomerRBA["bnfcountWeight"].ToString();
                        bnfcountScore.Text = drCustomerRBA["bnfcountScore"].ToString();

                        taRating.Text = drCustomerRBA["txnrbaRating"].ToString();
                        taWeight.Text = drCustomerRBA["txnrbaWeight"].ToString(); ;
                        taScore.Text = drCustomerRBA["txnrbaScore"].ToString(); ;

                        paRating.Text = drCustomerRBA["custPeriodicRbaRating"].ToString();
                        paWeight.Text = drCustomerRBA["custPeriodicRbaWeight"].ToString();
                        paScore.Text = drCustomerRBA["custPeriodicRbaScore"].ToString();

                        rbaSummaryTotal.Text = drCustomerRBA["finalrba"].ToString();
                        rbaSummaryRating.Text = drCustomerRBA["finalRbaCatagory"].ToString().ToUpper();
                        rbaSummaryRating.CssClass = drCustomerRBA["finalRbaCatagory"].ToString().ToLower();

                        
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