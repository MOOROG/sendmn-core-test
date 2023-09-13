using System;
using System.IO;
using System.Net.Mail;
using System.Net.Mime;

namespace Swift.web.Library
{
    public class SmtpMailSetting
    {
        public SmtpMailSetting()
        {
            ToEmails = "";
            CcEmails = "";
            BccEmails = "";
            MsgSubject = "";
            MsgBody = "";
            SmtpPort = Convert.ToInt16(GetStatic.ReadWebConfig("SmtpPort", ""));
            SmtpServer = GetStatic.ReadWebConfig("SmtpServer", "");
            SendEmailId = GetStatic.ReadWebConfig("SendEmailId", "");
            SendEmailPwd = GetStatic.ReadWebConfig("SendEmailPwd", "");
            EnableSsl = true;
        }

        public int SmtpPort { get; set; }
        public string SmtpServer { get; set; }
        public string SendEmailId { get; set; }
        public string SendEmailPwd { get; set; }
        public string ToEmails { get; set; }
        public string CcEmails { get; set; }
        public string BccEmails { get; set; }
        public string MsgSubject { get; set; }
        public string MsgBody { get; set; }
        public bool EnableSsl { get; set; }
        public string Status { get; set; }

        /// <summary>
        /// Send mail through gme SMTP server
        /// </summary>
        /// <param name="smtpMail">
        /// receiver details mail body and subject
        /// </param>
        /// <returns>
        /// </returns>
        public string SendSmtpMail(SmtpMailSetting smtpMail, string attachmentFilename = "")
        {
            MailMessage mail = new MailMessage();
            SmtpClient SmtpServer = new SmtpClient();
            try
            {
                SmtpServer.Host = smtpMail.SmtpServer;
                SmtpServer.Port = smtpMail.SmtpPort;
                SmtpServer.Credentials = new System.Net.NetworkCredential(smtpMail.SendEmailId, smtpMail.SendEmailPwd);
                SmtpServer.EnableSsl = EnableSsl;

                mail.From = new MailAddress(smtpMail.SendEmailId);
                mail.To.Add(smtpMail.ToEmails);
                var ccList = smtpMail.CcEmails.Split(';');
                if (ccList[0] != "")
                {
                    for (int i = 0; i < ccList.Length; i++)
                    {
                        mail.CC.Add(ccList[i]);
                    }
                }

                //if (!string.IsNullOrEmpty(smtpMail.CcEmails))
                //     mail.CC.Add(smtpMail.CcEmails);
                if (!string.IsNullOrEmpty(smtpMail.BccEmails))
                    mail.Bcc.Add(smtpMail.BccEmails);

                mail.Subject = smtpMail.MsgSubject;
                mail.IsBodyHtml = true;
                mail.Body = smtpMail.MsgBody;

                if (!string.IsNullOrEmpty(attachmentFilename))
                {
                    Attachment attachment = new Attachment(attachmentFilename, MediaTypeNames.Application.Octet);
                    ContentDisposition disposition = attachment.ContentDisposition;
                    disposition.CreationDate = File.GetCreationTime(attachmentFilename);
                    disposition.ModificationDate = File.GetLastWriteTime(attachmentFilename);
                    disposition.ReadDate = File.GetLastAccessTime(attachmentFilename);
                    disposition.FileName = Path.GetFileName(attachmentFilename.Replace("SampleFile", ""));
                    disposition.Size = new FileInfo(attachmentFilename).Length;
                    disposition.DispositionType = DispositionTypeNames.Attachment;
                    mail.Attachments.Add(attachment);
                }

                SmtpServer.Send(mail);
                smtpMail.Status = "Y";
                SmtpServer.Dispose();
            }
            catch (SmtpFailedRecipientsException ex)
            {
                for (int i = 0; i < ex.InnerExceptions.Length; i++)
                {
                    SmtpStatusCode status = ex.InnerExceptions[i].StatusCode;
                    if (status == SmtpStatusCode.MailboxBusy || status == SmtpStatusCode.MailboxUnavailable)
                    {
                        // Console.WriteLine("Delivery failed - retrying in 5 seconds.");
                        System.Threading.Thread.Sleep(5000);
                        SmtpServer.Send(mail);
                    }
                    else
                    {
                        //  Console.WriteLine("Failed to deliver message to {0}", ex.InnerExceptions[i].FailedRecipient);
                        //throw ex;
                        smtpMail.Status = "N";
                        //smtpMail.MsgBody = ex.Message;

            smtpMail.MsgBody = ex.InnerExceptions[i].Message;
                        GetStatic.EmailNotificationLog(smtpMail);
                    }
                }
            }
            catch (Exception ex)
            {
                smtpMail.Status = "N";
                smtpMail.MsgBody = ex.Message;
                GetStatic.EmailNotificationLog(smtpMail);
            }
            finally
            {


                SmtpServer.Dispose();
            }
            GetStatic.EmailNotificationLog(smtpMail);

            return (smtpMail.Status == "Y") ? "Mail Send" : "Error while sending Email";
        }

    public string SendSmtpMailSimple(SmtpMailSetting smtpMail) {
      MailMessage mail = new MailMessage();
      SmtpClient SmtpServer = new SmtpClient();
      try {
        System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;
        SmtpServer.Host = smtpMail.SmtpServer;
        SmtpServer.Port = smtpMail.SmtpPort;
        SmtpServer.Credentials = new System.Net.NetworkCredential(smtpMail.SendEmailId, smtpMail.SendEmailPwd);
        SmtpServer.EnableSsl = EnableSsl;

        mail.From = new MailAddress(smtpMail.SendEmailId);
        mail.To.Add(smtpMail.ToEmails);
        mail.Subject = smtpMail.MsgSubject;
        mail.IsBodyHtml = true;
        mail.Body = smtpMail.MsgBody;

        SmtpServer.Send(mail);
        smtpMail.Status = "Y";
        SmtpServer.Dispose();
      } catch (SmtpFailedRecipientsException ex) {
        for (int i = 0; i < ex.InnerExceptions.Length; i++) {
          SmtpStatusCode status = ex.InnerExceptions[i].StatusCode;
          if (status == SmtpStatusCode.MailboxBusy || status == SmtpStatusCode.MailboxUnavailable) {
            // Console.WriteLine("Delivery failed - retrying in 5 seconds.");
            System.Threading.Thread.Sleep(5000);
            SmtpServer.Send(mail);
          } else {
            //  Console.WriteLine("Failed to deliver message to {0}", ex.InnerExceptions[i].FailedRecipient);
            //throw ex;
            smtpMail.Status = "N";
            //smtpMail.MsgBody = ex.Message;

            smtpMail.MsgBody = ex.InnerExceptions[i].Message;
            GetStatic.EmailNotificationLog(smtpMail);
          }
        }
      } catch (Exception ex) {
        smtpMail.Status = "N";
        smtpMail.MsgBody = ex.Message;
        GetStatic.EmailNotificationLog(smtpMail);
      } finally {


        SmtpServer.Dispose();
      }
      GetStatic.EmailNotificationLog(smtpMail);

      return (smtpMail.Status == "Y") ? "Mail Send" : "Error while sending Email";
    }

  }
}

