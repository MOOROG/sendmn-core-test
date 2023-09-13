using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.BL.ThirdParty.GME
{
    public interface IGMEDao
    {
        DbResult SelectByPinNo(string user, string branchId, string refNo);

        DbResult PayConfirm(GMEPayConfirmDetails _payConfirmDetails);

        DataSet ShowAcAllList(string user);

        DbResult DownloadAcDepositTxn(string user);

        DataTable ShowFilterTxnList(string FilterType);

        DbResult Delete(string user, string rowId);

        DataRow SelectByRowId(string rowId);

        DataRow SelectByPinNo(string gitNo);

        DbResult UpdateBeneficiaryBank(string user, string rowId, string rBank, string rBankBranch, string pBankType);

        DbResult UpdateReceiverName(string user, string rowId, string rName);

        DbResult UpdateBankDetails(string user, string rowId, string rBank, string rBankBranch, string rAccNo);

        DbResult PayConfirmProcess(string user);

        DataTable GetDataForPaidSyncToPartner(string provider);
    }
}