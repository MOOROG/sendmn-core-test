USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tranupdatelocal]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tranupdatelocal](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[icn] [varchar](20) NULL,
	[approveddatelocal] [date] NULL,
	[monthnum] [int] NULL,
	[icn2] [varchar](25) NOT NULL,
	[icn3] [varchar](25) NOT NULL,
	[tranno] [numeric](15, 0) NOT NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_tranupdatelocal_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tranupdatelocal] ADD  CONSTRAINT [MSrepl_tran_version_default_9B752D3A_DDBD_46FB_A314_A39C983A29FE_1557944972]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
