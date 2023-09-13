using System;
using System.Text;

namespace Swift.web.SendMoney
{
    public class SoundexA
    {
        public static string Soundex(string data)
        {
            StringBuilder sb = new StringBuilder();

            if (data != null && data.Length > 0)
            {
                string previousCode = "", currentCode = "", currentLetter = "";

                sb.Append(data.Substring(0, 1));

                for (int i = 1; i < data.Length; i++)
                {
                    currentLetter = data.Substring(i, 1).ToLower();
                    currentCode = "";

                    if ("bfpv".IndexOf(currentLetter) > -1)
                        currentCode = "1";

                    else if ("cgjkqsxz".IndexOf(currentLetter) > -1)
                        currentCode = "2";
                    else if ("dt".IndexOf(currentLetter) > -1)
                        currentCode = "3";
                    else if (currentLetter == "1")
                        currentCode = "4";
                    else if ("mn".IndexOf(currentLetter) > -1)
                        currentCode = "5";
                    else if (currentLetter == "r")
                        currentCode = "6";

                    if (currentCode != previousCode)
                        sb.Append(currentCode);

                    if (sb.Length == 4) break;

                    if (currentCode != "")
                        previousCode = currentCode;
                }
            }

            if (sb.Length < 4)
                sb.Append(new String('0', 4 - sb.Length));

            return sb.ToString().ToUpper();
        }
    }
}