using System;
using System.Text.RegularExpressions;

namespace Common.Utility
{
    public class CheckPasswordUtility
    {
        protected string dob = "";
        protected string idNumber = "";
        protected string email = "";
        protected string mobile = "";
        protected string idType = "";

        public CheckPasswordUtility()
        {
            //dob = EncryptDecryptUtility.ReadSession("birthDate", "");
            //idNumber = EncryptDecryptUtility.ReadSession("senderIdNo", "").Replace("-", "");
            //email = EncryptDecryptUtility.ReadSession("username", "");
            //mobile = EncryptDecryptUtility.ReadSession("mobile", "");
            //idType = EncryptDecryptUtility.ReadSession("senderIdType", "");
        }

        private void SetParams(string dobR, string idNumberR, string emailR, string mobileR, string idTypeR)
        {
            dob = string.IsNullOrEmpty(dobR) ? dob : dobR;
            idNumber = string.IsNullOrEmpty(idNumberR) ? idNumber : idNumberR;
            email = string.IsNullOrEmpty(emailR) ? email : emailR;
            mobile = string.IsNullOrEmpty(mobileR) ? mobile : mobileR;
            idType = string.IsNullOrEmpty(idTypeR) ? idType : idTypeR;
        }

        public string CheckPassword(string password, string dobR = "", string idNumberR = "", string emailR = "", string mobileR = "", string idTypeR = "")
        {
            SetParams(dobR, idNumberR, emailR, mobileR, idTypeR);

            string errMsg = "";
            errMsg = CheckForRegExp(password);
            if (!string.IsNullOrEmpty(errMsg))
            {
                return errMsg;
            }
            errMsg = CheckForEmail(password);
            if (!string.IsNullOrEmpty(errMsg))
            {
                return errMsg;
            }
            //errMsg = CheckMobile(password);
            //if (!string.IsNullOrEmpty(errMsg))
            //{
            //    return errMsg;
            //}
            //errMsg = CheckIdNumber(password);
            //if (!string.IsNullOrEmpty(errMsg))
            //{
            //    return errMsg;
            //}
            //errMsg = CheckDob(password);
            return errMsg;
        }

        private string CheckForRegExp(string password)
        {
            string patternPassword = @"^(?=.*\d)(?=.*[A-Z]).{9,30}$";

            if (!string.IsNullOrEmpty(password))
            {
                if (!Regex.IsMatch(password, patternPassword))
                {
                    return "Password must meet the following requirements: At least one symbol / At least one capital letter / At least one number / Be at least 9 characters";
                }
            }
            Regex r = new Regex(@"[~`!@#$%^&*()-+=|\{}':;.,<>/?]");
            if (!r.IsMatch(password))
            {
                return "Password must meet the following requirements: At least one symbol / At least one capital letter / At least one number / Be at least 9 characters";
            }
            return "";
        }

        private string CheckDob(string password)
        {
            string[] dobArr = null;
            string dateOfBirth = "";
            if (idType.ToLower() == "passport" || idType.Trim().Equals("10997"))
            {
                dobArr = dob.Split('/');
                string mm = dobArr[0], dd = dobArr[1];
                if (dobArr[0].Length == 1)
                {
                    mm = "0" + mm;
                }
                if (dobArr[1].Length == 1)
                {
                    dd = "0" + dd;
                }
                dateOfBirth = dobArr[2].Substring(0, 4) + mm + dd;
            }
            else
            {
                dateOfBirth = idNumber.Substring(0, 6);

                string yy = "19" + dateOfBirth.Substring(0, 2);

                int nowYear = DateTime.Now.Year;
                if ((nowYear - Convert.ToInt16(yy)) > 80)
                {
                    yy = "20" + dateOfBirth.Substring(0, 2);
                }

                dateOfBirth = yy + dateOfBirth.Substring(2, 4);
            }

            string dateOfBirth1 = dateOfBirth.Substring(0, 4);
            string dateOfBirth2 = dateOfBirth.Substring(2, 6);
            string dateOfBirth3 = dateOfBirth.Substring(4, 4);
            if (password.Contains(dateOfBirth1))
            {
                return "Password can not be same as DOB!";
            }
            if (password.Contains(dateOfBirth2))
            {
                return "Password can not be same as DOB!";
            }
            if (password.Contains(dateOfBirth3))
            {
                return "Password can not be same as DOB!";
            }
            return "";
        }

        private string CheckIdNumber(string password)
        {
            if (idType.ToLower() == "passport")
            {
                if (password.Contains(idNumber))
                {
                    return "Password can not be same as id Number!";
                }
            }
            string idFirstPart = idNumber.Substring(0, 6);
            string idSecondPart = idNumber.Substring(6, idNumber.Length - 6);
            if (password.Contains(idFirstPart))
            {
                return "Password can not be same as id Number!";
            }
            if (password.Contains(idSecondPart))
            {
                return "Password can not be same as id Number!";
            }
            return "";
        }

        private string CheckMobile(string password)
        {
            string mobileNum = "";
            if (mobile.Contains("+82"))
            {
                mobileNum = mobile.Replace("+82", "0");
            }
            else
            {
                string mobileFirst2 = mobile.Substring(0, 2);

                if (mobileFirst2 == "82")
                {
                    mobileNum = "0" + mobile.Substring(2, mobile.Length - 2);
                }
                else if (mobile.Substring(0, 1) != "0" && mobile.Length == 10)
                {
                    mobileNum = "0" + mobileNum;
                }
                else
                {
                    mobileNum = mobile;
                }
            }
            string mobileNum1 = mobileNum.Substring(3, mobileNum.Length - 3);

            if (password.Contains(mobileNum1))
            {
                return "Password can not be same as mobile number!";
            }
            return "";
        }

        private string CheckForEmail(string password)
        {
            var emailArr = email.Split('@');
            if (password.ToLower().Contains(emailArr[0].ToLower()))
            {
                return "Password can not be same as email!";
            }
            return "";
        }
    }
}