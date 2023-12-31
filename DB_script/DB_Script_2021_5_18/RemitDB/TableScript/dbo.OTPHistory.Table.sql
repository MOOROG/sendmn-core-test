USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[OTPHistory]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OTPHistory](
	[rowid] [bigint] IDENTITY(1,1) NOT NULL,
	[username] [varchar](100) NULL,
	[OTP] [varchar](50) NULL,
	[OTP_Used] [bit] NULL,
	[createdDate] [datetime] NOT NULL,
	[codeType] [varchar](20) NULL,
	[customerId] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OTPHistory] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
