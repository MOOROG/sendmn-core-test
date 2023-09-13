using System;
using Swift.web.Library;
using System.Web.UI.WebControls;
using Swift.DAL.BL.Remit.Transaction.ThirdParty.MoneyGram;

namespace Swift.web.Remit.Transaction.ThirdPartyTXN.Pay
{
    public partial class PayMg : System.Web.UI.Page
    {
        private readonly StaticDataDdl _sdd = new StaticDataDdl();
        private const string ViewFunctionId = "20124600";
        private readonly MoneyGramDao _mgDao = new MoneyGramDao();

        protected void Page_Load(object sender, EventArgs e)
        {
            _sdd.CheckSession();
            Authenticate();
            if (!IsPostBack)
            {
                PopulateDdl();
                SearchTransaction();
                SetDate();
            }
        }

        private void Authenticate()
        {
            _sdd.CheckAuthentication(ViewFunctionId);
        }

        void PopulateDdl()
        {
            string defValue = "NPL";
            _sdd.SetDDL(ref rIdType, "EXEC proc_countryIdType @flag = 'il-with-et', @countryId='151', @spFlag = '5201'", "detail", "idTitle", "", "Select");
            _sdd.SetDDL(ref photoIdCountry, "EXEC proc_dropDownLists @flag='mgCountry'", "countryCode", "countryName", defValue, "Select");
           
        }

