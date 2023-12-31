USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[csDetail]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[csDetail](
	[csDetailId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[csMasterId] [bigint] NULL,
	[condition] [int] NULL,
	[collMode] [int] NULL,
	[paymentMode] [int] NULL,
	[tranCount] [int] NULL,
	[amount] [money] NULL,
	[period] [int] NULL,
	[nextAction] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[approvedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[isEnable] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[profession] [int] NULL,
	[documentRequired] [bit] NULL,
 CONSTRAINT [pk_idx_csDetail_csDetailId] PRIMARY KEY CLUSTERED 
(
	[csDetailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[csDetail] ADD  CONSTRAINT [MSrepl_tran_version_default_FCF69F7D_E1CA_4F0F_9C16_D011264C53D4_275688230]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
