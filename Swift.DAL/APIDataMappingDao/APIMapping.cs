using System.Data;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.APIDataMappingDao
{
    public class APIMapping : RemittanceDao
    {
        public DbResult SyncBank(string user, string bankXml, string BankcountryName, string apiPartnerId, string CountryCurrency, string sessionId)
        {
            var sql = "EXEC PROC_MAP_BANK_DATA @flag = 'syncBank'";
            sql += ", @user = " + FilterString(user);
            sql += ", @XML = " + FilterString(bankXml);
            sql += ", @API_PARTNER_ID = " + FilterString(apiPartnerId);
            sql += ", @BANK_COUNTRY = " + FilterString(BankcountryName);
            sql += ", @BANK_CURRENCY = " + FilterString(CountryCurrency);
            sql += ", @SESSION_ID = " + FilterString(sessionId);

            return ParseDbResult(sql);
        }

        public DataTable ShowMissingList(string user, string country, string payoutMethod, string apiPartnerId)
        {
            var sql = "EXEC PROC_MAP_BANK_DATA @flag = 'SHOW-MISSING-DATA'";
            sql += ", @user = " + FilterString(user);
            sql += ", @COUNTRY_CODE = " + FilterString(country);
            sql += ", @PAYMENT_TYPE_ID = " + FilterString(payoutMethod);
            sql += ", @API_PARTNER_ID  = " + FilterString(apiPartnerId);

            return ExecuteDataTable(sql);
        }

        public DataTable ShowMappedList(string user, string country, string payoutMethod, string apiPartnerId)
        {
            var sql = "EXEC PROC_MAP_BANK_DATA @flag = 'SHOW-MAP-DATA'";
            sql += ", @user = " + FilterString(user);
            sql += ", @COUNTRY_CODE = " + FilterString(country);
            sql += ", @PAYMENT_TYPE_ID = " + FilterString(payoutMethod);
            sql += ", @API_PARTNER_ID  = " + FilterString(apiPartnerId);

            return ExecuteDataTable(sql);
        }

        public DataTable GetMasterDataList(string user, string country, string payoutMethod, string apiPartnerId, string noOfRows)
        {
            var sql = "EXEC PROC_MAP_BANK_DATA @flag = 'MASTER-DATA'";
            sql += ", @user = " + FilterString(user);
            sql += ", @COUNTRY_CODE = " + FilterString(country);
            sql += ", @PAYMENT_TYPE_ID = " + FilterString(payoutMethod);
            sql += ", @API_PARTNER_ID  = " + FilterString(apiPartnerId);
            sql += ", @NO_OF_ROWS  = " + FilterString(noOfRows);

            return ExecuteDataTable(sql);
        }

        public DataTable GetMasterDownlodList(string user, string country, string payoutMethod, string apiPartnerId, string sessionId)
        {
            var sql = "EXEC PROC_MAP_BANK_DATA @flag = 'DOWNLOAD-DATA'";
            sql += ", @user = " + FilterString(user);
            sql += ", @COUNTRY_CODE = " + FilterString(country);
            sql += ", @PAYMENT_TYPE_ID = " + FilterString(payoutMethod);
            sql += ", @API_PARTNER_ID  = " + FilterString(apiPartnerId);
            sql += ", @SESSION_ID = " + FilterString(sessionId);

            return ExecuteDataTable(sql);
        }

        public DbResult SaveMissingBanks(string user, string ids, string partnerId)
        {
            var sql = "EXEC PROC_MAP_BANK_DATA @flag = 'SAVE-MISSING-DATA'";
            sql += ", @user = " + FilterString(user);
            sql += ", @IDS = " + FilterString(ids);
            sql += ", @IDS = " + FilterString(partnerId);

            return ParseDbResult(sql);
        }

        public void SaveMappingData(string user, string xml)
        {
            var sql = "EXEC PROC_MAP_BANK_DATA @flag = 'MAP-DATA'";
            sql += ", @user = " + FilterString(user);
            sql += ", @xmlA = " + FilterString(xml);

            ExecuteDataTable(sql);
        }

        public DbResult SaveMainTable(string user, string country, string payoutMethod, string apiPartnerId)
        {
            var sql = "EXEC PROC_MAP_BANK_DATA @flag = 'MAP-DATA'";
            sql += ", @user = " + FilterString(user);
            sql += ", @COUNTRY_CODE = " + FilterString(country);
            sql += ", @PAYMENT_TYPE_ID = " + FilterString(payoutMethod);
            sql += ", @API_PARTNER_ID  = " + FilterString(apiPartnerId);

            return ParseDbResult(sql);
        }
        public DbResult SaveEditedData(string user, string rowId, string countryName, string paymentTypeId,string apiPartner,string changedBankId)
        {
            var sql = "EXEC PROC_MAP_BANK_DATA @flag = 'SAVE-EDITED-BANK-MAPPING'";
            sql += ", @user = " + FilterString(user);
            sql += ", @ROW_ID = " + FilterString(rowId);
            sql += ", @BANK_COUNTRY = " + FilterString(countryName);
            sql += ", @PAYMENT_TYPE_ID = " + FilterString(paymentTypeId);
            sql += ", @API_PARTNER_ID  = " + FilterString(apiPartner);
            sql += ", @CHANGED_BANK_ID  = " + FilterString(changedBankId);

            return ParseDbResult(sql);
        }
    }
}
