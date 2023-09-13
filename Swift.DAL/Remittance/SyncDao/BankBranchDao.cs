using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.SyncDao
{
    public class BankBranchDao : RemittanceDao
    {
        public DbResult EnableDisableBank(string rowId, string user, string isActive)
        {
            var sql = "EXEC PROC_API_BANK_BRANCH_SETUP @flag = 'enable-disable-bank'";

            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @IsActive = " + FilterString(isActive);

            return ParseDbResult(sql);
        }

        public DbResult EnableDisableBankBranch(string rowId, string user, string isActive)
        {
            var sql = "EXEC PROC_API_BANK_BRANCH_SETUP @flag = 'enable-disable-bankBranch'";

            sql += ", @user = " + FilterString(user);
            sql += ", @rowId = " + FilterString(rowId);
            sql += ", @IsActive = " + FilterString(isActive);

            return ParseDbResult(sql);
        }

        public DbResult SyncBank(string user, string bankXml, string BankcountryName, string apiPartnerId)
        {
            var sql = "EXEC PROC_API_BANK_BRANCH_SETUP @flag = 'syncBank'";
            sql += ", @user = " + FilterString(user);
            sql += ", @XML = " + FilterString(bankXml);
            sql += ", @API_PARTNER_ID = " + FilterString(apiPartnerId);
            sql += ", @BANK_COUNTRY = " + FilterString(BankcountryName);
            return ParseDbResult(sql);
        }

        public DbResult SyncBankBranch(string user,string bankCode, string bankBranchXml, string BankcountryName, string apiPartnerId)
        {
            var sql = "EXEC PROC_API_BANK_BRANCH_SETUP @flag = 'syncBankBranch'";
            sql += ", @user = " + FilterString(user);
            sql += ", @XML = " + FilterString(bankBranchXml);
            sql += ", @bankId = " + FilterString(bankCode);
            sql += ", @API_PARTNER_ID = " + FilterString(apiPartnerId);
            sql += ", @BANK_COUNTRY = " + FilterString(BankcountryName);
            return ParseDbResult(sql);
        }

        public DbResult SyncState(string user, string stateXml, string stateCountryName, string apiPartnerId)
        {
            var sql = "EXEC PROC_API_STATE_SETUP @flag = 'syncState'";
            sql += ", @user = " + FilterString(user);
            sql += ", @XML = " + FilterString(stateXml);
            sql += ", @API_PARTNER_ID = " + FilterString(apiPartnerId);
            sql += ", @STATE_COUNTRY = " + FilterString(stateCountryName);
            return ParseDbResult(sql);
        }

        public DbResult SyncCity(string user, string cityXml, string cityCountryName, string stateId)
        {
            var sql = "EXEC PROC_API_STATE_SETUP @flag = 'syncCity'";
            sql += ", @user = " + FilterString(user);
            sql += ", @XML = " + FilterString(cityXml);
            sql += ", @stateId = " + FilterString(stateId);
            sql += ", @CITY_COUNTRY = " + FilterString(cityCountryName);
            return ParseDbResult(sql);
        }

        public DbResult SyncTown(string user, string townXml, string townCountryName, string stateId, string cityId)
        {
            var sql = "EXEC PROC_API_STATE_SETUP @flag = 'syncTown'";
            sql += ", @user = " + FilterString(user);
            sql += ", @XML = " + FilterString(townXml);
            sql += ", @stateId = " + FilterString(stateId);
            sql += ", @cityId = " + FilterString(cityId);
            sql += ", @TOWN_COUNTRY = " + FilterString(townCountryName);
            return ParseDbResult(sql);
        }
    }
}