USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[onlineCustomerLimitSetup]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[onlineCustomerLimitSetup](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[customerVerification] [varchar](20) NULL,
	[payBy] [varchar](20) NULL,
	[receivingCountry] [int] NULL,
	[currency] [varchar](20) NULL,
	[minimum] [money] NULL,
	[maximum] [money] NULL,
	[numberofTXN] [int] NULL,
	[createdBy] [varchar](200) NULL,
	[createdDate] [datetime] NULL,
	[isDeleted] [char](1) NULL,
	[modifiedBy] [varchar](200) NULL,
	[modifiedDate] [datetime] NULL,
	[limitType] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
