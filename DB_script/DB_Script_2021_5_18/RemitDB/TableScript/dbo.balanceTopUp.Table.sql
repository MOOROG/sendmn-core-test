USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[balanceTopUp]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[balanceTopUp](
	[btId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[amount] [int] NULL,
	[topUpExpiryDate] [datetime] NULL,
	[btStatus] [varchar](50) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[modType] [varchar](1) NULL,
	[baseLimit] [money] NULL,
	[totalLimitTopup] [money] NULL,
	[currentBalance] [money] NULL,
	[availableLimit] [money] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[remarks] [varchar](max) NULL,
	[reqAmt] [money] NULL,
 CONSTRAINT [PK__balanceT__5276C66636D2B482] PRIMARY KEY CLUSTERED 
(
	[btId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[balanceTopUp] ADD  CONSTRAINT [MSrepl_tran_version_default_EE4F4068_72FF_4DEF_AB73_AA0CD89C379D_453172960]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
