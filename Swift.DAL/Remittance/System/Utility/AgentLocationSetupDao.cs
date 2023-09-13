using Swift.DAL.SwiftDAL;
using System.Data;

namespace Swift.DAL.BL.System.Utility
{
   public class AgentLocationSetupDao:SwiftDao
    {
       public DbResult Update(string user, string locationId, string agentId, string city, string country, string address, string zip,string postalCode)
       {
           string sql = "exec [proc_agentDoorToDoorLocation]";
           sql += "  @flag =" + (locationId == "0" ? "'i'" : "'u'");
           sql += ",@user=" + FilterString(user);
           sql += ",@locationId=" + FilterString(locationId);
           sql += ",@agentId=" + FilterString(agentId);
           sql += ",@city=" + FilterString(city);
           sql += ",@country=" + FilterString(country);
           sql += ",@address=" + FilterString(address);
           sql += ",@zip=" + FilterString(zip);
           sql += ",@postalCode=" + FilterString(postalCode);
          return ParseDbResult(sql);
       }

       public DbResult Delete(string user, string locationId)
       {
           string sql = "exec [proc_agentDoorToDoorLocation]";
           sql += " @flag = 'd'";
           sql += ",@locationId=" + FilterString(locationId);
           sql += ",@user=" + FilterString(user);
           return ParseDbResult(sql);
       }

       public DataRow SelectById(string user, string locationId)
       {
           string sql = "exec [proc_agentDoorToDoorLocation]";
           sql += " @flag = 'a'";
           sql += ",@locationId=" + FilterString(locationId);
           sql += ",@user=" + FilterString(user);
           return ExecuteDataRow(sql);
       }
    }
}
