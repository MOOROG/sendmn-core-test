USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[TBL_MOBILE_OTP_REQUEST]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBL_MOBILE_OTP_REQUEST](
	[ROW_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[MOBILE_NUMBER] [varchar](30) NOT NULL,
	[OTP_CODE] [varchar](5) NULL,
	[REQUESTED_DATE] [datetime] NULL,
	[VERIFIED_DATE] [datetime] NULL,
	[IS_EXPIRED] [bit] NULL,
	[IS_SUCCESS] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ROW_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
