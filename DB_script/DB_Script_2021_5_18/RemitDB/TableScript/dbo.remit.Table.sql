USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[remit]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[remit](
	[id] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[controlNo] [varchar](20) NULL,
 CONSTRAINT [pk_idx_remit_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
