USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[fixedDeposit]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fixedDeposit](
	[fdId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[bankName] [varchar](50) NULL,
	[fixedDepositNo] [varchar](20) NULL,
	[amount] [money] NULL,
	[currency] [int] NULL,
	[issuedDate] [datetime] NULL,
	[expiryDate] [datetime] NULL,
	[followUpDate] [datetime] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[fdId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fixedDeposit] ADD  CONSTRAINT [MSrepl_tran_version_default_B36CFD6E_210A_47D8_AB5E_A6464B850DF6_1901353938]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
