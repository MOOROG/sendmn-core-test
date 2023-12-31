USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[CustomerEnquiry]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerEnquiry](
	[enquiryId] [bigint] IDENTITY(1,1) NOT NULL,
	[firstName] [varchar](255) NULL,
	[mobile] [varchar](20) NULL,
	[email] [varchar](255) NULL,
	[message] [varchar](255) NULL,
	[controlNo] [varchar](15) NULL,
	[enquiryType] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[responseBy] [varchar](255) NULL,
	[responseDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[enquiryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
