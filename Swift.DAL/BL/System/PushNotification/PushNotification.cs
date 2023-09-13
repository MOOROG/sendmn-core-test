using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using Swift.DAL.SwiftDAL;
using System.Net;
using System.IO;
using System.Web.Script.Serialization;
using System.Data;
namespace Swift.DAL.BL.System.PushNotification
{
    public class PushNotification  : IPushNotification
    {
        
        DbResult _dbResult;
        RemittanceDao _dao = new RemittanceDao();


        public PushNotification()
        {
            
            _dbResult = new DbResult();
        }
        public void test()
        {

        }
        public object SendPushNotification(string cmRegistrationId,string os, string message,string notificationId)
        {
            var _responseResult=new object();
           
            string _baseURL = ConfigurationSettings.AppSettings["pushNotificationUrl"].ToString();
            PushNotificationParam _requestParam = new PushNotificationParam()
            {
                cmRegistrationId=cmRegistrationId,
                os=os,
                message=message
            };

            var _requestMain = new JavaScriptSerializer().Serialize(_requestParam);
            try
            {
                HttpWebRequest _httpRequest = (HttpWebRequest)WebRequest.Create(_baseURL);
                _httpRequest.ContentType = "application/json";
                _httpRequest.Method = "POST";
               
                using (var _streamWriter = new StreamWriter(_httpRequest.GetRequestStream()))
                {
                    _streamWriter.Write(_requestMain);
                    _streamWriter.Flush();
                    _streamWriter.Close();
                }

                var _httpResponse = (HttpWebResponse)_httpRequest.GetResponse();
                using (var _streamReader = new StreamReader(_httpResponse.GetResponseStream()))
                {
                    _responseResult = new JavaScriptSerializer().Deserialize<object>(_streamReader.ReadToEnd());
                    UpdateNotification(notificationId);
                }
                _httpResponse.Close();
            }
            catch (Exception e)
            {
                
                _responseResult = e.Message.ToString();
                return _responseResult;
            }
            return _responseResult;
        }
        public DataTable GetDeviceDetail(string customerId)
        {

            string sql = "EXEC proc_getNotificationDetails";
            sql += " @flag = 'getDevice'";
            sql += ", @customerId = " + _dao.FilterString(customerId);
            
            return _dao.ExecuteDataTable(sql);
        }
        public DbResult CreateNotification(Notifiers notifiers)
        {
            var sql = "EXEC [proc_getNotificationDetails] @flag ='pushInternal'";
            sql += ", @notifierId = " + _dao.FilterString(notifiers.notifierId);
            sql += ", @notifierName = " + _dao.FilterString(notifiers.notifierName);
            sql += ", @notifierUrl = " + _dao.FilterString(notifiers.notifierUrl);
            sql += ", @notificationCode = " + _dao.FilterString(notifiers.notificationCode);
            sql += ", @notificationMessage = " + _dao.FilterString(notifiers.notificationMessage);
            sql += ", @userId = " + _dao.FilterString(notifiers.userId);
            sql += ", @module = " + _dao.FilterString(notifiers.module);
            return _dao.ParseDbResult(sql);
        }
        public void UpdateNotification(string notificationId)
        {
            var sql = string.Format("EXEC mobile_proc_notificationMaster @flag='u', @notificationId={0}", _dao.FilterString(notificationId));
            var dbResp = _dao.ParseDbResult(sql);
        }
    }
}
