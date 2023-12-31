USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tblRejectLogVirtualBankDepositRequest]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRejectLogVirtualBankDepositRequest](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[processId] [varchar](50) NULL,
	[obpId] [varchar](50) NULL,
	[customerName] [nvarchar](100) NULL,
	[virtualAccountNo] [varchar](50) NULL,
	[amount] [money] NULL,
	[receivedOn] [varchar](40) NULL,
	[partnerServiceKey] [varchar](10) NULL,
	[institution] [varchar](50) NULL,
	[depositor] [nvarchar](100) NULL,
	[no] [varchar](50) NULL,
	[reason] [varchar](50) NULL,
	[logDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblRejectLogVirtualBankDepositRequest] ADD  DEFAULT (getdate()) FOR [logDate]
GO
