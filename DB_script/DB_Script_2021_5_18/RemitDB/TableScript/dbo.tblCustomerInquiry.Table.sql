USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tblCustomerInquiry]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCustomerInquiry](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[mobileNo] [varchar](15) NOT NULL,
	[complian] [varchar](max) NOT NULL,
	[msgType] [varchar](50) NOT NULL,
	[Country] [varchar](50) NULL,
	[createdBy] [varchar](50) NOT NULL,
	[createdDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCustomerInquiry] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
