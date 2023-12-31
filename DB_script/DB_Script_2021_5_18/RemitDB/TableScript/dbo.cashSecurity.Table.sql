USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[cashSecurity]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cashSecurity](
	[csId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[agentId] [int] NULL,
	[depositAcNo] [varchar](30) NULL,
	[cashDeposit] [money] NULL,
	[currency] [int] NULL,
	[depositedDate] [datetime] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[bankName] [varchar](200) NULL,
 CONSTRAINT [PK__cashSecu__2C52D1BC0723A160] PRIMARY KEY CLUSTERED 
(
	[csId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cashSecurity] ADD  CONSTRAINT [MSrepl_tran_version_default_6B0382E1_61B2_4491_8D0F_8D6E8C4F0972_1981354223]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
