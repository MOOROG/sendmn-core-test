using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.Remit.Administration.VisaCardDetail
{
    public class VisaCardDao:SwiftDao
    {
            public DbResult UploadVisaCardDetail(string user,string xml)
            {
                string sql = "EXEC proc_visaCardDetail @flag='u'";
                sql = sql + " ,@user=" + FilterString(user);
                sql = sql + " ,@xml='" + xml + "'";
                return ParseDbResult(sql);
            }
    }
}
