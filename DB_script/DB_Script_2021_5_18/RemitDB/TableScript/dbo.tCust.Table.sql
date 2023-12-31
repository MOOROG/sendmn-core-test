USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[tCust]    Script Date: 5/18/2021 5:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tCust](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[membershipId] [int] NULL,
	[name] [varchar](50) NULL,
	[address] [varchar](50) NULL,
	[mobile] [varchar](50) NULL,
	[email] [varchar](50) NULL,
	[customerType] [char](1) NULL,
 CONSTRAINT [pk_idx_tCust_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
