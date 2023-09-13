using Swift.DAL.BL.ThirdParty.GME;
using Swift.DAL.SwiftDAL;
using Swift.web.Library;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Swift.web.Remit.ThirdPartyTXN.ACDeposit.GME
{
    public partial class UnpaidTxnDetails : System.Web.UI.Page
    {
        readonly RemittanceLibrary _sl = new RemittanceLibrary();
        IGMEDao _gme = new GMEDao();
        private readonly StaticDataDdl sdd = new StaticDataDdl();
        protected void Page_Load(object sender, EventArgs e)
        {
            _sl.CheckSession();
            hdnRowId.Value = GetStatic.ReadQueryString("rowId", "");
            var viewFlag = GetStatic.ReadQueryString("flag", "");
            if (viewFlag == "R")
            {
                rBank.Enabled = false;
                rBankBranch.Enabled = false;
                updateBank.Visible = false;
            }
            else
            {
                rBank.Enabled = true;
                rBankBranch.Enabled = true;
                updateBank.Visible = true;
            }




            if (!IsPostBack)
            {
                PopulateBank();
                PopulateBankBranch();
                SelectByRowId(hdnRowId.Value);
            }

        }

        private void SelectByRowId(string rowId)
        {

            var dRow = _gme.SelectByRowId(rowId);
            hdnPbankId.Value = dRow["pBankId"].ToString();
            hdnPbranchId.Value = dRow["pBranchId"].ToString();
            hdnControlNo.Value = dRow["controlNo"].ToString();
            controlNo.Text = dRow["controlNo"].ToString();
            hdnPaymentMode.Value = dRow["paymentMode"].ToString();
            updateBank.Visible = string.IsNullOrWhiteSpace(hdnPbankId.Value);
            downloadTokenId.Value = dRow["downloadTokenId"].ToString();
            idType.Value = dRow["rIdType"].ToString();
            idNo.Value = dRow["rIdNo"].ToString();

            #region Sender Details
            sName.Text = dRow["sName"].ToString();
            sAddress.Text = dRow["sAddress"].ToString();
            sCountry.Text = dRow["sCountry"].ToString();
            sContactNo.Text = dRow["sContactNo"].ToString();
            //sIdType.Text = dRow["sIdType"].ToString();
            //sIdNo.Text = dRow["sIdNo"].ToString();
            //sIdValidDate.Text = dRow["sIdValidDate"].ToString();
            //sNationality.Text = dRow["sNationality"].ToString();
            #endregion
            #region recieverDetails
            rName.Text = dRow["rName"].ToString();
            rAddress.Text = dRow["rAddress"].ToString();
            rCountry.Text = dRow["rCountry"].ToString();
            rContactNo.Text = dRow["rContactNo"].ToString();
            rIdNo.Text = dRow["rIdNo"].ToString();
            #endregion
            #region transactionDetails
            rBankName.Text = dRow["rBankName"].ToString();
            rBankAcNo.Text = dRow["rBankAcNo"].ToString();
            rAmount.Text = dRow["rAmount"].ToString();
            rBranchName.Text = dRow["rBankBranchName"].ToString();
            rCurrency.Text = dRow["rCurrency"].ToString();
            #endregion
            PopulateBank();
            PopulateBankBranch();
        }

        private void SelectByPinNo(string gitNo)
        {
            controlNo.Text = gitNo;
            var dRow = _gme.SelectByPinNo(gitNo);
            #region Sender Details
            sName.Text = dRow["sName"].ToString();
            sAddress.Text = dRow["sAddress"].ToString();
            sCountry.Text = dRow["sCountry"].ToString();
            sContactNo.Text = dRow["sContactNo"].ToString();
            sIdType.Text = dRow["sIdType"].ToString();
            sIdNo.Text = dRow["sIdNo"].ToString();
            sIdValidDate.Text = dRow["sIdValidDate"].ToString();
            sNationality.Text = dRow["sNationality"].ToString();
            #endregion
            #region recieverDetails
            rName.Text = dRow["rName"].ToString();
            rAddress.Text = dRow["rAddress"].ToString();
            rCountry.Text = dRow["rCountry"].ToString();
            rContactNo.Text = dRow["rContactNo"].ToString();
            rIdNo.Text = dRow["rIdNo"].ToString();
            #endregion
            #region transactionDetails
            rBankName.Text = dRow["rBankName"].ToString();
            rBankAcNo.Text = dRow["rBankAcNo"].ToString();
            rAmount.Text = dRow["rAmount"].ToString();
            rBranchName.Text = dRow["rBankBranchName"].ToString();
            rCurrency.Text = dRow["rCurrency"].ToString();
            #endregion
        }

        private void PopulateBank()
        {
            const string sql = "EXEC proc_agentMaster @flag = 'bankbl'";
            sdd.SetDDL(ref rBank, sql, "agentId", "agentName", hdnPbankId.Value, "SELECT");
        }

        private void PopulateBankBranch()
        {
            var pBankArr = rBank.SelectedValue;

            var sql = string.Format("EXEC proc_agentMaster @flag = 'bl',@parentId='{0}'", pBankArr);
            sdd.SetDDL(ref rBankBranch, sql, "agentId", "agentName", hdnPbranchId.Value, "SELECT");
        }

        protected void updateBank_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(rBank.Text) || string.IsNullOrWhiteSpace(rBankBranch.Text))
            {
                GetStatic.AlertMessage(Page, "Please select Bank and Bank Branch Properly.");
                return;
            }
            var pBank = rBank.SelectedValue;

            var dr = _gme.UpdateBeneficiaryBank(GetStatic.GetUser(), hdnRowId.Value, rBank.SelectedValue, rBankBranch.SelectedValue, "");
            GetStatic.AlertMessage(Page, dr.Msg);
            if (dr.ErrorCode.Equals("0"))
            {
                SelectByRowId(hdnRowId.Value);
            }
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            GMEPayConfirmDetails _payConfirmDetails = new GMEPayConfirmDetails()
            {
                user = GetStatic.GetUser(),
                rowId = hdnRowId.Value,
                refNo = hdnControlNo.Value,
                payTokenId = downloadTokenId.Value,
                pBranch = rBankBranch.SelectedValue,
                rIdType = idType.Value,
                rIdNumber = idNo.Value,
                rContactNo = rContactNo.Text,
                pAmount = rAmount.Text
            };

            //var dr = _gme.PayConfirmBankDeposit(_payConfirmDetails);
            var dr = new DbResult();
            GetStatic.AlertMessage(Page, dr.Msg);
            if (dr.ErrorCode.Equals("0"))
            {
                //GetStatic.CallBackJs1(Page, "closePage", "window.close();");
                var url = "../../../Transaction/ReprintVoucher/PayIntlReceipt.aspx?controlNo=" + dr.Id;
                Response.Redirect(url);
            }
            else
            {
                GetStatic.AlertMessage(Page, dr.Msg);
            }
        }

        protected void rBank_SelectedIndexChanged(object sender, EventArgs e)
        {
            PopulateBankBranch();
        }

        protected void btnRecNameUpdate_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(rName.Text))
            {
                GetStatic.AlertMessage(Page, "Please enter Name!!.");
                return;
            }
            var dr = _gme.UpdateReceiverName(GetStatic.GetUser(), hdnRowId.Value, rName.Text);
            GetStatic.AlertMessage(Page, dr.Msg);
            if (dr.ErrorCode.Equals("0"))
            {
                SelectByRowId(hdnRowId.Value);
            }
        }

        protected void btnUpdateBank_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(rBankName.Text) || string.IsNullOrWhiteSpace(rBranchName.Text) || string.IsNullOrWhiteSpace(rBankAcNo.Text))
            {
                GetStatic.AlertMessage(Page, "Please select Bank Name,Bank Branch and Account No Properly.");
                return;
            }
            if (IsAlphaNumeric(rBankAcNo.Text) == true)
            {
                var dr = _gme.UpdateBankDetails(GetStatic.GetUser(), hdnRowId.Value, rBankName.Text, rBranchName.Text, rBankAcNo.Text);
                GetStatic.AlertMessage(Page, dr.Msg);
                if (dr.ErrorCode.Equals("0"))
                {                    
                    SelectByRowId(hdnRowId.Value);
                }
            }
            else
            {
                GetStatic.AlertMessage(Page, "Please enter valid Bank Account No..");
                return;

            }
        }
        public bool IsAlphaNumeric(string inputString)
        {
            Regex r = new Regex("^[a-zA-Z0-9]+$");
            if (r.IsMatch(inputString))
            {
                return true;
            }
            else
                return false;
        }
    }
}