USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[paymentModeMaster]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[paymentModeMaster](
	[paymentModeId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[paymentCode] [varchar](10) NULL,
	[modeTitle] [varchar](30) NULL,
	[modeDesc] [varchar](max) NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_paymentModeMaster_paymentModeId] PRIMARY KEY CLUSTERED 
(
	[paymentModeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[paymentModeMaster] ADD  CONSTRAINT [MSrepl_tran_version_default_44F9E8A6_7665_454C_A38E_6B085AB681DD_7007106]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
