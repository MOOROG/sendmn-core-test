using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Treasury
{
   public interface IFundTransferDao
    {
       DbResult AddNewBank(string bankName, string krwAcc, string usdAcc, string user, string rowID, string hasChk);
       DbResult SaveDealBooking(string Date, string BankId, string UsdAmt, string Rate, string LCYAmt, string Dealer, string MaturityDate, string ContractNo, string User);

       DataRow SelectBankById(string Id, string User);
       DataTable GetDealSummaryToTransfer(string BankId);

       DbResult SaveFundTransfer(string PartnerId, string tAmt, string ids, string User,string Date);

       DbResult UpdateFundTransferDetail(string rowId, string nameOfPartner, string receiveInUSD, string furtherTransferTo, string User);

       DataRow GetSettingDetails(string rowId);

       DbResult AddCorrespondent(string TransferFund, string PartnerName, string ReceiveAc, string CorrespondentAc, string User, string Id);

       DataRow SelectCorrespondentBankById(string Id, string User);
    }
}
