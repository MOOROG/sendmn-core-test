USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[remitTranComplianceTemp]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[remitTranComplianceTemp](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[csDetailTranId] [int] NULL,
	[matchTranId] [varchar](max) NULL,
	[agentRefId] [varchar](20) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
	[reason] [varchar](500) NULL,
 CONSTRAINT [pk_idx_remitTranComplianceTemp_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[remitTranComplianceTemp] ADD  CONSTRAINT [MSrepl_tran_version_default_5F0BE661_CB60_4758_9418_CAC3E9C251ED_932562756]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
