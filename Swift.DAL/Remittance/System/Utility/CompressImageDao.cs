using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Collections;
using Swift.DAL.SwiftDAL;

namespace Swift.DAL.BL.System.Utility
{
    public class CompressImageDao : RemittanceDao
    {
        public bool CompressImageAndSave(long contentLength, string orgImageSource, string tmpFilePath)
        {
            try
            {
                Image original = Image.FromFile(orgImageSource);

                ImageCodecInfo jpgEncoder = null;
                ImageCodecInfo[] codecs = ImageCodecInfo.GetImageEncoders();
                foreach (ImageCodecInfo codec in codecs)
                {
                    if (codec.FormatID == ImageFormat.Jpeg.Guid)
                    {
                        jpgEncoder = codec;
                        break;
                    }
                }
                if (jpgEncoder != null)
                {
                    Encoder encoder = Encoder.Quality;
                    EncoderParameters encoderParameters = new EncoderParameters(1);

                    var suggestedImage = GetSuggestedImage(contentLength, original.Height, original.Width);
                    EncoderParameter encoderParameter = new EncoderParameter(encoder, long.Parse(suggestedImage.Id));
                    encoderParameters.Param[0] = encoderParameter;

                    string fileOut = tmpFilePath;
                    FileStream ms = new FileStream(fileOut, FileMode.Create, FileAccess.ReadWrite);
                    try
                    {
                        original.Save(ms, jpgEncoder, encoderParameters);
                    }
                    catch (Exception)
                    {
                    }
                    finally
                    {
                        ms.Flush();
                        ms.Close();

                        original.Dispose();
                        if (File.Exists(orgImageSource))
                            File.Delete(orgImageSource);
                    }
                }
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public DbResult GetSuggestedImage(long imageSize, int height, int width)
        {
            string sql = "EXEC proc_getSuggestedImage @flag=si";
            sql += ", @imgActualSize = " + FilterString(imageSize.ToString());
            sql += ", @imgActualHight = " + FilterString(height.ToString());
            sql += ", @imgActualWidth = " + FilterString(width.ToString());
            return ParseDbResult(sql);
        }
    }

    public class Pic
    {
        public string Description;
        public string FilePath;
        public bool IsSuggested = false;
    }
}