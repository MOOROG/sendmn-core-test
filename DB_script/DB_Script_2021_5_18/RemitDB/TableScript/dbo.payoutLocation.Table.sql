USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[payoutLocation]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[payoutLocation](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Branch] [varchar](500) NULL,
	[Country] [varchar](150) NULL,
	[City] [varchar](150) NULL,
	[Address] [varchar](1000) NULL,
	[Contact] [varchar](500) NULL,
	[Paymode] [char](1) NULL,
 CONSTRAINT [PK_payoutLocation_1] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
