using Swift.DAL.SwiftDAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;

namespace Swift.DAL.Remittance.TPSetup
{
    public class TPSetupDao : RemittanceDao
    {
        public DbResult InsertUpdateSetup(string rowId, string user, string countryId, string serviceTypeId, string location, string partnerLocationId, string isActive)
        {
            var sql = "EXEC proc_tpLocationSetup";
            sql += " @Flag ='" + ((string.IsNullOrEmpty(rowId)) ? "i" : "u") + "'";
            sql += ",@countryId =" + FilterString(countryId);
            sql += ",@serviceTypeId =" + FilterString(serviceTypeId);
            sql += ",@location = N" + FilterString(location);
            sql += ",@partnerLocationId = " + FilterString(partnerLocationId);
            sql += ",@rowId =" + FilterString(rowId);
            sql += ",@isActive =" + FilterString(isActive);
            sql += ",@user =" + FilterString(user);

            return ParseDbResult(sql);
        }

        
        public DbResult EnableDisable(string user, string rowId)
        {
            var sql = "EXEC proc_tpLocationSetup";
            sql += " @Flag ='block-unblock'";
            sql += ",@rowId =" + FilterString(rowId);
            sql += ",@user =" + FilterString(user);

            return ParseDbResult(sql);
        }


        public DataRow GetPartnerDetails(string rowId, string user)
        {
            var sql = "EXEC proc_tpLocationSetup";
            sql += " @Flag ='partner-details'";
            sql += ",@rowId =" + FilterString(rowId);
            sql += ",@user =" + FilterString(user);

            return ExecuteDataRow(sql);
        }

        public DbResult InsertUpdateSubLocation(string rowId, string user, string subLocation, string subLocationCode, string isActive, string locationId)
        {
            var sql = "EXEC proc_tpLocationSetup";
            sql += " @Flag ='" + ((string.IsNullOrEmpty(rowId)) ? "sub-i" : "sub-u") + "'";
            sql += ",@subLocation = N" + FilterString(subLocation);
            sql += ",@partnerSubLocationId =" + FilterString(subLocationCode);
            sql += ",@locationId =" + FilterString(locationId);
            sql += ",@rowId =" + FilterString(rowId);
            sql += ",@isActive =" + FilterString(isActive);
            sql += ",@user =" + FilterString(user);

            return ParseDbResult(sql);
        }

        public DataRow GetSubLocationDetails(string rowId, string user)
        {
            var sql = "EXEC proc_tpLocationSetup";
            sql += " @Flag ='sub-loc'";
            sql += ",@rowId =" + FilterString(rowId);
            sql += ",@user =" + FilterString(user);

            return ExecuteDataRow(sql);
        }
    }
}
