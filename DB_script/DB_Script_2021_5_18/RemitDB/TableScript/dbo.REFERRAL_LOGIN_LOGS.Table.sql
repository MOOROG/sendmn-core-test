USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[REFERRAL_LOGIN_LOGS]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[REFERRAL_LOGIN_LOGS](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[referralUserId] [bigint] NULL,
	[logType] [varchar](50) NULL,
	[IP] [varchar](100) NULL,
	[Reason] [varchar](2000) NULL,
	[fieldValue] [varchar](2000) NULL,
	[createdBy] [varchar](100) NULL,
	[createdDate] [datetime] NULL,
	[UserData] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