        protected void photoIdCountry_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (photoIdCountry.Text.Trim().ToUpper() == "CAN" || photoIdCountry.Text.Trim().ToUpper() == "MEX" || photoIdCountry.Text.Trim().ToUpper() == "USA")
            {
                _sdd.SetDDL(ref photoIdState, "EXEC proc_dropDownLists @flag='mgCountryState',@param=" + _sdd.FilterString(photoIdCountry.Text), "stateCode", "stateName", "", "Select");
            
            }
            else
            {
                photoIdState.Items.Clear();                
                var  item = new ListItem { Value = "", Text = "Select" };
                item.Selected = true;
                photoIdState.Items.Add(item);               
            }
        }

       
        private void SearchTransaction()
        {
            var referenceNo = GetStatic.ReadQueryString("referenceNo", "");
            MgReceiveData mgData;
            var dbResult = _mgDao.SelectByPinNo(GetStatic.GetUser(),GetBranchId(),GetBranchName(), referenceNo, out mgData);
            if (dbResult.ErrorCode.Equals("0"))
            {
                tranId.Value = dbResult.Id;
                lblControlNo.Text = mgData.referenceNumber;
                tranStatus.Text = mgData.transactionStatus.ToUpper().Equals("AVAIL") ? "UNPAID" : mgData.transactionStatus;
                transactionDate.Text = mgData.dateTimeSent;

                /* Sender Block */
                sName.Text = GetStatic.GetFullName(mgData.senderFirstName, mgData.senderMiddleName, mgData.senderLastName, mgData.senderLastName2);
                sAddress.Text = mgData.senderAddress;
                sCountry.Text = (mgData.senderCountry == "" ? mgData.originatingCountry : mgData.senderCountry); 
                sCity.Text = mgData.senderCity;
                homePhone.Text = mgData.senderHomePhone;
                message.InnerHtml = mgData.message1 + "<br>" + mgData.message2;

                /* Receiver Block */
                rName.Text = GetStatic.GetFullName(mgData.receiverFirstName, mgData.receiverMiddleName, mgData.receiverLastName, mgData.receiverLastName2);
                rAddress.Text = mgData.receiverAddress;
                rCity.Text = mgData.receiverCity;
                rContactNo.Text = mgData.receiverPhone;
                rCountry.Text = mgData.receiverCountry;

                /* Pay Amount */
                payoutAmount.Text = GetStatic.ShowDecimal(HideNoAfterDecimal(mgData.receiveAmount));
                hddAmt.Value = mgData.receiveAmount;
                payoutCurr.Text = mgData.receiveCurrency;
                hdnDelOpt.Value = mgData.deliveryOption;
                
                displayBlock.Visible = true;
                payOutBlock.Visible = true;
                errorMsg.Visible = false;
            }
            else
            {
                displayBlock.Visible = false;
                payOutBlock.Visible = false;
                errorMsg.InnerHtml = dbResult.Msg;
                errorMsg.Visible = true;
            }
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            var amount = Convert.ToDouble(payoutAmount.Text).ToString();   
            MgReciveTxnData txn = new MgReciveTxnData();
            var dob = _mgDao.GetDate("",dobMonth.Text + "/" + dobDay.Text + "/" + dobYear.Text);
            if (string.IsNullOrEmpty(dob))
            {
                GetStatic.AlertMessage(Page, "Invalid Date of Birth.");
                return;
            }
            if (amount.Equals(amtTobePaid.Text.Trim()))
            {
                txn.ReferenceNumber = lblControlNo.Text;
                txn.ReceiveAmount = hddAmt.Value;
                txn.ReceiveCurrency = payoutCurr.Text;
                txn.DeliveryOption = hdnDelOpt.Value;               

                txn.ReceiverPhotoIdCountry = photoIdCountry.Text.Trim();
                if (!string.IsNullOrWhiteSpace(photoIdCountry.Text.Trim()))
                    txn.ReceiverPhotoIdCountryName = photoIdCountry.SelectedItem.Text;

                txn.ReceiverPhotoIdState = photoIdState.Text.Trim();
                if (!string.IsNullOrWhiteSpace(photoIdState.Text.Trim()))
                    txn.ReceiverPhotoIdStateName = photoIdState.SelectedItem.Text;


                txn.ReceiverCountry = photoIdCountry.Text.Trim();
                if (!string.IsNullOrWhiteSpace(photoIdCountry.Text.Trim()))
                    txn.ReceiverCountryName = photoIdCountry.SelectedItem.Text;

                txn.ReceiverState = photoIdState.Text.Trim();
                if (!string.IsNullOrWhiteSpace(photoIdState.Text.Trim()))
                    txn.ReceiverStateName = photoIdState.SelectedItem.Text;

                txn.ReceiverAddress = recAddress.Text;
                txn.ReceiverCity = recCity.Text;
                txn.ReceiverPhotoIdType = rIdType.Text;
                txn.ReceiverPhotoIdNo = rIdNumber.Text;
                txn.ReceiverZipCode = "99999";
                txn.ReceiverDob = GetDateInMGFormat(dob);
                txn.Remarks = remarks.Text;
                txn.tranId = tranId.Value;
                txn.ReceiverOccupation = occupation.Text;
                txn.ReceiverContactNo = recPhoneNo.Text;
                txn.user = GetStatic.GetUser();
                txn.AgentUseReceiveData = GetBranchId();
                var dbResult = _mgDao.PayConfirm(GetBranchId(), txn);
                GetStatic.AlertMessage(Page, dbResult.Msg);
                if (dbResult.ErrorCode.Equals("0"))
                    Response.Redirect("../../../../AgentPanel/Pay/ThirdParty/MgReceipt.aspx?controlNo=" + dbResult.Id);
            }
            else
            {
                GetStatic.AlertMessage(Page, "Payout amount didn't match");
            }
        }

        private string GetBranchId()
        {
            return GetStatic.ReadQueryString("branchId", "");
        }
        private string GetBranchName()
        {
            return GetStatic.ReadQueryString("branchName", "");
        }


        private string GetDateInMGFormat(string strDate)
        {
            if (string.IsNullOrWhiteSpace(strDate))
                return "";
            var dateParts = strDate.Split('/');
            if (dateParts.Length < 3)
                return "";
            var m = dateParts[0];
            var d = dateParts[1];
            var y = dateParts[2];
            return y + "-" + (m.Length == 1 ? "0" + m : m) + "-" + (d.Length == 1 ? "0" + d : d);           
        }

      

        private static string HideNoAfterDecimal(string amount)
        {
            return Math.Floor(Convert.ToDouble(amount)).ToString();
        }

        private void SetDate()
        {
            for (var d = 1; d <= 32; d++)
            {
                var day = new ListItem { Value = d.ToString(), Text = d.ToString() };
                dobDay.Items.Add(day);
            }

            for(var y=2000;y<2090;y++)
            {
                var year = new ListItem { Value = y.ToString(), Text = y.ToString() };       
                dobYear.Items.Add(year);
            }
        }
    }
}